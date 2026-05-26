import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile/services/api_service.dart';
import 'package:provider/provider.dart';
import '../config/app_constants.dart';
import '../models/harga_sampah_model.dart';
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
  // final _kantongController = TextEditingController(text: '1');
  final _beratController = TextEditingController();
  final _catatanController = TextEditingController();

  String? _selectedHargaSampahId;
  HargaSampahModel? _selectedHargaSampah;
  DateTime? _tanggalJemput;
  double? _latitude;
  double? _longitude;
  bool _isLoadingLocation = false;

  @override
  void dispose() {
    // _kantongController.dispose();
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

  String get _tanggalJemputApiText {
    final tanggal = _tanggalJemput;
    if (tanggal == null) return '';
    return DateFormat('yyyy-MM-dd').format(tanggal);
  }

  String get _tanggalJemputDisplayText {
    final tanggal = _tanggalJemput;
    if (tanggal == null) return 'Belum dipilih';
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(tanggal);
  }

  Future<void> _pickTanggalJemput() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalJemput ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 30)),
      helpText: 'Pilih tanggal penjemputan',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (picked == null || !mounted) return;
    setState(() => _tanggalJemput = picked);
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final selectedSampah = _selectedHargaSampah;
    if (selectedSampah == null) {
      _showError('Pilih jenis sampah terlebih dahulu');
      return;
    }

    if (_tanggalJemput == null) {
      _showError('Pilih tanggal penjemputan terlebih dahulu');
      return;
    }

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

    // final kantong = int.parse(_kantongController.text);
    final berat = double.parse(_beratController.text);
    final catatan = _catatanController.text.trim();
    final api = ApiService();
    final lat = _latitude!;
    final lng = _longitude!;

    final firestoreRequest = PickupRequestModel(
      userId: user.id,
      // estimasiKantong: kantong,
      estimasiBerat: berat,
      jenisSampah: selectedSampah.namaSampah,
      kategoriSampah: selectedSampah.kategori,
      hargaPerKg: selectedSampah.hargaPerKg,
      poinPerKg: selectedSampah.poinPerKg,
      tanggalJemput: _tanggalJemputApiText,
      catatan: catatan,
      latitude: lat,
      longitude: lng,
      status: 'menunggu',
    );

    final success = await pickup.submitHybrid(
      firestoreRequest: firestoreRequest,
      syncToMysql: () => api.createPickupRequest(
        namaWarga: user.nama,
        alamat: _alamatText,
        jenisSampah: selectedSampah.namaSampah,
        estimasiBerat: berat,
        // estimasiKantong: kantong,
        tanggalJemput: _tanggalJemputApiText,
        catatan: catatan,
        userId: mysqlUserId,
        idSampah: int.tryParse(selectedSampah.id),
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
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final numberFormat = NumberFormat('#,###', 'id_ID');

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
                    'Pilih Jenis Sampah',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection(AppConstants.hargaSampahCollection)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return InputDecorator(
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.category_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: cs.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Memuat data sampah...',
                                style: GoogleFonts.inter(fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Text(
                          'Gagal memuat data sampah: ${snapshot.error}',
                          style: GoogleFonts.inter(color: cs.error),
                        );
                      }

                      final items = ((snapshot.data?.docs ?? [])
                            .map(HargaSampahModel.fromFirestore)
                            .toList())
                        ..sort((a, b) {
                          final categoryCompare =
                              a.kategori.compareTo(b.kategori);
                          if (categoryCompare != 0) return categoryCompare;
                          return a.namaSampah.compareTo(b.namaSampah);
                        });

                      if (items.isEmpty) {
                        return InputDecorator(
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.category_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                          ),
                          child: Text(
                            'Belum ada data harga sampah',
                            style: GoogleFonts.inter(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        );
                      }

                      final selectedId = items.any(
                        (item) => item.id == _selectedHargaSampahId,
                      )
                          ? _selectedHargaSampahId
                          : null;

                      return DropdownButtonFormField<String>(
                        value: selectedId,
                        isExpanded: true,
                        menuMaxHeight: 420,
                        decoration: InputDecoration(
                          hintText: 'Pilih sampah dari daftar harga',
                          prefixIcon: const Icon(Icons.category_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                        ),
                        items: items.map((item) {
                          return DropdownMenuItem<String>(
                            value: item.id,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.namaSampah,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${item.kategori} - ${currencyFormat.format(item.hargaPerKg)} / kg - ${numberFormat.format(item.poinPerKg)} poin/kg',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        selectedItemBuilder: (context) {
                          return items.map((item) {
                            return Text(
                              '${item.namaSampah} - ${currencyFormat.format(item.hargaPerKg)} / kg - ${numberFormat.format(item.poinPerKg)} poin/kg',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(fontSize: 14),
                            );
                          }).toList();
                        },
                        onChanged: pickup.isSubmitting
                            ? null
                            : (value) {
                                final selected = items.firstWhere(
                                  (item) => item.id == value,
                                );
                                setState(() {
                                  _selectedHargaSampahId = selected.id;
                                  _selectedHargaSampah = selected;
                                });
                              },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Pilih jenis sampah';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  // const SizedBox(height: 20),
                  // Text(
                  //   'Estimasi Kantong',
                  //   style: GoogleFonts.inter(
                  //     fontSize: 14,
                  //     fontWeight: FontWeight.w600,
                  //   ),
                  // ),
                  const SizedBox(height: 8),
                  // TextFormField(
                  //   // controller: _kantongController,
                  //   keyboardType: TextInputType.number,
                  //   decoration: InputDecoration(
                  //     hintText: 'Contoh: 3',
                  //     prefixIcon: const Icon(Icons.shopping_bag_outlined),
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(12),
                  //     ),
                  //     filled: true,
                  //   ),
                  //   validator: (v) {
                  //     if (v == null || v.isEmpty) return 'Wajib diisi';
                  //     if (int.tryParse(v) == null || int.parse(v) < 1) {
                  //       return 'Masukkan angka valid (min. 1)';
                  //     }
                  //     return null;
                  //   },
                  // ),
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
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                              ),
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
                  Text(
                    'Tanggal Penjemputan',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: pickup.isSubmitting ? null : _pickTanggalJemput,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.calendar_month_rounded),
                        suffixIcon: const Icon(Icons.expand_more_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                      ),
                      child: Text(
                        _tanggalJemputDisplayText,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: _tanggalJemput == null
                              ? cs.onSurfaceVariant
                              : cs.onSurface,
                        ),
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
