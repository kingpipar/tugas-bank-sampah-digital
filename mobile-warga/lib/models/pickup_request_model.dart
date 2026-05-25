import 'package:cloud_firestore/cloud_firestore.dart';

class PickupRequestModel {
  final String? id;
  final String userId;
  final int estimasiKantong;
  final double estimasiBerat;
  final String catatan;
  final double latitude;
  final double longitude;
  final String status;
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

  factory PickupRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // FIX koordinat parsing
    final koordinat =
        Map<String, dynamic>.from(data['koordinat'] ?? {});

    return PickupRequestModel(
      id: doc.id,
      userId: data['user_id']?.toString() ?? '',
      estimasiKantong:
          (data['estimasi_kantong'] ?? 0) as int,
      estimasiBerat:
          (data['estimasi_berat'] ?? 0).toDouble(),
      catatan: data['catatan'] ?? '',
      latitude: (koordinat['lat'] ?? 0).toDouble(),
      longitude: (koordinat['lng'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      createdAt:
          (data['created_at'] as Timestamp?)
                  ?.toDate() ??
              DateTime.now(),
    );
  }
}