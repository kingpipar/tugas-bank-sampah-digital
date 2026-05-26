// ============================================================
// Konfigurasi Konstanta Aplikasi
// ============================================================
// File ini menyimpan semua konstanta global yang digunakan
// di seluruh aplikasi. Ganti nilai-nilai di bawah sesuai
// dengan konfigurasi server Anda.

class AppConstants {
  AppConstants._(); // Prevent instantiation

  // ----------------------------------------------------------
  // BASE URL REST API
  // ----------------------------------------------------------
  // TODO: Ganti dengan IP publik VM GCP Anda.
  //       Contoh: 'http://34.101.xxx.xxx:3000/api'
  //       Atau jika menggunakan domain: 'https://api.banksampahdigi.com/api'
  //
  // Format endpoint yang diharapkan:
  //   POST /api/sync-user         → Sync user Firebase → MySQL (setelah login)
  //   POST /api/auth/login        → Login warga
  //   GET  /api/saldo/:userId     → Ambil saldo poin warga
  //   GET  /api/transaksi/:userId → Ambil riwayat penukaran poin
  // ----------------------------------------------------------
  //static const String baseUrl = 'http://10.0.2.2:3000/api';
  //static const String baseUrl = 'http://3.24.1.123:3000/api';
  static const String baseUrl = 'http://localhost:3000/api';
  // ☝️ 10.0.2.2 adalah alias localhost untuk Android Emulator.
  //    Ganti dengan IP VM GCP saat deploy ke production.

  // ----------------------------------------------------------
  // FIREBASE FIRESTORE COLLECTIONS
  // ----------------------------------------------------------
  // Nama collection di Firestore. Sesuaikan jika berbeda.
  static const String pickupRequestsCollection = 'request_jemput_realtime';
  static const String notificationsCollection = 'notifikasi';
  static const String hargaSampahCollection = 'harga_sampah_realtime';
  static const String voucherRewardCollection = 'voucher_reward_realtime';

  // ----------------------------------------------------------
  // MOCK KOORDINAT GPS (Yogyakarta)
  // ----------------------------------------------------------
  // TODO: Ganti dengan koordinat GPS asli dari device
  //       menggunakan package `geolocator` atau `location`.
  static const double mockLatitude = -7.7956;
  static const double mockLongitude = 110.3695;

  // ----------------------------------------------------------
  // TIMEOUT & RETRY
  // ----------------------------------------------------------
  static const Duration apiTimeout = Duration(seconds: 15);
}
