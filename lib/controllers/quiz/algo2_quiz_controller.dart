// controllers/quiz/algo2_quiz_controller.dart

import '../../models/quiz/quiz_model.dart';
import 'base_quiz_controller.dart';

class Algo2QuizController implements BaseQuizController {
  late CustomQuizSession _session;

  @override
  CustomQuizSession get session => _session;

  static const List<Map<String, dynamic>> _questionsDatabase = [
    // ========== CHAPITRE 01: DATA STRUCTURE ==========
    {
      'id': 'a2_c1_q1',
      'chapter': 'Chapitre 01',
      'enonce': 'What is a data structure?',
      'reponseA': 'A programming language',
      'reponseB': 'A way to organize and store data efficiently',
      'reponseC': 'A type of algorithm',
      'reponseD': 'A database system',
      'bonneReponse': 'B',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    {
      'id': 'a2_c1_q2',
      'chapter': 'Chapitre 01',
      'enonce': 'What is a record (enregistrement) in data structures?',
      'reponseA': 'A single value stored in memory',
      'reponseB': 'A collection of fields of different types grouped under one name',
      'reponseC': 'A type of loop',
      'reponseD': 'A recursive function',
      'bonneReponse': 'B',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    {
      'id': 'a2_c1_q3',
      'chapter': 'Chapitre 01',
      'enonce': 'What is the main characteristic of an array (tableau)?',
      'reponseA': 'Elements are stored at random memory locations',
      'reponseB': 'Elements are of different types',
      'reponseC': 'Elements are stored in contiguous memory locations',
      'reponseD': 'The size can change dynamically',
      'bonneReponse': 'C',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    {
      'id': 'a2_c1_q4',
      'chapter': 'Chapitre 01',
      'enonce': 'What is a pointer?',
      'reponseA': 'A variable that stores a value',
      'reponseB': 'A variable that stores the memory address of another variable',
      'reponseC': 'A type of array',
      'reponseD': 'A sorting algorithm',
      'bonneReponse': 'B',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    {
      'id': 'a2_c1_q5',
      'chapter': 'Chapitre 01',
      'enonce': 'What is recursion?',
      'reponseA': 'A loop that iterates a fixed number of times',
      'reponseB': 'A function that calls itself until a base case is reached',
      'reponseC': 'A data structure for storing hierarchical data',
      'reponseD': 'A method to sort arrays',
      'bonneReponse': 'B',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    // ========== CHAPITRE 02: FILES ==========
    {
      'id': 'a2_c2_q1',
      'chapter': 'Chapitre 02',
      'enonce': 'What is a queue (file)?',
      'reponseA': 'A data structure where the last element added is the first to be removed',
      'reponseB': 'A data structure where the first element added is the first to be removed',
      'reponseC': 'A sorted list of elements',
      'reponseD': 'A tree structure',
      'bonneReponse': 'B',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    {
      'id': 'a2_c2_q2',
      'chapter': 'Chapitre 02',
      'enonce': 'What is the principle of a stack (pile)?',
      'reponseA': 'FIFO – First In, First Out',
      'reponseB': 'FILO – First In, Last Out',
      'reponseC': 'LIFO – Last In, First Out',
      'reponseD': 'LILO – Last In, Last Out',
      'bonneReponse': 'C',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    {
      'id': 'a2_c2_q3',
      'chapter': 'Chapitre 02',
      'enonce': 'Order the steps to enqueue an element in a circular queue:',
      'reponseA': '',
      'reponseB': '',
      'reponseC': '',
      'reponseD': '',
      'bonneReponse': 'Check if full|Advance rear pointer|Insert element|Update size',
      'type': 'ordering',
      'codeLines': ['Insert element', 'Check if full', 'Update size', 'Advance rear pointer'],
    },
    {
      'id': 'a2_c2_q4',
      'chapter': 'Chapitre 02',
      'enonce': 'What is the advantage of a circular queue over a simple queue?',
      'reponseA': 'It uses more memory',
      'reponseB': 'It avoids wasting space after dequeue operations',
      'reponseC': 'It sorts elements automatically',
      'reponseD': 'It has faster search time',
      'bonneReponse': 'B',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    {
      'id': 'a2_c2_q5',
      'chapter': 'Chapitre 02',
      'enonce': 'Which operation removes the front element from a queue?',
      'reponseA': 'push',
      'reponseB': 'pop',
      'reponseC': 'enqueue',
      'reponseD': 'dequeue',
      'bonneReponse': 'D',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    // ========== CHAPITRE 03: LINKED LIST ==========
    {
      'id': 'a2_c3_q1',
      'chapter': 'Chapitre 03',
      'enonce': 'What is a singly linked list?',
      'reponseA': 'A list where each node points to the previous and next node',
      'reponseB': 'A list where each node contains data and a pointer to the next node',
      'reponseC': 'A list where the last node points to the first node',
      'reponseD': 'A list stored in contiguous memory',
      'bonneReponse': 'B',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    {
      'id': 'a2_c3_q2',
      'chapter': 'Chapitre 03',
      'enonce': 'What distinguishes a doubly linked list from a singly linked list?',
      'reponseA': 'Each node has two data fields',
      'reponseB': 'Each node has pointers to both the next and previous nodes',
      'reponseC': 'The list can only be traversed forwards',
      'reponseD': 'It uses less memory',
      'bonneReponse': 'B',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    {
      'id': 'a2_c3_q3',
      'chapter': 'Chapitre 03',
      'enonce': 'In a circular linked list, what does the last node point to?',
      'reponseA': 'null / Nothing',
      'reponseB': 'The previous node',
      'reponseC': 'The first node (head)',
      'reponseD': 'Itself',
      'bonneReponse': 'C',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    {
      'id': 'a2_c3_q4',
      'chapter': 'Chapitre 03',
      'enonce': 'Order the steps to insert a node at the beginning of a linked list:',
      'reponseA': '',
      'reponseB': '',
      'reponseC': '',
      'reponseD': '',
      'bonneReponse': 'Create new node|Set new node next to head|Update head to new node',
      'type': 'ordering',
      'codeLines': ['Update head to new node', 'Create new node', 'Set new node next to head'],
    },
    {
      'id': 'a2_c3_q5',
      'chapter': 'Chapitre 03',
      'enonce': 'What is the time complexity of accessing the nth element in a linked list?',
      'reponseA': 'O(1)',
      'reponseB': 'O(log n)',
      'reponseC': 'O(n)',
      'reponseD': 'O(n²)',
      'bonneReponse': 'C',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    // ========== CHAPITRE 04: QUEUES AND STACKS ==========
    {
      'id': 'a2_c4_q1',
      'chapter': 'Chapitre 04',
      'enonce': 'Which data structure is used for function call management?',
      'reponseA': 'Queue',
      'reponseB': 'Stack',
      'reponseC': 'Array',
      'reponseD': 'Linked list',
      'bonneReponse': 'B',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    {
      'id': 'a2_c4_q2',
      'chapter': 'Chapitre 04',
      'enonce': 'Which data structure is used in Breadth-First Search (BFS)?',
      'reponseA': 'Stack',
      'reponseB': 'Tree',
      'reponseC': 'Queue',
      'reponseD': 'Graph',
      'bonneReponse': 'C',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    {
      'id': 'a2_c4_q3',
      'chapter': 'Chapitre 04',
      'enonce': 'What is a vector in the context of data structures?',
      'reponseA': 'A fixed-size array',
      'reponseB': 'A dynamic array that can resize itself',
      'reponseC': 'A linked list',
      'reponseD': 'A tree structure',
      'bonneReponse': 'B',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    {
      'id': 'a2_c4_q4',
      'chapter': 'Chapitre 04',
      'enonce': 'What is a matrix?',
      'reponseA': 'A one-dimensional array',
      'reponseB': 'A two-dimensional array organized in rows and columns',
      'reponseC': 'A dynamic list of elements',
      'reponseD': 'A type of linked list',
      'bonneReponse': 'B',
      'type': 'multipleChoice',
      'codeLines': null,
    },
    {
      'id': 'a2_c4_q5',
      'chapter': 'Chapitre 04',
      'enonce': 'Order the steps for matrix multiplication:',
      'reponseA': '',
      'reponseB': '',
      'reponseC': '',
      'reponseD': '',
      'bonneReponse': 'Check dimensions compatibility|Initialize result matrix|Compute dot products|Store results',
      'type': 'ordering',
      'codeLines': ['Compute dot products', 'Check dimensions compatibility', 'Store results', 'Initialize result matrix'],
    },
  ];

  Algo2QuizController({
    required List<String> selectedChapters,
    required int intensity,
  }) {
    _initializeSession(selectedChapters, intensity);
  }

  void _initializeSession(List<String> selectedChapters, int intensity) {
    final List<Quiz> quizzes = [];

    for (final chapter in selectedChapters) {
      final chapterQuestions = _getQuestionsByChapter(chapter);
      final selectedQuestions = chapterQuestions.take(intensity).toList();

      final quiz = Quiz(
        id: 'algo2_quiz_${chapter.replaceAll(' ', '_')}',
        title: chapter,
        chapter: chapter,
        icon: _getChapterIcon(chapter),
        questions: selectedQuestions,
      );

      quizzes.add(quiz);
    }

    _session = CustomQuizSession(
      id: 'algo2_session_${DateTime.now().millisecondsSinceEpoch}',
      selectedChapters: selectedChapters,
      intensity: intensity,
      quizzes: quizzes,
    );
  }

  List<Question> _getQuestionsByChapter(String chapter) {
    return _questionsDatabase
        .where((q) => q['chapter'] == chapter)
        .map(_mapToQuestion)
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
      type: data['type'] == 'ordering'
          ? QuestionType.ordering
          : QuestionType.multipleChoice,
      codeLines: data['codeLines'] as List<String>?,
    );
  }

  String _getChapterIcon(String chapter) {
    switch (chapter) {
      case 'Chapitre 01':
        return 'assets/images/icons_algo2/data_structure_icone.png';
      case 'Chapitre 02':
        return 'assets/images/icons_algo2/files_icone.png';
      case 'Chapitre 03':
        return 'assets/images/icons_algo2/listes_icones.png';
      case 'Chapitre 04':
        return 'assets/images/icons_algo2/stacks_icone.png';
      default:
        return 'assets/images/icons_algo2/data_structure_icone.png';
    }
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

    final question =
        _session.currentQuiz.questions.firstWhere((q) => q.id == questionId);

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
    final question =
        _session.currentQuiz.questions.firstWhere((q) => q.id == questionId);

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
      if (!_session.currentQuiz.userAnswers.containsKey(questionId)) return null;
    } else {
      if (!_session.currentQuiz.userOrderings.containsKey(questionId)) return null;
    }

    return checkAnswer(questionId);
  }

  @override
  int getCurrentQuizScore() {
    int score = 0;
    for (final question in _session.currentQuiz.questions) {
      if (getQuestionStatus(question.id) == true) score++;
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