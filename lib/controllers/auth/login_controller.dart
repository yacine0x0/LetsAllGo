// lib/controllers/auth/login_controller.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/auth/login_model.dart';
import '../../service/auth/LoginService.dart';
import '../../service/progress/progress_service.dart';
import '../../service/app_logger.dart';

class AuthData {
  final String token;
  final String userId;
  final String nom;
  final String prenom;
  final String role;

  AuthData({
    required this.token,
    required this.userId,
    required this.nom,
    required this.prenom,
    required this.role,
  });
}

class LoginController {
  // ✅ URL dynamique selon la plateforme
  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost:3000/api/auth';
    if (Platform.isAndroid) return 'http://10.0.2.2:3000/api/auth';
    return 'http://localhost:3000/api/auth'; // Windows / iOS / Desktop
  }

  static AuthData? currentUser;

  Future<String?> login(String email, String password) async {
    final model = LoginModel(email: email.trim(), password: password);
    final error = model.validate();
    if (error != null) return error;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email':    email.trim(),
          'password': password,
        }),
      );

      AppLogger.d('login status: ${response.statusCode}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final role = data['role'] as String? ?? 'etudiant';

        currentUser = AuthData(
          token:  data['token'],
          userId: data['userId'].toString(),
          nom:    data['nom'],
          prenom: data['prenom'],
          role:   role,
        );

        LoginService.saveToken(data['token']);
        LoginService.saveUser(
          userId: data['userId'].toString(),
          nom:    data['nom'],
          prenom: data['prenom'],
          role:   role,
        );

        // ✅ Charger la progression après connexion
        if (role == 'etudiant') {
          await ProgressService.loadProgress();
          AppLogger.d('progress loaded after login');
        }

        AppLogger.d('user logged: ${currentUser?.prenom} ${currentUser?.nom} [$role]');
        return null;
      } else {
        return data['message'] ?? 'Identifiants incorrects';
      }
    } catch (e) {
      AppLogger.e('login error', error: e);
      return 'Impossible de contacter le serveur';
    }
  }

  Future<void> logout() async {
    try {
      currentUser = null;
      ProgressService.reset();

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      AppLogger.d('logout ok');
    } catch (e) {
      AppLogger.e('logout error', error: e);
      rethrow;
    }
  }
}