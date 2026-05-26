class AppNotification {
  final String id;
  final String type;
  final String title;
  final String message;
  final String status;
  final double points;
  final DateTime date;
  final Map<String, dynamic> metadata;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.status,
    required this.points,
    required this.date,
    required this.metadata,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'general',
      title: json['title']?.toString() ?? 'Notifikasi',
      message: json['message']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      points: (json['points'] ?? 0).toDouble(),
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}
