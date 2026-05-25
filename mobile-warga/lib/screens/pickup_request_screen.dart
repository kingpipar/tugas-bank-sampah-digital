import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/services/api_service.dart';
import 'package:provider/provider.dart';
import '../models/pickup_request_model.dart';
import '../providers/auth_provider.dart';
import '../providers/pickup_provider.dart';
import '../services/location_service.dart';
import '../widgets/loading_overlay.dart';

/// Form request penjemputan — koordinat dari GPS (geolocator).
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

  double? _latitude;
  double? _longitude;
  bool _isLoadingLocation = false;

  @override
  void dispose() {
    _kantongController.dispose();
    _beratController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _pickCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      final position = await LocationService.getCurrentPosition();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lokasi berhasil diambil'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on LocationException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Gagal mengambil lokasi: $e');
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  String get _alamatText {
    if (_latitude == null || _longitude == null) {
      return 'Belum dipilih';
    }
    return '${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}';
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_latitude == null || _longitude == null) {
      _showError('Pilih lokasi saat ini terlebih dahulu');
      return;
    }

    final auth = context.read<AuthProvider>();
    final pickup = context.read<PickupProvider>();
    final user = auth.user;

    if (user == null) {
      _showError('User belum login');
      return;
    }

    final mysqlUserId = user.mysqlUserId;
    if (mysqlUserId == null) {
      _showError('ID akun belum tersinkron. Silakan logout lalu login kembali.');
      return;
    }

    final kantong = int.parse(_kantongController.text);
    final berat = double.parse(_beratController.text);
    final catatan = _catatanController.text.trim();
    final api = ApiService();
    final lat = _latitude!;
    final lng = _longitude!;

    final firestoreRequest = PickupRequestModel(
      userId: user.id,
      estimasiKantong: kantong,
      estimasiBerat: berat,
      catatan: catatan,
      latitude: lat,
      longitude: lng,
      status: 'pending',
    );

    final success = await pickup.submitHybrid(
      firestoreRequest: firestoreRequest,
      syncToMysql: () => api.createPickupRequest(
        namaWarga: user.nama,
        alamat: _alamatText,
        jenisSampah: 'Campuran',
        estimasiBerat: berat,
        estimasiKantong: kantong,
        tanggalJemput: DateTime.now().toIso8601String().split('T')[0],
        catatan: catatan,
        userId: mysqlUserId,
      ),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Request penjemputan berhasil dikirim! ✅'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else {
      _showError(pickup.errorMessage ?? 'Gagal mengirim request');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pickup = context.watch<PickupProvider>();
    final hasLocation = _latitude != null && _longitude != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Request Jemput Sampah',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
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
                  Card(
                    elevation: 0,
                    color: cs.primaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: cs.onPrimaryContainer,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Isi form di bawah untuk meminta penjemputan sampah. Pengepul akan segera memproses permintaan Anda.',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: cs.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Estimasi Jumlah Kantong',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _kantongController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Contoh: 3',
                      prefixIcon: const Icon(Icons.shopping_bag_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Wajib diisi';
                      if (int.tryParse(v) == null || int.parse(v) < 1) {
                        return 'Masukkan angka valid (min. 1)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Estimasi Berat (kg)',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _beratController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Contoh: 5.5',
                      prefixIcon: const Icon(Icons.scale_outlined),
                      suffixText: 'kg',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Wajib diisi';
                      if (double.tryParse(v) == null || double.parse(v) <= 0) {
                        return 'Masukkan berat yang valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Catatan Tambahan (Opsional)',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _catatanController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText:
                          'Contoh: Sampah plastik dan kardus, rumah cat biru.',
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 48),
                        child: Icon(Icons.notes_outlined),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Lokasi Penjemputan',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 0,
                    color: hasLocation
                        ? cs.primaryContainer.withValues(alpha: 0.35)
                        : cs.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: hasLocation
                            ? cs.primary.withValues(alpha: 0.4)
                            : cs.outlineVariant,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(
                                hasLocation
                                    ? Icons.location_on_rounded
                                    : Icons.location_off_outlined,
                                color: hasLocation
                                    ? cs.primary
                                    : cs.onSurfaceVariant,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  hasLocation
                                      ? 'Koordinat: $_alamatText'
                                      : 'Lokasi belum dipilih',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: cs.onSurface,
                                    fontWeight: hasLocation
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _isLoadingLocation || pickup.isSubmitting
                                ? null
                                : _pickCurrentLocation,
                            icon: _isLoadingLocation
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: cs.primary,
                                    ),
                                  )
                                : const Icon(Icons.my_location_rounded),
                            label: Text(
                              _isLoadingLocation
                                  ? 'Mengambil lokasi...'
                                  : 'Pilih Lokasi Saat Ini',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: pickup.isSubmitting ? null : _handleSubmit,
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Kirim Request Penjemputan'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (pickup.isSubmitting)
            const LoadingOverlay(message: 'Mengirim request...'),
        ],
      ),
    );
  }
}
