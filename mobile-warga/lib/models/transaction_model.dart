// ============================================================
// Model: TransactionModel
// ============================================================
// Merepresentasikan satu record riwayat penukaran poin.
// Data di-fetch dari REST API (MySQL) via endpoint:
//   GET /api/transaksi/:userId
//
// Contoh JSON response yang diharapkan:
// ```json
// [
//   {
//     "id": 1,
//     "jenis": "Tukar Sembako",
//     "jumlah_poin": 500,
//     "keterangan": "Tukar 500 poin → 1kg beras",
//     "tanggal": "2026-05-10T10:30:00Z"
//   }
// ]
// ```
//
// TODO: Sesuaikan key JSON dengan response API backend Anda.

class TransactionModel {
  final String id;
  final String jenis; // e.g. "Tukar Sembako", "Tukar Uang", "Setoran Sampah"
  final double jumlahPoin;
  final String keterangan;
  final DateTime tanggal;

  TransactionModel({
    required this.id,
    required this.jenis,
    required this.jumlahPoin,
    required this.keterangan,
    required this.tanggal,
  });

  /// Factory constructor untuk parsing JSON dari REST API.
  /// TODO: Sesuaikan key JSON ('id', 'jenis', 'jumlah_poin', dll.)
  ///       dengan field name yang dikembalikan oleh backend Anda.
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id']?.toString() ?? '',
      jenis: json['jenis'] ?? '',
      jumlahPoin: (json['jumlah_poin'] ?? 0).toDouble(),
      keterangan: json['keterangan'] ?? '',
      tanggal: DateTime.tryParse(json['tanggal'] ?? '') ?? DateTime.now(),
    );
  }
}
