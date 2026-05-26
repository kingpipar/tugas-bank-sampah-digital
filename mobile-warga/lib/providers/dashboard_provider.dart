import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  double _saldoPoin = 0;
  bool _isLoading = false;
  String? _errorMessage;

  double get saldoPoin => _saldoPoin;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setSaldo(double saldo) {
    _saldoPoin = saldo;
    notifyListeners();
  }

  Future<void> fetchSaldo(int? mysqlUserId) async {
    if (mysqlUserId == null) {
      _saldoPoin = 0;
      _errorMessage = 'Akun belum tersinkron. Login ulang.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _saldoPoin =
          await _apiService.fetchUserSaldo(mysqlUserId.toString());
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal memuat saldo. Coba lagi.';
      _isLoading = false;
      notifyListeners();
    }
  }
}
