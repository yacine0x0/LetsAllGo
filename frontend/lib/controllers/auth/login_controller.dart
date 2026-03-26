import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/auth/login_model.dart';

class LoginController {
  static const String _baseUrl = 'http://localhost:3000/api/auth';

  Future<String?> login(String email, String password) async {
    final model = LoginModel(
      email: email.trim(),
      password: password,
    );

    final error = model.validate();
    if (error != null) return error;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data['token'];
        print('TOKEN: $token');
        return null; // succès
      } else {
        return data['message'] ?? 'Erreur de connexion';
      }
    } catch (e) {
      return 'Impossible de contacter le serveur';
    }
  }
}