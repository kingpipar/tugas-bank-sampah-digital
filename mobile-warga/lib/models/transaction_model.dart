class TransactionModel {
  final String id;
  final String jenis;
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
