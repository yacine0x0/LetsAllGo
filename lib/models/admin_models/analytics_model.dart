// lib/models/admin_models/analytics_model.dart

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
      algo1Completion: (json['completion'] as num).toDouble(),
      algo2Completion: 0.0,
    );
  }

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
  final int    totalQuestions;

  const QuizStat({
    required this.day,
    required this.quizzesDone,
    this.totalQuestions = 0,
  });

  factory QuizStat.fromApi(Map<String, dynamic> json) {
    return QuizStat(
      day:            json['day']             as String,
      quizzesDone:    (json['quizzesDone']    as num).toInt(),
      totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 0,
    );
  }
}

class AnalyticsModel {
  int               totalQuizzesDone;
  List<ChapterStat> chapters;
  List<QuizStat>    quizStats;
  List<QuizStat>    quizStatsAlgo1;
  List<QuizStat>    quizStatsAlgo2;
  int               selectedAlgo;
  int               selectedQuizAlgo;

  AnalyticsModel({
    required this.totalQuizzesDone,
    required this.chapters,
    required this.quizStats,
    List<QuizStat>? quizStatsAlgo1,
    List<QuizStat>? quizStatsAlgo2,
    this.selectedAlgo     = 0,
    this.selectedQuizAlgo = 0,
  })  : quizStatsAlgo1 = quizStatsAlgo1 ?? quizStats,
        quizStatsAlgo2 = quizStatsAlgo2 ?? [];

  List<ChapterStat> get displayedChapters => chapters;

  List<QuizStat> get currentQuizStats =>
      selectedQuizAlgo == 0 ? quizStatsAlgo1 : quizStatsAlgo2;

  List<double> get currentCompletions => chapters
      .map((c) => selectedAlgo == 0 ? c.algo1Completion : c.algo2Completion)
      .toList();
}