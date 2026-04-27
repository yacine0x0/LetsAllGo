import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:ui';

import '../../service/language_service.dart';

import '../../models/quiz/quiz_model.dart';
import '../dashboard/dashboard_page.dart';
import '../files/files_page.dart';
import '../leaderboard/leaderboard_page.dart';
import 'quiz_selection_page.dart';
import '../../controllers/quiz/base_quiz_controller.dart';
import '../../controllers/auth/login_controller.dart';
import '../../service/quiz/quiz_score_service.dart';

class QuizPageContent extends StatefulWidget {
  final BaseQuizController controller;
  final String algoType;

  const QuizPageContent({
    super.key,
    required this.controller,
    this.algoType = 'algo1',
  });

  @override
  State<QuizPageContent> createState() => _QuizPageContentState();
}

class _QuizPageContentState extends State<QuizPageContent> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool?        _answerChecked      = null;
  List<String> _currentOrder       = [];
  bool         _quizCompleted      = false;
  bool         _isQuestionValidated = false;
  bool         _hasSelection       = false;
  int          _pointsGagnes       = 0;
  bool         _isSubmitted        = false;

  final _user = LoginController.currentUser;
  late LanguageService _lang;

  // ══════════════════════════════════════════
  // SOUND — edit the file names here to change sounds
  // ══════════════════════════════════════════
  static const String _soundCorrect  = 'sounds/CORRECTANSWER.mp3';
  static const String _soundWrong    = 'sounds/WRONGANSWER.mp3';
  static const String _soundButton1  = 'sounds/PRESS_1.wav';
  static const String _soundButton2  = 'sounds/PRESS_2.wav';
  static const String _soundCheers   = 'sounds/CHEERS.wav';

  Future<void> _playSound(String soundPath) async {
    await _audioPlayer.play(AssetSource(soundPath));
  }

  @override
  void initState() {
    super.initState();
    _lang = Provider.of<LanguageService>(context, listen: false);
    _loadQuestion();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
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
      final alreadyAnsweredMC =
          widget.controller.currentQuiz.userAnswers.containsKey(q.id);
      final alreadyAnsweredOrd =
          widget.controller.currentQuiz.userOrderings.containsKey(q.id);

      if (q.type == QuestionType.multipleChoice && alreadyAnsweredMC) {
        final userAnswer =
            widget.controller.currentQuiz.userAnswers[q.id];
        _answerChecked = (userAnswer == q.bonneReponse);
        _hasSelection  = true;
      } else if (q.type == QuestionType.ordering && alreadyAnsweredOrd) {
        final saved = widget.controller.currentQuiz.userOrderings[q.id];
        _currentOrder =
            saved != null ? List.from(saved) : List.from(q.codeLines!);
        final correctOrder = q.bonneReponse.split('|');
        _answerChecked =
            (_currentOrder.join('|') == correctOrder.join('|'));
        _hasSelection = true;
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
  }

  void _nextQuestion() {
    _playSound(_soundButton1);
    if (widget.controller.isLastQuestion) {
      if (widget.controller.isLastQuiz) {
        _submitAndComplete();
      } else {
        widget.controller.nextQuiz();
        setState(() {
          _answerChecked       = null;
          _currentOrder        = [];
          _hasSelection        = false;
          _isQuestionValidated = false;
          _loadQuestion();
        });
      }
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
    _playSound(_soundButton1);
    widget.controller.prevQuestion();
    setState(() {
      _answerChecked       = null;
      _currentOrder        = [];
      _hasSelection        = false;
      _isQuestionValidated = false;
      _loadQuestion();
    });
  }

  Future<void> _submitAndComplete() async {
    if (_isSubmitted) return;
    _isSubmitted = true;

   
    final totalScore = widget.controller.getTotalScore();
    final points     = await QuizScoreService.submitScore(
      correctAnswers: totalScore,
      algoType:       widget.algoType,
    );

    if (!mounted) return;

    if (points != null && points > 0) {
      _pointsGagnes = points;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.star, color: Colors.amber, size: 20),
          const SizedBox(width: 10),
          Text(
            _lang.t('+$points Go Points !', '+$points Go Points !'),
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ]),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ));
    }
     _playSound(_soundCheers);

    setState(() => _quizCompleted = true);
  }

  void _resetQuiz() {
    _playSound(_soundButton2);
    widget.controller.resetSession();
    setState(() {
      _answerChecked       = null;
      _quizCompleted       = false;
      _currentOrder        = [];
      _hasSelection        = false;
      _isQuestionValidated = false;
      _pointsGagnes        = 0;
      _isSubmitted         = false;
      _loadQuestion();
    });
  }

  void _quitQuiz() {
    _playSound(_soundButton2);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A3E),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text(
          _lang.t('Quitter le quiz ?', 'Quit Quiz?'),
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          _lang.t('Ta progression sera perdue. Es-tu sûr ?',
              'Your progress will be lost. Are you sure?'),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _playSound(_soundButton2);
              Navigator.pop(ctx);
            },
            child: Text(_lang.t('Annuler', 'Cancel'),
                style: const TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              _playSound(_soundButton2);
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const QuizSelectionPage()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(_lang.t('Quitter', 'Quit'),
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _checkAnswer() {
    final q         = widget.controller.currentQuestion;
    final isCorrect = widget.controller.checkAnswer(q.id);

    // Play correct or wrong sound based on the answer
    _playSound(isCorrect ? _soundCorrect : _soundWrong);

    setState(() {
      _answerChecked       = isCorrect;
      _isQuestionValidated =
          widget.controller.currentQuiz.isQuestionValidated(q.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    _lang = context.watch<LanguageService>();
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
                    fit: BoxFit.cover),
              ),
            ),
          ),
          Column(
            children: [
              _buildTopNavBar(h, w),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: w * 0.03, vertical: h * 0.01),
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter:
                                ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withValues(alpha: 0.02),
                                borderRadius:
                                    BorderRadius.circular(16),
                                border: Border.all(
                                    color: Colors.white
                                        .withValues(alpha: 0.15),
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
                                    Expanded(
                                        child:
                                            _buildQuestionContent(h, w)),
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

  Widget _buildTopNavBar(double h, double w) {
    final String initiale = _user?.prenom?.isNotEmpty == true
        ? _user!.prenom![0].toUpperCase()
        : '?';
    final String displayName = _user != null
        ? '${_user!.prenom} ${_user!.nom}'.trim()
        : _lang.t('Invité', 'Guest');

    return Container(
      height: h * 0.11,
      padding: EdgeInsets.symmetric(horizontal: w * 0.02),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        border: Border(
            bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          Image.asset("assets/images/icone_dash.png",
              height: h * 0.12,
              width: w * 0.12,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.school, color: Colors.blue, size: 40)),
          SizedBox(width: w * 0.02),
          Container(width: 1, height: h * 0.05, color: Colors.white24),
          SizedBox(width: w * 0.02),
          GestureDetector(
            onTap: () {
              _playSound(_soundButton1);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(
                      builder: (_) => const DashboardPage()));
            },
            child: _buildNavButton(
                Icons.home_outlined, _lang.t("Accueil", "Home"), h),
          ),
          SizedBox(width: w * 0.02),
          GestureDetector(
            onTap: () {
              _playSound(_soundButton1);
              Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => const LeaderboardPage()));
            },
            child: _buildNavButton(Icons.emoji_events_outlined,
                _lang.t("Classement", "Leaderboard"), h),
          ),
          SizedBox(width: w * 0.02),
          GestureDetector(
            onTap: () {
              _playSound(_soundButton1);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const FilesPage()));
            },
            child: _buildNavButton(Icons.folder_outlined,
                _lang.t("Fichiers", "Files"), h),
          ),
          SizedBox(width: w * 0.02),
          GestureDetector(
            onTap: _quitQuiz,
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: w * 0.015, vertical: h * 0.008),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: Colors.red.withValues(alpha: 0.4)),
              ),
              child: Row(children: [
                Icon(Icons.exit_to_app,
                    color: Colors.red.shade300, size: h * 0.025),
                const SizedBox(width: 6),
                Text(_lang.t("Quitter le quiz", "Quit Quiz"),
                    style: TextStyle(
                        color: Colors.red.shade300,
                        fontSize: h * 0.018)),
              ]),
            ),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: w * 0.015, vertical: h * 0.008),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(children: [
              CircleAvatar(
                radius: h * 0.030,
                backgroundColor: Colors.blue,
                child: Text(initiale,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: h * 0.025,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Text(displayName,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: h * 0.020,
                      fontWeight: FontWeight.w500)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, String label, double h) {
    return Row(children: [
      Icon(icon, color: Colors.white70, size: h * 0.035),
      const SizedBox(width: 6),
      Text(label,
          style: TextStyle(color: Colors.white70, fontSize: h * 0.020)),
    ]);
  }

  Widget _buildCompletionScreen(double h, double w) {
    final totalScore     = widget.controller.getTotalScore();
    final totalQuestions = widget.controller.session.totalPossibleScore;
    final percentage     = widget.controller.getPercentage();

    String   message = _lang.t("Continue à t'entraîner ! Tu vas y arriver ! 💪", "Keep practicing! You'll get there! 💪");
    IconData icon    = Icons.fitness_center;
    Color    color   = Colors.red;

    if (percentage >= 80) {
      message = _lang.t("Excellent ! Tu es un pro ! 🎉", "Excellent! You're a pro! 🎉");
      icon  = Icons.emoji_events;
      color = const Color(0xFFFFD700);
    } else if (percentage >= 60) {
      message = _lang.t("Bon travail ! Continue comme ça ! 👍", "Good job! Keep going! 👍");
      icon  = Icons.thumb_up;
      color = Colors.green;
    } else if (percentage >= 40) {
      message = _lang.t("Pas mal ! Revois et réessaie ! 📚", "Not bad! Review and try again! 📚");
      icon  = Icons.school;
      color = Colors.orange;
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
                          image: AssetImage(
                              "assets/images/background.png"),
                          fit: BoxFit.cover)))),
          Center(
            child: SingleChildScrollView(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter:
                      ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: w * 0.45,
                    padding: EdgeInsets.all(h * 0.05),
                    decoration: BoxDecoration(
                        color:
                            Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(24),
                        border:
                            Border.all(color: Colors.white24)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration:
                              const Duration(milliseconds: 800),
                          builder: (context, value, child) =>
                              Transform.scale(
                            scale: value,
                            child: Container(
                              padding: EdgeInsets.all(h * 0.02),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: color
                                      .withValues(alpha: 0.2),
                                  border: Border.all(
                                      color: color, width: 3)),
                              child: Icon(icon,
                                  size: h * 0.08, color: color),
                            ),
                          ),
                        ),
                        SizedBox(height: h * 0.03),
                        Text(
                            _lang.t(
                                "Quiz terminé !", "Quiz Completed!"),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: h * 0.04,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: h * 0.02),
                        Text(message,
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: h * 0.018),
                            textAlign: TextAlign.center),
                        if (_pointsGagnes > 0) ...[
                          SizedBox(height: h * 0.02),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: w * 0.03,
                                vertical: h * 0.015),
                            decoration: BoxDecoration(
                                color: Colors.amber
                                    .withValues(alpha: 0.15),
                                borderRadius:
                                    BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.amber
                                        .withValues(alpha: 0.5))),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  _lang.t(
                                      '+${_pointsGagnes} Points Go !',
                                      '+${_pointsGagnes} Go Points !'),
                                  style: const TextStyle(
                                      color: Colors.amber,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                                      AlwaysStoppedAnimation<Color>(
                                          color),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("$totalScore",
                                      style: TextStyle(
                                          color: color,
                                          fontSize: h * 0.045,
                                          fontWeight:
                                              FontWeight.bold)),
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
                        Container(
                          height: h * 0.008,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius:
                                  BorderRadius.circular(4)),
                          child: FractionallySizedBox(
                            widthFactor: percentage / 100,
                            child: Container(
                                decoration: BoxDecoration(
                                    color: color,
                                    borderRadius:
                                        BorderRadius.circular(4))),
                          ),
                        ),
                        SizedBox(height: h * 0.04),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _playSound(_soundButton2);
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const QuizSelectionPage()));
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white24,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: w * 0.02,
                                      vertical: h * 0.015)),
                              child: Row(children: [
                                Icon(Icons.refresh,
                                    color: Colors.white,
                                    size: h * 0.02),
                                const SizedBox(width: 8),
                                Text(
                                    _lang.t("Nouveau Quiz",
                                        "New Quiz"),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: h * 0.016)),
                              ]),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: _resetQuiz,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: w * 0.02,
                                      vertical: h * 0.015)),
                              child: Row(children: [
                                Icon(Icons.replay,
                                    color: Colors.white,
                                    size: h * 0.02),
                                const SizedBox(width: 8),
                                Text(
                                    _lang.t(
                                        "Réessayer", "Try Again"),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: h * 0.016)),
                              ]),
                            ),
                          ],
                        ),
                        SizedBox(height: h * 0.02),
                        TextButton(
                          onPressed: () {
                            _playSound(_soundButton2);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const DashboardPage()));
                          },
                          child: Text(
                              _lang.t("Retour au tableau de bord",
                                  "Back to Dashboard"),
                              style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: h * 0.014)),
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

  Widget _buildHeader(double h) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_lang.t("Quiz en cours", "Quiz in Progress"),
            style: TextStyle(
                fontSize: h * 0.04,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        SizedBox(height: h * 0.005),
        Text(
            _lang.t("Chapitre : ", "Chapter: ") +
                "${widget.controller.currentQuiz.chapter}",
            style:
                TextStyle(fontSize: h * 0.016, color: Colors.white60)),
      ],
    );
  }

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
            Text(_lang.t("Progression du quiz", "Course progression"),
                style: TextStyle(
                    color: Colors.white70, fontSize: h * 0.018)),
            Text("${(currentQuizProgress * 100).toInt()}%",
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
                    borderRadius: BorderRadius.circular(20)),
                child: Text(
                  _lang.t("Question ", "Question ") +
                      "${widget.controller.currentQuestionIndex + 1} ${_lang.t("sur", "of")} ${widget.controller.totalQuestionsInCurrentQuiz}",
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

      if (isLocked) {
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
                _playSound(_soundButton1);
                setState(() {
                  widget.controller.answerMultipleChoice(
                      question.id, choice["key"]!);
                  _hasSelection = true;
                });
              },
        child: Container(
          height: h * 0.11,
          decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1.5)),
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
                    border:
                        Border.all(color: borderColor, width: 1.5)),
                child: Center(
                    child: Text(choice["key"]!,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: h * 0.014,
                            fontWeight: FontWeight.bold))),
              ),
              SizedBox(width: h * 0.012),
              Expanded(
                  child: Text(choice["label"]!,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: h * 0.016),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis)),
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
            Expanded(child: buildChoice(choices[1]))
          ]),
          SizedBox(height: h * 0.015),
          Row(children: [
            Expanded(child: buildChoice(choices[2])),
            SizedBox(width: h * 0.015),
            Expanded(child: buildChoice(choices[3]))
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
              Icon(Icons.drag_handle,
                  color: Colors.blue, size: h * 0.02),
              const SizedBox(width: 8),
              Text(
                  isLocked
                      ? _lang.t("Réponse verrouillée",
                          "Answer locked")
                      : _lang.t(
                          "Glisse pour ordonner les étapes",
                          "Drag and drop to order the steps"),
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
                    _playSound(_soundButton1);
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
                final correctOrder =
                    question.bonneReponse.split('|');
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
                      end: Alignment.centerRight),
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
                      colors: [
                          Color(0xFF2979FF),
                          Color(0xFF1565C0)
                        ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight)
                  : null,
              color: canCheck ? null : Colors.white12,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: canCheck ? Colors.blue : Colors.white24,
                  width: 1.5),
              boxShadow: canCheck
                  ? [
                      BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 1)
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline,
                    color: canCheck ? Colors.white : Colors.white38,
                    size: h * 0.022),
                const SizedBox(width: 10),
                Text(_lang.t("Vérifier la réponse", "Check Answer"),
                    style: TextStyle(
                        color:
                            canCheck ? Colors.white : Colors.white38,
                        fontSize: h * 0.018,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedback(double h) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)), child: child),
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
                  color:
                      _answerChecked! ? Colors.green : Colors.red),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                    _answerChecked!
                        ? Icons.check_circle
                        : Icons.cancel,
                    color:
                        _answerChecked! ? Colors.green : Colors.red,
                    size: h * 0.022),
                const SizedBox(width: 8),
                Text(
                    _answerChecked!
                        ? _lang.t("✓ Correct !", "✓ Correct!")
                        : _lang.t("✗ Incorrect !", "✗ Incorrect!"),
                    style: TextStyle(
                        color: _answerChecked!
                            ? Colors.green
                            : Colors.red,
                        fontSize: h * 0.018,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(double h, double w) {
    final canGoNext = _answerChecked != null || _isQuestionValidated;

    return Padding(
      padding: EdgeInsets.only(top: h * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: widget.controller.isFirstQuestion
                ? null
                : _prevQuestion,
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
                Text(_lang.t("Précédent", "Prev"),
                    style: TextStyle(
                        color: widget.controller.isFirstQuestion
                            ? Colors.white24
                            : Colors.white,
                        fontSize: h * 0.016)),
              ]),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: w * 0.02, vertical: h * 0.008),
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20)),
            child: Text(
              "${widget.controller.currentQuestionIndex + 1} / ${widget.controller.totalQuestionsInCurrentQuiz}",
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: h * 0.016,
                  fontWeight: FontWeight.w500),
            ),
          ),
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
                        : const LinearGradient(colors: [
                            Colors.blue,
                            Color(0xFF2196F3)
                          ]))
                    : null,
                color: canGoNext ? null : Colors.white12,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                Text(
                  (widget.controller.isLastQuestion &&
                          widget.controller.isLastQuiz)
                      ? _lang.t("Terminer", "Finish")
                      : _lang.t("Suivant", "Next"),
                  style: TextStyle(
                      color:
                          canGoNext ? Colors.white : Colors.white38,
                      fontSize: h * 0.016,
                      fontWeight: FontWeight.bold),
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
              ]),
            ),
          ),
        ],
      ),
    );
  }

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
                width: 1.5),
          ),
          padding: EdgeInsets.all(h * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.question_answer,
                    color: Colors.blue, size: h * 0.022),
                const SizedBox(width: 8),
                Text(_lang.t("Questions", "Questions"),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: h * 0.022,
                        fontWeight: FontWeight.bold)),
              ]),
              SizedBox(height: h * 0.02),
              Expanded(
                child: ListView.builder(
                  itemCount:
                      widget.controller.totalQuestionsInCurrentQuiz,
                  itemBuilder: (context, index) {
                    final isCurrent =
                        widget.controller.currentQuestionIndex ==
                            index;
                    return GestureDetector(
                      onTap: () {
                        _playSound(_soundButton1);
                        setState(() {
                          widget.controller.currentQuiz
                              .currentQuestionIndex = index;
                          _answerChecked       = null;
                          _currentOrder        = [];
                          _hasSelection        = false;
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
                              color: isCurrent
                                  ? Colors.blue
                                  : Colors.white24,
                              width: isCurrent ? 1.5 : 1),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(Icons.help_outline,
                                  color: isCurrent
                                      ? Colors.blue
                                      : Colors.white54,
                                  size: h * 0.016),
                              const SizedBox(width: 6),
                              Text(
                                  _lang.t("Question ", "Question ") +
                                      "${index + 1}",
                                  style: TextStyle(
                                      color: isCurrent
                                          ? Colors.white
                                          : Colors.white70,
                                      fontSize: h * 0.014,
                                      fontWeight: isCurrent
                                          ? FontWeight.bold
                                          : FontWeight.normal)),
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
                        Colors.purple.withValues(alpha: 0.3)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    Text(_lang.t("Score de la session", "Session Score"),
                        style: TextStyle(
                            color: Colors.white54,
                            fontSize: h * 0.012)),
                    Text(
                      "${widget.controller.getTotalScore()} / ${widget.controller.session.totalPossibleScore}",
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: h * 0.028,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: h * 0.005),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: widget.controller.session
                                    .totalPossibleScore >
                                0
                            ? widget.controller.getTotalScore() /
                                widget.controller.session
                                    .totalPossibleScore
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