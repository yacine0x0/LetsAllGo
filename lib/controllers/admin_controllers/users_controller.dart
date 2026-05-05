import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/admin_models/users_model.dart';
import '../../service/auth/LoginService.dart';

class AdminController {
  static const String _baseUrl = 'http://localhost:3000/api';

  UsersModel _model = UsersModel(users: []);
  UsersModel get model => _model;

  bool isLoading = false;

  // ── Charger les étudiants depuis la BDD
  Future<void> loadUsers() async {
    final token = LoginService.getToken();
    if (token == null) return;

    isLoading = true;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List<dynamic> list = data['data'];
        _model = UsersModel(
          users: list.map((e) => UserItem.fromApi(e)).toList(),
        );
        print('✅ ${_model.users.length} étudiants chargés');
      }
    } catch (e) {
      print('❌ Erreur chargement users: $e');
    }

    isLoading = false;
  }

  // ── Supprimer un étudiant depuis la BDD
  Future<String?> deleteUser(String userId) async {
    final token = LoginService.getToken();
    if (token == null) return 'Non connecté';

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/admin/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Supprimer localement aussi
        _model.users.removeWhere((u) => u.id == userId);
        // Recalculer les rangs
        for (int i = 0; i < _model.users.length; i++) {
          _model.users[i] = UserItem(
            id:          _model.users[i].id,
            rank:        i + 1,
            firstName:   _model.users[i].firstName,
            lastName:    _model.users[i].lastName,
            email:       _model.users[i].email,
            totalPoints: _model.users[i].totalPoints,
            isBlocked:   _model.users[i].isBlocked,
          );
        }
        return null; // ✅ succès
      }

      return data['message'] ?? 'Erreur suppression';
    } catch (e) {
      return 'Impossible de contacter le serveur';
    }
  }

  // ── Recherche locale
  void search(String query) {
    _model.searchQuery = query;
  }

  // ── Toggle block (local uniquement pour l'instant)
  Future<String?> toggleBlock(String userId) async {
    final token = LoginService.getToken();
    if (token == null) return 'Non connecté';

    final index = _model.users.indexWhere((u) => u.id == userId);
    if (index == -1) return 'Utilisateur introuvable';

    final shouldBlock = !_model.users[index].isBlocked;
    final endpoint = shouldBlock ? 'block' : 'unblock';

    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/admin/users/$userId/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _model.users[index].isBlocked = shouldBlock;
        return null;
      }
      return data['message'] ?? 'Erreur lors de la mise a jour';
    } catch (_) {
      return 'Impossible de contacter le serveur';
    }
  }
}