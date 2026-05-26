import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String docId; // Firestore document ID (untuk mark-as-read)
  final String title;
  final String message;
  final int tipeTrigger;
  final int userId;
  final bool isRead;
  final DateTime date;

  const AppNotification({
    required this.docId,
    required this.title,
    required this.message,
    required this.tipeTrigger,
    required this.userId,
    required this.isRead,
    required this.date,
  });

  /// Factory utama — dari Firestore DocumentSnapshot.
  /// Field Firestore: judul, pesan, tipe_trigger, user_id, isRead, created_at
  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final json = doc.data() as Map<String, dynamic>? ?? {};

    DateTime parsedDate = DateTime.now();
    final rawDate = json['created_at'] ?? json['date'];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    }

    return AppNotification(
      docId: doc.id,
      title: json['judul']?.toString() ?? 'Notifikasi',
      message: json['pesan']?.toString() ?? '',
      tipeTrigger: _parseInt(json['tipe_trigger']),
      userId: _parseInt(json['user_id']),
      isRead: json['isRead'] == true,
      date: parsedDate,
    );
  }

  /// Backward-compat factory dari plain Map (misal dari REST API).
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate = DateTime.now();
    final rawDate = json['created_at'] ?? json['date'];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    }

    return AppNotification(
      docId: json['docId']?.toString() ?? '',
      title: json['judul']?.toString() ?? json['title']?.toString() ?? 'Notifikasi',
      message: json['pesan']?.toString() ?? json['message']?.toString() ?? '',
      tipeTrigger: _parseInt(json['tipe_trigger']),
      userId: _parseInt(json['user_id']),
      isRead: json['isRead'] == true,
      date: parsedDate,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}