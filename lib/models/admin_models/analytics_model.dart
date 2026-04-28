class ChapterStat {
  final String label;
  final double algo1Completion;
  final double algo2Completion;

  const ChapterStat({
    required this.label,
    required this.algo1Completion,
    required this.algo2Completion,
  });

  factory ChapterStat.fromApi(Map<String, dynamic> json) {
    return ChapterStat(
      label:           json['label'] as String,
      // ✅ FIX : algo1 et algo2 ont des champs séparés
      algo1Completion: (json['completion'] as num).toDouble(),
      algo2Completion: 0.0, // sera écrasé si vient de algo2Chapters
    );
  }

  // ✅ NOUVEAU : constructeur dédié pour algo2
  factory ChapterStat.fromApiAlgo2(Map<String, dynamic> json) {
    return ChapterStat(
      label:           json['label'] as String,
      algo1Completion: 0.0,
      algo2Completion: (json['completion'] as num).toDouble(),
    );
  }
}

class QuizStat {
  final String day;
  final int    quizzesDone;

  const QuizStat({required this.day, required this.quizzesDone});

  factory QuizStat.fromApi(Map<String, dynamic> json) {
    return QuizStat(
      day:         json['day']         as String,
      quizzesDone: (json['quizzesDone'] as num).toInt(), // ✅ FIX : num → int
    );
  }
}

class AnalyticsModel {
  int               totalQuizzesDone;
  List<ChapterStat> chapters;
  List<QuizStat>    quizStats;
  int               selectedAlgo;

  AnalyticsModel({
    required this.totalQuizzesDone,
    required this.chapters,
    required this.quizStats,
    this.selectedAlgo = 0,
  });

  List<ChapterStat> get displayedChapters => chapters;

  List<double> get currentCompletions => chapters
      .map((c) => selectedAlgo == 0 ? c.algo1Completion : c.algo2Completion)
      .toList();
}