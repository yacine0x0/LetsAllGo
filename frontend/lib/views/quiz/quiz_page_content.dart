
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import '../../models/quiz/quiz_model.dart';
import '../dashboard/dashboard_page.dart';

import '../files/files_page.dart';
import '../leaderboard/leaderboard_page.dart';
import 'quiz_selection_page.dart';

import '../../controllers/quiz/base_quiz_controller.dart';


class QuizPageContent extends StatefulWidget {
  final BaseQuizController controller;
  const QuizPageContent({super.key, required this.controller});

  @override
  State<QuizPageContent> createState() => _QuizPageContentState();
}

class _QuizPageContentState extends State<QuizPageContent> {
  // null  = pas encore checké
  // true  = checké et correct
  // false = checké et incorrect
  bool? _answerChecked;

  List<String> _currentOrder = [];
  bool _quizCompleted = false;

  // true si la question a déjà été validée dans une session précédente
  bool _isQuestionValidated = false;

  // true si l'utilisateur a sélectionné/ordonné une réponse (mais pas encore checké)
  bool _hasSelection = false;

  @override
  void initState() {
    super.initState();
    _loadQuestion();
  }

  // ─── Chargement d'une question ───────────────────────────────────────────────

  void _loadQuestion() {
    final q = widget.controller.currentQuestion;
    _isQuestionValidated =
        widget.controller.currentQuiz.isQuestionValidated(q.id);

    if (_isQuestionValidated) {
      // Question déjà validée → on affiche le résultat sans permettre de modifier
      _answerChecked = true;
      _hasSelection = true;
      if (q.type == QuestionType.ordering && q.codeLines != null) {
        final saved = widget.controller.currentQuiz.userOrderings[q.id];
        _currentOrder = saved != null ? List.from(saved) : List.from(q.codeLines!);
      }
    } else {
      // Question non validée → on repart d'un état propre
      _answerChecked = null;
      if (q.type == QuestionType.ordering && q.codeLines != null) {
        final saved = widget.controller.currentQuiz.userOrderings[q.id];
        if (saved != null) {
          _currentOrder = List.from(saved);
          _hasSelection = true; // l'ordre avait déjà été modifié
        } else {
          _currentOrder = List.from(q.codeLines!);
          _hasSelection = false;
        }
      } else {
        // Multiple choice : sélection sauvegardée ?
        _hasSelection =
            widget.controller.currentQuiz.userAnswers.containsKey(q.id);
      }
    }
  }

  // ─── Navigation ──────────────────────────────────────────────────────────────

  void _nextQuestion() {
    if (widget.controller.isLastQuestion) {
      if (widget.controller.isLastQuiz) {
        setState(() => _quizCompleted = true);
      } else {
        widget.controller.nextQuiz();
        setState(() {
          _answerChecked = null;
          _currentOrder = [];
          _hasSelection = false;
          _isQuestionValidated = false;
          _loadQuestion();
        });
      }
    } else {
      widget.controller.nextQuestion();
      setState(() {
        _answerChecked = null;
        _currentOrder = [];
        _hasSelection = false;
        _isQuestionValidated = false;
        _loadQuestion();
      });
    }
  }

  void _prevQuestion() {
    widget.controller.prevQuestion();
    setState(() {
      _answerChecked = null;
      _currentOrder = [];
      _hasSelection = false;
      _isQuestionValidated = false;
      _loadQuestion();
    });
  }

  void _resetQuiz() {
    widget.controller.resetSession();
    setState(() {
      _answerChecked = null;
      _quizCompleted = false;
      _currentOrder = [];
      _hasSelection = false;
      _isQuestionValidated = false;
      _loadQuestion();
    });
  }

  // ─── Action Check ─────────────────────────────────────────────────────────────

  void _checkAnswer() {
    final q = widget.controller.currentQuestion;
    final isCorrect = widget.controller.checkAnswer(q.id);
    setState(() {
      _answerChecked = isCorrect;
      _isQuestionValidated =
          widget.controller.currentQuiz.isQuestionValidated(q.id);
    });
  }

  // ─── Build principal ─────────────────────────────────────────────────────────

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
              _buildTopNavBar(h, w),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.03,
                    vertical: h * 0.01,
                  ),
                  child: Row(
                    children: [
                      Expanded(
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
                                  width: 1.5,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(h * 0.03),
                                child: Column(
                                  children: [
                                    _buildHeader(h),
                                    SizedBox(height: h * 0.02),
                                    _buildProgressBar(h, w),
                                    SizedBox(height: h * 0.02),
                                    Expanded(
                                      child: _buildQuestionContent(h, w),
                                    ),
                                    _buildBottomNav(h, w),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: w * 0.02),
                      _buildRightPanel(h, w),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Top Nav ─────────────────────────────────────────────────────────────────

  Widget _buildTopNavBar(double h, double w) {
    return Container(
      height: h * 0.11,
      padding: EdgeInsets.symmetric(horizontal: w * 0.02),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          Image.asset(
            "assets/images/icone_dash.png",
            height: h * 0.12,
            width: w * 0.12,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.school, color: Colors.blue, size: 40),
          ),
          SizedBox(width: w * 0.02),
          Container(width: 1, height: h * 0.05, color: Colors.white24),
          SizedBox(width: w * 0.02),
          GestureDetector(
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DashboardPage()),
            ),
            child: _buildNavButton(Icons.home_outlined, "Home", h),
          ),
          SizedBox(width: w * 0.02),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LeaderboardPage()),
            ),
            child: _buildNavButton(Icons.emoji_events_outlined, "Leaderboard", h),
          ),
          SizedBox(width: w * 0.02),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FilesPage()),
            ),
            child: _buildNavButton(Icons.folder_outlined, "Files", h),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.015,
              vertical: h * 0.008,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: h * 0.030,
                  backgroundColor: Colors.blue,
                  child: Text(
                    "H",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: h * 0.025,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Hamid_09",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: h * 0.020,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, String label, double h) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: h * 0.035),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(color: Colors.white70, fontSize: h * 0.020)),
      ],
    );
  }

  // ─── Completion Screen ────────────────────────────────────────────────────────

  Widget _buildCompletionScreen(double h, double w) {
    final totalScore = widget.controller.getTotalScore();
    final totalQuestions = widget.controller.session.totalPossibleScore;
    final percentage = widget.controller.getPercentage();

    String message;
    IconData icon;
    Color color;

    if (percentage >= 80) {
      message = "Excellent! You're a pro! 🎉";
      icon = Icons.emoji_events;
      color = const Color(0xFFFFD700);
    } else if (percentage >= 60) {
      message = "Good job! Keep going! 👍";
      icon = Icons.thumb_up;
      color = Colors.green;
    } else if (percentage >= 40) {
      message = "Not bad! Review and try again! 📚";
      icon = Icons.school;
      color = Colors.orange;
    } else {
      message = "Keep practicing! You'll get there! 💪";
      icon = Icons.fitness_center;
      color = Colors.red;
    }

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
          Center(
            child: SingleChildScrollView(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: w * 0.45,
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
                          builder: (context, value, child) => Transform.scale(
                            scale: value,
                            child: Container(
                              padding: EdgeInsets.all(h * 0.02),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color.withValues(alpha: 0.2),
                                border: Border.all(color: color, width: 3),
                              ),
                              child:
                                  Icon(icon, size: h * 0.08, color: color),
                            ),
                          ),
                        ),
                        SizedBox(height: h * 0.03),
                        Text(
                          "Quiz Completed!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: h * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: h * 0.02),
                        Text(
                          message,
                          style: TextStyle(
                              color: Colors.white70, fontSize: h * 0.018),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: h * 0.03),
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
                                  Text(
                                    "$totalScore",
                                    style: TextStyle(
                                      color: color,
                                      fontSize: h * 0.045,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "/ $totalQuestions",
                                    style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: h * 0.016),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: h * 0.02),
                        Text(
                          "$percentage%",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: h * 0.028,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: h * 0.04),
                        Container(
                          height: h * 0.008,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FractionallySizedBox(
                            widthFactor: percentage / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: h * 0.04),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const QuizSelectionPage()),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white24,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                padding: EdgeInsets.symmetric(
                                    horizontal: w * 0.02,
                                    vertical: h * 0.015),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.refresh,
                                      color: Colors.white,
                                      size: h * 0.02),
                                  const SizedBox(width: 8),
                                  Text("New Quiz",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: h * 0.016)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: _resetQuiz,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                padding: EdgeInsets.symmetric(
                                    horizontal: w * 0.02,
                                    vertical: h * 0.015),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.replay,
                                      color: Colors.white,
                                      size: h * 0.02),
                                  const SizedBox(width: 8),
                                  Text("Try Again",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: h * 0.016)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: h * 0.02),
                        TextButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const DashboardPage()),
                          ),
                          child: Text(
                            "Back to Dashboard",
                            style: TextStyle(
                                color: Colors.white54,
                                fontSize: h * 0.014),
                          ),
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

  // ─── Header ───────────────────────────────────────────────────────────────────

  Widget _buildHeader(double h) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quiz in Progress",
          style: TextStyle(
            fontSize: h * 0.04,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: h * 0.005),
        Text(
          "Chapter: ${widget.controller.currentQuiz.chapter}",
          style: TextStyle(fontSize: h * 0.016, color: Colors.white60),
        ),
      ],
    );
  }

  // ─── Progress Bar ────────────────────────────────────────────────────────────

  Widget _buildProgressBar(double h, double w) {
    final currentQuizProgress =
        (widget.controller.currentQuestionIndex + 1) /
            widget.controller.totalQuestionsInCurrentQuiz;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Course progression",
                style:
                    TextStyle(color: Colors.white70, fontSize: h * 0.018)),
            Text(
              "${(currentQuizProgress * 100).toInt()}%",
              style: TextStyle(
                color: Colors.white,
                fontSize: h * 0.018,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: h * 0.01),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: currentQuizProgress,
            backgroundColor: Colors.white12,
            valueColor:
                const AlwaysStoppedAnimation<Color>(Colors.blue),
            minHeight: h * 0.012,
          ),
        ),
      ],
    );
  }

  // ─── Question Content ─────────────────────────────────────────────────────────

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
                  "Question ${widget.controller.currentQuestionIndex + 1}"
                  " of ${widget.controller.totalQuestionsInCurrentQuiz}",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: h * 0.016,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: h * 0.02),
              Text(
                question.enonce,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: h * 0.022,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              SizedBox(height: h * 0.03),
              Expanded(
                child: question.type == QuestionType.multipleChoice
                    ? _buildMultipleChoice(h, question)
                    : _buildOrdering(h, question),
              ),
              SizedBox(height: h * 0.02),

              // ── Feedback + bouton Check ──────────────────────────────────
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

  // ─── Multiple Choice ──────────────────────────────────────────────────────────

  Widget _buildMultipleChoice(double h, Question question) {
    final choices = [
      {"key": "A", "label": question.reponseA},
      {"key": "B", "label": question.reponseB},
      {"key": "C", "label": question.reponseC},
      {"key": "D", "label": question.reponseD},
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 3.5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: choices.map((choice) {
        final isSelected =
            widget.controller.currentQuiz.userAnswers[question.id] ==
                choice["key"];

        // Couleurs selon état
        Color borderColor = Colors.white24;
        Color bgColor = Colors.white.withValues(alpha: 0.08);

        if (_isQuestionValidated && isSelected) {
          // Déjà validé dans une session précédente → vert
          borderColor = Colors.green;
          bgColor = Colors.green.withValues(alpha: 0.2);
        } else if (_answerChecked != null && isSelected) {
          // Vient d'être checké
          borderColor =
              _answerChecked! ? Colors.green : Colors.red;
          bgColor = _answerChecked!
              ? Colors.green.withValues(alpha: 0.2)
              : Colors.red.withValues(alpha: 0.2);
        } else if (isSelected) {
          // Sélectionné mais pas encore checké → bleu
          borderColor = Colors.blue;
          bgColor = Colors.blue.withValues(alpha: 0.2);
        }

        // Désactivé si déjà checké ou déjà validé
        final isLocked = _answerChecked != null || _isQuestionValidated;

        return GestureDetector(
          onTap: isLocked
              ? null
              : () {
                  setState(() {
                    widget.controller.answerMultipleChoice(
                        question.id, choice["key"]!);
                    _hasSelection = true;
                    // PAS de _answerChecked ici → l'utilisateur doit cliquer Check
                  });
                },
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: h * 0.01),
                child: Text(
                  choice["label"]!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: h * 0.016,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Ordering ─────────────────────────────────────────────────────────────────

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
            borderRadius: BorderRadius.circular(8),
          ),
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
                  fontSize: h * 0.014,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: h * 0.015),
        Expanded(
          child: ReorderableListView.builder(
            shrinkWrap: true,
            itemCount: _currentOrder.length,
            onReorder: isLocked
                ? (_, __) {}
                : (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex--;
                      final item = _currentOrder.removeAt(oldIndex);
                      _currentOrder.insert(newIndex, item);
                      widget.controller
                          .setOrdering(question.id, _currentOrder);
                      _hasSelection = true;
                      // PAS de _answerChecked ici → l'utilisateur doit cliquer Check
                    });
                  },
            itemBuilder: (context, index) {
              // Couleur selon état
              Color itemBorderColor = Colors.white24;
              Color textColor = Colors.white;
              Color iconColor = Colors.white54;
              Color badgeColor = Colors.blue;

              if (isLocked && _answerChecked == true) {
                itemBorderColor = Colors.green;
                textColor = Colors.green;
                iconColor = Colors.green;
                badgeColor = Colors.green;
              } else if (isLocked && _answerChecked == false) {
                itemBorderColor = Colors.red;
                textColor = Colors.red;
                iconColor = Colors.red;
                badgeColor = Colors.red;
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
                      Colors.white.withValues(alpha: 0.05),
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
                      child: Text(
                        _currentOrder[index],
                        style: TextStyle(
                          color: textColor,
                          fontSize: h * 0.016,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    Container(
                      width: h * 0.035,
                      height: h * 0.035,
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          "${index + 1}",
                          style: TextStyle(
                            color: badgeColor,
                            fontSize: h * 0.014,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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

  // ─── Bouton Check ─────────────────────────────────────────────────────────────

  Widget _buildCheckButton(double h, double w) {
    // Désactivé si aucune sélection / ordre non modifié
    final canCheck = _hasSelection;

    return Padding(
      padding: EdgeInsets.only(top: h * 0.015),
      child: Center(
        child: GestureDetector(
          onTap: canCheck ? _checkAnswer : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
                horizontal: w * 0.04, vertical: h * 0.016),
            decoration: BoxDecoration(
              gradient: canCheck
                  ? const LinearGradient(
                      colors: [Color(0xFF2979FF), Color(0xFF1565C0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: canCheck ? null : Colors.white12,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: canCheck ? Colors.blue : Colors.white24,
                width: 1.5,
              ),
              boxShadow: canCheck
                  ? [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 1,
                      )
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: canCheck ? Colors.white : Colors.white38,
                  size: h * 0.022,
                ),
                const SizedBox(width: 10),
                Text(
                  "Check Answer",
                  style: TextStyle(
                    color: canCheck ? Colors.white : Colors.white38,
                    fontSize: h * 0.018,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Feedback ─────────────────────────────────────────────────────────────────

  Widget _buildFeedback(double h) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: child,
        ),
      ),
      child: Padding(
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
                color: _answerChecked! ? Colors.green : Colors.red,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _answerChecked! ? Icons.check_circle : Icons.cancel,
                  color: _answerChecked! ? Colors.green : Colors.red,
                  size: h * 0.022,
                ),
                const SizedBox(width: 8),
                Text(
                  _answerChecked! ? "✓ Correct!" : "✗ Incorrect!",
                  style: TextStyle(
                    color: _answerChecked! ? Colors.green : Colors.red,
                    fontSize: h * 0.018,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Bottom Nav ───────────────────────────────────────────────────────────────

  Widget _buildBottomNav(double h, double w) {
    // On peut passer à la question suivante seulement si :
    // - la question a été checkée OU déjà validée
    final canGoNext = _answerChecked != null || _isQuestionValidated;

    return Padding(
      padding: EdgeInsets.only(top: h * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Prev ──────────────────────────────────────────────────────────
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
                      : Colors.white30,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.chevron_left,
                    color: widget.controller.isFirstQuestion
                        ? Colors.white24
                        : Colors.white,
                    size: h * 0.02,
                  ),
                  Text(
                    "Prev",
                    style: TextStyle(
                      color: widget.controller.isFirstQuestion
                          ? Colors.white24
                          : Colors.white,
                      fontSize: h * 0.016,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Indicateur ────────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: w * 0.02, vertical: h * 0.008),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${widget.controller.currentQuestionIndex + 1}"
              " / ${widget.controller.totalQuestionsInCurrentQuiz}",
              style: TextStyle(
                color: Colors.white70,
                fontSize: h * 0.016,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // ── Next / Finish ─────────────────────────────────────────────────
          GestureDetector(
            onTap: canGoNext ? _nextQuestion : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                  horizontal: w * 0.02, vertical: h * 0.015),
              decoration: BoxDecoration(
                gradient: canGoNext
                    ? ((widget.controller.isLastQuestion &&
                            widget.controller.isLastQuiz)
                        ? const LinearGradient(
                            colors: [Colors.green, Color(0xFF00C853)])
                        : const LinearGradient(
                            colors: [Colors.blue, Color(0xFF2196F3)]))
                    : null,
                color: canGoNext ? null : Colors.white12,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Text(
                    (widget.controller.isLastQuestion &&
                            widget.controller.isLastQuiz)
                        ? "Finish"
                        : "Next",
                    style: TextStyle(
                      color: canGoNext ? Colors.white : Colors.white38,
                      fontSize: h * 0.016,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    (widget.controller.isLastQuestion &&
                            widget.controller.isLastQuiz)
                        ? Icons.check_circle
                        : Icons.chevron_right,
                    color: canGoNext ? Colors.white : Colors.white38,
                    size: h * 0.018,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Right Panel ──────────────────────────────────────────────────────────────

  Widget _buildRightPanel(double h, double w) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: w * 0.18,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          padding: EdgeInsets.all(h * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.question_answer,
                      color: Colors.blue, size: h * 0.022),
                  const SizedBox(width: 8),
                  Text(
                    "Questions",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: h * 0.022,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: h * 0.02),
              Expanded(
                child: ListView.builder(
                  itemCount:
                      widget.controller.totalQuestionsInCurrentQuiz,
                  itemBuilder: (context, index) {
                    final isCurrent =
                        widget.controller.currentQuestionIndex == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          widget.controller.currentQuiz
                              .currentQuestionIndex = index;
                          _answerChecked = null;
                          _currentOrder = [];
                          _hasSelection = false;
                          _isQuestionValidated = false;
                          _loadQuestion();
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: h * 0.01),
                        padding:
                            EdgeInsets.symmetric(vertical: h * 0.012),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? Colors.blue.withValues(alpha: 0.3)
                              : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                isCurrent ? Colors.blue : Colors.white24,
                            width: isCurrent ? 1.5 : 1,
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.help_outline,
                                color: isCurrent
                                    ? Colors.blue
                                    : Colors.white54,
                                size: h * 0.016,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Question ${index + 1}",
                                style: TextStyle(
                                  color: isCurrent
                                      ? Colors.white
                                      : Colors.white70,
                                  fontSize: h * 0.014,
                                  fontWeight: isCurrent
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: h * 0.01),
              Container(
                padding: EdgeInsets.all(h * 0.015),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withValues(alpha: 0.3),
                      Colors.purple.withValues(alpha: 0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.blue.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    Text(
                      "Session Score",
                      style: TextStyle(
                          color: Colors.white54, fontSize: h * 0.012),
                    ),
                    Text(
                      "${widget.controller.getTotalScore()}"
                      " / ${widget.controller.session.totalPossibleScore}",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: h * 0.028,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: h * 0.005),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: widget.controller.session.totalPossibleScore >
                                0
                            ? widget.controller.getTotalScore() /
                                widget.controller.session.totalPossibleScore
                            : 0,
                        minHeight: h * 0.004,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}