import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl = 'http://localhost:3000/api/auth';

  // ── POST /api/auth/register
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
        return null; // success
      } else {
        return data['message'] ?? 'Erreur lors de l\'inscription';
      }
    } catch (e) {
      return 'Impossible de contacter le serveur';
    }
  }

  // ── POST /api/auth/verify-email
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
        return null; // success
      } else {
        return data['message'] ?? 'Code invalide';
      }
    } catch (e) {
      return 'Impossible de contacter le serveur';
    }
  }
}