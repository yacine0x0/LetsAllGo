class ProfileModel {
  final String id;          // UUID depuis la BDD
  final String firstName;   // prenom
  final String lastName;    // nom
  final String email;
  final String studentId;   // généré depuis id
  final String enrollmentDate; // dateinscription
  final String speciality;
  final String studyLevel;
  final String role;
  final double globalProgress;
  final int coursesSuivis;  // depuis etudie
  final int quizReussis;    // depuis passe
  final int classement;     // rang
  final int pointsXP;       // scoretotal
  bool isFrench;
  bool soundEffects;

  ProfileModel({
    this.id = '',
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.studentId,
    required this.enrollmentDate,
    required this.speciality,
    required this.studyLevel,
    required this.role,
    required this.globalProgress,
    required this.coursesSuivis,
    required this.quizReussis,
    required this.classement,
    required this.pointsXP,
    this.isFrench = true,
    this.soundEffects = true,
  });

  // 🆕 Depuis la réponse JSON du backend
  factory ProfileModel.fromApi(Map<String, dynamic> json) {
    // dateinscription → "2024-09-15T00:00:00.000Z" → "2024-09-15"
    final dateRaw = (json['dateinscription'] as String?) ?? '';
    final date = dateRaw.length >= 10 ? dateRaw.substring(0, 10) : '—';

    return ProfileModel(
      id:              json['id'] as String,
      firstName:       json['prenom'] as String,
      lastName:        json['nom'] as String,
      email:           json['email'] as String,
      studentId:       json['id'].toString().substring(0, 8).toUpperCase(),
      enrollmentDate:  date,
      speciality:      'Informatique — Génie logiciel',
      studyLevel:      'Licence 3',
      role:            json['role'] as String? ?? 'etudiant',
      globalProgress:  0.0,
      coursesSuivis:   0,
      quizReussis:     0,
      classement:      json['rang'] as int? ?? 0,
      pointsXP:        json['scoretotal'] as int? ?? 0,
    );
  }

  // Données fictives
  static ProfileModel mock() {
    return ProfileModel(
      id:              '00000000',
      firstName:       'Zakaria',
      lastName:        'Laadj',
      email:           'zakaria.laadj@gmail.com',
      studentId:       '2024-004872',
      enrollmentDate:  '09/15/2024',
      speciality:      'Informatique — Génie logiciel',
      studyLevel:      'Licence 3',
      role:            'etudiant',
      globalProgress:  0.65,
      coursesSuivis:   12,
      quizReussis:     38,
      classement:      4,
      pointsXP:        2420,
      isFrench:        true,
      soundEffects:    true,
    );
  }
}
