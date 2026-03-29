// ─────────────────────────────────────────
// MODEL : profile_model.dart
// lib/models/profile/profile_model.dart
// ─────────────────────────────────────────

class ProfileModel {
  final String firstName;
  final String lastName;
  final String email;
  final String studentId;
  final String enrollmentDate;
  final String speciality;
  final String studyLevel;
  final String role;
  final double globalProgress;
  final int coursesSuivis;
  final int quizReussis;
  final int classement;
  final int pointsXP;

  // ── Paramètres
  bool isFrench;       // true = français, false = anglais
  bool soundEffects;   // true = activé

  ProfileModel({
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

  // ── Données fictives — remplace par un appel BDD dans le controller
  static ProfileModel mock() {
    return ProfileModel(
      firstName: "Zakaria",
      lastName: "Laadj",
      email: "zakaria.laadj@gmail.com",
      studentId: "2024-004872",
      enrollmentDate: "09/15/2024",
      speciality: "Informatique — Génie logiciel",
      studyLevel: "Licence 3",
      role: "Étudiant",
      globalProgress: 0.65,
      coursesSuivis: 12,
      quizReussis: 38,
      classement: 4,
      pointsXP: 2420,
      isFrench: true,
      soundEffects: true,
    );
  }
}