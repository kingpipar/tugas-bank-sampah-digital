import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/app_constants.dart';
import '../providers/auth_provider.dart';
import '../models/voucher_reward_model.dart';

class KatalogVoucherScreen extends StatelessWidget {
  const KatalogVoucherScreen({super.key});

  IconData _getVoucherIcon(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('minyak')) {
      return Icons.opacity_rounded;
    } else if (lowerName.contains('beras')) {
      return Icons.rice_bowl_rounded;
    } else if (lowerName.contains('gula')) {
      return Icons.cookie_rounded;
    } else if (lowerName.contains('telur')) {
      return Icons.egg_rounded;
    } else if (lowerName.contains('dana') || lowerName.contains('uang') || lowerName.contains('saldo')) {
      return Icons.account_balance_wallet_rounded;
    }
    return Icons.card_giftcard_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final auth = context.watch<AuthProvider>();
    final userPoints = auth.user?.saldoPoin ?? 0;
    final numberFormat = NumberFormat('#,###', 'id_ID');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Katalog Voucher',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ---- POINT DISPLAY ----
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.secondaryContainer, cs.secondaryContainer.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.secondary.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.stars_rounded, color: cs.primary, size: 28),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Poin Anda saat ini',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: cs.onSecondaryContainer,
                          ),
                        ),
                        Text(
                          '${numberFormat.format(userPoints)} Poin',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => auth.refreshSaldo(),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text('Refresh', style: GoogleFonts.inter(fontSize: 12)),
                )
              ],
            ),
          ),

          // ---- VOUCHER LIST ----
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(AppConstants.voucherRewardCollection)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Gagal memuat voucher: ${snapshot.error}',
                      style: GoogleFonts.inter(color: cs.error),
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.redeem_rounded,
                          size: 64,
                          color: cs.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada voucher tersedia',
                          style: GoogleFonts.inter(
                            color: cs.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final voucherDoc = docs[index];
                    final model = VoucherRewardModel.fromFirestore(voucherDoc);
                    final name = model.namaVoucher;
                    final minPoin = model.minPoin.toInt();
                    final stock = model.stok;
                    final hasEnoughPoints = userPoints >= minPoin;

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: cs.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: cs.primaryContainer.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getVoucherIcon(name),
                                color: cs.primary,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Info Voucher
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Stok: $stock item',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: cs.primary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '${numberFormat.format(minPoin)} Poin',
                                          style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: cs.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Status / Button Tukar
                            Column(
                              children: [
                                if (stock <= 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: cs.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Habis',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                  )
                                else if (hasEnoughPoints)
                                  ElevatedButton(
                                    onPressed: () {
                                      _showExchangeDialog(context, name, minPoin, cs);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: cs.primary,
                                      foregroundColor: cs.onPrimary,
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      'Tukar',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: cs.errorContainer.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Poin Kurang',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: cs.onErrorContainer,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showExchangeDialog(BuildContext context, String voucherName, int points, ColorScheme cs) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Konfirmasi Penukaran',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin menukarkan $points poin dengan "$voucherName"? Silakan tunjukkan ke petugas bank sampah untuk verifikasi.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Permintaan penukaran "$voucherName" diajukan! Harap hubungi petugas admin.'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: cs.primary,
                ),
              );
            },
            child: const Text('Tukar Sekarang'),
          ),
        ],
      ),
    );
  }
}
