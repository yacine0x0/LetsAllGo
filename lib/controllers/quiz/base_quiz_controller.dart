// controllers/quiz/base_quiz_controller.dart

import '../../models/quiz/quiz_model.dart';

abstract class BaseQuizController {
  CustomQuizSession get session;
  bool get isFirstQuestion;
  bool get isLastQuestion;
  bool get isLastQuiz;
  int get totalQuestionsInCurrentQuiz;
  int get currentQuestionIndex;
  Question get currentQuestion;
  Quiz get currentQuiz;

  void nextQuestion();
  void prevQuestion();
  bool nextQuiz();
  void answerMultipleChoice(String questionId, String answer);
  void setOrdering(String questionId, List<String> order);
  bool checkAnswer(String questionId);
  bool? getQuestionStatus(String questionId);
  int getCurrentQuizScore();
  int getTotalScore();
  int getPercentage();
  void resetSession();
}