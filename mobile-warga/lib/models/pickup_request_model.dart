import 'package:cloud_firestore/cloud_firestore.dart';

class PickupRequestModel {
  final String? id;
  final String userId;
  final double estimasiBerat;
  final String jenisSampah;
  final String kategoriSampah;
  final double hargaPerKg;
  final double poinPerKg;
  final String tanggalJemput;
  final String catatan;
  final double latitude;
  final double longitude;
  final String status;
  final DateTime createdAt;

  PickupRequestModel({
    this.id,
    required this.userId,
    required this.estimasiBerat,
    this.jenisSampah = 'Campuran',
    this.kategoriSampah = '',
    this.hargaPerKg = 0,
    this.poinPerKg = 0,
    this.tanggalJemput = '',
    this.catatan = '',
    required this.latitude,
    required this.longitude,
    this.status = 'pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'estimasi_berat': estimasiBerat,
      'jenis_sampah': jenisSampah,
      'kategori_sampah': kategoriSampah,
      'harga_per_kg': hargaPerKg,
      'poin_per_kg': poinPerKg,
      'tanggal_jemput': tanggalJemput,
      'catatan': catatan,
      'koordinat': {
        'lat': latitude,
        'lng': longitude,
      },
      'status': status,
      'created_at': FieldValue.serverTimestamp(),
    };
  }

  factory PickupRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // FIX koordinat parsing
    final koordinat = Map<String, dynamic>.from(data['koordinat'] ?? {});

    return PickupRequestModel(
      id: doc.id,
      userId: data['user_id']?.toString() ?? '',
      estimasiBerat: (data['estimasi_berat'] ?? 0).toDouble(),
      jenisSampah: data['jenis_sampah']?.toString() ?? 'Campuran',
      kategoriSampah: data['kategori_sampah']?.toString() ?? '',
      hargaPerKg: (data['harga_per_kg'] ?? 0).toDouble(),
      poinPerKg: (data['poin_per_kg'] ?? 0).toDouble(),
      tanggalJemput: data['tanggal_jemput']?.toString() ?? '',
      catatan: data['catatan'] ?? '',
      latitude: (koordinat['lat'] ?? 0).toDouble(),
      longitude: (koordinat['lng'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
