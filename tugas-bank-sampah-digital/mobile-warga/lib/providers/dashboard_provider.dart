import 'package:flutter/material.dart';
// TODO: Uncomment saat backend siap
// import '../services/api_service.dart';

/// ============================================================
/// DashboardProvider — State Management untuk Dashboard/Home
/// ============================================================
/// Mengelola state saldo poin warga yang di-fetch dari REST API.
///
/// CATATAN: Saat ini menggunakan MOCK DATA karena backend
///          belum tersedia. Ganti method [fetchSaldo] dengan
///          pemanggilan API yang sesungguhnya saat backend siap.

class DashboardProvider extends ChangeNotifier {
  // TODO: Uncomment saat backend siap
  // final ApiService _apiService = ApiService();

  double _saldoPoin = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // ----------------------------------------------------------
  // Getters
  // ----------------------------------------------------------
  double get saldoPoin => _saldoPoin;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ----------------------------------------------------------
  // FETCH SALDO POIN
  // ----------------------------------------------------------
  /// Mengambil saldo poin terbaru dari REST API.
  ///
  /// TODO: Saat backend sudah siap, HAPUS blok mock data
  ///       dan UNCOMMENT blok API call di bawahnya.
  Future<void> fetchSaldo(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // ======================================================
      // 🔧 MOCK DATA — Hapus blok ini saat backend sudah siap
      // ======================================================
      await Future.delayed(const Duration(milliseconds: 800));
      _saldoPoin = 1500;
      // ======================================================
      // AKHIR MOCK DATA
      // ======================================================

      // ======================================================
      // 🚀 API CALL — Uncomment blok ini saat backend siap
      // ======================================================
      // _saldoPoin = await _apiService.fetchUserSaldo(userId);
      // ======================================================

      _isLoading = false;
      notifyListeners();
      // TODO: Uncomment catch ApiException saat backend siap
      // } on ApiException catch (e) {
      //   _errorMessage = e.message;
      //   _isLoading = false;
      //   notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal memuat saldo. Coba lagi.';
      _isLoading = false;
      notifyListeners();
    }
  }
}
