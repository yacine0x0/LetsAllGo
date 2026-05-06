// lib/controllers/profil/profil_controller.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/profil/profil_model.dart';
import '../../service/auth/LoginService.dart';
import '../auth/login_controller.dart';
import '../../service/app_logger.dart';

class ProfileController extends ChangeNotifier {
  static const String _soundEffectsPrefKey = 'profile_sound_effects';

  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost:3000/api';
    return 'http://localhost:3000/api';
  }

  ProfileModel _model = ProfileModel.empty();
  ProfileModel get model => _model;

  Map<String, dynamic> _safeJsonMap(String rawBody) {
    try {
      final decoded = jsonDecode(rawBody);
      if (decoded is Map<String, dynamic>) return decoded;
      return <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

Future<void> loadProfile() async {
  final prefs = await SharedPreferences.getInstance();
  final savedSoundEffects = prefs.getBool(_soundEffectsPrefKey);
  final token = LoginService.getToken();
  if (token == null) {
    AppLogger.d('profile: token missing');
    _model = ProfileModel.empty();
    if (savedSoundEffects != null) {
      _model.soundEffects = savedSoundEffects;
    }
    notifyListeners();
    return;
  }

  try {
    final response = await http.get(
      Uri.parse('$_baseUrl/users/me'),
      headers: {
        'Content-Type':  'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    AppLogger.d('profile load status: ${response.statusCode}');

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      // ✅ Gère les deux formats : {data: {...}} ou directement {...}
      final userData = (body.containsKey('data') && body['data'] is Map)
          ? body['data'] as Map<String, dynamic>
          : body;

      _model = ProfileModel.fromApi(userData);
      if (savedSoundEffects != null) {
        _model.soundEffects = savedSoundEffects;
      }
      AppLogger.d('profile loaded: ${_model.firstName} ${_model.lastName}');
      notifyListeners();
    } else {
      AppLogger.d('profile load http ${response.statusCode}');
      _model = ProfileModel.empty();
      if (savedSoundEffects != null) {
        _model.soundEffects = savedSoundEffects;
      }
      notifyListeners();
    }
  } catch (e) {
    AppLogger.e('profile load error', error: e);
    _model = ProfileModel.empty();
    if (savedSoundEffects != null) {
      _model.soundEffects = savedSoundEffects;
    }
    notifyListeners();
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
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'prenom': newFirstName.trim(),
          'nom':    newLastName.trim(),
        }),
      );
      final data = _safeJsonMap(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _model = _model.copyWith(
          firstName: newFirstName.trim(),
          lastName:  newLastName.trim(),
        );
        notifyListeners();

        LoginService.saveUser(
          userId: LoginService.getUserId() ?? '',
          nom:    newLastName.trim(),
          prenom: newFirstName.trim(),
          role:   LoginService.getRole() ?? 'etudiant',
        );

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
      return data['message'] as String? ??
          'Erreur lors de la mise à jour (HTTP ${response.statusCode})';
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
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );
      final data = _safeJsonMap(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) return null;
      return data['message'] as String? ??
          'Erreur mot de passe (HTTP ${response.statusCode})';
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
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'newEmail': newEmail.trim()}),
      );
      final data = _safeJsonMap(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) return null;
      return data['message'] as String? ??
          'Erreur envoi code (HTTP ${response.statusCode})';
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
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'newEmail': newEmail.trim(),
          'code':     otp.trim(),
        }),
      );
      final data = _safeJsonMap(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _model = _model.copyWith(email: newEmail.trim());
        notifyListeners();
        return null;
      }
      return data['message'] as String? ??
          'Code invalide (HTTP ${response.statusCode})';
    } catch (e) {
      return 'Erreur réseau : $e';
    }
  }

  void toggleLanguage() => _model.isFrench    = !_model.isFrench;
  void toggleSound() {
    _model.soundEffects = !_model.soundEffects;
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setBool(_soundEffectsPrefKey, _model.soundEffects),
    );
  }
  String t(String fr, String en) => _model.isFrench ? fr : en;
}