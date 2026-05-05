// lib/views/courses_study_page/chapter_quiz_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import '../../models/quiz/quiz_model.dart';
import '../../controllers/courses_study/chapter_quiz_controller.dart';
import '../../service/progress/progress_service.dart';
import '../../service/sound/sound_settings_service.dart';
import '../../service/language_service.dart';
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
  bool         _isSubmitting        = false;
  late LanguageService _lang;

  // ✅ Progression depuis l'API
  double _algo1Progress  = 0.0;
  double _algo2Progress  = 0.0;
  double _globalProgress = 0.0;

  final AudioPlayer _audioPlayer = AudioPlayer();
  static const String _soundCorrect = 'sounds/CORRECTANSWER.mp3';
  static const String _soundWrong   = 'sounds/WRONGANSWER.mp3';
  static const String _soundCheers  = 'sounds/CHEERS.wav';

  Future<void> _playSound(String soundPath) async {
    try {
      if (!await SoundSettingsService.isSoundEnabled()) return;
      await _audioPlayer.play(AssetSource(soundPath));
    } catch (e) {
      print('❌ Audio error: $e');
    }
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
      _answerChecked = null;
      _hasSelection  = false;
      if (q.type == QuestionType.ordering && q.codeLines != null) {
        _currentOrder = List.from(q.codeLines!);
      } else {
        _currentOrder = [];
      }
    }
  }

  Future<void> _nextQuestion() async {
    if (widget.controller.isLastQuestion) {
      if (_isSubmitting) return;
      _isSubmitting = true;

      // ✅ Vérifier si première completion
      final alreadyDone = ProgressService.isAlreadyCompleted(
        widget.algoType,
        widget.chapterTitle,
      );
      _isFirstCompletion = !alreadyDone;

      // ✅ Appel API — marque le chapitre complété + met à jour progression en DB
      await ProgressService.completeChapter(
        algoType:     widget.algoType,
        chapterTitle: widget.chapterTitle,
      );

      // ✅ Récupérer progression mise à jour depuis le cache local
      _algo1Progress  = ProgressService.getAlgo1Progress();
      _algo2Progress  = ProgressService.getAlgo2Progress();
      _globalProgress = ProgressService.getGlobalProgress();

      await _playSound(_soundCheers);

      if (mounted) setState(() => _quizCompleted = true);

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
    _playSound(isCorrect ? _soundCorrect : _soundWrong);
  }

  void _resetQuiz() {
    widget.controller.resetSession();
    setState(() {
      _answerChecked       = null;
      _quizCompleted       = false;
      _currentOrder        = [];
      _hasSelection        = false;
      _isQuestionValidated = false;
      _isSubmitting        = false;
      _loadQuestion();
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
                    horizontal: w * 0.03, vertical: h * 0.01,
                  ),
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
      height:  h * 0.09,
      padding: EdgeInsets.symmetric(horizontal: w * 0.03),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(children: [
        Icon(Icons.quiz, color: Colors.blue, size: h * 0.04),
        SizedBox(width: w * 0.01),
        Text(
          "${_lang.t("Quiz du chapitre", "Chapter Quiz")} — ${_localizedChapterTitle(widget.chapterTitle)}",
          style: TextStyle(
            color:      Colors.white,
            fontSize:   h * 0.022,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardPage()),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.015, vertical: h * 0.008,
            ),
            decoration: BoxDecoration(
              color:        Colors.red.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
            ),
            child: Row(children: [
              Icon(Icons.exit_to_app,
                  color: Colors.red.shade300, size: h * 0.025),
              const SizedBox(width: 6),
                Text(_lang.t('Quitter', 'Exit'),
                  style: TextStyle(
                    color:    Colors.red.shade300,
                    fontSize: h * 0.018,
                  )),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildHeader(double h) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_lang.t("Quiz du chapitre", "Chapter Quiz"),
            style: TextStyle(
              fontSize:   h * 0.04,
              fontWeight: FontWeight.bold,
              color:      Colors.white,
            )),
        SizedBox(height: h * 0.005),
        Text(_lang.t(
            "Teste tes connaissances sur ${_localizedChapterTitle(widget.chapterTitle)}",
            "Test your knowledge of ${_localizedChapterTitle(widget.chapterTitle)}"),
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
            Text(_lang.t("Progression", "Progress"),
                style: TextStyle(color: Colors.white70, fontSize: h * 0.018)),
            Text("${(progress * 100).toInt()}%",
                style: TextStyle(
                  color:      Colors.white,
                  fontSize:   h * 0.018,
                  fontWeight: FontWeight.bold,
                )),
          ],
        ),
        SizedBox(height: h * 0.01),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value:           progress,
            backgroundColor: Colors.white12,
            valueColor:      const AlwaysStoppedAnimation<Color>(Colors.blue),
            minHeight:       h * 0.012,
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
          width:   double.infinity,
          padding: EdgeInsets.all(h * 0.03),
          decoration: BoxDecoration(
            color:        Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border:       Border.all(color: Colors.white24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: h * 0.02, vertical: h * 0.008,
                ),
                decoration: BoxDecoration(
                  color:        Colors.blue.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${_lang.t("Question", "Question")} ${widget.controller.currentQuestionIndex + 1} ${_lang.t("sur", "of")} ${widget.controller.totalQuestionsInCurrentQuiz}",
                  style: TextStyle(
                    color:      Colors.blue,
                    fontSize:   h * 0.016,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: h * 0.02),
              Text(question.enonce,
                  style: TextStyle(
                    color:      Colors.white,
                    fontSize:   h * 0.022,
                    fontWeight: FontWeight.w500,
                    height:     1.5,
                  )),
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
                setState(() {
                  widget.controller
                      .answerMultipleChoice(question.id, choice["key"]!);
                  _hasSelection = true;
                });
              },
        child: Container(
          height: h * 0.11,
          decoration: BoxDecoration(
            color:        bgColor,
            borderRadius: BorderRadius.circular(12),
            border:       Border.all(color: borderColor, width: 1.5),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: h * 0.015, vertical: h * 0.01,
          ),
          child: Row(children: [
            Container(
              width:  h * 0.035,
              height: h * 0.035,
              decoration: BoxDecoration(
                shape:  BoxShape.circle,
                color:  isSelected && !isLocked
                    ? Colors.blue : Colors.white12,
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Center(
                child: Text(choice["key"]!,
                    style: TextStyle(
                      color:      Colors.white,
                      fontSize:   h * 0.014,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ),
            SizedBox(width: h * 0.012),
            Expanded(
              child: Text(choice["label"]!,
                  style:    TextStyle(color: Colors.white, fontSize: h * 0.016),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis),
            ),
            if (trailingIcon != null) trailingIcon,
          ]),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(children: [
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
      ]),
    );
  }

  Widget _buildOrdering(double h, Question question) {
    final isLocked = _answerChecked != null || _isQuestionValidated;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: h * 0.02, vertical: h * 0.01,
          ),
          decoration: BoxDecoration(
            color:        Colors.blue.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.drag_handle, color: Colors.blue, size: h * 0.02),
              const SizedBox(width: 8),
              Text(
                isLocked
                    ? _lang.t("✓ Reponse verrouillee", "✓ Answer locked")
                    : _lang.t("Glisse pour ordonner les etapes", "Drag and drop to order the steps"),
                style: TextStyle(
                  color:    isLocked ? Colors.green : Colors.blue,
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
            itemCount:  _currentOrder.length,
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
                itemBorderColor = isCorrectPos ? Colors.green : Colors.red;
                textColor       = isCorrectPos ? Colors.green : Colors.red;
                iconColor       = isCorrectPos ? Colors.green : Colors.red;
                badgeColor      = isCorrectPos ? Colors.green : Colors.red;
              }

              return Container(
                key:     ValueKey(_currentOrder[index]),
                margin:  EdgeInsets.only(bottom: h * 0.01),
                padding: EdgeInsets.symmetric(
                  horizontal: h * 0.02, vertical: h * 0.012,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.white.withValues(alpha: 0.05),
                  ]),
                  borderRadius: BorderRadius.circular(10),
                  border:       Border.all(color: itemBorderColor),
                ),
                child: Row(children: [
                  Icon(Icons.drag_handle,
                      color: iconColor, size: h * 0.025),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(_currentOrder[index],
                        style: TextStyle(
                          color:      textColor,
                          fontSize:   h * 0.016,
                          fontFamily: 'monospace',
                        )),
                  ),
                  Container(
                    width:  h * 0.035,
                    height: h * 0.035,
                    decoration: BoxDecoration(
                      color:        badgeColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text("${index + 1}",
                          style: TextStyle(
                            color:      badgeColor,
                            fontSize:   h * 0.014,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  ),
                ]),
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
              horizontal: w * 0.04, vertical: h * 0.016,
            ),
            decoration: BoxDecoration(
              gradient: _hasSelection
                  ? const LinearGradient(
                      colors: [Color(0xFF2979FF), Color(0xFF1565C0)],
                      begin:  Alignment.topLeft,
                      end:    Alignment.bottomRight,
                    )
                  : null,
              color:        _hasSelection ? null : Colors.white12,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _hasSelection ? Colors.blue : Colors.white24,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline,
                    color: _hasSelection ? Colors.white : Colors.white38,
                    size:  h * 0.022),
                const SizedBox(width: 10),
                Text(_lang.t("Verifier la reponse", "Check Answer"),
                    style: TextStyle(
                      color:      _hasSelection ? Colors.white : Colors.white38,
                      fontSize:   h * 0.018,
                      fontWeight: FontWeight.bold,
                    )),
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
            horizontal: h * 0.03, vertical: h * 0.01,
          ),
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
                size:  h * 0.022,
              ),
              const SizedBox(width: 8),
              Text(
                _answerChecked! ? _lang.t("✓ Correct !", "✓ Correct!") : _lang.t("✗ Incorrect !", "✗ Incorrect!"),
                style: TextStyle(
                  color:      _answerChecked! ? Colors.green : Colors.red,
                  fontSize:   h * 0.018,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                horizontal: w * 0.02, vertical: h * 0.015,
              ),
              decoration: BoxDecoration(
                color: widget.controller.isFirstQuestion
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: widget.controller.isFirstQuestion
                      ? Colors.white12 : Colors.white30,
                ),
              ),
              child: Row(children: [
                Icon(Icons.chevron_left,
                    color: widget.controller.isFirstQuestion
                        ? Colors.white24 : Colors.white,
                    size: h * 0.02),
                Text(_lang.t("Precedent", "Prev"),
                    style: TextStyle(
                      color: widget.controller.isFirstQuestion
                          ? Colors.white24 : Colors.white,
                      fontSize: h * 0.016,
                    )),
              ]),
            ),
          ),
          Text(
            "${widget.controller.currentQuestionIndex + 1} / ${widget.controller.totalQuestionsInCurrentQuiz}",
            style: TextStyle(
              color:      Colors.white70,
              fontSize:   h * 0.016,
              fontWeight: FontWeight.w500,
            ),
          ),
          GestureDetector(
            onTap: canGoNext ? () async => await _nextQuestion() : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.02, vertical: h * 0.015,
              ),
              decoration: BoxDecoration(
                gradient: canGoNext
                    ? (isLast
                        ? const LinearGradient(
                            colors: [Colors.green, Color(0xFF00C853)])
                        : const LinearGradient(
                            colors: [Colors.blue, Color(0xFF2196F3)]))
                    : null,
                color:        canGoNext ? null : Colors.white12,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                Text(
                  isLast ? _lang.t("Terminer", "Finish") : _lang.t("Suivant", "Next"),
                  style: TextStyle(
                    color:      canGoNext ? Colors.white : Colors.white38,
                    fontSize:   h * 0.016,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  isLast ? Icons.check_circle : Icons.chevron_right,
                  color: canGoNext ? Colors.white : Colors.white38,
                  size:  h * 0.018,
                ),
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
      message = _lang.t("Excellent ! Chapitre maitrise ! 🎉", "Excellent! Chapter mastered! 🎉");
      icon    = Icons.emoji_events;
      color   = const Color(0xFFFFD700);
    } else if (percentage >= 60) {
      message = _lang.t("Bon travail ! Continue ! 👍", "Good job! Keep going! 👍");
      icon    = Icons.thumb_up;
      color   = Colors.green;
    } else if (percentage >= 40) {
      message = _lang.t("Pas mal ! Revois le chapitre puis reessaie ! 📚", "Not bad! Review the chapter and try again! 📚");
      icon    = Icons.school;
      color   = Colors.orange;
    } else {
      message = _lang.t("Continue a pratiquer ! Tu vas y arriver ! 💪", "Keep practicing! You'll get there! 💪");
      icon    = Icons.fitness_center;
      color   = Colors.red;
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
                  fit:   BoxFit.cover,
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
                    width:   w * 0.55,
                    padding: EdgeInsets.all(h * 0.05),
                    decoration: BoxDecoration(
                      color:        Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                      border:       Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Icône animée
                        TweenAnimationBuilder<double>(
                          tween:    Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 800),
                          builder: (context, value, child) =>
                              Transform.scale(
                            scale: value,
                            child: Container(
                              padding: EdgeInsets.all(h * 0.02),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:  color.withValues(alpha: 0.2),
                                border: Border.all(color: color, width: 3),
                              ),
                              child: Icon(icon,
                                  size: h * 0.08, color: color),
                            ),
                          ),
                        ),
                        SizedBox(height: h * 0.03),
                        Text(_lang.t("Quiz termine !", "Quiz Completed!"),
                            style: TextStyle(
                              color:      Colors.white,
                              fontSize:   h * 0.04,
                              fontWeight: FontWeight.bold,
                            )),
                        SizedBox(height: h * 0.01),
                        Text(message,
                            style: TextStyle(
                              color:    Colors.white70,
                              fontSize: h * 0.018,
                            ),
                            textAlign: TextAlign.center),
                        SizedBox(height: h * 0.03),

                        // ── Score circulaire
                        SizedBox(
                          width:  h * 0.15,
                          height: h * 0.15,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width:  h * 0.15,
                                height: h * 0.15,
                                child: CircularProgressIndicator(
                                  value: totalQuestions > 0
                                      ? totalScore / totalQuestions : 0,
                                  strokeWidth:     h * 0.012,
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
                                        color:      color,
                                        fontSize:   h * 0.045,
                                        fontWeight: FontWeight.bold,
                                      )),
                                  Text("/ $totalQuestions",
                                      style: TextStyle(
                                        color:    Colors.white54,
                                        fontSize: h * 0.016,
                                      )),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: h * 0.02),
                        Text("$percentage%",
                            style: TextStyle(
                              color:      Colors.white,
                              fontSize:   h * 0.028,
                              fontWeight: FontWeight.bold,
                            )),
                        SizedBox(height: h * 0.04),

                        // ✅ Bloc progression — affiché seulement à la première completion
                        if (_isFirstCompletion) ...[
                          Container(
                            width:   double.infinity,
                            padding: EdgeInsets.all(h * 0.02),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.green.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Icon(Icons.emoji_events,
                                      color: Colors.amber,
                                      size:  h * 0.025),
                                  const SizedBox(width: 8),
                                  Text(_lang.t("Chapitre termine ! 🎉", "Chapter Completed! 🎉"),
                                      style: TextStyle(
                                        color:      Colors.amber,
                                        fontSize:   h * 0.018,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ]),
                                SizedBox(height: h * 0.02),
                                _buildProgressRow(
                                  h:     h,
                                  label: "Algo 1",
                                  value: _algo1Progress,
                                  color: const Color(0xFF00E5FF),
                                ),
                                SizedBox(height: h * 0.015),
                                _buildProgressRow(
                                  h:     h,
                                  label: "Algo 2",
                                  value: _algo2Progress,
                                  color: Colors.purple,
                                ),
                                SizedBox(height: h * 0.015),
                                _buildProgressRow(
                                  h:     h,
                                  label: "Global",
                                  value: _globalProgress,
                                  color: Colors.green,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: h * 0.03),
                        ],

                        // ── Boutons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _resetQuiz,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: w * 0.02,
                                  vertical:   h * 0.015,
                                ),
                              ),
                              child: Row(children: [
                                Icon(Icons.replay,
                                    color: Colors.white, size: h * 0.02),
                                const SizedBox(width: 8),
                                Text(_lang.t("Reessayer", "Try Again"),
                                    style: TextStyle(
                                      color:    Colors.white,
                                      fontSize: h * 0.016,
                                    )),
                              ]),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              // ✅ loadProgress avant de retourner au dashboard
                              onPressed: () async {
                                await ProgressService.loadProgress();
                                if (mounted) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const DashboardPage(),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white24,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: w * 0.02,
                                  vertical:   h * 0.015,
                                ),
                              ),
                              child: Row(children: [
                                Icon(Icons.home,
                                    color: Colors.white, size: h * 0.02),
                                const SizedBox(width: 8),
                                Text(_lang.t("Tableau de bord", "Dashboard"),
                                    style: TextStyle(
                                      color:    Colors.white,
                                      fontSize: h * 0.016,
                                    )),
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

  String _localizedChapterTitle(String chapterTitle) {
    switch (chapterTitle) {
      case 'Basics':
        return _lang.t('Notions de base', 'Basics');
      case 'Conditions':
        return _lang.t('Conditions', 'Conditions');
      case 'Loops':
        return _lang.t('Boucles', 'Loops');
      case 'Data Structures - Vectors and Matrices':
      case 'Data Structures – Vectors and Matrices':
        return _lang.t('Structures de donnees - Vecteurs et matrices', 'Data Structures - Vectors and Matrices');
      case 'Subprograms (Functions and Procedures)':
        return _lang.t('Sous-programmes (Fonctions et Procedures)', 'Subprograms (Functions and Procedures)');
      case 'Les Enregistrements':
        return _lang.t('Les Enregistrements', 'Records');
      case 'Les Fichiers':
        return _lang.t('Les Fichiers', 'Files');
      case 'Les Listes chaînées':
      case 'Les Listes chainees':
        return _lang.t('Les Listes chainees', 'Linked Lists');
      case 'Piles et Files':
        return _lang.t('Piles et Files', 'Stacks and Queues');
      default:
        return chapterTitle;
    }
  }

  Widget _buildProgressRow({
    required double h,
    required String label,
    required double value,
    required Color  color,
  }) {
    return Row(children: [
      SizedBox(
        width:  h * 0.07,
        height: h * 0.07,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width:  h * 0.07,
              height: h * 0.07,
              child: CircularProgressIndicator(
                value:           value,
                strokeWidth:     h * 0.008,
                backgroundColor: Colors.white12,
                valueColor:      AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text("${(value * 100).toInt()}%",
                style: TextStyle(
                  color:      color,
                  fontSize:   h * 0.013,
                  fontWeight: FontWeight.bold,
                )),
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
                  color:      Colors.white70,
                  fontSize:   h * 0.015,
                  fontWeight: FontWeight.bold,
                )),
            SizedBox(height: h * 0.006),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value:           value,
                minHeight:       h * 0.007,
                backgroundColor: Colors.white12,
                valueColor:      AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}