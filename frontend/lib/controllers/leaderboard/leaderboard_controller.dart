import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/leaderboard/leaderboard_model.dart';
import '../../service/LoginService.dart';

class LeaderboardController {
  static const String _baseUrl = 'http://localhost:3000/api';

  LeaderboardModel _model = LeaderboardModel(entries: []);
  LeaderboardModel get model => _model;

  Future<void> loadLeaderboard() async {
    final token = LoginService.getToken();

    // Pas de token → mock
    if (token == null) {
      print('❌ Pas de token → mock');
      _model = LeaderboardModel.mock();
      return;
    }

    try {
      print('🔄 Chargement leaderboard...');

      final response = await http.get(
        Uri.parse('$_baseUrl/leaderboard'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('✅ Status: ${response.statusCode}');
      print('✅ Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // ✅ Vraies données depuis la BDD
        final List<dynamic> entriesJson = data['data']['entries'];
        final entries = entriesJson
            .map((e) => LeaderboardEntry.fromJson(e))
            .toList();

        // Utilisateur connecté
        final currentUserJson = data['data']['currentUser'];
        final currentUser = currentUserJson != null
            ? LeaderboardEntry.fromJson(currentUserJson)
            : null;

        _model = LeaderboardModel(entries: entries, currentUser: currentUser);
        print('✅ Leaderboard chargé: ${entries.length} entrées');
      } else {
        print('❌ Erreur backend → mock');
        _model = LeaderboardModel.mock();
      }
    } catch (e) {
      print('❌ ERREUR réseau: $e');
      _model = LeaderboardModel.mock();
    }
  }

  static Color medalColor(int rank) {
    switch (rank) {
      case 1: return const Color(0xFFFFD700);
      case 2: return const Color(0xFFC0C0C0);
      case 3: return const Color(0xFFCD7F32);
      default: return const Color(0xFF607D8B);
    }
  }

  static String medalEmoji(int rank) {
    switch (rank) {
      case 1: return '🥇';
      case 2: return '🥈';
      case 3: return '🥉';
      default: return '';
    }
  }
}
