// lib/controllers/admin_controllers/analytics_controller.dart
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
    isLoading = true;

    try {
      final token = LoginService.getToken();
      if (token == null) {
        print('❌ Token null');
        return;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/admin/analytics'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // ✅ Debug complet
      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final d = data['data'];

        // ✅ Debug champs quiz
        print('quizStatsAlgo1: ${d['quizStatsAlgo1']}');
        print('quizStatsAlgo2: ${d['quizStatsAlgo2']}');
        print('algo1Chapters:  ${d['algo1Chapters']}');
        print('algo2Chapters:  ${d['algo2Chapters']}');

        final algo1 = (d['algo1Chapters'] as List)
            .map((e) => ChapterStat.fromApi(e))
            .toList();

        final algo2 = (d['algo2Chapters'] as List)
            .map((e) => ChapterStat.fromApiAlgo2(e))
            .toList();

        final quizStatsAlgo1 = (d['quizStatsAlgo1'] as List)
            .map((e) => QuizStat.fromApi(e))
            .toList();

        final quizStatsAlgo2 = (d['quizStatsAlgo2'] as List)
            .map((e) => QuizStat.fromApi(e))
            .toList();

        print(' quizStatsAlgo1 parsed: ${quizStatsAlgo1.length} items');
        print(' quizStatsAlgo2 parsed: ${quizStatsAlgo2.length} items');

        model = AnalyticsModel(
          totalQuizzesDone: (d['totalQuizzesDone'] as num).toInt(),
          chapters:         algo1,
          algo1Chapters:    algo1,
          algo2Chapters:    algo2,
          quizStats:        quizStatsAlgo1,
          quizStatsAlgo1:   quizStatsAlgo1,
          quizStatsAlgo2:   quizStatsAlgo2,
          selectedAlgo:     model.selectedAlgo,
          selectedQuizAlgo: model.selectedQuizAlgo,
        );
      } else {
        print(' Erreur API: ${data['message']}');
      }
    } catch (e, stack) {
      print(' Erreur analytics: $e');
      print(' Stack: $stack');
    } finally {
      isLoading = false;
    }
  }

  void selectAlgo(int index)     => model.selectedAlgo     = index;
  void selectQuizAlgo(int index) => model.selectedQuizAlgo = index;
}