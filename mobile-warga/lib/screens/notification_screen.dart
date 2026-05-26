import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/notification_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

  class _NotificationScreenState extends State<NotificationScreen> {
    // late Future<List<AppNotification>> _notificationsFuture;

    // @override
    // void initState() {
    //   super.initState();
    //   _notificationsFuture = _fetchNotifications();
    // }

    // Future<List<AppNotification>> _fetchNotifications() async {
    //   final userId = context.read<AuthProvider>().user?.mysqlUserId;
    //   if (userId == null) {
    //     throw ApiException('Akun belum tersinkron. Login ulang.');
    //   }

    //   final data = await fetchNotifications(userId);
    //   return data
    //       .map(
    //         (json) => AppNotification.fromJson(Map<String, dynamic>.from(json)),
    //       )
    //       .toList();
    // }

    // Future<void> _refresh() async {
    //   setState(() {
    //     _notificationsFuture = _fetchNotifications();
    //   });
    //   await _notificationsFuture;
    //}

    @override
    Widget build(BuildContext context) {
      final cs = Theme.of(context).colorScheme;

      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Notifikasi',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
        ),
        body: StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('notifikasi_realtime')
        .orderBy('created_at', descending: true)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (snapshot.hasError) {
        return _StateView(
          icon: Icons.error_outline_rounded,
          title: 'Gagal memuat notifikasi',
          message: snapshot.error.toString(),
          color: cs.error,
        );
      }

      final docs = snapshot.data?.docs ?? [];

      if (docs.isEmpty) {
        return _StateView(
          icon: Icons.notifications_none_rounded,
          title: 'Belum ada notifikasi',
          message: 'Aktivitas penjemputan dan poin akan tampil di sini.',
          color: cs.onSurface.withValues(alpha: 0.45),
        );
      }

      final notifications = docs.map((doc) {
        return AppNotification.fromJson(
          doc.data() as Map<String, dynamic>,
        );
      }).toList();

      return ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          return _NotificationCard(
            notification: notifications[index],
          );
        },
      );
    },
  ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final df = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    final nf = NumberFormat('#,###', 'id_ID');
    final accent = _accentColor(notification.type);
    final hasPoints =
        notification.type == 'points_received' ||
        notification.type == 'points_redeemed';

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: accent.withValues(alpha: 0.12),
              child: Icon(_icon(notification.type), color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (hasPoints)
                        Text(
                          '${notification.points >= 0 ? '+' : ''}${nf.format(notification.points)}',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: accent,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    notification.message,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      height: 1.35,
                      color: cs.onSurface.withValues(alpha: 0.72),
                    ),
                  ),
                  if (_detailText(notification).isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _detailText(notification),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    df.format(notification.date),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _icon(String type) {
    switch (type) {
      case 'pickup_request':
        return Icons.assignment_turned_in_rounded;
      case 'pickup_completed':
        return Icons.local_shipping_rounded;
      case 'points_received':
        return Icons.add_circle_rounded;
      case 'points_redeemed':
        return Icons.remove_circle_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _accentColor(String type) {
    switch (type) {
      case 'pickup_request':
        return Colors.blue.shade700;
      case 'pickup_completed':
        return Colors.teal.shade700;
      case 'points_received':
        return Colors.green.shade700;
      case 'points_redeemed':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  String _detailText(AppNotification notification) {
    if (notification.type != 'pickup_request' &&
        notification.type != 'pickup_completed') {
      return notification.status;
    }

    final berat = (notification.metadata['estimasi_berat'] ?? 0).toDouble();
    final kantong = notification.metadata['estimasi_kantong'] ?? 0;
    final parts = <String>[
      if (notification.status.isNotEmpty) 'Status: ${notification.status}',
      if (berat > 0) '${NumberFormat('#,###.##', 'id_ID').format(berat)} kg',
      if (kantong > 0) '$kantong kantong',
    ];
    return parts.join(' - ');
  }
}

class _StateView extends StatelessWidget {
  const _StateView({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 140),
        Icon(icon, size: 58, color: color),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.62),
            ),
          ),
        ),
      ],
    );
  }
}
