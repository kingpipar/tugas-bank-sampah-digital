import 'package:cloud_firestore/cloud_firestore.dart';

class VoucherRewardModel {
  final String id;
  final String namaVoucher;
  final double minPoin;
  final int stok;

  VoucherRewardModel({
    required this.id,
    required this.namaVoucher,
    required this.minPoin,
    required this.stok,
  });

  factory VoucherRewardModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return VoucherRewardModel(
      id: doc.id,
      namaVoucher: data['nama_voucher']?.toString() ?? 'Voucher Menarik',
      minPoin: (data['min_poin'] ?? 0).toDouble(),
      stok: (data['stok'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nama_voucher': namaVoucher,
      'min_poin': minPoin,
      'stok': stok,
    };
  }
}
