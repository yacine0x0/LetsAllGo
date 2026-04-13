// controllers/quiz/quiz_controller.dart
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import '../../models/quiz/quiz_model.dart';
import 'base_quiz_controller.dart';

class QuizController implements BaseQuizController {
  late CustomQuizSession _session;

  @override
  CustomQuizSession get session => _session;

  // Map chapitre → icône (inchangé)
  static const Map<String, String> _chapterIcons = {
    'Chapitre 01': 'assets/images/icons_algo1/basics_icone.png',
    'Chapitre 02': 'assets/images/icons_algo1/si_sinon_icon.png',
    'Chapitre 03': 'assets/images/icons_algo1/loops_icone.png',
    'Chapitre 04': 'assets/images/icons_algo1/vectors_matris_icon.png',
    'Chapitre 05': 'assets/images/icons_algo1/fonction_procedure_icone.png',
  };

  // Constructeur privé — utilise QuizController.create() pour instancier
  QuizController._();

  /// Factory async : charge les XML puis construit la session.
  static Future<QuizController> create({
    required List<String> selectedChapters,
    required int intensity,
  }) async {
    final ctrl = QuizController._();
    await ctrl._initializeSession(selectedChapters, intensity);
    return ctrl;
  }

  // ─── Chargement XML ───────────────────────────────────────────────────────

  /// Convertit "Chapitre 01" → "chapitre01", "Chapitre 05" → "chapitre05"
  static String _chapterToFileName(String chapter) {
    final match = RegExp(r'(\d+)').firstMatch(chapter);
    final number = match != null ? match.group(1)!.padLeft(2, '0') : '';
    return 'chapitre$number';
  }

  /// Charge et parse un fichier XML d'un chapitre.
  static Future<List<Question>> _loadQuestionsFromXml(String chapter) async {
    final fileName = _chapterToFileName(chapter);
    final path = 'assets/data/algo1/quiz/$fileName.xml';

    late String raw;
    try {
      raw = await rootBundle.loadString(path);
    } catch (_) {
      // Fichier absent → chapitre ignoré silencieusement
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
        // Les lignes à afficher (déjà mélangées dans le XML)
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
          bonneReponse: bonneReponseRaw, // "Step1|Step2|Step3"
          type:         QuestionType.ordering,
          codeLines:    codeLines,
        ));
      } else {
        // multipleChoice — construit reponseA..D depuis les <choice>
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
          bonneReponse: bonneReponseRaw, // "A", "B", "C" ou "D"
          type:         QuestionType.multipleChoice,
          codeLines:    null,
        ));
      }
    }

    return questions;
  }

  // ─── Initialisation de la session ─────────────────────────────────────────

  Future<void> _initializeSession(
    List<String> selectedChapters,
    int intensity,
  ) async {
    final List<Quiz> quizzes = [];

    for (final chapter in selectedChapters) {
      final allQuestions = await _loadQuestionsFromXml(chapter);

      // Prend au maximum `intensity` questions
      final selected = allQuestions.take(intensity).toList();

      quizzes.add(Quiz(
        id:        'quiz_${chapter.replaceAll(' ', '_')}',
        title:     chapter,
        chapter:   chapter,
        icon:      _chapterIcons[chapter] ??
                   'assets/images/icons_algo1/basics_icone.png',
        questions: selected,
      ));
    }

    _session = CustomQuizSession(
      id:               'session_${DateTime.now().millisecondsSinceEpoch}',
      selectedChapters: selectedChapters,
      intensity:        intensity,
      quizzes:          quizzes,
    );
  }

  // ─── BaseQuizController (inchangé) ────────────────────────────────────────

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
  int get totalQuestionsInCurrentQuiz => _session.currentQuiz.totalQuestions;

  @override
  int get currentQuestionIndex => _session.currentQuiz.currentQuestionIndex;

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
      isCorrect =
          _session.currentQuiz.userAnswers[questionId] == question.bonneReponse;
    } else {
      final userOrder = _session.currentQuiz.userOrderings[questionId];
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
        final userOrder = _session.currentQuiz.userOrderings[questionId];
        if (userOrder == null) return false;
        return userOrder.join('|') == question.bonneReponse;
      }
    }

    if (question.type == QuestionType.multipleChoice) {
      if (!_session.currentQuiz.userAnswers.containsKey(questionId)) return null;
    } else {
      if (!_session.currentQuiz.userOrderings.containsKey(questionId)) return null;
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
  int getTotalScore() => _session.getTotalScore();

  @override
  int getPercentage() => _session.getPercentage();

  @override
  void resetSession() {
    for (final quiz in _session.quizzes) {
      quiz.reset();
    }
    _session.currentQuizIndex = 0;
  }
}
