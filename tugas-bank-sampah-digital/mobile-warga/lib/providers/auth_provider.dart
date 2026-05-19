import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// ============================================================
/// AuthProvider — State Management untuk Autentikasi
/// ============================================================
/// Mengelola state login/logout, token JWT, dan data user.
///
/// CATATAN: Saat ini menggunakan MOCK DATA karena backend
///          belum tersedia. Ganti method [login] dengan
///          pemanggilan API yang sesungguhnya saat backend siap.

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  // ----------------------------------------------------------
  // Getters
  // ----------------------------------------------------------
  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null && _token != null;
  String? get errorMessage => _errorMessage;

  // ----------------------------------------------------------
  // LOGIN
  // ----------------------------------------------------------
  /// Melakukan login ke backend.
  ///
  /// TODO: Saat backend sudah siap, HAPUS blok mock data
  ///       dan UNCOMMENT blok API call di bawahnya.
  Future<bool> login(String email, String password) async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    // ======================================================
    // FIREBASE LOGIN
    // ======================================================
    final credential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      throw Exception('User tidak ditemukan');
    }

    // ======================================================
    // AMBIL DATA FIRESTORE
    // ======================================================
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    Map<String, dynamic>? userData = userDoc.data();

    // kalau user belum ada di firestore
    if (!userDoc.exists) {
      userData = {
        'nama': 'Warga Baru',
        'email': firebaseUser.email,
        'saldoPoin': 0,
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .set(userData);
    }

    // ======================================================
    // SYNC KE MYSQL
    // ======================================================
    final syncResult = await _apiService.register(
      uid: firebaseUser.uid,
      nama: userData?['nama'] ?? 'Warga Baru',
      email: firebaseUser.email ?? email,
      password: password,
    );

    final mysqlUserId = syncResult['id'] is int
        ? syncResult['id'] as int
        : int.tryParse(syncResult['id']?.toString() ?? '');

    if (mysqlUserId == null) {
      throw ApiException(
        'Gagal mendapatkan ID user dari server. Coba login ulang.',
      );
    }

    // ======================================================
    // TOKEN + USER MODEL
    // ======================================================
    _token = await firebaseUser.getIdToken();

    _user = UserModel(
      id: firebaseUser.uid,
      mysqlUserId: mysqlUserId,
      nama: userData?['nama'] ?? 'Warga',
      email: firebaseUser.email ?? email,
      saldoPoin: (userData?['saldoPoin'] ?? 0).toDouble(),
    );

    _apiService.setToken(_token!);

    _isLoading = false;
    notifyListeners();
    return true;
  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case 'user-not-found':
        _errorMessage = 'Email tidak terdaftar';
        break;

      case 'wrong-password':
      case 'invalid-credential':
        _errorMessage = 'Email atau password salah';
        break;

      case 'invalid-email':
        _errorMessage = 'Format email tidak valid';
        break;

      default:
        _errorMessage = 'Gagal login: ${e.message}';
    }

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

  // ----------------------------------------------------------
  // LOGOUT
  // ----------------------------------------------------------
  void logout() {
    FirebaseAuth.instance.signOut();

    _user = null;
    _token = null;
    _apiService.clearToken();
    notifyListeners();
  }
}