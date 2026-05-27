import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/app_constants.dart';

class ApiService {
  // Singleton Pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Token JWT — di-set setelah login berhasil
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  // Headers Builder — otomatis menyisipkan token Authorization
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

  // GENERIC HTTP METHODS
  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');

    try {
      final response = await http
          .get(url, headers: _headers)
          .timeout(AppConstants.apiTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException('Request timeout. Periksa koneksi internet Anda.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Gagal menghubungi server: $e');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');

    try {
      final response = await http
          .post(url, headers: _headers, body: jsonEncode(body))
          .timeout(AppConstants.apiTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException('Request timeout. Periksa koneksi internet Anda.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Gagal menghubungi server: $e');
    }
  }

  // Response Handler
  dynamic _handleResponse(http.Response response) {
    final raw = response.body.trim();
    if (raw.isEmpty) {
      throw ApiException('Server mengembalikan respons kosong.');
    }
    if (raw.startsWith('<')) {
      throw ApiException(
        'Server mengembalikan HTML, bukan JSON. '
        'Periksa baseUrl di app_constants.dart dan pastikan backend berjalan.',
      );
    }

    final dynamic body;
    try {
      body = jsonDecode(raw);
    } on FormatException {
      throw ApiException('Respons server tidak valid (bukan JSON).');
    }

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

  // ENDPOINT
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await post('/auth/login', {
      'email': email,
      'password': password,
    });
    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> register({
    required String uid,
    required String nama,
    required String email,
    required String password,
    required String rt,
    required String rw,
    required String jenisKelamin,
  }) async {
    final response = await post('/sync-user', {
      'uid': uid,
      'nama': nama,
      'email': email,
      'password': password,
      'rt': rt,
      'rw': rw,
      'jenis_kelamin': jenisKelamin,
    });
    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> createPickupRequest({
    required String namaWarga,
    required String alamat,
    required String jenisSampah,
    required double estimasiBerat,
    required String tanggalJemput,
    required String catatan,
    required int userId,
    int? idSampah,
  }) async {
    final response = await post('/request_jemput', {
      'nama_warga': namaWarga,
      'alamat': alamat,
      'jenis_sampah': jenisSampah,
      'estimasi_berat': estimasiBerat,
      'tanggal_jemput': tanggalJemput,
      'catatan': catatan,
      'user_id': userId,
      'id_sampah': idSampah,
    });

    return Map<String, dynamic>.from(response);
  }

  Future<double> tukarPoin({
    required int userId,
    required double jumlahPoin,
    required String jenis,
    required String keterangan,
  }) async {
    final response = await post('/tukar', {
      'user_id': userId,
      'jumlah_poin': jumlahPoin,
      'jenis': jenis,
      'keterangan': keterangan,
    });
    return (response['saldo_poin'] ?? 0).toDouble();
  }

  Future<Map<String, dynamic>> redeemVoucher({
    required int userId,
    required String namaWarga,
    required int idVoucher,
    required int poinDitukar,
  }) async {
    final response = await post('/penukaran', {
      'id_warga': userId,
      'nama_warga': namaWarga,
      'id_voucher': idVoucher,
      'poin_ditukar': poinDitukar,
    });
    return Map<String, dynamic>.from(response);
  }

  Future<double> fetchUserSaldo(String userId) async {
    final response = await get('/saldo/$userId');
    return (response['saldo_poin'] ?? 0).toDouble();
  }

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

Future<List<dynamic>> fetchNotifications(int userId) async {
  final api = ApiService();

  try {
    final response = await api.get('/notif');

    return List<dynamic>.from(response['data'] ?? []);
  } catch (e) {
    throw ApiException('Gagal mengambil notifikasi: $e');
  }
}
