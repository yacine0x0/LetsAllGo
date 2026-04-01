// controllers/quiz/quiz_controller.dart

import '../../models/quiz/quiz_model.dart';
import 'base_quiz_controller.dart';

class QuizController implements BaseQuizController {
  late CustomQuizSession _session;

  @override
  CustomQuizSession get session => _session;

  static const List<Map<String, dynamic>> _questionsDatabase = [
    // ========== CHAPITRE 01: BASICS ==========
    {
      'id': 'c1_q1',
      'chapter': 'Chapitre 01',
      'enonce': 'What is an algorithm?',
      'reponseA': 'A programming language',
      'reponseB': 'A step-by-step procedure for solving a problem',
      'reponseC': 'A type of computer',
      'reponseD': 'A data structure',
      'bonneReponse': 'B',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    {
      'id': 'c1_q2',
      'chapter': 'Chapitre 01',
      'enonce': 'Which of the following is NOT a characteristic of an algorithm?',
      'reponseA': 'Finiteness',
      'reponseB': 'Definiteness',
      'reponseC': 'Ambiguity',
      'reponseD': 'Effectiveness',
      'bonneReponse': 'C',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    {
      'id': 'c1_q3',
      'chapter': 'Chapitre 01',
      'enonce': 'What is the time complexity of searching in an unsorted array?',
      'reponseA': 'O(1)',
      'reponseB': 'O(n)',
      'reponseC': 'O(log n)',
      'reponseD': 'O(n²)',
      'bonneReponse': 'B',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    {
      'id': 'c1_q4',
      'chapter': 'Chapitre 01',
      'enonce': 'Which is the best time complexity for a search algorithm?',
      'reponseA': 'O(n)',
      'reponseB': 'O(log n)',
      'reponseC': 'O(1)',
      'reponseD': 'O(n log n)',
      'bonneReponse': 'C',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    {
      'id': 'c1_q5',
      'chapter': 'Chapitre 01',
      'enonce': 'What does "Big O" notation describe?',
      'reponseA': 'Memory usage',
      'reponseB': 'Time complexity in worst case',
      'reponseC': 'The number of lines of code',
      'reponseD': 'CPU speed',
      'bonneReponse': 'B',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    // ========== CHAPITRE 02: CONDITIONS ==========
    {
      'id': 'c2_q1',
      'chapter': 'Chapitre 02',
      'enonce': 'What does an "if-else" statement do?',
      'reponseA': 'Loop execution',
      'reponseB': 'Conditional execution',
      'reponseC': 'Function definition',
      'reponseD': 'Variable declaration',
      'bonneReponse': 'B',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    {
      'id': 'c2_q2',
      'chapter': 'Chapitre 02',
      'enonce': 'Which keyword is used for multiple conditions?',
      'reponseA': 'switch',
      'reponseB': 'while',
      'reponseC': 'for',
      'reponseD': 'foreach',
      'bonneReponse': 'A',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    {
      'id': 'c2_q3',
      'chapter': 'Chapitre 02',
      'enonce': 'What is the logical operator for AND?',
      'reponseA': '|',
      'reponseB': '||',
      'reponseC': '&&',
      'reponseD': '&',
      'bonneReponse': 'C',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    {
      'id': 'c2_q4',
      'chapter': 'Chapitre 02',
      'enonce': 'What is the logical operator for OR?',
      'reponseA': '&&',
      'reponseB': '||',
      'reponseC': '&',
      'reponseD': '!',
      'bonneReponse': 'B',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    {
      'id': 'c2_q5',
      'chapter': 'Chapitre 02',
      'enonce': 'What does the NOT operator (!) do?',
      'reponseA': 'Inverts a boolean value',
      'reponseB': 'Adds two numbers',
      'reponseC': 'Compares two values',
      'reponseD': 'Declares a variable',
      'bonneReponse': 'A',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    // ========== CHAPITRE 03: LOOPS ==========
    {
      'id': 'c3_q1',
      'chapter': 'Chapitre 03',
      'enonce': 'Order the steps for a for loop:',
      'reponseA': '',
      'reponseB': '',
      'reponseC': '',
      'reponseD': '',
      'bonneReponse': 'Initialization|Condition|Body|Increment',
      'type': 'ordering',
      'codeLines': ['Body', 'Initialization', 'Increment', 'Condition'],
    },
    {
      'id': 'c3_q2',
      'chapter': 'Chapitre 03',
      'enonce': 'What is the purpose of a while loop?',
      'reponseA': 'Execute code a fixed number of times',
      'reponseB': 'Execute code while a condition is true',
      'reponseC': 'Define a function',
      'reponseD': 'Create an array',
      'bonneReponse': 'B',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    {
      'id': 'c3_q3',
      'chapter': 'Chapitre 03',
      'enonce': 'What is the key difference between for and while loops?',
      'reponseA': 'for is faster',
      'reponseB': 'while cannot iterate',
      'reponseC': 'for has a predefined iteration count',
      'reponseD': 'They are identical',
      'bonneReponse': 'C',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    {
      'id': 'c3_q4',
      'chapter': 'Chapitre 03',
      'enonce': 'What does "break" statement do in a loop?',
      'reponseA': 'Pauses the loop',
      'reponseB': 'Exits the loop immediately',
      'reponseC': 'Restarts the loop',
      'reponseD': 'Increases the iteration',
      'bonneReponse': 'B',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    {
      'id': 'c3_q5',
      'chapter': 'Chapitre 03',
      'enonce': 'What does "continue" statement do?',
      'reponseA': 'Exits the loop',
      'reponseB': 'Pauses the execution',
      'reponseC': 'Skips to the next iteration',
      'reponseD': 'Repeats the current iteration',
      'bonneReponse': 'C',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    // ========== CHAPITRE 04: DATA STRUCTURES ==========
    {
      'id': 'c4_q1',
      'chapter': 'Chapitre 04',
      'enonce': 'What is a vector?',
      'reponseA': 'A fixed-size array',
      'reponseB': 'A dynamic array that can grow or shrink',
      'reponseC': 'A constant value',
      'reponseD': 'A function parameter',
      'bonneReponse': 'B',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    {
      'id': 'c4_q2',
      'chapter': 'Chapitre 04',
      'enonce': 'What is the time complexity of accessing an element in an array?',
      'reponseA': 'O(n)',
      'reponseB': 'O(log n)',
      'reponseC': 'O(1)',
      'reponseD': 'O(n²)',
      'bonneReponse': 'C',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    {
      'id': 'c4_q3',
      'chapter': 'Chapitre 04',
      'enonce': 'What is a matrix?',
      'reponseA': 'A one-dimensional array',
      'reponseB': 'A two-dimensional array',
      'reponseC': 'A dynamic array',
      'reponseD': 'A type of vector',
      'bonneReponse': 'B',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    {
      'id': 'c4_q4',
      'chapter': 'Chapitre 04',
      'enonce': 'Order the steps for matrix traversal:',
      'reponseA': '',
      'reponseB': '',
      'reponseC': '',
      'reponseD': '',
      'bonneReponse': 'Initialize row index|Initialize column index|Access element|Move to next element',
      'type': 'ordering',
      'codeLines': ['Access element', 'Initialize row index', 'Move to next element', 'Initialize column index'],
    },
    {
      'id': 'c4_q5',
      'chapter': 'Chapitre 04',
      'enonce': 'What is the advantage of using vectors over arrays?',
      'reponseA': 'Faster access',
      'reponseB': 'Dynamic sizing',
      'reponseC': 'Less memory usage',
      'reponseD': 'No advantages',
      'bonneReponse': 'B',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    // ========== CHAPITRE 05: FUNCTIONS ==========
    {
      'id': 'c5_q1',
      'chapter': 'Chapitre 05',
      'enonce': 'What is a function?',
      'reponseA': 'A variable',
      'reponseB': 'A reusable block of code that performs a task',
      'reponseC': 'A loop',
      'reponseD': 'A data type',
      'bonneReponse': 'B',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    {
      'id': 'c5_q2',
      'chapter': 'Chapitre 05',
      'enonce': 'What are parameters in a function?',
      'reponseA': 'The function name',
      'reponseB': 'Input values passed to the function',
      'reponseC': 'The function body',
      'reponseD': 'The return type',
      'bonneReponse': 'B',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    {
      'id': 'c5_q3',
      'chapter': 'Chapitre 05',
      'enonce': 'What is recursion?',
      'reponseA': 'A loop',
      'reponseB': 'A function calling itself',
      'reponseC': 'A data structure',
      'reponseD': 'An array operation',
      'bonneReponse': 'B',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    {
      'id': 'c5_q4',
      'chapter': 'Chapitre 05',
      'enonce': 'What is the base case in recursion?',
      'reponseA': 'The first function call',
      'reponseB': 'The condition to stop recursion',
      'reponseC': 'The return value',
      'reponseD': 'The function parameters',
      'bonneReponse': 'B',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    {
      'id': 'c5_q5',
      'chapter': 'Chapitre 05',
      'enonce': 'Order the function execution steps:',
      'reponseA': '',
      'reponseB': '',
      'reponseC': '',
      'reponseD': '',
      'bonneReponse': 'Function declaration|Function call|Parameter passing|Function execution|Return value',
      'type': 'ordering',
      'codeLines': ['Function execution', 'Function declaration', 'Return value', 'Function call', 'Parameter passing'],
    },
  ];

  QuizController({
    required List<String> selectedChapters,
    required int intensity,
  }) {
    _initializeSession(selectedChapters, intensity);
  }

  void _initializeSession(List<String> selectedChapters, int intensity) {
    List<Quiz> quizzes = [];

    for (var chapter in selectedChapters) {
      final chapterQuestions = _getQuestionsByChapter(chapter);
      final selectedQuestions = chapterQuestions.take(intensity).toList();

      final quiz = Quiz(
        id: 'quiz_${chapter.replaceAll(' ', '_')}',
        title: chapter,
        chapter: chapter,
        icon: "assets/images/icons_algo1/basics_icone.png",
        questions: selectedQuestions,
      );

      quizzes.add(quiz);
    }

    _session = CustomQuizSession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      selectedChapters: selectedChapters,
      intensity: intensity,
      quizzes: quizzes,
    );
  }

  List<Question> _getQuestionsByChapter(String chapter) {
    return _questionsDatabase
        .where((q) => q['chapter'] == chapter)
        .map((q) => _mapToQuestion(q))
        .toList();
  }

  Question _mapToQuestion(Map<String, dynamic> data) {
    return Question(
      id: data['id'],
      enonce: data['enonce'],
      reponseA: data['reponseA'],
      reponseB: data['reponseB'],
      reponseC: data['reponseC'],
      reponseD: data['reponseD'],
      bonneReponse: data['bonneReponse'],
      type: data['type'] == 'ordering' ? QuestionType.ordering : QuestionType.multipleChoice,
      codeLines: data['codeLines'] as List<String>?,
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
  bool nextQuiz() {
    return _session.nextQuiz();
  }

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
    if (_session.currentQuiz.isQuestionValidated(questionId)) {
      return;
    }
    _session.currentQuiz.userAnswers[questionId] = answer;
  }

  @override
  void setOrdering(String questionId, List<String> order) {
    if (_session.currentQuiz.isQuestionValidated(questionId)) {
      return;
    }
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
      final userOrder = _session.currentQuiz.userOrderings[questionId];
      if (userOrder == null) return false;
      final correctOrder = question.bonneReponse.split('|');
      isCorrect = userOrder.join('|') == correctOrder.join('|');
    }

    if (isCorrect) {
      _session.currentQuiz.validateQuestion(questionId);
    }

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
        final correctOrder = question.bonneReponse.split('|');
        return userOrder.join('|') == correctOrder.join('|');
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
    for (var question in _session.currentQuiz.questions) {
      if (getQuestionStatus(question.id) == true) {
        score++;
      }
    }
    return score;
  }

  @override
  int getTotalScore() {
    return _session.getTotalScore();
  }

  @override
  int getPercentage() {
    return _session.getPercentage();
  }

  @override
  void resetSession() {
    for (var quiz in _session.quizzes) {
      quiz.reset();
    }
    _session.currentQuizIndex = 0;
  }
}