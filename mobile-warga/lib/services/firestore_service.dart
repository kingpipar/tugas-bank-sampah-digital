import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_constants.dart';
import '../models/pickup_request_model.dart';

/// ============================================================
/// FirestoreService — CRUD untuk Firebase Firestore
/// ============================================================
/// Mengelola operasi read/write ke Firestore untuk:
///   - Collection `pickup_requests` (request penjemputan sampah)
///   - Collection `notifications` (notifikasi warga) — future use
///
/// CATATAN: Pastikan Firebase sudah diinisialisasi di main.dart
///          dan file google-services.json sudah dikonfigurasi.

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============================================================
  // PICKUP REQUESTS
  // ============================================================

  /// Membuat request penjemputan baru ke Firestore.
  ///
  /// Data akan masuk ke collection [AppConstants.pickupRequestsCollection]
  /// dengan status awal "pending".
  ///
  /// Return: Document ID yang baru dibuat.
  Future<String> createPickupRequest(PickupRequestModel request) async {
    final docRef = await _db
        .collection(AppConstants.pickupRequestsCollection)
        .add(request.toFirestore());

    return docRef.id;
  }

  /// Stream untuk memantau semua pickup request milik [userId]
  /// secara real-time.
  ///
  /// Data diurutkan berdasarkan `created_at` descending (terbaru di atas).
  /// Gunakan dengan `StreamBuilder` di UI.
  ///
  /// Status yang mungkin:
  ///   - "pending"    → Menunggu konfirmasi pengepul
  ///   - "on_the_way" → Pengepul sedang dalam perjalanan
  ///   - "completed"  → Penjemputan selesai
  Stream<List<PickupRequestModel>> streamMyPickupRequests(String userId) {
    return _db
        .collection(AppConstants.pickupRequestsCollection)
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PickupRequestModel.fromFirestore(doc))
            .toList());
  }

  /// Mengambil satu pickup request berdasarkan document ID.
  Future<PickupRequestModel?> getPickupRequest(String docId) async {
    final doc = await _db
        .collection(AppConstants.pickupRequestsCollection)
        .doc(docId)
        .get();

    if (doc.exists) {
      return PickupRequestModel.fromFirestore(doc);
    }
    return null;
  }
}
