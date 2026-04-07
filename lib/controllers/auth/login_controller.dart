import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';   // ← Ajout important

import '../../../models/auth/login_model.dart';
import '../../service/LoginService.dart';

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
        final role = data['role'] as String? ?? 'etudiant';

        currentUser = AuthData(
          token: data['token'],
          userId: data['userId'].toString(),
          nom: data['nom'],
          prenom: data['prenom'],
          role: role,
        );

        // Sauvegarde via LoginService (gardé comme avant)
        LoginService.saveToken(data['token']);
        LoginService.saveUser(
          userId: data['userId'].toString(),
          nom: data['nom'],
          prenom: data['prenom'],
          role: role,
        );

        print('✅ Utilisateur connecté: ${currentUser?.prenom} ${currentUser?.nom} [$role]');
        return null;
      } else {
        return data['message'] ?? 'Identifiants incorrects';
      }
    } catch (e) {
      print('❌ ERREUR: $e');
      return 'Impossible de contacter le serveur';
    }
  }

  /// ✅ MÉTHODE LOGOUT CORRIGÉE
  Future<void> logout() async {
    try {
      // 1. Nettoyer la variable statique
      currentUser = null;

      // 2. Nettoyer le stockage local (SharedPreferences)
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();                    // Supprime tout (le plus simple et sûr pour logout)

      // Alternative si vous voulez supprimer seulement certaines clés :
      // await prefs.remove('token');
      // await prefs.remove('userId');
      // await prefs.remove('nom');
      // await prefs.remove('prenom');
      // await prefs.remove('role');

      print('✅ Logout réussi - toutes les données locales ont été supprimées');
    } catch (e) {
      print('❌ Erreur lors du logout: $e');
      rethrow;
    }
  }
}