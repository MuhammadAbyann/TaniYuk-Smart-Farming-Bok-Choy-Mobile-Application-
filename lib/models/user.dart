class User {
  final String email;
  final String? lokasiLahan;
  final String? jenisTanaman;
  final String? luasLahan;
  final String? lamaPanen;
  final String? role;

  User({
    required this.email,
    this.lokasiLahan,
    this.jenisTanaman,
    this.luasLahan,
    this.lamaPanen,
    this.role = 'user',
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        email: json['email'] ?? '',
        lokasiLahan: json['lokasiLahan'],
        jenisTanaman: json['jenisTanaman'],
        luasLahan: json['luasLahan'],
        lamaPanen: json['lamaPanen'],
        role: json['role'] ?? 'user',
      );
}
