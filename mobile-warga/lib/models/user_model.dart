class UserModel {
  final String id;
  final int? mysqlUserId;
  final String nama;
  final String email;
  final double saldoPoin;

  UserModel({
    required this.id,
    this.mysqlUserId,
    required this.nama,
    required this.email,
    this.saldoPoin = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['firebase_uid']?.toString() ?? json['id']?.toString() ?? '',
      mysqlUserId: _parseMysqlId(json['id']),
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      saldoPoin: (json['saldo_poin'] ?? 0).toDouble(),
    );
  }

  static int? _parseMysqlId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  /// Copy model dengan saldo yang diperbarui.
  UserModel copyWith({double? saldoPoin, int? mysqlUserId}) {
    return UserModel(
      id: id,
      mysqlUserId: mysqlUserId ?? this.mysqlUserId,
      nama: nama,
      email: email,
      saldoPoin: saldoPoin ?? this.saldoPoin,
    );
  }
}
