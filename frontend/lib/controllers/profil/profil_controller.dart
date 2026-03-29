// ─────────────────────────────────────────
// CONTROLLER : profile_controller.dart
// lib/controllers/profile/profile_controller.dart
// ─────────────────────────────────────────
import '../../models/profil/profil_model.dart';


class ProfileController {
  ProfileModel _model = ProfileModel.mock();

  ProfileModel get model => _model;

  // ══════════════════════════════════════════════════════════════
  // CHARGEMENT — appelle dans initState()
  // ══════════════════════════════════════════════════════════════
  Future<void> loadProfile() async {
    // ── DÉVELOPPEMENT : données fictives
    _model = ProfileModel.mock();

    // ── PRODUCTION (BDD) : décommente et adapte
    //
    // Option A — API REST :
    // final response = await http.get(Uri.parse('https://ton-api.com/profile'));
    // if (response.statusCode == 200) {
    //   final json = jsonDecode(response.body);
    //   _model = ProfileModel(
    //     firstName:      json['first_name'],
    //     lastName:       json['last_name'],
    //     email:          json['email'],
    //     studentId:      json['student_id'],
    //     enrollmentDate: json['enrollment_date'],
    //     speciality:     json['speciality'],
    //     studyLevel:     json['study_level'],
    //     role:           json['role'],
    //     globalProgress: json['global_progress'],
    //     coursesSuivis:  json['courses_suivis'],
    //     quizReussis:    json['quiz_reussis'],
    //     classement:     json['classement'],
    //     pointsXP:       json['points_xp'],
    //   );
    // }
    //
    // Option B — SQLite :
    // final db = await openDatabase('app.db');
    // final rows = await db.query('users', where: 'id = ?', whereArgs: [userId]);
    // if (rows.isNotEmpty) { _model = ProfileModel(...rows.first); }
  }

  // ── Toggle langue
  void toggleLanguage() {
    _model.isFrench = !_model.isFrench;
  }

  // ── Toggle son
  void toggleSound() {
    _model.soundEffects = !_model.soundEffects;
  }

  // ── Textes traduits selon la langue active
  String t(String fr, String en) => _model.isFrench ? fr : en;
}