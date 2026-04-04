class ProfileModel {
  final String id;
  final String firstName;
  final String lastName;
  String email;
  final String studentId;
  final String enrollmentDate;
  final String role;
  final double globalProgress;
  final int coursesSuivis;
  final int quizReussis;
  final int classement;
  final int pointsXP;
  bool isFrench;
  bool soundEffects;

  ProfileModel({
    this.id = '',
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.studentId,
    required this.enrollmentDate,
    required this.role,
    required this.globalProgress,
    required this.coursesSuivis,
    required this.quizReussis,
    required this.classement,
    required this.pointsXP,
    this.isFrench = true,
    this.soundEffects = true,
  });

  factory ProfileModel.fromApi(Map<String, dynamic> json) {
    final dateRaw = (json['dateinscription'] as String?) ?? '';
    final date = dateRaw.length >= 10 ? dateRaw.substring(0, 10) : '—';
    final rawId = json['id']?.toString() ?? '';
    final shortId = rawId.replaceAll('-', '').substring(0, 8).toUpperCase();

    return ProfileModel(
      id:             rawId,
      firstName:      json['prenom']?.toString() ?? '',
      lastName:       json['nom']?.toString() ?? '',
      email:          json['email']?.toString() ?? '',
      studentId:      shortId,
      enrollmentDate: date,
      role:           json['role']?.toString() ?? 'etudiant',
      globalProgress: 0.0,
      coursesSuivis:  0,
      quizReussis:    0,
      classement:     (json['rang'] as num?)?.toInt() ?? 0,
      pointsXP:       (json['scoretotal'] as num?)?.toInt() ?? 0,
    );
  }

  static ProfileModel mock() => ProfileModel(
    id:             '00000000',
    firstName:      'Utilisateur',
    lastName:       '',
    email:          '',
    studentId:      '00000000',
    enrollmentDate: '—',
    role:           'etudiant',
    globalProgress: 0.0,
    coursesSuivis:  0,
    quizReussis:    0,
    classement:     0,
    pointsXP:       0,
  );

  ProfileModel copyWith({String? firstName, String? lastName, String? email}) {
    return ProfileModel(
      id:             id,
      firstName:      firstName      ?? this.firstName,
      lastName:       lastName       ?? this.lastName,
      email:          email          ?? this.email,
      studentId:      studentId,
      enrollmentDate: enrollmentDate,
      role:           role,
      globalProgress: globalProgress,
      coursesSuivis:  coursesSuivis,
      quizReussis:    quizReussis,
      classement:     classement,
      pointsXP:       pointsXP,
      isFrench:       isFrench,
      soundEffects:   soundEffects,
    );
  }
}