import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/profil/profil_model.dart'; 
import '../../service/LoginService.dart';

class ProfileController {
  static const String _baseUrl = 'http://localhost:3000/api';

  ProfileModel _model = ProfileModel.mock();
  ProfileModel get model => _model;

  Future<void> loadProfile() async {
    final token = LoginService.getToken();

    if (token == null) {
      print(' Pas de token → mock');
      _model = ProfileModel.mock();
      return;
    }

    try {
      print('🔄 Chargement profil depuis le backend...');

      final response = await http.get(
        Uri.parse('$_baseUrl/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('✅ Status: ${response.statusCode}');
      print('✅ Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _model = ProfileModel.fromApi(data['data']);
        print('✅ Profil chargé: ${_model.firstName} ${_model.lastName}');
      } else {
        print('❌ Erreur backend → mock');
        _model = ProfileModel.mock();
      }
    } catch (e) {
      print('❌ ERREUR réseau: $e');
      _model = ProfileModel.mock();
    }
  }

  void toggleLanguage() => _model.isFrench = !_model.isFrench;
  void toggleSound()    => _model.soundEffects = !_model.soundEffects;
  String t(String fr, String en) => _model.isFrench ? fr : en;
}