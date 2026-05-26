import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../models/notification_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _hasAutoMarked = false;

  /// Otomatis tandai semua notifikasi sebagai sudah dibaca
  /// saat pertama kali halaman dibuka.
  void _autoMarkAllRead(List<AppNotification> notifications) {
    if (_hasAutoMarked) return;
    _hasAutoMarked = true;

    final unread = notifications.where((n) => !n.isRead).toList();
    if (unread.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    for (final notif in unread) {
      final docRef =
          FirebaseFirestore.instance.collection('notifikasi').doc(notif.docId);
      batch.update(docRef, {'isRead': true});
    }
    batch.commit().catchError((e) {
      debugPrint('[NOTIF] Gagal auto-mark-read: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal update status baca: $e'),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });
  }

  /// Manual: tandai semua sebagai dibaca (tombol AppBar).
  Future<void> _markAllAsRead(List<AppNotification> notifications) async {
    final unread = notifications.where((n) => !n.isRead).toList();
    if (unread.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    for (final notif in unread) {
      final docRef =
          FirebaseFirestore.instance.collection('notifikasi').doc(notif.docId);
      batch.update(docRef, {'isRead': true});
    }

    try {
      await batch.commit();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Semua notifikasi telah ditandai dibaca'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('[NOTIF] Gagal mark all read: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: $e'),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final userId = context.read<AuthProvider>().user?.mysqlUserId;

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
      body: userId == null
          ? _StateView(
              icon: Icons.warning_amber_rounded,
              title: 'Akun belum tersinkron',
              message: 'Silakan login ulang untuk melihat notifikasi.',
              color: cs.error,
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifikasi')
                  .where('user_id', isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
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
                    message:
                        'Aktivitas penjemputan dan poin akan tampil di sini.',
                    color: cs.onSurface.withValues(alpha: 0.45),
                  );
                }

                final notifications = docs
                    .map((doc) => AppNotification.fromFirestore(doc))
                    .toList()
                  ..sort((a, b) => b.date.compareTo(a.date)); // terbaru di atas

                // Auto mark-as-read saat pertama kali data masuk
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _autoMarkAllRead(notifications);
                });

                final hasUnread = notifications.any((n) => !n.isRead);

                return Column(
                  children: [
                    // Tombol "Tandai Semua Dibaca" jika ada unread
                    if (hasUnread)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: TextButton.icon(
                          onPressed: () => _markAllAsRead(notifications),
                          icon: const Icon(Icons.done_all_rounded, size: 18),
                          label: Text(
                            'Tandai Semua Dibaca',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: cs.primary,
                          ),
                        ),
                      ),
                    Expanded(
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: notifications.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          return _NotificationCard(
                            notification: notifications[index],
                          );
                        },
                      ),
                    ),
                  ],
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
    final accent = _accentColor(notification.tipeTrigger);

    return Card(
      elevation: notification.isRead ? 0.5 : 2,
      margin: EdgeInsets.zero,
      color: notification.isRead
          ? null
          : cs.primary.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: notification.isRead
            ? BorderSide.none
            : BorderSide(color: cs.primary.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: accent.withValues(alpha: 0.12),
              child: Icon(_icon(notification.tipeTrigger), color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: notification.isRead
                                ? FontWeight.w600
                                : FontWeight.w700,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6),
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
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

  IconData _icon(int tipeTrigger) {
    switch (tipeTrigger) {
      case 1:
        return Icons.check_circle_outline_rounded;
      case 2:
        return Icons.assignment_turned_in_rounded;
      case 3:
        return Icons.local_shipping_rounded;
      case 4:
        return Icons.add_circle_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _accentColor(int tipeTrigger) {
    switch (tipeTrigger) {
      case 1:
        return Colors.orange.shade700;
      case 2:
        return Colors.blue.shade700;
      case 3:
        return Colors.teal.shade700;
      case 4:
        return Colors.green.shade700;
      default:
        return Colors.grey.shade700;
    }
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
