import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:ui';

import '../../service/language_service.dart';

import 'package:flutter_project_1/controllers/quiz/quiz_controller.dart';
import 'package:flutter_project_1/controllers/quiz/algo2_quiz_controller.dart';
import 'package:flutter_project_1/views/quiz/quiz_page_content.dart';
import '../dashboard/dashboard_page.dart';
import '../auth/login_page.dart';
import '../leaderboard/leaderboard_page.dart';
import '../files/files_page.dart';

class QuizSelectionPage extends StatefulWidget {
  const QuizSelectionPage({super.key});

  @override
  State<QuizSelectionPage> createState() => _QuizSelectionPageState();
}

class _QuizSelectionPageState extends State<QuizSelectionPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  int              _selectedIndex     = 1;
  int              _selectedAlgo      = 1;
  final List<String> _selectedChapters = [];
  int              _selectedIntensity = 10;
  int              _currentStep       = 1;
  bool             _isLoadingQuiz     = false;

  late LanguageService _lang;

  // ══════════════════════════════════════════
  // SOUND — edit the file names here to change sounds
  // ══════════════════════════════════════════
  static const String _soundSidebarButton = 'sounds/PRESS_1.wav';

  Future<void> _playSound(String soundPath) async {
    await _audioPlayer.play(AssetSource(soundPath));
  }

  final List<Map<String, String>> _chaptersAlgo1 = const [
    {"id": "Chapitre 01", "title": "Basics",                                    "icon": "assets/images/icons_algo1/basics_icone.png"},
    {"id": "Chapitre 02", "title": "Conditions",                                "icon": "assets/images/icons_algo1/si_sinon_icon.png"},
    {"id": "Chapitre 03", "title": "Loops",                                     "icon": "assets/images/icons_algo1/loops_icone.png"},
    {"id": "Chapitre 04", "title": "Data Structures - Vectors and Matrices",    "icon": "assets/images/icons_algo1/vectors_matris_icon.png"},
    {"id": "Chapitre 05", "title": "Subprograms (Functions and Procedures)",    "icon": "assets/images/icons_algo1/fonction_procedure_icone.png"},
  ];

  final List<Map<String, String>> _chaptersAlgo2 = const [
    {"id": "Chapitre 01", "title": "Les Enregistrements",   "icon": "assets/images/icons_algo2/data_structure_icone.png"},
    {"id": "Chapitre 02", "title": "Les Fichiers", "icon": "assets/images/icons_algo2/files_icone.png"},
    {"id": "Chapitre 03", "title": "La recursivité",   "icon": "assets/images/icons_algo2/listes_icones.png"},
    {"id": "Chapitre 04", "title": "Linked Lists",         "icon": "assets/images/icons_algo2/stacks_icone.png"},
    {"id": "Chapitre 05", "title": "Stacks and Queues",    "icon": "assets/images/icons_algo2/stacks_icone.png"},
  ];

  List<Map<String, String>> get _currentChapters =>
      _selectedAlgo == 1 ? _chaptersAlgo1 : _chaptersAlgo2;

  List<int> get _currentIntensities =>
      _selectedAlgo == 1 ? [10, 15, 20, 30] : [5, 10, 15, 20];

  List<String> get _currentIntensityLabels => [
        _lang.t("Facile",    "Easy"),
        _lang.t("Moyen",     "Medium"),
        _lang.t("Difficile", "Hard"),
        _lang.t("Expert",    "Expert"),
      ];

  List<Color> get _currentIntensityColors => _selectedAlgo == 1
      ? [Colors.orange, Colors.red, Colors.purple, const Color.fromARGB(255, 0, 39, 212)]
      : [Colors.green,  Colors.orange, Colors.red, const Color.fromARGB(255, 212, 0, 117)];

  int get _defaultIntensity => _selectedAlgo == 1 ? 10 : 5;

  @override
  void initState() {
    super.initState();
    _lang = Provider.of<LanguageService>(context, listen: false);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _startQuiz() async {
    if (_isLoadingQuiz) return;
    setState(() => _isLoadingQuiz = true);
    try {
      if (_selectedAlgo == 1) {
        final controller = await QuizController.create(
          selectedChapters: _selectedChapters,
          intensity:        _selectedIntensity,
        );
        if (!mounted) return;
        Navigator.push(context,
            MaterialPageRoute(
                builder: (_) => QuizPageContent(
                    controller: controller, algoType: 'algo1')));
      } else {
        final controller = await Algo2QuizController.create(
          selectedChapters: _selectedChapters,
          intensity:        _selectedIntensity,
        );
        if (!mounted) return;
        Navigator.push(context,
            MaterialPageRoute(
                builder: (_) => QuizPageContent(
                    controller: controller, algoType: 'algo2')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_lang.t('Erreur lors du chargement du quiz',
            'Error loading quiz')),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _isLoadingQuiz = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _lang = context.watch<LanguageService>();
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

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
          Row(
            children: [
              _buildSidebar(h, w),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: Container(
                      margin: EdgeInsets.all(h * 0.02),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(h),
                            SizedBox(height: h * 0.02),
                            _buildFilters(h),
                            SizedBox(height: h * 0.02),
                            _buildProgressSteps(h, w),
                            SizedBox(height: h * 0.03),
                            Expanded(
                              child: _currentStep == 1
                                  ? _buildChapterSelection(h, w)
                                  : _currentStep == 2
                                      ? _buildIntensitySelection(h, w)
                                      : _buildReviewSection(h, w),
                            ),
                            _buildNavigationButtons(h, w),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _buildRightPanel(h, w),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(double h, double w) {
    final items = [
      {"icon": Icons.menu_book,    "label": _lang.t("Cours",      "Courses")},
      {"icon": Icons.quiz,         "label": _lang.t("Quiz",       "Quiz")},
      {"icon": Icons.emoji_events, "label": _lang.t("Classement", "Leaderboard")},
      {"icon": Icons.folder,       "label": _lang.t("Fichiers",   "Files")},
    ];

    return Container(
      width: w * 0.07,
      color: const Color.fromARGB(66, 33, 32, 32),
      child: Column(
        children: [
          SizedBox(height: h * 0.02),
          Image.asset("assets/images/icone_dash.png",
              width: h * 0.15, height: h * 0.15),
          SizedBox(height: h * 0.04),
          ...items.asMap().entries.map(
            (entry) => GestureDetector(
              onTap: () async {
                await _playSound(_soundSidebarButton);
                setState(() => _selectedIndex = entry.key);
                _navigateToPage(entry.key);
              },
              child: _buildSidebarItem(
                icon:     entry.value["icon"] as IconData,
                label:    entry.value["label"] as String,
                h:        h,
                isActive: _selectedIndex == entry.key,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () async {
              await _playSound(_soundSidebarButton);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const LoginPage()));
            },
            child: _buildSidebarItem(
              icon:     Icons.logout,
              label:    _lang.t("Déconnexion", "Logout"),
              h:        h,
              isLogout: true,
            ),
          ),
          SizedBox(height: h * 0.02),
        ],
      ),
    );
  }

  void _navigateToPage(int index) {
    if (index == 0) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const DashboardPage()));
    } else if (index == 2) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const LeaderboardPage()));
    } else if (index == 3) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const FilesPage()));
    }
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String   label,
    required double   h,
    bool isLogout = false,
    bool isActive = false,
  }) {
    return Row(
      children: [
        Container(
          width: 4,
          height: h * 0.08,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: h * 0.02),
            child: Column(
              children: [
                Icon(icon,
                    color: isActive
                        ? Colors.blue
                        : (isLogout ? Colors.red : Colors.white70),
                    size: h * 0.06),
                SizedBox(height: h * 0.005),
                Text(label,
                    style: TextStyle(
                        color: isActive
                            ? Colors.blue
                            : (isLogout ? Colors.red : Colors.white70),
                        fontSize: h * 0.020,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(double h) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_lang.t("Prépare ton quiz", "Prepare your quiz"),
            style: TextStyle(
                fontSize: h * 0.04,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        SizedBox(height: h * 0.005),
        Text(
          _selectedAlgo == 1
              ? _lang.t(
                  "Sélectionne les chapitres et le niveau de difficulté",
                  "Select chapters and quiz intensity to begin")
              : _lang.t(
                  "Structures de données avancées — Sélectionne les chapitres et la difficulté",
                  "Advanced data structures — Select chapters and difficulty"),
          style: TextStyle(fontSize: h * 0.016, color: Colors.white60),
        ),
      ],
    );
  }

  Widget _buildFilters(double h) {
    return Row(
      children: [
        GestureDetector(
            onTap: () => _switchAlgo(1),
            child: _filterChip(_lang.t("Algo 1", "Algo 1"), h,
                selected: _selectedAlgo == 1)),
        const SizedBox(width: 8),
        GestureDetector(
            onTap: () => _switchAlgo(2),
            child: _filterChip(_lang.t("Algo 2", "Algo 2"), h,
                selected: _selectedAlgo == 2)),
      ],
    );
  }

  void _switchAlgo(int algo) {
    setState(() {
      _selectedAlgo      = algo;
      _selectedIntensity = _defaultIntensity;
      _currentStep       = 1;
      _selectedChapters.clear();
    });
  }

  Widget _filterChip(String label, double h, {bool selected = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: h * 0.008),
      decoration: BoxDecoration(
        color: selected ? Colors.blue : Colors.white12,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: selected ? Colors.blue : Colors.white24),
      ),
      child: Text(label,
          style: TextStyle(
              color: Colors.white,
              fontSize: h * 0.015,
              fontWeight:
                  selected ? FontWeight.bold : FontWeight.normal)),
    );
  }

  Widget _buildProgressSteps(double h, double w) {
    final steps = [
      _lang.t("Chapitres", "Chapters"),
      _lang.t("Difficulté", "Intensity"),
      _lang.t("Résumé", "Review"),
    ];
    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          return Expanded(
              child: Container(
                  height: 2,
                  color: _currentStep > (i ~/ 2) + 1
                      ? Colors.blue
                      : Colors.white24));
        }
        final stepIndex = i ~/ 2 + 1;
        final isDone    = _currentStep > stepIndex;
        final isActive  = _currentStep == stepIndex;
        return Column(
          children: [
            Container(
              width: h * 0.05,
              height: h * 0.05,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone
                    ? Colors.green
                    : (isActive ? Colors.blue : Colors.white24),
                border: Border.all(
                    color: isActive ? Colors.blue : Colors.white24,
                    width: 2),
              ),
              child: Center(
                child: isDone
                    ? Icon(Icons.check,
                        color: Colors.white, size: h * 0.025)
                    : Text("$stepIndex",
                        style: TextStyle(
                            color: isActive
                                ? Colors.white
                                : Colors.white38,
                            fontSize: h * 0.022,
                            fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: h * 0.008),
            Text(steps[i ~/ 2],
                style: TextStyle(
                    color: isActive ? Colors.blue : Colors.white38,
                    fontSize: h * 0.014,
                    fontWeight: isActive
                        ? FontWeight.bold
                        : FontWeight.normal)),
          ],
        );
      }),
    );
  }

  Widget _buildChapterSelection(double h, double w) {
    final chapters = _currentChapters;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_lang.t("Sélectionne les chapitres", "Select chapters"),
            style: TextStyle(
                color: Colors.white,
                fontSize: h * 0.022,
                fontWeight: FontWeight.bold)),
        SizedBox(height: h * 0.02),
        Expanded(
          child: GridView.builder(
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 60,
                    mainAxisSpacing: 25,
                    childAspectRatio: 3.5),
            itemCount: chapters.length,
            itemBuilder: (context, index) {
              final chapter    = chapters[index];
              final isSelected =
                  _selectedChapters.contains(chapter["id"]);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedChapters.remove(chapter["id"]);
                    } else {
                      _selectedChapters.add(chapter["id"]!);
                    }
                  });
                },
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft:     Radius.circular(13),
                      topRight:    Radius.circular(13),
                      bottomLeft:  Radius.circular(27),
                      bottomRight: Radius.circular(27)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: EdgeInsets.only(
                          top:    h * 0.005,
                          left:   h * 0.02,
                          right:  h * 0.02,
                          bottom: h * 0.02),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue.withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: isSelected
                                ? Colors.blue
                                : Colors.white24,
                            width: isSelected ? 2 : 1),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: FittedBox(
                              fit:       BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(chapter["id"]!,
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: h * 0.025,
                                          fontWeight:
                                              FontWeight.bold)),
                                  SizedBox(height: h * 0.005),
                                  Text(chapter["title"]!,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: h * 0.02,
                                          fontWeight:
                                              FontWeight.bold),
                                      maxLines: 2,
                                      overflow:
                                          TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: h * 0.010),
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Image.asset(chapter["icon"]!,
                                  width:  h * 0.08,
                                  height: h * 0.08),
                              Container(
                                width: h * 0.025,
                                height: h * 0.025,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? Colors.blue
                                      : Colors.white24,
                                  border: Border.all(
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.white54,
                                      width: 2),
                                ),
                                child: isSelected
                                    ? Icon(Icons.check,
                                        color: Colors.white,
                                        size: h * 0.015)
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildIntensitySelection(double h, double w) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            _lang.t("Niveau de difficulté du quiz",
                "Quiz difficulty level"),
            style: TextStyle(
                color: Colors.white,
                fontSize: h * 0.022,
                fontWeight: FontWeight.bold)),
        SizedBox(height: h * 0.02),
        Wrap(
          spacing: 16,
          children:
              List.generate(_currentIntensities.length, (index) {
            final intensity  = _currentIntensities[index];
            final isSelected = _selectedIntensity == intensity;
            final color      = _currentIntensityColors[index];
            return GestureDetector(
              onTap: () =>
                  setState(() => _selectedIntensity = intensity),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: w * 0.03, vertical: h * 0.015),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color:
                          isSelected ? color : Colors.white24,
                      width: isSelected ? 2 : 1),
                ),
                child: Column(
                  children: [
                    Text(_currentIntensityLabels[index],
                        style: TextStyle(
                            color: isSelected
                                ? color
                                : Colors.white70,
                            fontSize: h * 0.020,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal)),
                    Text(
                        "$intensity ${_lang.t("questions par chapitre", "questions/chapter")}",
                        style: TextStyle(
                            color: isSelected
                                ? color.withValues(alpha: 0.8)
                                : Colors.white54,
                            fontSize: h * 0.012)),
                  ],
                ),
              ),
            );
          }),
        ),
        SizedBox(height: h * 0.03),
        Container(
          padding: EdgeInsets.all(h * 0.02),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  _lang.t(
                      "Que signifie le niveau de difficulté ?",
                      "What does difficulty level mean?"),
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: h * 0.018,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: h * 0.01),
              Text(
                _selectedAlgo == 1
                    ? _lang.t(
                        "Le niveau de difficulté détermine le nombre de questions que tu devras répondre par chapitre sélectionné :\n\n"
                        "• Facile (10) : Bon pour apprendre\n"
                        "• Moyen (15) : Questions plus challenging\n"
                        "• Difficile (20) : Niveau avancé\n"
                        "• Expert (30) : Difficulté maximale",
                        "The difficulty level determines how many questions you'll answer from each selected chapter:\n\n"
                        "• 10 ● : Medium - Good for learning\n"
                        "• 15 ● : Hard - Challenging questions\n"
                        "• 20 ● : Expert - Advanced difficulty\n"
                        "• 30 ● : Master - Maximum difficulty")
                    : _lang.t(
                        "Le niveau de difficulté détermine le nombre de questions que tu devras répondre par chapitre sélectionné :\n\n"
                        "• Facile (5) : Questions de base pour commencer\n"
                        "• Moyen (10) : Mélange de questions basiques et intermédiaires\n"
                        "• Difficile (15) : Questions challenging pour les avancés\n"
                        "• Expert (20) : Difficulté maximale pour les experts",
                        "The difficulty level determines how many questions you'll answer from each selected chapter:\n\n"
                        "• 5 ● : Easy - Basic questions to get started\n"
                        "• 10 ● : Medium - Mix of basic and intermediate questions\n"
                        "• 15 ● : Hard - Challenging questions for advanced learners\n"
                        "• 20 ● : Expert - Maximum difficulty for experts"),
                style: TextStyle(
                    color: Colors.white54,
                    fontSize: h * 0.014,
                    height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSection(double h, double w) {
    final totalQuestions =
        _selectedChapters.length * _selectedIntensity;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(h * 0.02),
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.green, size: h * 0.03),
                    const SizedBox(width: 12),
                    Text(
                        _lang.t("Configuration du Quiz",
                                "Quiz Configuration") +
                            " — ${_selectedAlgo == 1 ? "Algo 1" : "Algo 2"}",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: h * 0.022,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: h * 0.02),
                _buildReviewRow(
                    h,
                    _lang.t("Chapitres sélectionnés",
                        "Selected Chapters"),
                    "${_selectedChapters.length}"),
                SizedBox(height: h * 0.02),
                _buildReviewRow(
                    h,
                    _lang.t("Niveau de difficulté",
                        "Difficulty Level"),
                    "${_currentIntensityLabels[_currentIntensities.indexOf(_selectedIntensity)]} ($_selectedIntensity ${_lang.t("questions par chapitre", "questions/chapter")})"),
                SizedBox(height: h * 0.02),
                _buildReviewRow(
                    h,
                    _lang.t("Total de questions", "Total Questions"),
                    "$totalQuestions"),
                SizedBox(height: h * 0.02),
                Container(
                  padding: EdgeInsets.all(h * 0.015),
                  decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color:
                              Colors.green.withValues(alpha: 0.5))),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.green, size: h * 0.022),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _lang.t(
                              "Tu es prêt à commencer ! Clique sur 'Commencer le Quiz'",
                              "You're ready to start! Click 'Start Quiz' to begin."),
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: h * 0.014),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewRow(double h, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.white54, fontSize: h * 0.016)),
        Text(value,
            style: TextStyle(
                color: Colors.blue,
                fontSize: h * 0.016,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildNavigationButtons(double h, double w) {
    return Padding(
      padding: EdgeInsets.only(top: h * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 1)
            GestureDetector(
              onTap: () => setState(() => _currentStep--),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: w * 0.02, vertical: h * 0.015),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white30)),
                child: Row(
                  children: [
                    Icon(Icons.chevron_left,
                        color: Colors.white, size: h * 0.02),
                    Text(_lang.t("Retour", "Back"),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: h * 0.018)),
                  ],
                ),
              ),
            )
          else
            const SizedBox(width: 80),
          if (_currentStep < 3)
            GestureDetector(
              onTap: () {
                if (_currentStep == 1 &&
                    _selectedChapters.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(_lang.t(
                        "Veuillez sélectionner au moins un chapitre",
                        "Please select at least one chapter")),
                    backgroundColor: Colors.orange.shade700,
                  ));
                  return;
                }
                setState(() => _currentStep++);
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: w * 0.03, vertical: h * 0.015),
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Text(_lang.t("Suivant", "Next"),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: h * 0.018,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right,
                        color: Colors.white, size: h * 0.02),
                  ],
                ),
              ),
            )
          else
            GestureDetector(
              onTap: _isLoadingQuiz ? null : _startQuiz,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: w * 0.04, vertical: h * 0.015),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: _isLoadingQuiz
                          ? [Colors.grey, Colors.grey.shade700]
                          : [Colors.green, Colors.green.shade700]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    if (_isLoadingQuiz)
                      SizedBox(
                          width: h * 0.022,
                          height: h * 0.022,
                          child: const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                    else
                      Icon(Icons.play_arrow,
                          color: Colors.white, size: h * 0.022),
                    const SizedBox(width: 8),
                    Text(
                        _isLoadingQuiz
                            ? _lang.t(
                                "Chargement...", "Loading...")
                            : _lang.t("Commencer le Quiz",
                                "Start Quiz"),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: h * 0.018,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRightPanel(double h, double w) {
    final totalQuestions =
        _selectedChapters.length * _selectedIntensity;
    final totalChapters  = _currentChapters.length;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: w * 0.22,
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              border: Border(
                  left: BorderSide(
                      color: Colors.blue.withValues(alpha: 0.2)))),
          padding: EdgeInsets.all(h * 0.025),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.blue, size: h * 0.022),
                  const SizedBox(width: 8),
                  Text(
                      _lang.t("Infos Quiz", "Quiz Info") +
                          " — ${_selectedAlgo == 1 ? "Algo 1" : "Algo 2"}",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: h * 0.020,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: h * 0.02),
              _buildInfoCard(h,
                  icon:  Icons.school,
                  label: _lang.t("Total chapitres", "Total Chapters"),
                  value: "$totalChapters",
                  color: Colors.blue),
              SizedBox(height: h * 0.015),
              _buildInfoCard(h,
                  icon:  Icons.check_circle_outline,
                  label: _lang.t("Sélectionnés", "Selected"),
                  value: "${_selectedChapters.length}",
                  color: Colors.green),
              SizedBox(height: h * 0.015),
              _buildInfoCard(h,
                  icon:  Icons.assignment,
                  label: _lang.t("Questions", "Questions"),
                  value: "$totalQuestions",
                  color: Colors.purple),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(double h,
      {required IconData icon,
      required String    label,
      required String    value,
      required Color     color}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(h * 0.015),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: color.withValues(alpha: 0.3))),
      child: Row(
        children: [
          Icon(icon, color: color, size: h * 0.028),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: Colors.white54,
                      fontSize: h * 0.013)),
              Text(value,
                  style: TextStyle(
                      color: color,
                      fontSize: h * 0.020,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}