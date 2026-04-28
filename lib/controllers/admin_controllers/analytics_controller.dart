import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/admin_models/analytics_model.dart';
import '../../service/auth/LoginService.dart';

class AnalyticsController {
  static const String _baseUrl = 'http://localhost:3000/api';

  AnalyticsModel model = AnalyticsModel(
    totalQuizzesDone: 0,
    chapters:         [],
    quizStats:        [],
  );

  bool isLoading = false;

  Future<void> loadAnalytics() async {
    isLoading = true; // ✅ FIX 1 : avant le check token

    try {
      final token = LoginService.getToken();

      if (token == null) {
        print('❌ Token manquant');
        return;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/admin/analytics'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final d = data['data'];

        final algo1 = (d['algo1Chapters'] as List)
            .map((e) => ChapterStat(
                  label:           e['label'] as String,
                  algo1Completion: (e['completion'] as num).toDouble(),
                  algo2Completion: 0.0,
                ))
            .toList();

        final algo2 = (d['algo2Chapters'] as List)
            .map((e) => ChapterStat(
                  label:           e['label'] as String,
                  algo1Completion: 0.0,
                  algo2Completion: (e['completion'] as num).toDouble(),
                ))
            .toList();

        // ✅ FIX 2 : fusion par label, pas par index
        final allLabels = {
          ...algo1.map((e) => e.label),
          ...algo2.map((e) => e.label),
        };

        final merged = allLabels.map((label) {
          final a1 = algo1.firstWhere(
            (e) => e.label == label,
            orElse: () => ChapterStat(label: label, algo1Completion: 0.0, algo2Completion: 0.0),
          );
          final a2 = algo2.firstWhere(
            (e) => e.label == label,
            orElse: () => ChapterStat(label: label, algo1Completion: 0.0, algo2Completion: 0.0),
          );
          return ChapterStat(
            label:           label,
            algo1Completion: a1.algo1Completion,
            algo2Completion: a2.algo2Completion,
          );
        }).toList();

        final quizStats = (d['quizStats'] as List)
            .map((e) => QuizStat.fromApi(e))
            .toList();

        model = AnalyticsModel(
          totalQuizzesDone: (d['totalQuizzesDone'] as num).toInt(), // ✅ FIX 3 : cast sûr
          chapters:         merged,
          quizStats:        quizStats,
          selectedAlgo:     model.selectedAlgo,
        );
      } else {
        print('❌ Erreur API: ${data['message']}');
      }
    } catch (e) {
      print('❌ Erreur analytics: $e');
    } finally {
      isLoading = false; // ✅ FIX 4 : finally garantit le reset même en cas d'erreur
    }
  }

  void selectAlgo(int index) => model.selectedAlgo = index;
}