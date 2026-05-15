// ============================================================
// Model: UserModel
// ============================================================
// Merepresentasikan data warga yang login.
// Data ini di-fetch dari REST API (MySQL) via endpoint login
// dan endpoint saldo.

class UserModel {
  final String id;
  final String nama;
  final String email;
  final double saldoPoin;

  UserModel({
    required this.id,
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
      id: json['id']?.toString() ?? '',
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      saldoPoin: (json['saldo_poin'] ?? 0).toDouble(),
    );
  }

  /// Copy model dengan saldo yang diperbarui.
  UserModel copyWith({double? saldoPoin}) {
    return UserModel(
      id: id,
      nama: nama,
      email: email,
      saldoPoin: saldoPoin ?? this.saldoPoin,
    );
  }
}
