import 'package:geolocator/geolocator.dart';

/// Mengambil koordinat GPS perangkat dengan penanganan izin.
class LocationService {
  LocationService._();

  static Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException(
        'Layanan lokasi tidak aktif. Aktifkan GPS di pengaturan perangkat.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw LocationException('Izin lokasi ditolak.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationException(
        'Izin lokasi ditolak permanen. Aktifkan di pengaturan aplikasi.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }
}

class LocationException implements Exception {
  final String message;
  LocationException(this.message);

  @override
  String toString() => message;
}
