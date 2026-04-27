import 'package:flutter/material.dart';
import 'dart:ui';
import '../../models/quiz/quiz_model.dart';
import '../../controllers/courses_study/chapter_quiz_controller.dart';
import '../../service/progress/progress_service.dart';
import '../dashboard/dashboard_page.dart';

class ChapterQuizPage extends StatefulWidget {
  final ChapterQuizController controller;
  final String chapterTitle;
  final String algoType;

  const ChapterQuizPage({
    super.key,
    required this.controller,
    required this.chapterTitle,
    required this.algoType,
  });

  @override
  State<ChapterQuizPage> createState() => _ChapterQuizPageState();
}

class _ChapterQuizPageState extends State<ChapterQuizPage> {
  bool?        _answerChecked       = null;
  List<String> _currentOrder        = [];
  bool         _quizCompleted       = false;
  bool         _isQuestionValidated = false;
  bool         _hasSelection        = false;
  bool         _isFirstCompletion   = false;

  @override
  void initState() {
    super.initState();
    _loadQuestion();
  }

  void _loadQuestion() {
    final q = widget.controller.currentQuestion;
    _isQuestionValidated =
        widget.controller.currentQuiz.isQuestionValidated(q.id);

    if (_isQuestionValidated) {
      _answerChecked = true;
      _hasSelection  = true;
      if (q.type == QuestionType.ordering && q.codeLines != null) {
        final saved = widget.controller.currentQuiz.userOrderings[q.id];
        _currentOrder =
            saved != null ? List.from(saved) : List.from(q.codeLines!);
      }
    } else {
      _answerChecked = null;
      _hasSelection  = false;
      if (q.type == QuestionType.ordering && q.codeLines != null) {
        _currentOrder = List.from(q.codeLines!);
      } else {
        _currentOrder = [];
      }
    }
  }

  void _nextQuestion() {
    if (widget.controller.isLastQuestion) {
      // Check first completion before marking as complete
      _isFirstCompletion = !ProgressService.isAlreadyCompleted(
          widget.algoType, widget.chapterTitle);
      if (_isFirstCompletion) {
        ProgressService.completeChapter(
            widget.algoType, widget.chapterTitle);
      }
      setState(() => _quizCompleted = true);
    } else {
      widget.controller.nextQuestion();
      setState(() {
        _answerChecked       = null;
        _currentOrder        = [];
        _hasSelection        = false;
        _isQuestionValidated = false;
        _loadQuestion();
      });
    }
  }

  void _prevQuestion() {
    widget.controller.prevQuestion();
    setState(() {
      _answerChecked       = null;
      _currentOrder        = [];
      _hasSelection        = false;
      _isQuestionValidated = false;
      _loadQuestion();
    });
  }

  void _checkAnswer() {
    final q         = widget.controller.currentQuestion;
    final isCorrect = widget.controller.checkAnswer(q.id);
    setState(() {
      _answerChecked       = isCorrect;
      _isQuestionValidated =
          widget.controller.currentQuiz.isQuestionValidated(q.id);
    });
  }

  void _resetQuiz() {
    widget.controller.resetSession();
    setState(() {
      _answerChecked       = null;
      _quizCompleted       = false;
      _currentOrder        = [];
      _hasSelection        = false;
      _isQuestionValidated = false;
      _loadQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    if (_quizCompleted) return _buildCompletionScreen(h, w);

    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFF0D0D2B)),
          Opacity(
            opacity: 0.90,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/background.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Column(
            children: [
              _buildTopBar(h, w),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: w * 0.03, vertical: h * 0.01),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.02),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                              width: 1.5),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(h * 0.03),
                          child: Column(
                            children: [
                              _buildHeader(h),
                              SizedBox(height: h * 0.02),
                              _buildProgressBar(h, w),
                              SizedBox(height: h * 0.02),
                              Expanded(child: _buildQuestionContent(h, w)),
                              _buildBottomNav(h, w),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(double h, double w) {
    return Container(
      height: h * 0.09,
      padding: EdgeInsets.symmetric(horizontal: w * 0.03),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        border: Border(
            bottom:
                BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          Icon(Icons.quiz, color: Colors.blue, size: h * 0.04),
          SizedBox(width: w * 0.01),
          Text(
            "Chapter Quiz — ${widget.chapterTitle}",
            style: TextStyle(
                color: Colors.white,
                fontSize: h * 0.022,
                fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const DashboardPage())),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: w * 0.015, vertical: h * 0.008),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: Colors.red.withValues(alpha: 0.4)),
              ),
              child: Row(children: [
                Icon(Icons.exit_to_app,
                    color: Colors.red.shade300, size: h * 0.025),
                const SizedBox(width: 6),
                Text('Exit',
                    style: TextStyle(
                        color: Colors.red.shade300,
                        fontSize: h * 0.018)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double h) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Chapter Quiz",
            style: TextStyle(
                fontSize: h * 0.04,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        SizedBox(height: h * 0.005),
        Text("Test your knowledge of ${widget.chapterTitle}",
            style: TextStyle(fontSize: h * 0.016, color: Colors.white60)),
      ],
    );
  }

  Widget _buildProgressBar(double h, double w) {
    final progress = (widget.controller.currentQuestionIndex + 1) /
        widget.controller.totalQuestionsInCurrentQuiz;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Progress",
                style:
                    TextStyle(color: Colors.white70, fontSize: h * 0.018)),
            Text("${(progress * 100).toInt()}%",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: h * 0.018,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: h * 0.01),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white12,
            valueColor:
                const AlwaysStoppedAnimation<Color>(Colors.blue),
            minHeight: h * 0.012,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionContent(double h, double w) {
    final question = widget.controller.currentQuestion;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(h * 0.03),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: h * 0.02, vertical: h * 0.008),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Question ${widget.controller.currentQuestionIndex + 1} of ${widget.controller.totalQuestionsInCurrentQuiz}",
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: h * 0.016,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: h * 0.02),
              Text(question.enonce,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: h * 0.022,
                      fontWeight: FontWeight.w500,
                      height: 1.5)),
              SizedBox(height: h * 0.03),
              Expanded(
                child: question.type == QuestionType.multipleChoice
                    ? _buildMultipleChoice(h, question)
                    : _buildOrdering(h, question),
              ),
              SizedBox(height: h * 0.02),
              if (_answerChecked != null)
                _buildFeedback(h)
              else
                _buildCheckButton(h, w),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMultipleChoice(double h, Question question) {
    final choices = [
      {"key": "A", "label": question.reponseA},
      {"key": "B", "label": question.reponseB},
      {"key": "C", "label": question.reponseC},
      {"key": "D", "label": question.reponseD},
    ];

    final isLocked = _answerChecked != null || _isQuestionValidated;

    Widget buildChoice(Map<String, String> choice) {
      final isSelected =
          widget.controller.currentQuiz.userAnswers[question.id] ==
              choice["key"];
      Color   borderColor = Colors.white24;
      Color   bgColor     = Colors.white.withValues(alpha: 0.08);
      Widget? trailingIcon;

      if (_answerChecked != null || _isQuestionValidated) {
        final isCorrectChoice = choice["key"] == question.bonneReponse;
        if (isCorrectChoice) {
          borderColor  = Colors.green;
          bgColor      = Colors.green.withValues(alpha: 0.2);
          trailingIcon = Icon(Icons.check_circle,
              color: Colors.green, size: h * 0.025);
        } else if (isSelected) {
          borderColor  = Colors.red;
          bgColor      = Colors.red.withValues(alpha: 0.2);
          trailingIcon =
              Icon(Icons.cancel, color: Colors.red, size: h * 0.025);
        }
      } else if (isSelected) {
        borderColor = Colors.blue;
        bgColor     = Colors.blue.withValues(alpha: 0.2);
      }

      return GestureDetector(
        onTap: isLocked
            ? null
            : () {
                setState(() {
                  widget.controller
                      .answerMultipleChoice(question.id, choice["key"]!);
                  _hasSelection = true;
                });
              },
        child: Container(
          height: h * 0.11,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          padding: EdgeInsets.symmetric(
              horizontal: h * 0.015, vertical: h * 0.01),
          child: Row(
            children: [
              Container(
                width: h * 0.035,
                height: h * 0.035,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected && !isLocked
                      ? Colors.blue
                      : Colors.white12,
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Center(
                  child: Text(choice["key"]!,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: h * 0.014,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(width: h * 0.012),
              Expanded(
                child: Text(choice["label"]!,
                    style: TextStyle(
                        color: Colors.white, fontSize: h * 0.016),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis),
              ),
              if (trailingIcon != null) trailingIcon,
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Row(children: [
            Expanded(child: buildChoice(choices[0])),
            SizedBox(width: h * 0.015),
            Expanded(child: buildChoice(choices[1])),
          ]),
          SizedBox(height: h * 0.015),
          Row(children: [
            Expanded(child: buildChoice(choices[2])),
            SizedBox(width: h * 0.015),
            Expanded(child: buildChoice(choices[3])),
          ]),
        ],
      ),
    );
  }

  Widget _buildOrdering(double h, Question question) {
    final isLocked = _answerChecked != null || _isQuestionValidated;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: h * 0.02, vertical: h * 0.01),
          decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.drag_handle, color: Colors.blue, size: h * 0.02),
              const SizedBox(width: 8),
              Text(
                  isLocked
                      ? "✓ Answer locked"
                      : "Drag and drop to order the steps",
                  style: TextStyle(
                      color: isLocked ? Colors.green : Colors.blue,
                      fontSize: h * 0.014)),
            ],
          ),
        ),
        SizedBox(height: h * 0.015),
        Expanded(
          child: ReorderableListView.builder(
            shrinkWrap: true,
            itemCount: _currentOrder.length,
            onReorder: isLocked
                ? (_, _) {}
                : (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex--;
                      final item = _currentOrder.removeAt(oldIndex);
                      _currentOrder.insert(newIndex, item);
                      widget.controller
                          .setOrdering(question.id, _currentOrder);
                      _hasSelection = true;
                    });
                  },
            itemBuilder: (context, index) {
              Color itemBorderColor = Colors.white24;
              Color textColor      = Colors.white;
              Color iconColor      = Colors.white54;
              Color badgeColor     = Colors.blue;

              if (isLocked) {
                final correctOrder = question.bonneReponse.split('|');
                final isCorrectPos = index < correctOrder.length &&
                    correctOrder[index] == _currentOrder[index];
                itemBorderColor =
                    isCorrectPos ? Colors.green : Colors.red;
                textColor  = isCorrectPos ? Colors.green : Colors.red;
                iconColor  = isCorrectPos ? Colors.green : Colors.red;
                badgeColor = isCorrectPos ? Colors.green : Colors.red;
              }

              return Container(
                key: ValueKey(_currentOrder[index]),
                margin: EdgeInsets.only(bottom: h * 0.01),
                padding: EdgeInsets.symmetric(
                    horizontal: h * 0.02, vertical: h * 0.012),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.white.withValues(alpha: 0.05)
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: itemBorderColor),
                ),
                child: Row(
                  children: [
                    Icon(Icons.drag_handle,
                        color: iconColor, size: h * 0.025),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(_currentOrder[index],
                            style: TextStyle(
                                color: textColor,
                                fontSize: h * 0.016,
                                fontFamily: 'monospace'))),
                    Container(
                      width: h * 0.035,
                      height: h * 0.035,
                      decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8)),
                      child: Center(
                          child: Text("${index + 1}",
                              style: TextStyle(
                                  color: badgeColor,
                                  fontSize: h * 0.014,
                                  fontWeight: FontWeight.bold))),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCheckButton(double h, double w) {
    return Padding(
      padding: EdgeInsets.only(top: h * 0.015),
      child: Center(
        child: GestureDetector(
          onTap: _hasSelection ? _checkAnswer : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
                horizontal: w * 0.04, vertical: h * 0.016),
            decoration: BoxDecoration(
              gradient: _hasSelection
                  ? const LinearGradient(
                      colors: [Color(0xFF2979FF), Color(0xFF1565C0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight)
                  : null,
              color: _hasSelection ? null : Colors.white12,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: _hasSelection ? Colors.blue : Colors.white24,
                  width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline,
                    color:
                        _hasSelection ? Colors.white : Colors.white38,
                    size: h * 0.022),
                const SizedBox(width: 10),
                Text("Check Answer",
                    style: TextStyle(
                        color: _hasSelection
                            ? Colors.white
                            : Colors.white38,
                        fontSize: h * 0.018,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedback(double h) {
    return Padding(
      padding: EdgeInsets.only(top: h * 0.015),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: h * 0.03, vertical: h * 0.01),
          decoration: BoxDecoration(
            color: _answerChecked!
                ? Colors.green.withValues(alpha: 0.2)
                : Colors.red.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: _answerChecked! ? Colors.green : Colors.red),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                  _answerChecked! ? Icons.check_circle : Icons.cancel,
                  color: _answerChecked! ? Colors.green : Colors.red,
                  size: h * 0.022),
              const SizedBox(width: 8),
              Text(_answerChecked! ? "✓ Correct!" : "✗ Incorrect!",
                  style: TextStyle(
                      color:
                          _answerChecked! ? Colors.green : Colors.red,
                      fontSize: h * 0.018,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(double h, double w) {
    final canGoNext = _answerChecked != null || _isQuestionValidated;
    final isLast    = widget.controller.isLastQuestion;

    return Padding(
      padding: EdgeInsets.only(top: h * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: widget.controller.isFirstQuestion ? null : _prevQuestion,
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: w * 0.02, vertical: h * 0.015),
              decoration: BoxDecoration(
                color: widget.controller.isFirstQuestion
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: widget.controller.isFirstQuestion
                        ? Colors.white12
                        : Colors.white30),
              ),
              child: Row(children: [
                Icon(Icons.chevron_left,
                    color: widget.controller.isFirstQuestion
                        ? Colors.white24
                        : Colors.white,
                    size: h * 0.02),
                Text("Prev",
                    style: TextStyle(
                        color: widget.controller.isFirstQuestion
                            ? Colors.white24
                            : Colors.white,
                        fontSize: h * 0.016)),
              ]),
            ),
          ),
          Text(
            "${widget.controller.currentQuestionIndex + 1} / ${widget.controller.totalQuestionsInCurrentQuiz}",
            style: TextStyle(
                color: Colors.white70,
                fontSize: h * 0.016,
                fontWeight: FontWeight.w500),
          ),
          GestureDetector(
            onTap: canGoNext ? _nextQuestion : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                  horizontal: w * 0.02, vertical: h * 0.015),
              decoration: BoxDecoration(
                gradient: canGoNext
                    ? (isLast
                        ? const LinearGradient(
                            colors: [Colors.green, Color(0xFF00C853)])
                        : const LinearGradient(
                            colors: [Colors.blue, Color(0xFF2196F3)]))
                    : null,
                color: canGoNext ? null : Colors.white12,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                Text(
                  isLast ? "Finish" : "Next",
                  style: TextStyle(
                      color:
                          canGoNext ? Colors.white : Colors.white38,
                      fontSize: h * 0.016,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                Icon(
                    isLast
                        ? Icons.check_circle
                        : Icons.chevron_right,
                    color:
                        canGoNext ? Colors.white : Colors.white38,
                    size: h * 0.018),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen(double h, double w) {
    final totalScore     = widget.controller.getTotalScore();
    final totalQuestions = widget.controller.session.totalPossibleScore;
    final percentage     = widget.controller.getPercentage();

    String   message;
    IconData icon;
    Color    color;

    if (percentage >= 80) {
      message = "Excellent! Chapter mastered! 🎉";
      icon    = Icons.emoji_events;
      color   = const Color(0xFFFFD700);
    } else if (percentage >= 60) {
      message = "Good job! Keep going! 👍";
      icon    = Icons.thumb_up;
      color   = Colors.green;
    } else if (percentage >= 40) {
      message = "Not bad! Review the chapter and try again! 📚";
      icon    = Icons.school;
      color   = Colors.orange;
    } else {
      message = "Keep practicing! You'll get there! 💪";
      icon    = Icons.fitness_center;
      color   = Colors.red;
    }

    final algo1Progress  = ProgressService.getAlgo1Progress();
    final algo2Progress  = ProgressService.getAlgo2Progress();
    final globalProgress = ProgressService.getGlobalProgress();

    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFF0D0D2B)),
          Opacity(
            opacity: 0.90,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/background.png"),
                    fit: BoxFit.cover),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: w * 0.55,
                    padding: EdgeInsets.all(h * 0.05),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 800),
                          builder: (context, value, child) =>
                              Transform.scale(
                            scale: value,
                            child: Container(
                              padding: EdgeInsets.all(h * 0.02),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color.withValues(alpha: 0.2),
                                border:
                                    Border.all(color: color, width: 3),
                              ),
                              child: Icon(icon,
                                  size: h * 0.08, color: color),
                            ),
                          ),
                        ),
                        SizedBox(height: h * 0.03),
                        Text("Quiz Completed!",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: h * 0.04,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: h * 0.01),
                        Text(message,
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: h * 0.018),
                            textAlign: TextAlign.center),
                        SizedBox(height: h * 0.03),

                        // Score circle
                        SizedBox(
                          width: h * 0.15,
                          height: h * 0.15,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: h * 0.15,
                                height: h * 0.15,
                                child: CircularProgressIndicator(
                                  value: totalQuestions > 0
                                      ? totalScore / totalQuestions
                                      : 0,
                                  strokeWidth: h * 0.012,
                                  backgroundColor: Colors.white24,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(color),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("$totalScore",
                                      style: TextStyle(
                                          color: color,
                                          fontSize: h * 0.045,
                                          fontWeight: FontWeight.bold)),
                                  Text("/ $totalQuestions",
                                      style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: h * 0.016)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: h * 0.02),
                        Text("$percentage%",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: h * 0.028,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: h * 0.04),

                        // Progress section — only show if first completion
                        if (_isFirstCompletion) ...[
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(h * 0.02),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.green.withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Icon(Icons.emoji_events,
                                      color: Colors.amber, size: h * 0.025),
                                  const SizedBox(width: 8),
                                  Text("Chapter Completed! 🎉",
                                      style: TextStyle(
                                          color: Colors.amber,
                                          fontSize: h * 0.018,
                                          fontWeight: FontWeight.bold)),
                                ]),
                                SizedBox(height: h * 0.02),
                                _buildProgressRow(
                                  h: h,
                                  label: "Algo 1",
                                  value: algo1Progress,
                                  color: const Color(0xFF00E5FF),
                                ),
                                SizedBox(height: h * 0.015),
                                _buildProgressRow(
                                  h: h,
                                  label: "Algo 2",
                                  value: algo2Progress,
                                  color: Colors.purple,
                                ),
                                SizedBox(height: h * 0.015),
                                _buildProgressRow(
                                  h: h,
                                  label: "Global",
                                  value: globalProgress,
                                  color: Colors.green,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: h * 0.03),
                        ],

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _resetQuiz,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10)),
                                padding: EdgeInsets.symmetric(
                                    horizontal: w * 0.02,
                                    vertical: h * 0.015),
                              ),
                              child: Row(children: [
                                Icon(Icons.replay,
                                    color: Colors.white,
                                    size: h * 0.02),
                                const SizedBox(width: 8),
                                Text("Try Again",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: h * 0.016)),
                              ]),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const DashboardPage())),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white24,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10)),
                                padding: EdgeInsets.symmetric(
                                    horizontal: w * 0.02,
                                    vertical: h * 0.015),
                              ),
                              child: Row(children: [
                                Icon(Icons.home,
                                    color: Colors.white,
                                    size: h * 0.02),
                                const SizedBox(width: 8),
                                Text("Dashboard",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: h * 0.016)),
                              ]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow({
    required double h,
    required String label,
    required double value,
    required Color  color,
  }) {
    return Row(
      children: [
        SizedBox(
          width: h * 0.07,
          height: h * 0.07,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: h * 0.07,
                height: h * 0.07,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: h * 0.008,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Text("${(value * 100).toInt()}%",
                  style: TextStyle(
                      color: color,
                      fontSize: h * 0.013,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        SizedBox(width: h * 0.015),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: h * 0.015,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: h * 0.006),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: h * 0.007,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}