class ProfileModel {
  String firstName;
  String lastName;
  String email;
  String studentId;
  String enrollmentDate;
  String role;
  int pointsXP;
  int classement;
  int coursesSuivis;
  int quizReussis;
  double globalProgress;
  bool isFrench;
  bool soundEffects;
  int totalQuestionsCorrectes;

  ProfileModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.studentId,
    required this.enrollmentDate,
    required this.role,
    required this.pointsXP,
    required this.classement,
    required this.coursesSuivis,
    required this.quizReussis,
    required this.globalProgress,
    this.isFrench = true,
    this.soundEffects = true,
    this.totalQuestionsCorrectes = 0,
  });

  // copyWith
  ProfileModel copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? studentId,
    String? enrollmentDate,
    String? role,
    int? pointsXP,
    int? classement,
    int? coursesSuivis,
    int? quizReussis,
    double? globalProgress,
    bool? isFrench,
    bool? soundEffects,
    int? totalQuestionsCorrectes,
  }) {
    return ProfileModel(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      studentId: studentId ?? this.studentId,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      role: role ?? this.role,
      pointsXP: pointsXP ?? this.pointsXP,
      classement: classement ?? this.classement,
      coursesSuivis: coursesSuivis ?? this.coursesSuivis,
      quizReussis: quizReussis ?? this.quizReussis,
      globalProgress: globalProgress ?? this.globalProgress,
      isFrench: isFrench ?? this.isFrench,
      soundEffects: soundEffects ?? this.soundEffects,
      totalQuestionsCorrectes:
          totalQuestionsCorrectes ?? this.totalQuestionsCorrectes,
    );
  }

  // Depuis l'API
  factory ProfileModel.fromApi(Map<String, dynamic> json) {
    print('📦 API PROFILE DATA: $json');

    final dateRaw = json['dateinscription']?.toString() ?? '';
    final date = dateRaw.length >= 10
        ? dateRaw.substring(0, 10)
        : '—';

    final xp = (json['scoretotal'] ?? 0) as int;
    final rank = (json['rang'] ?? 0) as int;
    final quizzes = (json['quizReussis'] ?? 0) as int;
    final totalCorrect =
        (json['totalQuestionsCorrectes'] ?? quizzes) as int;

    final courses = (json['coursesSuivis'] ?? 0) as int;

    final progress =
        courses > 0 ? (courses / 10).clamp(0.0, 1.0) : 0.0;

    return ProfileModel(
      firstName: json['prenom'] ?? '',
      lastName: json['nom'] ?? '',
      email: json['email'] ?? '',
      studentId: (json['id'] ?? '')
          .toString()
          .substring(0, 8)
          .toUpperCase(),
      enrollmentDate: date,
      role: json['role'] ?? 'etudiant',

      // stats backend
      pointsXP: xp,
      classement: rank,
      quizReussis: quizzes,
      totalQuestionsCorrectes: totalCorrect,

      // fallback intelligent
      coursesSuivis: courses,
      globalProgress: progress,
    );
  }
static ProfileModel mock() => ProfileModel(
  firstName: 'Mohamed Ali',
  lastName: 'Lebsir',
  email: 'med@example.com',
  studentId: '20241001',
  enrollmentDate: '2024-09-01',
  role: 'etudiant',
  pointsXP: 1250,
  classement: 42,
  coursesSuivis: 8,
  quizReussis: 15,
  globalProgress: 0.65,
  totalQuestionsCorrectes: 245,
);
}