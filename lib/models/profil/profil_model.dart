// lib/models/profil/profil_model.dart
import '../../service/progress/progress_service.dart';

class ProfileModel {
  String firstName;
  String lastName;
  String email;
  String studentId;
  String enrollmentDate;
  String role;
  int    pointsXP;
  int    classement;
  int    coursesSuivis;
  int    quizReussis;
  double globalProgress;
  bool   isFrench;
  bool   soundEffects;
  int    totalQuestionsCorrectes;

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
    this.isFrench    = true,
    this.soundEffects = true,
    this.totalQuestionsCorrectes = 0,
  });

  ProfileModel copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? studentId,
    String? enrollmentDate,
    String? role,
    int?    pointsXP,
    int?    classement,
    int?    coursesSuivis,
    int?    quizReussis,
    double? globalProgress,
    bool?   isFrench,
    bool?   soundEffects,
    int?    totalQuestionsCorrectes,
  }) {
    return ProfileModel(
      firstName:               firstName               ?? this.firstName,
      lastName:                lastName                ?? this.lastName,
      email:                   email                   ?? this.email,
      studentId:               studentId               ?? this.studentId,
      enrollmentDate:          enrollmentDate          ?? this.enrollmentDate,
      role:                    role                    ?? this.role,
      pointsXP:                pointsXP                ?? this.pointsXP,
      classement:              classement              ?? this.classement,
      coursesSuivis:           coursesSuivis           ?? this.coursesSuivis,
      quizReussis:             quizReussis             ?? this.quizReussis,
      globalProgress:          globalProgress          ?? this.globalProgress,
      isFrench:                isFrench                ?? this.isFrench,
      soundEffects:            soundEffects            ?? this.soundEffects,
      totalQuestionsCorrectes: totalQuestionsCorrectes ?? this.totalQuestionsCorrectes,
    );
  }

  // ✅ Depuis l'API — données réelles
  factory ProfileModel.fromApi(Map<String, dynamic> json) {
    print('📦 API PROFILE DATA: $json');

    // Date d'inscription
    final dateRaw = json['dateinscription']?.toString() ?? '';
    final date    = dateRaw.length >= 10 ? dateRaw.substring(0, 10) : '—';

    // Stats depuis l'API
    final xp      = (json['scoretotal'] as num?)?.toInt() ?? 0;
    final rank    = (json['rang']        as num?)?.toInt() ?? 0;
    final quizzes = (json['quizReussis'] as num?)?.toInt() ?? 0;
    final totalCorrect = (json['totalQuestionsCorrectes'] as num?)?.toInt() ?? quizzes;

    // ✅ Progression depuis ProgressService (déjà chargé au login)
    final globalProgress = ProgressService.getGlobalProgress();
    final algo1Progress  = ProgressService.getAlgo1Progress();
    final algo2Progress  = ProgressService.getAlgo2Progress();

    // ✅ Cours suivis = chapitres complétés réels
    final completedAlgo1 = (algo1Progress * 5).round();
    final completedAlgo2 = (algo2Progress * 4).round();
    final coursesSuivis  = completedAlgo1 + completedAlgo2;

    // ✅ studentId = 8 premiers chars de l'UUID en majuscules
    final rawId   = (json['id'] ?? '').toString();
    final studentId = rawId.length >= 8
        ? rawId.substring(0, 8).toUpperCase()
        : rawId.toUpperCase();

    return ProfileModel(
      firstName:               json['prenom'] ?? '',
      lastName:                json['nom']    ?? '',
      email:                   json['email']  ?? '',
      studentId:               studentId,
      enrollmentDate:          date,
      role:                    json['role']   ?? 'etudiant',
      pointsXP:                xp,
      classement:              rank,
      quizReussis:             quizzes,
      totalQuestionsCorrectes: totalCorrect,
      coursesSuivis:           coursesSuivis,
      globalProgress:          globalProgress,
    );
  }

  // ✅ Mock vide — utilisé seulement si pas de token
  static ProfileModel empty() => ProfileModel(
    firstName:               '—',
    lastName:                '—',
    email:                   '—',
    studentId:               '—',
    enrollmentDate:          '—',
    role:                    'etudiant',
    pointsXP:                0,
    classement:              0,
    coursesSuivis:           0,
    quizReussis:             0,
    globalProgress:          0.0,
    totalQuestionsCorrectes: 0,
  );
}