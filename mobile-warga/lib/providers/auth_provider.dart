import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

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
      // 🔧 MOCK DATA — Hapus blok ini saat backend sudah siap
      // ======================================================
      await Future.delayed(const Duration(seconds: 1)); // Simulasi network delay
      _token = 'mock_jwt_token_123';
      _user = UserModel(
        id: '1',
        nama: 'Budi Santoso',
        email: email,
        saldoPoin: 1500,
      );
      _apiService.setToken(_token!);
      // ======================================================
      // AKHIR MOCK DATA
      // ======================================================

      // ======================================================
      // 🚀 API CALL — Uncomment blok ini saat backend siap
      // ======================================================
      // final response = await _apiService.login(email, password);
      //
      // // Ambil token dari response
      // // TODO: Sesuaikan key 'token' dengan response backend Anda
      // _token = response['token'];
      // _apiService.setToken(_token!);
      //
      // // Ambil data user dari response
      // // TODO: Sesuaikan key 'user' dengan response backend Anda
      // _user = UserModel.fromJson(response['user']);
      // ======================================================

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan. Coba lagi nanti.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ----------------------------------------------------------
  // LOGOUT
  // ----------------------------------------------------------
  void logout() {
    _user = null;
    _token = null;
    _apiService.clearToken();
    notifyListeners();
  }
}
