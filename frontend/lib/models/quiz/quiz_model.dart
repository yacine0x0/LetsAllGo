// models/quiz/quiz_model.dart

enum QuestionType { multipleChoice, ordering }

class Question {
  final String id;
  final String enonce;
  final String reponseA;
  final String reponseB;
  final String reponseC;
  final String reponseD;
  final String bonneReponse;
  final QuestionType type;
  final List<String>? codeLines;

  Question({
    required this.id,
    required this.enonce,
    required this.reponseA,
    required this.reponseB,
    required this.reponseC,
    required this.reponseD,
    required this.bonneReponse,
    required this.type,
    this.codeLines,
  });

  Question copyWith({
    String? id,
    String? enonce,
    String? reponseA,
    String? reponseB,
    String? reponseC,
    String? reponseD,
    String? bonneReponse,
    QuestionType? type,
    List<String>? codeLines,
  }) {
    return Question(
      id: id ?? this.id,
      enonce: enonce ?? this.enonce,
      reponseA: reponseA ?? this.reponseA,
      reponseB: reponseB ?? this.reponseB,
      reponseC: reponseC ?? this.reponseC,
      reponseD: reponseD ?? this.reponseD,
      bonneReponse: bonneReponse ?? this.bonneReponse,
      type: type ?? this.type,
      codeLines: codeLines ?? this.codeLines,
    );
  }
}

class Quiz {
  final String id;
  final String title;
  final String chapter;
  final String icon;
  final List<Question> questions;
  int currentQuestionIndex;
  Map<String, String> userAnswers;
  Map<String, List<String>> userOrderings;
  Map<String, bool> validatedQuestions;

  Quiz({
    required this.id,
    required this.title,
    required this.chapter,
    required this.icon,
    required this.questions,
    this.currentQuestionIndex = 0,
    Map<String, String>? userAnswers,
    Map<String, List<String>>? userOrderings,
    Map<String, bool>? validatedQuestions,
  }) : userAnswers = userAnswers ?? {},
       userOrderings = userOrderings ?? {},
       validatedQuestions = validatedQuestions ?? {};

  void reset() {
    currentQuestionIndex = 0;
    userAnswers.clear();
    userOrderings.clear();
    validatedQuestions.clear();
  }

  bool isQuestionValidated(String questionId) {
    return validatedQuestions[questionId] ?? false;
  }

  void validateQuestion(String questionId) {
    validatedQuestions[questionId] = true;
  }

  bool hasAnswer(String questionId) {
    final question = questions.firstWhere((q) => q.id == questionId);
    if (question.type == QuestionType.multipleChoice) {
      return userAnswers.containsKey(questionId);
    } else {
      return userOrderings.containsKey(questionId);
    }
  }

  Question get currentQuestion => questions[currentQuestionIndex];
  bool get isFirstQuestion => currentQuestionIndex == 0;
  bool get isLastQuestion => currentQuestionIndex == questions.length - 1;
  int get totalQuestions => questions.length;
}

class CustomQuizSession {
  final String id;
  final List<String> selectedChapters;
  final int intensity;
  final List<Quiz> quizzes;
  int currentQuizIndex;

  CustomQuizSession({
    required this.id,
    required this.selectedChapters,
    required this.intensity,
    required this.quizzes,
    this.currentQuizIndex = 0,
  });

  Quiz get currentQuiz => quizzes[currentQuizIndex];

  bool nextQuiz() {
    if (currentQuizIndex < quizzes.length - 1) {
      currentQuizIndex++;
      return true;
    }
    return false;
  }

  bool get isLastQuiz => currentQuizIndex == quizzes.length - 1;

  int getTotalScore() {
    int totalScore = 0;
    for (var quiz in quizzes) {
      totalScore += _calculateQuizScore(quiz);
    }
    return totalScore;
  }

  int get totalPossibleScore =>
      quizzes.fold(0, (sum, quiz) => sum + quiz.totalQuestions);

  int _calculateQuizScore(Quiz quiz) {
    int score = 0;
    for (var question in quiz.questions) {
      if (quiz.isQuestionValidated(question.id)) {
        if (question.type == QuestionType.multipleChoice) {
          if (quiz.userAnswers[question.id] == question.bonneReponse) {
            score++;
          }
        } else {
          final userOrder = quiz.userOrderings[question.id];
          if (userOrder != null) {
            final correctOrder = question.bonneReponse.split('|');
            if (userOrder.join('|') == correctOrder.join('|')) {
              score++;
            }
          }
        }
      }
    }
    return score;
  }

  int getPercentage() {
    if (totalPossibleScore == 0) return 0;
    return ((getTotalScore() / totalPossibleScore) * 100).toInt();
  }
}