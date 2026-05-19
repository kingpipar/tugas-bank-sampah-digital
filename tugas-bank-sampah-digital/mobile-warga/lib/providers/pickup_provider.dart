import 'package:flutter/material.dart';
import '../models/pickup_request_model.dart';
import '../services/firestore_service.dart';

/// ============================================================
/// PickupProvider — State Management untuk Request Penjemputan
/// ============================================================
/// Mengelola state submit pickup request ke Firebase Firestore.

class PickupProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  bool _isSubmitting = false;
  String? _errorMessage;
  String? _lastCreatedDocId;

  // ----------------------------------------------------------
  // Getters
  // ----------------------------------------------------------
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get lastCreatedDocId => _lastCreatedDocId;

  // ----------------------------------------------------------
  // SUBMIT PICKUP REQUEST
  // ----------------------------------------------------------
  /// Mengirim request penjemputan ke Firestore.
  ///
  /// [request] berisi data form yang sudah diisi warga.
  /// Return: true jika berhasil, false jika gagal.
  Future<bool> submitPickupRequest(PickupRequestModel request) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _lastCreatedDocId =
          await _firestoreService.createPickupRequest(request);

      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error submitPickupRequest: $e');
      _errorMessage = 'Gagal mengirim request: $e';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  // ----------------------------------------------------------
  // STREAM PICKUP REQUESTS (untuk History Screen)
  // ----------------------------------------------------------
  /// Mengembalikan stream daftar pickup request milik [userId].
  /// Gunakan dengan StreamBuilder di UI.
  Stream<List<PickupRequestModel>> streamPickupRequests(String userId) {
    return _firestoreService.streamMyPickupRequests(userId);
  }
}
