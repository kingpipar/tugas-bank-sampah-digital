class AppConstants {
  AppConstants._();

  static const String baseUrl = 'http://localhost:3000/api';

  // FIREBASE FIRESTORE COLLECTIONS
  static const String pickupRequestsCollection = 'request_jemput_realtime';
  static const String notificationsCollection = 'notifikasi';
  static const String hargaSampahCollection = 'harga_sampah_realtime';
  static const String voucherRewardCollection = 'voucher_reward_realtime';

  // MOCK KOORDINAT GPS (Yogyakarta)
  //       menggunakan package `geolocator` atau `location`.
  static const double mockLatitude = -7.7956;
  static const double mockLongitude = 110.3695;

  // TIMEOUT & RETRY
  static const Duration apiTimeout = Duration(seconds: 15);
}
