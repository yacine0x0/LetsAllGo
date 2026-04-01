// ─────────────────────────────────────────
// SERVICE : LoginService.dart
// lib/service/LoginService.dart
// ─────────────────────────────────────────

class LoginService {
  static String? _token;
  static String? _userId;
  static String? _nom;
  static String? _prenom;
  static String? _role;

  // ── Sauvegarde du token
  static void saveToken(String token) {
    _token = token;
  }

  // ── 🆕 Sauvegarde des infos utilisateur
  static void saveUser({
    required String userId,
    required String nom,
    required String prenom,
    required String role,
  }) {
    _userId = userId;
    _nom    = nom;
    _prenom = prenom;
    _role   = role;
  }

  // ── Getters
  static String? getToken()  => _token;
  static String? getUserId() => _userId;
  static String? getNom()    => _nom;
  static String? getPrenom() => _prenom;
  static String? getRole()   => _role;

  // ── Nom complet
  static String getFullName() {
    if (_prenom == null && _nom == null) return "Utilisateur";
    return "${_prenom ?? ''} ${_nom ?? ''}".trim();
  }

  // ── Logout — tout effacer
  static void logout() {
    _token  = null;
    _userId = null;
    _nom    = null;
    _prenom = null;
    _role   = null;
  }
}