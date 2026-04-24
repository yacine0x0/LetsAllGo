import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/profil/profil_model.dart';
import '../../service/auth/LoginService.dart';
import '../auth/login_controller.dart';

class ProfileController {
  static const String _baseUrl = 'http://localhost:3000/api';

  ProfileModel _model = ProfileModel.mock();
  ProfileModel get model => _model;

  Future<void> loadProfile() async {
    final token = LoginService.getToken();
    if (token == null) {
      _model = ProfileModel.mock();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['success'] == true) {
        final userData = body['data'];
        if (userData != null) {
          _model = ProfileModel.fromApi(userData as Map<String, dynamic>);
        }
      }
    } catch (e) {
      // garde le mock en cas d'erreur
    }
  }

  Future<String?> updateName({
    required String newFirstName,
    required String newLastName,
  }) async {
    final token = LoginService.getToken();
    if (token == null) return 'Non authentifié';

    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'prenom': newFirstName.trim(),
          'nom':    newLastName.trim(),
        }),
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        // 1. Met à jour le modèle local
        _model = _model.copyWith(
          firstName: newFirstName.trim(),
          lastName:  newLastName.trim(),
        );

        // 2. Met à jour LoginService — utilisé par toute l'app
        LoginService.saveUser(
          userId: LoginService.getUserId() ?? '',
          nom:    newLastName.trim(),
          prenom: newFirstName.trim(),
          role:   LoginService.getRole() ?? 'etudiant',
        );

        // 3. Met à jour LoginController.currentUser — utilisé par navbar/dashboard
        if (LoginController.currentUser != null) {
          LoginController.currentUser = AuthData(
            token:  LoginController.currentUser!.token,
            userId: LoginController.currentUser!.userId,
            nom:    newLastName.trim(),
            prenom: newFirstName.trim(),
            role:   LoginController.currentUser!.role,
          );
        }

        return null;
      }
      return data['message'] as String? ?? 'Erreur lors de la mise à jour';
    } catch (e) {
      return 'Erreur réseau : $e';
    }
  }

  Future<String?> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final token = LoginService.getToken();
    if (token == null) return 'Non authentifié';

    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/users/me/password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && data['success'] == true) return null;
      return data['message'] as String? ?? 'Erreur mot de passe';
    } catch (e) {
      return 'Erreur réseau : $e';
    }
  }

  Future<String?> requestEmailChange({required String newEmail}) async {
    final token = LoginService.getToken();
    if (token == null) return 'Non authentifié';

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users/me/email/request'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'newEmail': newEmail.trim()}),
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && data['success'] == true) return null;
      return data['message'] as String? ?? "Erreur envoi code";
    } catch (e) {
      return 'Erreur réseau : $e';
    }
  }

  Future<String?> confirmEmailChange({
    required String newEmail,
    required String otp,
  }) async {
    final token = LoginService.getToken();
    if (token == null) return 'Non authentifié';

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users/me/email/confirm'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'newEmail': newEmail.trim(),
          'code':     otp.trim(),
        }),
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && data['success'] == true) {
        // Met à jour partout
        _model = _model.copyWith(email: newEmail.trim());
        LoginService.saveUser(
          userId: LoginService.getUserId() ?? '',
          nom:    LoginService.getNom()    ?? '',
          prenom: LoginService.getPrenom() ?? '',
          role:   LoginService.getRole()   ?? 'etudiant',
        );
        return null;
      }
      return data['message'] as String? ?? 'Code invalide';
    } catch (e) {
      return 'Erreur réseau : $e';
    }
  }

  void toggleLanguage() => _model.isFrench = !_model.isFrench;
  void toggleSound()    => _model.soundEffects = !_model.soundEffects;
  String t(String fr, String en) => _model.isFrench ? fr : en;
}