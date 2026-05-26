import 'package:cloud_firestore/cloud_firestore.dart';

class HargaSampahModel {
  final String id;
  final String kategori;
  final String namaSampah;
  final double hargaPerKg;
  final double poinPerKg;

  HargaSampahModel({
    required this.id,
    required this.kategori,
    required this.namaSampah,
    required this.hargaPerKg,
    required this.poinPerKg,
  });

  factory HargaSampahModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return HargaSampahModel(
      id: doc.id,
      kategori: data['kategori']?.toString() ?? 'Lain-lain',
      namaSampah: data['nama_sampah']?.toString() ?? 'Sampah Tanpa Nama',
      hargaPerKg: (data['harga_per_kg'] ?? 0).toDouble(),
      poinPerKg: (data['poin_per_kg'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'kategori': kategori,
      'nama_sampah': namaSampah,
      'harga_per_kg': hargaPerKg,
      'poin_per_kg': poinPerKg,
    };
  }
}
