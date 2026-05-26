import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null && _token != null;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('User tidak ditemukan');
      }

      final userData = await _ensureFirestoreUser(firebaseUser, email);
      await _finishAuth(firebaseUser, email, password, userData);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseAuthError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
    String email, 
    String password, {
    required String nama,
    required String rt,
    required String rw,
    required String jenisKelamin,
    }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Registrasi gagal');
      }

      final userData = {
        'nama': nama,
        'email': email,
        'rt': rt,
        'rw': rw,
        'jenisKelamin': jenisKelamin,
        'saldoPoin': 0,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('warga_realtime')
          .doc(firebaseUser.uid)
          .set(userData);

      await _finishAuth(
        firebaseUser, 
        email, 
        password,
        userData,
        rt: rt,
        rw: rw, 
        jenisKelamin: jenisKelamin,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseAuthError(e, isRegister: true);
      _isLoading = false;
      notifyListeners();
      return false;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>> _ensureFirestoreUser(
    User firebaseUser,
    String email,
  ) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('warga_realtime')
        .doc(firebaseUser.uid)
        .get();

    if (userDoc.exists) {
      return Map<String, dynamic>.from(userDoc.data()!);
    }

    final userData = {
      'nama': 'Warga Baru',
      'email': firebaseUser.email ?? email,
      'saldoPoin': 0,
    };

    await FirebaseFirestore.instance
        .collection('warga_realtime')
        .doc(firebaseUser.uid)
        .set(userData);

    return userData;
  }

  Future<void> _finishAuth(
    User firebaseUser,
    String email,
    String password,
    Map<String, dynamic> userData, {
    String? rt,
    String? rw,
    String? jenisKelamin,
  }) async {
    // Bug fix #1: saat login, rt/rw/jenisKelamin diambil dari Firestore
    // (userData sudah berisi field tsb dari _ensureFirestoreUser).
    // Hanya pakai parameter jika memang dikirim (registrasi baru).
    final effectiveRt = rt ?? userData['rt']?.toString() ?? '';
    final effectiveRw = rw ?? userData['rw']?.toString() ?? '';
    final effectiveJk = jenisKelamin ?? userData['jenisKelamin']?.toString() ?? '';

    final syncResult = await _apiService.register(
      uid: firebaseUser.uid,
      nama: userData['nama']?.toString() ?? 'Warga Baru',
      email: firebaseUser.email ?? email,
      password: password,
      rt: effectiveRt,
      rw: effectiveRw,
      jenisKelamin: effectiveJk,
    );

    final mysqlUserId = syncResult['id'] is int
        ? syncResult['id'] as int
        : int.tryParse(syncResult['id']?.toString() ?? '');

    if (mysqlUserId == null) {
      throw ApiException(
        'Gagal mendapatkan ID user dari server. Coba login ulang.',
      );
    }

    // Bug fix #2: ambil saldo aktual dari MySQL
    double saldoPoin = (syncResult['saldo_poin'] ?? 0).toDouble();
    try {
      saldoPoin = await _apiService.fetchUserSaldo(mysqlUserId.toString());
    } on ApiException {
      // gunakan saldo dari sync response
    }

    final mysqlNama = syncResult['nama']?.toString();
    final effectiveNama = (mysqlNama != null && mysqlNama.isNotEmpty)
        ? mysqlNama
        : (userData['nama']?.toString() ?? 'Warga Baru');

    // Perbarui Firestore dengan data lengkap (termasuk saldo terbaru)
    await FirebaseFirestore.instance
        .collection('warga_realtime')
        .doc(firebaseUser.uid)
        .set({
      'nama': effectiveNama,
      'email': firebaseUser.email ?? email,
      'rt': effectiveRt,
      'rw': effectiveRw,
      'jenisKelamin': effectiveJk,
      'saldoPoin': saldoPoin,
    }, SetOptions(merge: true));

    _token = await firebaseUser.getIdToken();
    _user = UserModel(
      id: firebaseUser.uid,
      mysqlUserId: mysqlUserId,
      nama: effectiveNama,
      email: firebaseUser.email ?? email,
      saldoPoin: saldoPoin,
    );

    _apiService.setToken(_token!);
    _isLoading = false;
    notifyListeners();
  }

  /// Refresh saldo dari MySQL dan update _user + notifyListeners.
  /// Dipanggil dari DashboardScreen agar tidak ada race condition.
  Future<void> refreshSaldo() async {
    final mysqlId = _user?.mysqlUserId;
    if (mysqlId == null) return;
    try {
      final saldo = await _apiService.fetchUserSaldo(mysqlId.toString());
      _user = UserModel(
        id: _user!.id,
        mysqlUserId: mysqlId,
        nama: _user!.nama,
        email: _user!.email,
        saldoPoin: saldo,
      );
      notifyListeners();
    } catch (_) {
      // biarkan saldo lama
    }
  }

  String _mapFirebaseAuthError(FirebaseAuthException e,
      {bool isRegister = false}) {
    switch (e.code) {
      case 'user-not-found':
        return 'Email tidak terdaftar';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau password salah';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'email-already-in-use':
        return 'Email sudah terdaftar';
      case 'weak-password':
        return 'Password minimal 6 karakter';
      case 'operation-not-allowed':
        return isRegister
            ? 'Registrasi email/password belum diaktifkan di Firebase'
            : 'Login tidak diizinkan';
      default:
        return isRegister
            ? 'Gagal registrasi: ${e.message}'
            : 'Gagal login: ${e.message}';
    }
  }

  void logout() {
    FirebaseAuth.instance.signOut();
    _user = null;
    _token = null;
    _apiService.clearToken();
    notifyListeners();
  }
}
