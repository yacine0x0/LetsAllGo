import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../models/auth/login_model.dart';
import '../../service/LoginService.dart'; // 🆕

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
  static const String _baseUrl = 'http://localhost:3000/api/auth';
  static AuthData? currentUser;

  Future<String?> login(String email, String password) async {
    final model = LoginModel(email: email.trim(), password: password);
    final error = model.validate();
    if (error != null) return error;

    try {
      print('🔄 Envoi requête vers $_baseUrl/login');

      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      );

      print('✅ Status: ${response.statusCode}');
      print('✅ Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // ── Sauvegarder dans AuthData (ton système existant)
        currentUser = AuthData(
          token:  data['token'],
          userId: data['userId'].toString(),
          nom:    data['nom'],
          prenom: data['prenom'],
          role:   data['role'] ?? 'etudiant',
        );

        // ── 🆕 Sauvegarder aussi dans AuthService pour ProfileController
        LoginService.saveToken(data['token']);
        LoginService.saveUser(
          userId: data['userId'].toString(),
          nom:    data['nom'],
          prenom: data['prenom'],
          role:   data['role'] ?? 'etudiant',
        );

        print('✅ Utilisateur connecté: ${currentUser?.prenom} ${currentUser?.nom}');
        return null; // ✅ succès
      } else {
        return data['message'] ?? 'Identifiants incorrects';
      }
    } catch (e) {
      print('❌ ERREUR: $e');
      return 'Impossible de contacter le serveur';
    }
  }
}