// views/quiz/quiz_selection_page.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_project_1/controllers/quiz/quiz_controller.dart';
import 'package:flutter_project_1/controllers/quiz/algo2_quiz_controller.dart';
import 'package:flutter_project_1/views/quiz/quiz_page_content.dart';
import 'package:flutter_project_1/views/quiz/widgets/quiz_chapters_grid.dart';
import 'package:flutter_project_1/views/quiz/widgets/quiz_intensity_selector.dart';
import '../dashboard/dashboard_page.dart';
import '../auth/login_page.dart';
import '../leaderboard/leaderboard_page.dart';
import '../files/files_page.dart';

// views/quiz/quiz_selection_page.dart

class QuizSelectionPage extends StatefulWidget {
  const QuizSelectionPage({super.key});

  @override
  State<QuizSelectionPage> createState() => _QuizSelectionPageState();
}

class _QuizSelectionPageState extends State<QuizSelectionPage> {
  int _selectedIndex = 1;
  int _selectedAlgo = 1;
  List<String> _selectedChapters = [];
  int _selectedIntensity = 10;
  int _currentStep = 1;

  final List<Map<String, String>> _chaptersAlgo1 = const [
    {"id": "Chapitre 01", "title": "Basics", "icon": "assets/images/icons_algo1/basics_icone.png"},
    {"id": "Chapitre 02", "title": "Conditions", "icon": "assets/images/icons_algo1/si_sinon_icon.png"},
    {"id": "Chapitre 03", "title": "Loops", "icon": "assets/images/icons_algo1/loops_icone.png"},
    {"id": "Chapitre 04", "title": "Data Structures - Vectors and Matrices", "icon": "assets/images/icons_algo1/vectors_matris_icon.png"},
    {"id": "Chapitre 05", "title": "Subprograms (Functions and Procedures)", "icon": "assets/images/icons_algo1/fonction_procedure_icone.png"},
  ];

  final List<Map<String, String>> _chaptersAlgo2 = const [
    {"id": "Chapitre 01", "title": "Data Structure", "icon": "assets/images/icons_algo2/data_structure_icone.png"},
    {"id": "Chapitre 02", "title": "Files", "icon": "assets/images/icons_algo2/files_icone.png"},
    {"id": "Chapitre 03", "title": "Linked List", "icon": "assets/images/icons_algo2/listes_icones.png"},
    {"id": "Chapitre 04", "title": "Queues and Stacks", "icon": "assets/images/icons_algo2/stacks_icone.png"},
  ];

  List<Map<String, String>> get _currentChapters =>
      _selectedAlgo == 1 ? _chaptersAlgo1 : _chaptersAlgo2;

  List<int> get _currentIntensities =>
      _selectedAlgo == 1 ? [10, 15, 20, 30] : [5, 10, 15, 20];

  List<String> get _currentIntensityLabels =>
      _selectedAlgo == 1 ? ["Medium", "Hard", "Expert", "Master"] : ["Easy", "Medium", "Hard", "Expert"];

  List<Color> get _currentIntensityColors =>
      _selectedAlgo == 1
          ? [Colors.orange, Colors.red, Colors.purple, Colors.deepPurple]
          : [Colors.green, Colors.orange, Colors.red, Colors.purple];

  int get _defaultIntensity => _selectedAlgo == 1 ? 10 : 5;

  @override
  Widget build(BuildContext context) {
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
                  fit: BoxFit.cover,
                ),
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
                          width: 1.5,
                        ),
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
      {"icon": Icons.menu_book, "label": "Courses"},
      {"icon": Icons.quiz, "label": "Quiz"},
      {"icon": Icons.emoji_events, "label": "Leaderboard"},
      {"icon": Icons.folder, "label": "Files"},
    ];

    return Container(
      width: w * 0.07,
      color: const Color.fromARGB(66, 33, 32, 32),
      child: Column(
        children: [
          SizedBox(height: h * 0.02),
          Image.asset(
            "assets/images/icone_dash.png",
            width: h * 0.15,
            height: h * 0.15,
            errorBuilder: (_, __, ___) => Icon(Icons.school, color: Colors.blue, size: h * 0.08),
          ),
          SizedBox(height: h * 0.04),
          ...items.asMap().entries.map(
            (entry) => GestureDetector(
              onTap: () {
                setState(() => _selectedIndex = entry.key);
                _navigateToPage(entry.key);
              },
              child: _buildSidebarItem(
                icon: entry.value["icon"] as IconData,
                label: entry.value["label"] as String,
                h: h,
                isActive: _selectedIndex == entry.key,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            ),
            child: _buildSidebarItem(
              icon: Icons.logout,
              label: "Logout",
              h: h,
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LeaderboardPage()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FilesPage()),
      );
    }
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    required double h,
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
                Icon(
                  icon,
                  color: isActive
                      ? Colors.blue
                      : (isLogout ? Colors.red : Colors.white70),
                  size: h * 0.06,
                ),
                SizedBox(height: h * 0.005),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive
                        ? Colors.blue
                        : (isLogout ? Colors.red : Colors.white70),
                    fontSize: h * 0.020,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
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
        Text(
          "Prepare your quiz",
          style: TextStyle(
            fontSize: h * 0.04,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: h * 0.005),
        Text(
          _selectedAlgo == 1
              ? "Select chapters and quiz intensity to begin"
              : "Advanced data structures — Select chapters and difficulty",
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
          child: _filterChip("Algo 1", h, selected: _selectedAlgo == 1),
        ),
        SizedBox(width: 8),
        GestureDetector(
          onTap: () => _switchAlgo(2),
          child: _filterChip("Algo 2", h, selected: _selectedAlgo == 2),
        ),
      ],
    );
  }

  void _switchAlgo(int algo) {
    setState(() {
      _selectedAlgo = algo;
      _selectedChapters.clear();
      _selectedIntensity = _defaultIntensity;
      _currentStep = 1;
    });
  }

  Widget _filterChip(String label, double h, {bool selected = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: h * 0.008),
      decoration: BoxDecoration(
        color: selected ? Colors.blue : Colors.white12,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? Colors.blue : Colors.white24),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: h * 0.015,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildProgressSteps(double h, double w) {
    final steps = ["Chapters", "Intensity", "Review"];
    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          return Expanded(
            child: Container(
              height: 2,
              color: _currentStep > (i ~/ 2) + 1 ? Colors.blue : Colors.white24,
            ),
          );
        }
        final stepIndex = i ~/ 2 + 1;
        final isDone = _currentStep > stepIndex;
        final isActive = _currentStep == stepIndex;
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
                  width: 2,
                ),
              ),
              child: Center(
                child: isDone
                    ? Icon(Icons.check, color: Colors.white, size: h * 0.025)
                    : Text(
                        "$stepIndex",
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.white38,
                          fontSize: h * 0.022,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            SizedBox(height: h * 0.008),
            Text(
              steps[i ~/ 2],
              style: TextStyle(
                color: isActive ? Colors.blue : Colors.white38,
                fontSize: h * 0.014,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
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
        Text(
          "Select chapters",
          style: TextStyle(
            color: Colors.white,
            fontSize: h * 0.022,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: h * 0.02),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 60,
              mainAxisSpacing: 25,
              childAspectRatio: 3.5,
            ),
            itemCount: chapters.length,
            itemBuilder: (context, index) {
              final chapter = chapters[index];
              final isSelected = _selectedChapters.contains(chapter["id"]);

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
                    topLeft: Radius.circular(13),
                    topRight: Radius.circular(13),
                    bottomLeft: Radius.circular(27),
                    bottomRight: Radius.circular(27),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: EdgeInsets.only(
                        top: h * 0.005,
                        left: h * 0.02,
                        right: h * 0.02,
                        bottom: h * 0.02,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color.fromARGB(255, 33, 150, 243).withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.white24,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    chapter["id"]!,
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: h * 0.025,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: h * 0.005),
                                  Text(
                                    chapter["title"]!,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: h * 0.02,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: h * 0.010),
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Image.asset(
                                  chapter["icon"]!,
                                  width: h * 0.08,
                                  height: h * 0.08,
                                  errorBuilder: (context, error, stackTrace) => Icon(
                                    Icons.image_not_supported,
                                    color: Colors.white38,
                                    size: h * 0.04,
                                  ),
                                ),
                              ),
                              Container(
                                width: h * 0.025,
                                height: h * 0.025,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? Colors.blue : Colors.white24,
                                  border: Border.all(
                                    color: isSelected ? Colors.blue : Colors.white54,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: h * 0.015,
                                      )
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
          "Quiz difficulty level",
          style: TextStyle(
            color: Colors.white,
            fontSize: h * 0.022,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: h * 0.02),
        Wrap(
          spacing: 16,
          children: List.generate(_currentIntensities.length, (index) {
            final intensity = _currentIntensities[index];
            final isSelected = _selectedIntensity == intensity;
            final color = _currentIntensityColors[index];
            return GestureDetector(
              onTap: () => setState(() => _selectedIntensity = intensity),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.03,
                  vertical: h * 0.015,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? color.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? color : Colors.white24,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _currentIntensityLabels[index],
                      style: TextStyle(
                        color: isSelected ? color : Colors.white70,
                        fontSize: h * 0.020,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    Text(
                      "$intensity questions/chapter",
                      style: TextStyle(
                        color: isSelected ? color.withValues(alpha: 0.8) : Colors.white54,
                        fontSize: h * 0.012,
                      ),
                    ),
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
                "What does difficulty level mean?",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: h * 0.018,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: h * 0.01),
              Text(
                _selectedAlgo == 1
                    ? "The difficulty level determines how many questions you'll answer from each selected chapter:\n\n"
                      "• 10 ● : Medium - Good for learning\n"
                      "• 15 ● : Hard - Challenging questions\n"
                      "• 20 ● : Expert - Advanced difficulty\n"
                      "• 30 ● : Master - Maximum difficulty"
                    : "The difficulty level determines how many questions you'll answer from each selected chapter:\n\n"
                      "• 5 ● : Easy - Basic questions to get started\n"
                      "• 10 ● : Medium - Mix of basic and intermediate questions\n"
                      "• 15 ● : Hard - Challenging questions for advanced learners\n"
                      "• 20 ● : Expert - Maximum difficulty for experts",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: h * 0.014,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSection(double h, double w) {
    final totalQuestions = _selectedChapters.length * _selectedIntensity;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: h * 0.03),
                    SizedBox(width: 12),
                    Text(
                      "Quiz Configuration — ${_selectedAlgo == 1 ? "Algo 1" : "Algo 2"}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: h * 0.022,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: h * 0.02),
                _buildReviewRow(h, "Selected Chapters", "${_selectedChapters.length}"),
                SizedBox(height: h * 0.01),
                ..._selectedChapters.map((chapterId) {
                  final chapter = _currentChapters.firstWhere(
                    (c) => c["id"] == chapterId,
                    orElse: () => {"title": "Unknown"},
                  );
                  return Padding(
                    padding: EdgeInsets.only(left: w * 0.03, bottom: h * 0.008),
                    child: Row(
                      children: [
                        Text("•", style: TextStyle(color: Colors.blue, fontSize: h * 0.020)),
                        SizedBox(width: 8),
                        Text(
                          chapter["title"]!,
                          style: TextStyle(color: Colors.white70, fontSize: h * 0.016),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                SizedBox(height: h * 0.02),
                _buildReviewRow(h, "Difficulty Level", "$_selectedIntensity questions/chapter"),
                SizedBox(height: h * 0.02),
                _buildReviewRow(h, "Total Questions", "$totalQuestions"),
                SizedBox(height: h * 0.02),
                Container(
                  padding: EdgeInsets.all(h * 0.015),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.green, size: h * 0.022),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "You're ready to start! Click 'Start Quiz' to begin.",
                          style: TextStyle(color: Colors.green, fontSize: h * 0.014),
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
        Text(label, style: TextStyle(color: Colors.white54, fontSize: h * 0.016)),
        Text(value, style: TextStyle(color: Colors.blue, fontSize: h * 0.016, fontWeight: FontWeight.bold)),
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
                padding: EdgeInsets.symmetric(horizontal: w * 0.02, vertical: h * 0.015),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white30),
                ),
                child: Row(
                  children: [
                    Icon(Icons.chevron_left, color: Colors.white, size: h * 0.02),
                    Text("Back", style: TextStyle(color: Colors.white, fontSize: h * 0.018)),
                  ],
                ),
              ),
            )
          else
            const SizedBox(width: 80),

          if (_currentStep < 3)
            GestureDetector(
              onTap: () {
                if (_currentStep == 1 && _selectedChapters.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Please select at least one chapter"),
                      backgroundColor: Colors.orange.shade700,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                setState(() => _currentStep++);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: h * 0.015),
                decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Text("Next", style: TextStyle(color: Colors.white, fontSize: h * 0.018, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.chevron_right, color: Colors.white, size: h * 0.02),
                  ],
                ),
              ),
            )
          else
            GestureDetector(
              onTap: () {
                final controller = _selectedAlgo == 1
                    ? QuizController(
                        selectedChapters: _selectedChapters,
                        intensity: _selectedIntensity,
                      )
                    : Algo2QuizController(
                        selectedChapters: _selectedChapters,
                        intensity: _selectedIntensity,
                      );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizPageContent(controller: controller),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.015),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.green, Colors.green.shade700]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Text("Start Quiz", style: TextStyle(color: Colors.white, fontSize: h * 0.018, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.play_arrow, color: Colors.white, size: h * 0.022),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRightPanel(double h, double w) {
    final totalQuestions = _selectedChapters.length * _selectedIntensity;
    final totalChapters = _currentChapters.length;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: w * 0.22,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            border: Border(left: BorderSide(color: Colors.blue.withValues(alpha: 0.2))),
          ),
          padding: EdgeInsets.all(h * 0.025),
           child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: h * 0.022),
                  SizedBox(width: 8),
                  Text(
                    "Quiz Info — ${_selectedAlgo == 1 ? "Algo 1" : "Algo 2"}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: h * 0.020,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: h * 0.02),
              _buildInfoCard(
                h,
                icon: Icons.school,
                label: "Total Chapters",
                value: "$totalChapters",
                color: Colors.blue,
              ),
              SizedBox(height: h * 0.015),
              _buildInfoCard(
                h,
                icon: Icons.check_circle_outline,
                label: "Selected",
                value: "${_selectedChapters.length}",
                color: Colors.green,
              ),
              SizedBox(height: h * 0.015),
              _buildInfoCard(
                h,
                icon: Icons.assignment,
                label: "Questions",
                value: "$totalQuestions",
                color: Colors.purple,
              ),
              SizedBox(height: h * 0.02),
              Container(
                height: 1,
                color: Colors.white12,
              ),
              SizedBox(height: h * 0.02),
              Text(
                "Tips:",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: h * 0.016,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: h * 0.01),
              Text(
                _selectedAlgo == 1
                    ? "• Mix different chapters\n"
                      "• Higher difficulty = more challenging\n"
                      "• Review before starting\n"
                      "• Take your time answering"
                    : "• Algo 2 covers advanced data structures\n"
                      "• Mix different chapters for better learning\n"
                      "• Higher difficulty = more challenging\n"
                      "• Review before starting\n"
                      "• Take your time answering",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: h * 0.013,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(double h, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(h * 0.015),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: h * 0.028),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: h * 0.013,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: h * 0.020,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}