import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/services/api_service.dart';
import 'package:provider/provider.dart';
import '../config/app_constants.dart';
// import '../models/pickup_request_model.dart';
import '../providers/auth_provider.dart';
import '../providers/pickup_provider.dart';
import '../widgets/loading_overlay.dart';

/// ============================================================
/// PickupRequestScreen — Form Request Penjemputan Sampah
/// ============================================================
/// Form berisi:
///   - Estimasi jumlah kantong
///   - Estimasi berat (kg)
///   - Catatan tambahan (opsional)
///
/// Saat submit → data dikirim ke Firebase Firestore collection
/// `pickup_requests` dengan status "pending".
/// Koordinat GPS menggunakan mock data (lihat AppConstants).
///
/// TODO: Integrasikan GPS asli menggunakan package `geolocator`.

class PickupRequestScreen extends StatefulWidget {
  const PickupRequestScreen({super.key});
  @override
  State<PickupRequestScreen> createState() => _PickupRequestScreenState();
}

class _PickupRequestScreenState extends State<PickupRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kantongController = TextEditingController(text: '1');
  final _beratController = TextEditingController();
  final _catatanController = TextEditingController();

  @override
  void dispose() {
    _kantongController.dispose();
    _beratController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
  if (!_formKey.currentState!.validate()) return;

  final auth = context.read<AuthProvider>();

  try {
    // ambil user login
    final user = auth.user;

    if (user == null) {
      throw Exception('User belum login');
    }

    final mysqlUserId = user.mysqlUserId;
    if (mysqlUserId == null) {
      throw Exception(
        'ID akun belum tersinkron. Silakan logout lalu login kembali.',
      );
    }

    // panggil API MySQL
    final api = ApiService();

    await api.createPickupRequest(
      namaWarga: user.nama,
      alamat: 'Alamat pengguna', // nanti bisa ambil dari profile
      jenisSampah: 'Campuran', // sementara hardcode
      estimasiBerat:
          double.tryParse(_beratController.text) ?? 0,
      tanggalJemput:
          DateTime.now().toIso8601String().split('T')[0],
      catatan: _catatanController.text.trim(),
      userId: mysqlUserId,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Request penjemputan berhasil dikirim! ✅',
        ),
        backgroundColor:
            Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gagal mengirim request: $e'),
        backgroundColor:
            Theme.of(context).colorScheme.error,
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pickup = context.watch<PickupProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Request Jemput Sampah', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ---- Header Info ----
                  Card(
                    elevation: 0, color: cs.primaryContainer,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(children: [
                        Icon(Icons.info_outline_rounded, color: cs.onPrimaryContainer),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Isi form di bawah untuk meminta penjemputan sampah. Pengepul akan segera memproses permintaan Anda.',
                            style: GoogleFonts.inter(fontSize: 13, color: cs.onPrimaryContainer),
                          ),
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ---- Estimasi Kantong ----
                  Text('Estimasi Jumlah Kantong', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _kantongController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Contoh: 3',
                      prefixIcon: const Icon(Icons.shopping_bag_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Wajib diisi';
                      if (int.tryParse(v) == null || int.parse(v) < 1) return 'Masukkan angka valid (min. 1)';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // ---- Estimasi Berat ----
                  Text('Estimasi Berat (kg)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _beratController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'Contoh: 5.5',
                      prefixIcon: const Icon(Icons.scale_outlined),
                      suffixText: 'kg',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Wajib diisi';
                      if (double.tryParse(v) == null || double.parse(v) <= 0) return 'Masukkan berat yang valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // ---- Catatan ----
                  Text('Catatan Tambahan (Opsional)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _catatanController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Sampah plastik dan kardus, rumah cat biru.',
                      prefixIcon: const Padding(padding: EdgeInsets.only(bottom: 48), child: Icon(Icons.notes_outlined)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ---- Lokasi Info (Mock) ----
                  Card(
                    elevation: 0, color: cs.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(children: [
                        Icon(Icons.location_on_outlined, color: cs.onSurfaceVariant, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            // TODO: Ganti dengan alamat GPS asli
                            'Lokasi: Mock GPS (${AppConstants.mockLatitude}, ${AppConstants.mockLongitude})',
                            style: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant),
                          ),
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ---- Submit Button ----
                  FilledButton.icon(
                    onPressed: pickup.isSubmitting ? null : _handleSubmit,
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Kirim Request Penjemputan'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---- Loading Overlay ----
          if (pickup.isSubmitting)
            const LoadingOverlay(message: 'Mengirim request...'),
        ],
      ),
    );
  }
}
