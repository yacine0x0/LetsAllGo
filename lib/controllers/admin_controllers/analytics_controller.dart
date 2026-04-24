// controllers/admin_controllers/analytics_controller.dart

import '../../models/admin_models/analytics_model.dart';

class AnalyticsController {
  late AnalyticsModel model;

  AnalyticsController() {
    model = AnalyticsModel(
      totalQuizzesDone: 569823,
      chapters: const [
        ChapterStat(
          label: "Chapitre 01",
          algo1Completion: 0.35,
          algo2Completion: 0.50,
        ),
        ChapterStat(
          label: "Chapitre 02",
          algo1Completion: 0.70,
          algo2Completion: 0.60,
        ),
        ChapterStat(
          label: "Chapitre 03",
          algo1Completion: 0.35,
          algo2Completion: 0.45,
        ),
        ChapterStat(
          label: "Chapitre 04",
          algo1Completion: 0.78,
          algo2Completion: 0.65,
        ),
        ChapterStat(
          label: "Chapitre 05",
          algo1Completion: 0.85,
          algo2Completion: 0.72,
        ),
      ],
      quizStats: const [
        QuizStat(day: "sunday", quizzesDone: 800),
        QuizStat(day: "monday", quizzesDone: 1200),
        QuizStat(day: "03", quizzesDone: 1500),
        QuizStat(day: "04", quizzesDone: 1800),
        QuizStat(day: "05", quizzesDone: 2100),
        QuizStat(day: "06", quizzesDone: 1900),
        QuizStat(day: "07", quizzesDone: 1700),
      ],
    );
  }

  /// Changer l'algo affiché dans le graphe des cours
  void selectAlgo(int index) {
    model.selectedAlgo = index;
  }
}
