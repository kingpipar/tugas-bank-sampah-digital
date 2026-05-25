import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/pickup_request_model.dart';
import '../models/transaction_model.dart';
import '../providers/auth_provider.dart';
import '../providers/pickup_provider.dart';
import '../services/api_service.dart';
import '../widgets/status_badge.dart';

/// ============================================================
/// HistoryScreen — Riwayat & Status (Kombinasi API + Firebase)
/// ============================================================
/// Tab 1: Status Penjemputan (Real-time via StreamBuilder/Firestore)
/// Tab 2: Riwayat Penukaran Poin (FutureBuilder/REST API MySQL)

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat & Status',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(icon: Icon(Icons.local_shipping_outlined), text: 'Status Jemput'),
            Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Riwayat Poin'),
          ],
          indicatorColor: cs.primary,
          labelColor: cs.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _PickupStatusTab(),
          _TransactionHistoryTab(),
        ],
      ),
    );
  }
}

// ================================================================
// TAB 1: Status Penjemputan (Real-time Firestore StreamBuilder)
// ================================================================
class _PickupStatusTab extends StatelessWidget {
  const _PickupStatusTab();

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthProvider>().user?.id ?? '';
    final pickup = context.read<PickupProvider>();
    final cs = Theme.of(context).colorScheme;
    final df = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    return StreamBuilder<List<PickupRequestModel>>(
      stream: pickup.streamPickupRequests(userId),
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // Error
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.error_outline, size: 48, color: cs.error),
                const SizedBox(height: 12),
                Text('Gagal memuat data: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(color: cs.error)),
              ]),
            ),
          );
        }
        // Empty
        final requests = snapshot.data ?? [];
        if (requests.isEmpty) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.inbox_outlined, size: 64,
                  color: cs.onSurface.withValues(alpha: 0.3)),
              const SizedBox(height: 12),
              Text('Belum ada request penjemputan',
                  style: GoogleFonts.inter(
                      color: cs.onSurface.withValues(alpha: 0.5))),
            ]),
          );
        }
        // List
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final r = requests[index];
            return Card(
              elevation: 1, margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Request #${r.id?.substring(0, 6) ?? '-'}',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700, fontSize: 14)),
                        StatusBadge(status: r.status),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _infoRow(Icons.shopping_bag_outlined,
                        '${r.estimasiKantong} kantong · ${r.estimasiBerat} kg'),
                    if (r.catatan.isNotEmpty)
                      _infoRow(Icons.notes_outlined, r.catatan),
                    _infoRow(Icons.access_time_outlined, df.format(r.createdAt)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(child: Text(text,
            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade700))),
      ]),
    );
  }
}

// ================================================================
// TAB 2: Riwayat Penukaran Poin (REST API MySQL)
// ================================================================
class _TransactionHistoryTab extends StatefulWidget {
  const _TransactionHistoryTab();
  @override
  State<_TransactionHistoryTab> createState() => _TransactionHistoryTabState();
}

class _TransactionHistoryTabState extends State<_TransactionHistoryTab> {
  late Future<List<TransactionModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchTransactions();
  }

  Future<List<TransactionModel>> _fetchTransactions() async {
    final mysqlUserId = context.read<AuthProvider>().user?.mysqlUserId;
    if (mysqlUserId == null) {
      throw ApiException('Akun belum tersinkron. Login ulang.');
    }

    final api = ApiService();
    final data = await api.fetchRiwayatTransaksi(mysqlUserId.toString());
    return data
        .map((j) => TransactionModel.fromJson(Map<String, dynamic>.from(j)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final df = DateFormat('dd MMM yyyy', 'id_ID');
    final nf = NumberFormat('#,###', 'id_ID');

    return FutureBuilder<List<TransactionModel>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Gagal memuat: ${snapshot.error}',
              style: GoogleFonts.inter(color: cs.error)));
        }
        final txns = snapshot.data ?? [];
        if (txns.isEmpty) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.receipt_long_outlined, size: 64,
                  color: cs.onSurface.withValues(alpha: 0.3)),
              const SizedBox(height: 12),
              Text('Belum ada riwayat transaksi',
                  style: GoogleFonts.inter(
                      color: cs.onSurface.withValues(alpha: 0.5))),
            ]),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: txns.length,
          itemBuilder: (context, index) {
            final t = txns[index];
            final isPositive = t.jumlahPoin >= 0;
            return Card(
              elevation: 1, margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: isPositive
                      ? Colors.green.shade100 : Colors.red.shade100,
                  child: Icon(
                    isPositive ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    color: isPositive ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
                title: Text(t.jenis,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text('${t.keterangan}\n${df.format(t.tanggal)}',
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600)),
                trailing: Text(
                  '${isPositive ? '+' : ''}${nf.format(t.jumlahPoin)}',
                  style: GoogleFonts.outfit(
                    fontSize: 16, fontWeight: FontWeight.bold,
                    color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }
}
