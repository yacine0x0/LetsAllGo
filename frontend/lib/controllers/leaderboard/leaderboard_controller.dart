import 'package:flutter/material.dart'; 
 import '../../models/leaderboard/leaderboard_model.dart';
 
class LeaderboardController {
  LeaderboardModel _model = LeaderboardModel(entries: []);
 
  LeaderboardModel get model => _model;
 
  // ══════════════════════════════════════════════════════════════
  // INITIALISATION — appelle cette méthode dans initState() de la page
  // ══════════════════════════════════════════════════════════════
  Future<void> loadLeaderboard() async {
    // ── DÉVELOPPEMENT : données fictives
    _model = LeaderboardModel.mock();
 
    // ── PRODUCTION (BDD) : décommente et adapte selon ton backend
    //
    // Option A — API REST (HTTP) :
    // ─────────────────────────────
    // final response = await http.get(Uri.parse('https://ton-api.com/leaderboard'));
    // if (response.statusCode == 200) {
    //   final List<dynamic> jsonList = jsonDecode(response.body);
    //   final entries = jsonList.map((e) => LeaderboardEntry.fromJson(e)).toList();
    //   final currentUserJson = jsonDecode(response.body)['current_user'];
    //   final currentUser = LeaderboardEntry.fromJson(currentUserJson);
    //   _model = LeaderboardModel(entries: entries, currentUser: currentUser);
    // }
    //
    // Option B — SQLite local (sqflite) :
    // ─────────────────────────────────────
    // final db = await openDatabase('app.db');
    // final List<Map<String, dynamic>> rows = await db.query(
    //   'leaderboard',
    //   orderBy: 'total_points DESC',
    //   limit: 15,
    // );
    // final entries = rows.asMap().entries.map((e) {
    //   return LeaderboardEntry.fromJson({...e.value, 'rank': e.key + 1});
    // }).toList();
    // _model = LeaderboardModel(entries: entries);
    //
    // Option C — Firebase Firestore :
    // ─────────────────────────────────
    // final snapshot = await FirebaseFirestore.instance
    //     .collection('users')
    //     .orderBy('total_points', descending: true)
    //     .limit(15)
    //     .get();
    // final entries = snapshot.docs.asMap().entries.map((e) {
    //   return LeaderboardEntry.fromJson({...e.value.data(), 'rank': e.key + 1});
    // }).toList();
    // _model = LeaderboardModel(entries: entries);
  }
 
  // ── Couleur de la médaille selon le rang
  // Utilisée dans la view pour afficher or/argent/bronze
  static Color medalColor(int rank) {
    switch (rank) {
      case 1: return const Color(0xFFFFD700); // Or
      case 2: return const Color(0xFFC0C0C0); // Argent
      case 3: return const Color(0xFFCD7F32); // Bronze
      default: return const Color(0xFF607D8B); // Gris-bleu
    }
  }
 
  // ── Icône médaille selon le rang
  static String medalEmoji(int rank) {
    switch (rank) {
      case 1: return '🥇';
      case 2: return '🥈';
      case 3: return '🥉';
      default: return '';
    }
  }
}