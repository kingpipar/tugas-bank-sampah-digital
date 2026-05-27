import 'package:flutter/material.dart';
import '../models/pickup_request_model.dart';
import '../services/api_service.dart';
import '../services/firestore_service.dart';

class PickupProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  bool _isSubmitting = false;
  String? _errorMessage;
  String? _lastCreatedDocId;

  // Getters
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get lastCreatedDocId => _lastCreatedDocId;

  // SUBMIT PICKUP REQUEST
  /// Kirim ke MySQL lalu Firestore (hybrid).
  Future<bool> submitHybrid({
    required PickupRequestModel firestoreRequest,
    required Future<Map<String, dynamic>> Function() syncToMysql,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final mysqlResult = await syncToMysql();
      final mysqlId = mysqlResult['id']?.toString();

      if (mysqlId == null || mysqlId.isEmpty) {
        throw ApiException('Gagal mendapatkan ID request dari server MySQL.');
      }

      _lastCreatedDocId = mysqlId;
      await _firestoreService.createPickupRequestWithId(mysqlId, firestoreRequest);

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
      _errorMessage = 'Gagal mengirim request: $e';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Stream<List<PickupRequestModel>> streamPickupRequests(String userId) {
    return _firestoreService.streamMyPickupRequests(userId);
  }
}
