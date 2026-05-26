class AppConstants {
  AppConstants._(); // Prevent instantiation

  // ----------------------------------------------------------
  // BASE URL REST API
  // ----------------------------------------------------------
  //
  // Format endpoint yang diharapkan:
  //   POST /api/sync-user         → Sync user Firebase → MySQL (setelah login)
  //   POST /api/auth/login        → Login warga
  //   GET  /api/saldo/:userId     → Ambil saldo poin warga
  //   GET  /api/transaksi/:userId → Ambil riwayat penukaran poin
  // ----------------------------------------------------------
  static const String baseUrl = 'http://localhost:3000/api';

  // ----------------------------------------------------------
  // FIREBASE FIRESTORE COLLECTIONS
  // ----------------------------------------------------------
  // Nama collection di Firestore.
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
