import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mysqlId = context.read<AuthProvider>().user?.mysqlUserId;
      context.read<DashboardProvider>().fetchSaldo(mysqlId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final auth = context.watch<AuthProvider>();
    final dash = context.watch<DashboardProvider>();
    final nf = NumberFormat('#,###', 'id_ID');

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await dash.fetchSaldo(auth.user?.mysqlUserId);
        },
        child: CustomScrollView(
          slivers: [
            // ---- APP BAR ----
            SliverAppBar(
              expandedHeight: 140, pinned: true,
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_rounded),
                  tooltip: 'Notifikasi',
                  onPressed: () => Navigator.pushNamed(context, '/notifications_screen'),
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded),
                  tooltip: 'Keluar',
                  onPressed: () {
                    auth.logout();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Halo, ${auth.user?.nama ?? 'Warga'} 👋',
                        style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: cs.onPrimary)),
                    Text('Selamat datang di Bank Sampah Digital',
                        style: GoogleFonts.inter(fontSize: 12, color: cs.onPrimary.withValues(alpha: 0.8))),
                  ],
                ),
              ),
            ),

            // ---- BODY ----
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // -- SALDO CARD --
                  _saldoCard(cs, dash, nf),
                  const SizedBox(height: 24),
                  Text('Menu Pintasan', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  // -- MENU GRID --
                  Row(children: [
                    Expanded(child: _menuCard(Icons.local_shipping_rounded, 'Request\nJemput', cs.primary, () => Navigator.pushNamed(context, '/pickup-request'))),
                    const SizedBox(width: 8),
                    Expanded(child: _menuCard(Icons.scale_rounded, 'Daftar\nHarga', cs.secondary, () => Navigator.pushNamed(context, '/harga-sampah'))),
                    const SizedBox(width: 8),
                    Expanded(child: _menuCard(Icons.history_rounded, 'Riwayat\n& Status', cs.tertiary, () => Navigator.pushNamed(context, '/history'))),
                  ]),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _saldoCard(ColorScheme cs, DashboardProvider dash, NumberFormat nf) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [cs.primary, cs.primary.withValues(alpha: 0.8)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: cs.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.account_balance_wallet_rounded, color: cs.onPrimary.withValues(alpha: 0.8), size: 20),
          const SizedBox(width: 8),
          Text('Total Saldo Poin', style: GoogleFonts.inter(fontSize: 14, color: cs.onPrimary.withValues(alpha: 0.8))),
        ]),
        const SizedBox(height: 4),
        Text(
          'Kumpulkan sampah anorganik dan tukarkan menjadi poin!',
          style: GoogleFonts.inter(fontSize: 11, color: cs.onPrimary.withValues(alpha: 0.7)),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: dash.isLoading
                  ? const SizedBox(
                      height: 40,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      ),
                    )
                  : Text(
                      '${nf.format(dash.saldoPoin)} Poin',
                      style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: cs.onPrimary),
                    ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/katalog-voucher'),
              icon: Icon(Icons.card_giftcard_rounded, color: cs.primary, size: 18),
              label: Text(
                'Tukar',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.onPrimary,
                foregroundColor: cs.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ]),
    );
  }

  Widget _menuCard(IconData icon, String label, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2, shadowColor: color.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap, borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(label, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}
