// lib/service/quiz_score_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'LoginService.dart';

class QuizScoreService {
  static const String _baseUrl = 'http://localhost:3000/api';

  /// [algoType] : 'algo1' ou 'algo2'
  /// Retourne les Go Points gagnés, ou null en cas d'erreur.
  static Future<int?> submitScore({
    required int correctAnswers,
    required String algoType,
  }) async {
    final token = LoginService.getToken();
    if (token == null) return null;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/quiz/submit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'correctAnswers': correctAnswers,
          'algoType':       algoType,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return (data['pointsGagnes'] as num?)?.toInt() ?? 0;
      }
      print('❌ submitScore: ${data['message']}');
      return null;
    } catch (e) {
      print('❌ QuizScoreService: $e');
      return null;
    }
  }
}