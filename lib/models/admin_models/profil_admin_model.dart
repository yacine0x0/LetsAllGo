class AdminProfilModel {
  final String id;
  String firstName;
  String lastName;
  String email;
  final String role;
  final String enrollmentDate;
  bool isDarkMode;
  String language;

  AdminProfilModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.enrollmentDate,
    this.isDarkMode = true,
    this.language   = 'Français',
  });

  // ✅ Depuis la BDD
  factory AdminProfilModel.fromApi(Map<String, dynamic> json) {
    final dateRaw = (json['dateinscription'] as String?) ?? '';
    final date    = dateRaw.length >= 10 ? dateRaw.substring(0, 10) : '—';

    return AdminProfilModel(
      id:             json['id'] as String,
      firstName:      json['prenom'] as String,
      lastName:       json['nom']    as String,
      email:          json['email']  as String,
      role:           json['role']   as String,
      enrollmentDate: date,
    );
  }

  // Données fictives
  static AdminProfilModel mock() {
    return AdminProfilModel(
      id:             '00000000',
      firstName:      'Admin',
      lastName:       'LetsAllGo',
      email:          'admin@letsallgo.com',
      role:           'admin',
      enrollmentDate: '2024-01-01',
    );
  }
}