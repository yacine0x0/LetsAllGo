import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/admin_models/profil_admin_model.dart';
import '../../service/LoginService.dart';

class ProfileController {
  static const String _baseUrl = 'http://localhost:3000/api';

  AdminProfilModel _model = AdminProfilModel.mock();
  AdminProfilModel get model => _model;

  // ── Charger les infos admin depuis la BDD
  Future<void> loadProfile() async {
    final token = LoginService.getToken();
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _model = AdminProfilModel.fromApi(data['data']);
        print(' Admin chargé: ${_model.firstName} ${_model.lastName}');
      }
    } catch (e) {
      print(' Erreur: $e');
    }
  }

  void toggleDarkMode(bool value) => _model.isDarkMode = value;
  void updateLanguage(String lang) => _model.language = lang;
}