// models/admin_models/analytics_model.dart

class ChapterStat {
  final String label;
  final double algo1Completion; // pourcentage 0.0 → 1.0
  final double algo2Completion;

  const ChapterStat({
    required this.label,
    required this.algo1Completion,
    required this.algo2Completion,
  });
}

class QuizStat {
  final String day;
  final int quizzesDone;

  const QuizStat({required this.day, required this.quizzesDone});
}

class AnalyticsModel {
  final List<ChapterStat> chapters;
  final List<QuizStat> quizStats;
  final int totalQuizzesDone;

  /// 0 = Algo 1, 1 = Algo 2
  int selectedAlgo;

  AnalyticsModel({
    required this.chapters,
    required this.quizStats,
    required this.totalQuizzesDone,
    this.selectedAlgo = 0,
  });

  /// Renvoie les taux de complétion pour l'algo sélectionné
  List<double> get currentCompletions {
  return displayedChapters.map((c) {
    return selectedAlgo == 0
        ? c.algo1Completion
        : c.algo2Completion;
  }).toList();
}

      List<ChapterStat> get displayedChapters {
  if (selectedAlgo == 0) {
    return chapters; // Algo 1 → tous les chapitres
  } else {
    return chapters.take(4).toList(); // Algo 2 → seulement 4
  }
}
}