import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_constants.dart';
import '../models/pickup_request_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> createPickupRequest(PickupRequestModel request) async {
    final docRef = await _db
        .collection(AppConstants.pickupRequestsCollection)
        .add(request.toFirestore());

    return docRef.id;
  }

  Future<void> createPickupRequestWithId(String docId, PickupRequestModel request) async {
    await _db
        .collection(AppConstants.pickupRequestsCollection)
        .doc(docId)
        .set(request.toFirestore());
  }

  Stream<List<PickupRequestModel>> streamMyPickupRequests(String userId) {
    return _db
        .collection(AppConstants.pickupRequestsCollection)
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => PickupRequestModel.fromFirestore(doc))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
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
