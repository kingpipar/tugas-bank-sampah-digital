// ============================================================
// Model: UserModel
// ============================================================
// Merepresentasikan data warga yang login.
// Data ini di-fetch dari REST API (MySQL) via endpoint login
// dan endpoint saldo.

class UserModel {
  /// Firebase UID — dipakai untuk Firestore (history, dll).
  final String id;
  /// ID numerik di tabel MySQL `users` — dipakai untuk REST API.
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

  /// Factory constructor untuk parsing JSON response dari API.
  ///
  /// Contoh JSON yang diharapkan dari endpoint login:
  /// ```json
  /// {
  ///   "id": "1",
  ///   "nama": "Budi Santoso",
  ///   "email": "budi@email.com"
  /// }
  /// ```
  ///
  /// TODO: Sesuaikan key JSON dengan response API backend Anda.
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
