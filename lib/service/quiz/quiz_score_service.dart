import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth/LoginService.dart';

class QuizScoreService {
  static const String _baseUrl = 'http://localhost:3000/api';

  static const Map<String, String> _algo1ChapterMap = {
    'Chapitre 01': 'Introduction à l\'algorithmique',
    'Chapitre 02': 'Conditions',
    'Chapitre 03': 'Boucles',
    'Chapitre 04': 'Structures de données – Vecteurs et Matrices',
    'Chapitre 05': 'Sous-programmes (Fonctions et Procédures)',
  };

  static const Map<String, String> _algo2ChapterMap = {
    'Chapitre 01': 'Tri et algorithmes de tri',
    'Chapitre 02': 'Recherche',
    'Chapitre 03': 'Récursivité avancée',
    'Chapitre 04': 'Listes chaînées',
    'Chapitre 05': 'Piles et Files',
  };

  static Future<int?> submitScore({
    required int    correctAnswers,
    required String algoType,
    String?         quizId,
    String?         chapterName,
    int?            totalQuestions, // ✅ nouveau
    String?         intensity,      // ✅ nouveau
  }) async {
    final token = LoginService.getToken();
    if (token == null) return null;

    // ✅ Mapper le nom
    String? mappedChapter;
    if (chapterName != null) {
      final map = algoType == 'algo2' ? _algo2ChapterMap : _algo1ChapterMap;
      mappedChapter = map[chapterName] ?? chapterName;
      print('📌 Chapter: "$chapterName" → "$mappedChapter"');
    }

    try {
      final body = {
        'correctAnswers': correctAnswers,
        'algoType':       algoType,
        if (quizId        != null) 'quizId':         quizId,
        if (mappedChapter != null) 'chapterName':     mappedChapter,
        if (totalQuestions != null) 'totalQuestions': totalQuestions,
        if (intensity     != null) 'intensity':      intensity,
      };

      print('📤 Envoi quiz: $body');

      final response = await http.post(
        Uri.parse('$_baseUrl/quiz/submit'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('📡 Response: ${response.statusCode} ${response.body}');

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return (data['pointsGagnes'] as num?)?.toInt() ?? 0;
      }
      print('❌ submitScore: ${data['message']}');
      return null;
    } catch (e) {
      print('❌ QuizScoreService.submitScore: $e');
      return null;
    }
  }

  static Future<bool> completeChapter({required String chapterId}) async {
    final token = LoginService.getToken();
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/courses/complete'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({ 'chapterId': chapterId }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && data['success'] == true) return true;
      print('❌ completeChapter: ${data['message']}');
      return false;
    } catch (e) {
      print('❌ QuizScoreService.completeChapter: $e');
      return false;
    }
  }
}