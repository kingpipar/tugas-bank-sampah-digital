import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/app_constants.dart';

/// ============================================================
/// ApiService — HTTP Client untuk REST API (MySQL via Express.js)
/// ============================================================
/// Singleton class yang mengelola semua request HTTP ke backend.
///
/// CARA PENGGUNAAN:
///   final api = ApiService();
///   api.setToken('jwt_token_dari_login');
///   final saldo = await api.fetchUserSaldo('userId');
///
/// TODO: Ganti [AppConstants.baseUrl] di file config/app_constants.dart
///       dengan IP publik VM GCP Anda.
///       Contoh: 'http://34.101.xxx.xxx:3000/api'

class ApiService {
  // ----------------------------------------------------------
  // Singleton Pattern
  // ----------------------------------------------------------
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // ----------------------------------------------------------
  // Token JWT — di-set setelah login berhasil
  // ----------------------------------------------------------
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  // ----------------------------------------------------------
  // Headers Builder — otomatis menyisipkan token Authorization
  // ----------------------------------------------------------
  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Jika token tersedia, tambahkan Authorization header.
    // Format: Bearer <JWT_TOKEN>
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  // ============================================================
  // GENERIC HTTP METHODS
  // ============================================================

  /// GET request ke [endpoint].
  /// [endpoint] adalah path relatif, contoh: '/saldo/1'
  /// Return: decoded JSON body.
  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');

    try {
      final response = await http
          .get(url, headers: _headers)
          .timeout(AppConstants.apiTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException('Request timeout. Periksa koneksi internet Anda.');
    } catch (e) {
      throw ApiException('Gagal menghubungi server: $e');
    }
  }

  /// POST request ke [endpoint] dengan [body].
  /// [body] akan di-encode ke JSON secara otomatis.
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');

    try {
      final response = await http
          .post(url, headers: _headers, body: jsonEncode(body))
          .timeout(AppConstants.apiTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException('Request timeout. Periksa koneksi internet Anda.');
    } catch (e) {
      throw ApiException('Gagal menghubungi server: $e');
    }
  }

  // ----------------------------------------------------------
  // Response Handler
  // ----------------------------------------------------------
  dynamic _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else if (response.statusCode == 401) {
      throw ApiException('Sesi telah berakhir. Silakan login kembali.');
    } else if (response.statusCode == 404) {
      throw ApiException('Data tidak ditemukan.');
    } else {
      final message = body['message'] ?? 'Terjadi kesalahan pada server.';
      throw ApiException(message);
    }
  }

  // ============================================================
  // ENDPOINT-SPECIFIC METHODS
  // ============================================================
  // Setiap method di bawah memanggil endpoint spesifik di backend.
  // TODO: Sesuaikan path endpoint dan struktur response JSON
  //       dengan API backend Anda.

  /// -----------------------------------------------------------
  /// LOGIN
  /// -----------------------------------------------------------
  /// Endpoint: POST /auth/login
  /// Body:     { "email": "...", "password": "..." }
  /// Response yang diharapkan:
  /// ```json
  /// {
  ///   "token": "eyJhbGciOiJIUzI1NiIs...",
  ///   "user": {
  ///     "id": "1",
  ///     "nama": "Budi Santoso",
  ///     "email": "budi@email.com"
  ///   }
  /// }
  /// ```
  /// TODO: Ganti '/auth/login' dengan path endpoint login Anda.
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await post('/auth/login', {
      'email': email,
      'password': password,
    });
    return Map<String, dynamic>.from(response);
  }

  /// -----------------------------------------------------------
  /// FETCH SALDO POIN WARGA
  /// -----------------------------------------------------------
  /// Endpoint: GET /saldo/:userId
  /// Response yang diharapkan:
  /// ```json
  /// {
  ///   "saldo_poin": 1500.0
  /// }
  /// ```
  /// TODO: Ganti '/saldo/$userId' dengan path endpoint saldo Anda.
  Future<double> fetchUserSaldo(String userId) async {
    final response = await get('/saldo/$userId');
    return (response['saldo_poin'] ?? 0).toDouble();
  }

  /// -----------------------------------------------------------
  /// FETCH RIWAYAT PENUKARAN POIN
  /// -----------------------------------------------------------
  /// Endpoint: GET /transaksi/:userId
  /// Response yang diharapkan:
  /// ```json
  /// [
  ///   {
  ///     "id": 1,
  ///     "jenis": "Tukar Sembako",
  ///     "jumlah_poin": 500,
  ///     "keterangan": "Tukar 500 poin → 1kg beras",
  ///     "tanggal": "2026-05-10T10:30:00Z"
  ///   }
  /// ]
  /// ```
  /// TODO: Ganti '/transaksi/$userId' dengan path endpoint
  ///       riwayat transaksi Anda.
  Future<List<dynamic>> fetchRiwayatTransaksi(String userId) async {
    final response = await get('/transaksi/$userId');
    return List<dynamic>.from(response);
  }
}

/// Custom exception untuk error dari API.
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
