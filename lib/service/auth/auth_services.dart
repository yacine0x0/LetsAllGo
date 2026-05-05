import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../controllers/auth/login_controller.dart';
import '../progress/progress_service.dart';
import 'LoginService.dart';

class AuthService {
  static const String _baseUrl = 'http://localhost:3000/api/auth';

  static Future<String?> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nom':      lastName.trim(),
          'prenom':   firstName.trim(),
          'email':    email.trim(),
          'password': password,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return null;
      } else {
        return data['message'] ?? 'Erreur lors de l\'inscription';
      }
    } catch (e) {
      return 'Impossible de contacter le serveur';
    }
  }

  static Future<String?> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/verify-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'code':  code.trim(),
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        LoginService.saveToken(data['token']);
        LoginService.saveUser(
          userId: data['userId'].toString(),
          nom:    data['nom'],
          prenom: data['prenom'],
          role:   data['role'] ?? 'etudiant',
        );
        return null;
      } else {
        return data['message'] ?? 'Code invalide';
      }
    } catch (e) {
      return 'Impossible de contacter le serveur';
    }
  }
}