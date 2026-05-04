// lib/controllers/courses_study/chapter_quiz_controller.dart
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import '../../models/quiz/quiz_model.dart';
import '../quiz/base_quiz_controller.dart';

class ChapterQuizController implements BaseQuizController {
  late CustomQuizSession _session;

  @override
  CustomQuizSession get session => _session;

  ChapterQuizController._();

  static Future<ChapterQuizController> create({
    required String xmlPath,
    required String chapterTitle,
  }) async {
    final ctrl = ChapterQuizController._();
    await ctrl._initializeSession(xmlPath, chapterTitle);
    return ctrl;
  }

  static Future<List<Question>> _loadQuestionsFromXml(String xmlPath) async {
    late String raw;
    try {
      raw = await rootBundle.loadString(xmlPath);
    } catch (_) {
      return [];
    }

    final document = XmlDocument.parse(raw);
    final List<Question> questions = [];

    for (final node in document.findAllElements('question')) {
      final id     = node.getAttribute('id') ?? '';
      final type   = node.getAttribute('type') ?? 'multipleChoice';
      final enonce = node.findElements('enonce').first.innerText.trim();
      final bonneReponseRaw =
          node.findElements('bonneReponse').first.innerText.trim();

      if (type == 'ordering') {
        final codeLines = node
            .findAllElements('line')
            .map((l) => l.innerText.trim())
            .toList();

        questions.add(Question(
          id:           id,
          enonce:       enonce,
          reponseA:     '',
          reponseB:     '',
          reponseC:     '',
          reponseD:     '',
          bonneReponse: bonneReponseRaw,
          type:         QuestionType.ordering,
          codeLines:    codeLines,
        ));
      } else {
        final choices = {
          for (final c in node.findAllElements('choice'))
            c.getAttribute('id')!: c.innerText.trim()
        };

        questions.add(Question(
          id:           id,
          enonce:       enonce,
          reponseA:     choices['A'] ?? '',
          reponseB:     choices['B'] ?? '',
          reponseC:     choices['C'] ?? '',
          reponseD:     choices['D'] ?? '',
          bonneReponse: bonneReponseRaw,
          type:         QuestionType.multipleChoice,
          codeLines:    null,
        ));
      }
    }

    return questions;
  }

  Future<void> _initializeSession(
    String xmlPath,
    String chapterTitle,
  ) async {
    final allQuestions = await _loadQuestionsFromXml(xmlPath);

    // ✅ 5 questions aléatoires
    final random   = Random();
    final shuffled = List<Question>.from(allQuestions)..shuffle(random);
    final selected = shuffled.take(5).toList();

    final quiz = Quiz(
      id:        'chapter_quiz_${DateTime.now().millisecondsSinceEpoch}',
      title:     chapterTitle,
      chapter:   chapterTitle,
      icon:      '',
      questions: selected,
    );

    _session = CustomQuizSession(
      id:               'chapter_session_${DateTime.now().millisecondsSinceEpoch}',
      selectedChapters: [chapterTitle],
      intensity:        5,
      quizzes:          [quiz],
    );
  }

  @override
  void nextQuestion() {
    if (!_session.currentQuiz.isLastQuestion) {
      _session.currentQuiz.currentQuestionIndex++;
    }
  }

  @override
  void prevQuestion() {
    if (!_session.currentQuiz.isFirstQuestion) {
      _session.currentQuiz.currentQuestionIndex--;
    }
  }

  @override
  bool nextQuiz() => _session.nextQuiz();

  @override
  bool get isFirstQuestion => _session.currentQuiz.isFirstQuestion;

  @override
  bool get isLastQuestion => _session.currentQuiz.isLastQuestion;

  @override
  bool get isLastQuiz => _session.isLastQuiz;

  @override
  int get totalQuestionsInCurrentQuiz =>
      _session.currentQuiz.totalQuestions;

  @override
  int get currentQuestionIndex =>
      _session.currentQuiz.currentQuestionIndex;

  @override
  Question get currentQuestion => _session.currentQuiz.currentQuestion;

  @override
  Quiz get currentQuiz => _session.currentQuiz;

  @override
  void answerMultipleChoice(String questionId, String answer) {
    if (_session.currentQuiz.isQuestionValidated(questionId)) return;
    _session.currentQuiz.userAnswers[questionId] = answer;
  }

  @override
  void setOrdering(String questionId, List<String> order) {
    if (_session.currentQuiz.isQuestionValidated(questionId)) return;
    _session.currentQuiz.userOrderings[questionId] = order;
  }

  @override
  bool checkAnswer(String questionId) {
    if (_session.currentQuiz.isQuestionValidated(questionId)) {
      return getQuestionStatus(questionId) ?? false;
    }

    final question = _session.currentQuiz.questions
        .firstWhere((q) => q.id == questionId);

    bool isCorrect;

    if (question.type == QuestionType.multipleChoice) {
      isCorrect = _session.currentQuiz.userAnswers[questionId] ==
          question.bonneReponse;
    } else {
      final userOrder =
          _session.currentQuiz.userOrderings[questionId];
      if (userOrder == null) return false;
      final correctOrder = question.bonneReponse.split('|');
      isCorrect = userOrder.join('|') == correctOrder.join('|');
    }

    if (isCorrect) _session.currentQuiz.validateQuestion(questionId);
    return isCorrect;
  }

  @override
  bool? getQuestionStatus(String questionId) {
    final question = _session.currentQuiz.questions
        .firstWhere((q) => q.id == questionId);

    if (_session.currentQuiz.isQuestionValidated(questionId)) {
      if (question.type == QuestionType.multipleChoice) {
        return _session.currentQuiz.userAnswers[questionId] ==
            question.bonneReponse;
      } else {
        final userOrder =
            _session.currentQuiz.userOrderings[questionId];
        if (userOrder == null) return false;
        return userOrder.join('|') == question.bonneReponse;
      }
    }

    if (question.type == QuestionType.multipleChoice) {
      if (!_session.currentQuiz.userAnswers.containsKey(questionId)) {
        return null;
      }
    } else {
      if (!_session.currentQuiz.userOrderings.containsKey(questionId)) {
        return null;
      }
    }

    return checkAnswer(questionId);
  }

  @override
  int getCurrentQuizScore() {
    int score = 0;
    for (final q in _session.currentQuiz.questions) {
      if (getQuestionStatus(q.id) == true) score++;
    }
    return score;
  }

  @override
  int getTotalScore()  => _session.getTotalScore();

  @override
  int getPercentage()  => _session.getPercentage();

  @override
  void resetSession() {
    for (final quiz in _session.quizzes) {
      quiz.reset();
    }
    _session.currentQuizIndex = 0;
  }
}