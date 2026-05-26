import 'package:flutter/material.dart';

/// ============================================================
/// Widget: StatusBadge
/// ============================================================
/// Badge visual untuk menampilkan status penjemputan.
/// Warna berubah sesuai status:
///   - "pending"    → Kuning/Amber
///   - "on_the_way" → Biru
///   - "completed"  → Hijau

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color backgroundColor;
    Color textColor;
    IconData icon;
    String label;

    switch (status) {
      case 'pending':
      case 'menunggu':
        backgroundColor = Colors.amber.shade100;
        textColor = Colors.amber.shade900;
        icon = Icons.hourglass_top_rounded;
        label = 'Menunggu';
        break;
      case 'on_the_way':
      case 'diterima':
      case 'proses_diantar':
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade900;
        icon = Icons.local_shipping_rounded;
        label = status == 'diterima' ? 'Diterima' : 'Dalam Perjalanan';
        break;
      case 'completed':
      case 'selesai':
        backgroundColor = colorScheme.primaryContainer;
        textColor = colorScheme.onPrimaryContainer;
        icon = Icons.check_circle_rounded;
        label = 'Selesai';
        break;
      case 'ditolak':
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade900;
        icon = Icons.cancel_rounded;
        label = 'Ditolak';
        break;
      default:
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
        icon = Icons.help_outline_rounded;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
