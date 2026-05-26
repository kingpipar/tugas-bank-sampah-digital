import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../config/app_constants.dart';
import '../models/harga_sampah_model.dart';

class HargaSampahScreen extends StatefulWidget {
  const HargaSampahScreen({super.key});

  @override
  State<HargaSampahScreen> createState() => _HargaSampahScreenState();
}

class _HargaSampahScreenState extends State<HargaSampahScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'plastik':
        return Icons.local_drink_rounded;
      case 'kertas':
        return Icons.description_rounded;
      case 'logam':
        return Icons.hardware_rounded;
      case 'elektronik':
        return Icons.devices_rounded;
      case 'kaca':
        return Icons.hourglass_empty_rounded;
      case 'minyak':
        return Icons.oil_barrel_rounded;
      case 'organik':
        return Icons.eco_rounded;
      default:
        return Icons.delete_outline_rounded;
    }
  }

  Color _getCategoryColor(String category, ColorScheme cs) {
    switch (category.toLowerCase()) {
      case 'plastik':
        return Colors.blue;
      case 'kertas':
        return Colors.orange;
      case 'logam':
        return Colors.blueGrey;
      case 'elektronik':
        return Colors.purple;
      case 'kaca':
        return Colors.teal;
      case 'minyak':
        return Colors.amber;
      case 'organik':
        return Colors.green;
      default:
        return cs.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final numberFormat = NumberFormat('#,###', 'id_ID');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Harga Sampah',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ---- SEARCH BAR ----
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari nama sampah...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: cs.surfaceContainerHighest,
              ),
            ),
          ),

          // ---- LIST OF PRICES ----
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(AppConstants.hargaSampahCollection)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Gagal memuat harga: ${snapshot.error}',
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
                          Icons.scale_rounded,
                          size: 64,
                          color: cs.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada data harga sampah',
                          style: GoogleFonts.inter(
                            color: cs.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Filter & Group by Category
                final Map<String, List<DocumentSnapshot>> groupedData = {};
                for (var doc in docs) {
                  final model = HargaSampahModel.fromFirestore(doc);
                  final name = model.namaSampah.toLowerCase();
                  final category = model.kategori;

                  if (_searchQuery.isEmpty || name.contains(_searchQuery)) {
                    if (!groupedData.containsKey(category)) {
                      groupedData[category] = [];
                    }
                    groupedData[category]!.add(doc);
                  }
                }

                if (groupedData.isEmpty) {
                  return Center(
                    child: Text(
                      'Nama sampah tidak ditemukan',
                      style: GoogleFonts.inter(
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  );
                }

                final categories = groupedData.keys.toList()..sort();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  itemBuilder: (context, catIndex) {
                    final category = categories[catIndex];
                    final items = groupedData[category]!;
                    final catColor = _getCategoryColor(category, cs);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ---- CATEGORY HEADER ----
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: catColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                category,
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: cs.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ---- ITEMS IN CATEGORY ----
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          itemBuilder: (context, itemIndex) {
                            final itemDoc = items[itemIndex];
                            final model = HargaSampahModel.fromFirestore(itemDoc);
                            final name = model.namaSampah;
                            final price = model.hargaPerKg.toInt();
                            final points = model.poinPerKg.toInt();

                            return Card(
                              elevation: 0,
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: cs.outlineVariant.withValues(alpha: 0.5),
                                ),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: catColor.withValues(alpha: 0.1),
                                  child: Icon(
                                    _getCategoryIcon(category),
                                    color: catColor,
                                  ),
                                ),
                                title: Text(
                                  name,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Text(
                                  'Harga: ${currencyFormat.format(price)} / kg',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cs.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '+${numberFormat.format(points)} Poin/kg',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: cs.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
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
}
