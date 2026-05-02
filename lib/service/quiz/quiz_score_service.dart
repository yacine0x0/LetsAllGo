// lib/service/quiz/quiz_score_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth/LoginService.dart';

class QuizScoreService {
  static const String _baseUrl = 'http://localhost:3000/api';

  static Future<int?> submitScore({
    required int    correctAnswers,
    required String algoType,
    String?         chapterName,
    int?            totalQuestions,
    String?         intensity,
  }) async {
    final token = LoginService.getToken();
    if (token == null) return null;

    try {
      final body = {
        'correctAnswers': correctAnswers,
        'algoType':       algoType,
        // ✅ On envoie "Chapitre 01" directement, le serveur fait le mapping
        if (chapterName    != null) 'chapterName':    chapterName,
        if (totalQuestions != null) 'totalQuestions': totalQuestions,
        if (intensity      != null) 'intensity':      intensity,
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
        body: jsonEncode({'chapterId': chapterId}),
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