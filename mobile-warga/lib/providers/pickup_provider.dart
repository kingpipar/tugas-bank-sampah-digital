import 'package:flutter/material.dart';
import '../models/pickup_request_model.dart';
import '../services/api_service.dart';
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
  /// Kirim ke MySQL lalu Firestore (hybrid).
  Future<bool> submitHybrid({
    required PickupRequestModel firestoreRequest,
    required Future<void> Function() syncToMysql,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await syncToMysql();
      _lastCreatedDocId =
          await _firestoreService.createPickupRequest(firestoreRequest);

      _isSubmitting = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isSubmitting = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Gagal mengirim request: $e';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  /// Firestore saja (legacy).
  Future<bool> submitPickupRequest(PickupRequestModel request) async {
    return submitHybrid(
      firestoreRequest: request,
      syncToMysql: () async {},
    );
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
