import 'package:cloud_firestore/cloud_firestore.dart';

/// ============================================================
/// Model: PickupRequestModel
/// ============================================================
/// Merepresentasikan satu permintaan penjemputan sampah.
/// Data disimpan dan di-stream dari Firebase Firestore
/// collection `pickup_requests`.
///
/// Status Flow:
///   "pending" → "on_the_way" → "completed"

class PickupRequestModel {
  final String? id; // Document ID Firestore (null saat create)
  final String userId;
  final int estimasiKantong;
  final double estimasiBerat; // dalam kg
  final String catatan;
  final double latitude;
  final double longitude;
  final String status; // "pending" | "on_the_way" | "completed"
  final DateTime createdAt;

  PickupRequestModel({
    this.id,
    required this.userId,
    required this.estimasiKantong,
    required this.estimasiBerat,
    this.catatan = '',
    required this.latitude,
    required this.longitude,
    this.status = 'pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert ke Map untuk dikirim ke Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'estimasi_kantong': estimasiKantong,
      'estimasi_berat': estimasiBerat,
      'catatan': catatan,
      'koordinat': {
        'lat': latitude,
        'lng': longitude,
      },
      'status': status,
      'created_at': FieldValue.serverTimestamp(),
    };
  }

  /// Factory constructor untuk parsing dari Firestore document.
  factory PickupRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final koordinat = data['koordinat'] as Map<String, dynamic>? ?? {};

    return PickupRequestModel(
      id: doc.id,
      userId: data['user_id'] ?? '',
      estimasiKantong: data['estimasi_kantong'] ?? 0,
      estimasiBerat: (data['estimasi_berat'] ?? 0).toDouble(),
      catatan: data['catatan'] ?? '',
      latitude: (koordinat['lat'] ?? 0).toDouble(),
      longitude: (koordinat['lng'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
