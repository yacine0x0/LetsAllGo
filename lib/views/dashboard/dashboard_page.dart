// lib/views/dashboard/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';

import '../../service/language_service.dart';
import '../../service/progress/progress_service.dart';

import 'package:flutter_project_1/views/profil/profil_page.dart';
import '../leaderboard/leaderboard_page.dart';
import '../../controllers/dashboard/dashboard_controller.dart';
import '../courses_study_page/courses_study_page.dart';
import '../auth/login_page.dart';
import 'algo2_grid.dart';
import '../../controllers/dashboard/algo2_controller.dart';
import '../files/files_page.dart';
import '../quiz/quiz_selection_page.dart';
import '../../controllers/auth/login_controller.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardController _controller      = DashboardController();
  final Algo2Controller     _algo2Controller = Algo2Controller();
  final AudioPlayer         _audioPlayer     = AudioPlayer();

  // ✅ Recherche
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  int _selectedIndex = 0;
  int _selectedAlgo  = 1;

  late LanguageService _lang;

  static const String _soundSidebarButton = 'sounds/PRESS_1.wav';

  Future<void> _playSound(String soundPath) async {
    try {
      await _audioPlayer.play(AssetSource(soundPath));
    } catch (e) {
      print('❌ Audio error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _lang = Provider.of<LanguageService>(context, listen: false);
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase().trim());
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ✅ Filtre les chapitres selon la recherche
  List<dynamic> get _filteredAlgo1Chapters {
    final chapters = _controller.model.chapters;
    if (_searchQuery.isEmpty) return chapters;
    return chapters.where((c) =>
      c.title.toLowerCase().contains(_searchQuery) ||
      c.id.toLowerCase().contains(_searchQuery)
    ).toList();
  }

  List<dynamic> get _filteredAlgo2Chapters {
    final chapters = _algo2Controller.model.chapters;
    if (_searchQuery.isEmpty) return chapters;
    return chapters.where((c) =>
      c.title.toLowerCase().contains(_searchQuery) ||
      c.number.toLowerCase().contains(_searchQuery)
    ).toList();
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
                            _buildHeader(h, w),
                            SizedBox(height: h * 0.02),
                            _buildSearchBar(h, w),
                            SizedBox(height: h * 0.02),
                            _buildFilters(h),
                            SizedBox(height: h * 0.02),
                            Expanded(
                              child: _selectedAlgo == 1
                                  ? _buildChaptersGrid(h, w)
                                  : _buildAlgo2Grid(h, w),
                            ),
                            _buildContinueButton(h, w),
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
                if (entry.key == 1) {
                  Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const QuizSelectionPage()));
                } else if (entry.key == 2) {
                  Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const LeaderboardPage()));
                } else if (entry.key == 3) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const FilesPage()));
                }
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
              final controller = LoginController();
              await controller.logout();
              if (!mounted) return;
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
                      fontSize:   h * 0.020,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(double h, double w) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hey ${_controller.model.username},",
          style: TextStyle(
            fontSize:   h * 0.04,
            fontWeight: FontWeight.bold,
            color:      Colors.white,
          ),
        ),
        Text(
          _lang.t(
            "Commencer votre journée d'Algorithmique.",
            "Let's start your algorithm journey.",
          ),
          style: TextStyle(fontSize: h * 0.016, color: Colors.white60),
        ),
      ],
    );
  }

  Widget _buildSearchBar(double h, double w) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: h * 0.055,
          decoration: BoxDecoration(
            color:        Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border:       Border.all(color: Colors.white24),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: Colors.white, fontSize: h * 0.016),
                  decoration: InputDecoration(
                    hintText:  _lang.t("Chercher un chapitre...", "Search a chapter..."),
                    hintStyle: TextStyle(color: Colors.white38, fontSize: h * 0.016),
                    prefixIcon: Icon(Icons.search,
                        color: Colors.white38, size: h * 0.025),
                    border:         InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: h * 0.015),
                  ),
                ),
              ),
              // ✅ Bouton clear
              if (_searchQuery.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: Padding(
                    padding: EdgeInsets.only(right: h * 0.015),
                    child: Icon(Icons.close,
                        color: Colors.white54, size: h * 0.025),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(double h) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => setState(() {
            _selectedAlgo = 1;
            _searchController.clear();
          }),
          child: _filterChip(_lang.t("Algo 1", "Algo 1"), h,
              selected: _selectedAlgo == 1),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => setState(() {
            _selectedAlgo = 2;
            _searchController.clear();
          }),
          child: _filterChip(_lang.t("Algo 2", "Algo 2"), h,
              selected: _selectedAlgo == 2),
        ),
        // ✅ Résultats de recherche
        if (_searchQuery.isNotEmpty) ...[
          const SizedBox(width: 12),
          Text(
            _lang.t(
              "${_selectedAlgo == 1 ? _filteredAlgo1Chapters.length : _filteredAlgo2Chapters.length} résultat(s)",
              "${_selectedAlgo == 1 ? _filteredAlgo1Chapters.length : _filteredAlgo2Chapters.length} result(s)",
            ),
            style: TextStyle(color: Colors.white54, fontSize: h * 0.015),
          ),
        ],
      ],
    );
  }

  Widget _filterChip(String label, double h, {bool selected = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: h * 0.008),
      decoration: BoxDecoration(
        color:        selected ? Colors.blue : Colors.white12,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? Colors.blue : Colors.white24,
        ),
      ),
      child: Text(label,
          style: TextStyle(
            color:      Colors.white,
            fontSize:   h * 0.015,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          )),
    );
  }

  // ✅ Grid algo1 avec recherche + isFinished
  Widget _buildChaptersGrid(double h, double w) {
    final chapters = _filteredAlgo1Chapters;

    if (chapters.isEmpty) {
      return Center(
        child: Text(
          _lang.t("Aucun chapitre trouvé", "No chapter found"),
          style: TextStyle(color: Colors.white54, fontSize: h * 0.022),
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:  2,
        crossAxisSpacing: 60,
        mainAxisSpacing:  25,
        childAspectRatio: 3.5,
      ),
      itemCount: chapters.length,
      itemBuilder: (context, index) {
        final chapter    = chapters[index];
        final isSelected = _controller.model.selectedChapterIndex == index;
        final isCompleted =
            ProgressService.isAlreadyCompleted('algo1', chapter.title);

        return GestureDetector(
          onDoubleTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CourseStudyPage(
                  chapterTitle:    chapter.title,
                  chapterSubtitle: chapter.id,
                  xmlPath:         chapter.xmlPath,
                  chapterIcon:     chapter.icon,
                ),
              ),
            );
          },
          onTap: () => setState(() => _controller.selectChapter(index)),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft:     Radius.circular(13),
              topRight:    Radius.circular(13),
              bottomLeft:  Radius.circular(27),
              bottomRight: Radius.circular(27),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: EdgeInsets.only(
                  top:    h * 0.005,
                  left:   h * 0.02,
                  right:  h * 0.02,
                  bottom: h * 0.02,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue.withValues(alpha: 0.3)
                      : isCompleted
                          ? Colors.green.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Colors.blue
                        : isCompleted
                            ? Colors.green.withValues(alpha: 0.6)
                            : Colors.white24,
                    width: isSelected || isCompleted ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit:       BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  chapter.id,
                                  style: TextStyle(
                                    color:      Colors.blue,
                                    fontSize:   h * 0.025,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // ✅ Badge complété
                                if (isCompleted) ...[
                                  const SizedBox(width: 6),
                                  Icon(Icons.check_circle,
                                      color: Colors.green,
                                      size:  h * 0.022),
                                ],
                              ],
                            ),
                            SizedBox(height: h * 0.005),
                            Text(
                              chapter.title,
                              style: TextStyle(
                                color:      Colors.white,
                                fontSize:   h * 0.02,
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
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Image.asset(
                        chapter.icon,
                        width:  h * 0.08,
                        height: h * 0.08,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.image_not_supported,
                          color: Colors.white38,
                          size:  h * 0.04,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ✅ Grid algo2 inline avec recherche + isFinished
  Widget _buildAlgo2Grid(double h, double w) {
    final chapters = _filteredAlgo2Chapters;

    if (chapters.isEmpty) {
      return Center(
        child: Text(
          _lang.t("Aucun chapitre trouvé", "No chapter found"),
          style: TextStyle(color: Colors.white54, fontSize: h * 0.022),
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:   2,
        crossAxisSpacing: 60,
        mainAxisSpacing:  25,
        childAspectRatio: 3.5,
      ),
      itemCount: chapters.length,
      itemBuilder: (context, index) {
        final chapter    = chapters[index];
        final isSelected = _algo2Controller.model.selectedChapterIndex == index;
        final isCompleted =
            ProgressService.isAlreadyCompleted('algo2', chapter.title);

        return GestureDetector(
          onDoubleTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CourseStudyPage(
                  chapterTitle:    chapter.title,
                  chapterSubtitle: chapter.number,
                  xmlPath:         chapter.xmlPath,
                  chapterIcon:     chapter.icon,
                ),
              ),
            );
          },
          onTap: () {
            setState(() => _algo2Controller.selectChapter(index));
          },
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft:     Radius.circular(13),
              topRight:    Radius.circular(13),
              bottomLeft:  Radius.circular(27),
              bottomRight: Radius.circular(27),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: EdgeInsets.only(
                  top:    h * 0.005,
                  left:   h * 0.02,
                  right:  h * 0.02,
                  bottom: h * 0.02,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue.withValues(alpha: 0.3)
                      : isCompleted
                          ? Colors.green.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Colors.blue
                        : isCompleted
                            ? Colors.green.withValues(alpha: 0.6)
                            : Colors.white24,
                    width: isSelected || isCompleted ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit:       BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  chapter.number,
                                  style: TextStyle(
                                    color:      Colors.blue,
                                    fontSize:   h * 0.025,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // ✅ Badge complété
                                if (isCompleted) ...[
                                  const SizedBox(width: 6),
                                  Icon(Icons.check_circle,
                                      color: Colors.green,
                                      size:  h * 0.022),
                                ],
                              ],
                            ),
                            SizedBox(height: h * 0.005),
                            Text(
                              chapter.title,
                              style: TextStyle(
                                color:      Colors.white,
                                fontSize:   h * 0.02,
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
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Image.asset(
                        chapter.icon,
                        width:  h * 0.08,
                        height: h * 0.08,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.image_not_supported,
                          color: Colors.white38,
                          size:  h * 0.04,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContinueButton(double h, double w) {
    return Padding(
      padding: EdgeInsets.only(top: h * 0.02),
      child: Center(
        child: SizedBox(
          width:  w * 0.25,
          height: h * 0.06,
          child: ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Colors.blue),
              ),
            ),
            icon:  const Icon(Icons.play_circle_outline, color: Colors.white),
            label: Text(
              _lang.t("Continuer le dernier chapitre", "Continue last chapter"),
              style: TextStyle(color: Colors.white, fontSize: h * 0.016),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRightPanel(double h, double w) {
    final lessons = _selectedAlgo == 1
        ? _controller.getSelectedLessons()
        : _algo2Controller.getSelectedLessons();
    final chapterTitle = _selectedAlgo == 1
        ? _controller.getSelectedChapterTitle()
        : _algo2Controller.getSelectedChapterTitle();

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width:   w * 0.27,
          color:   Colors.white.withValues(alpha: 0.08),
          padding: EdgeInsets.all(h * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProfilePage())),
                child: Container(
                  padding: EdgeInsets.all(h * 0.025),
                  decoration: BoxDecoration(
                    color:        Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius:          h * 0.035,
                        backgroundColor: Colors.blue,
                        child: Text(
                          _controller.model.username[0],
                          style: TextStyle(
                            color:    Colors.white,
                            fontSize: h * 0.025,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_controller.model.username,
                                style: TextStyle(
                                  color:      Colors.white,
                                  fontSize:   h * 0.023,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis),
                            Text(_controller.model.role,
                                style: TextStyle(
                                  color:    Colors.white60,
                                  fontSize: h * 0.020,
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: h * 0.03),

              // ✅ Progression globale dans le panel droit
              _buildProgressionPanel(h),
              SizedBox(height: h * 0.02),

              Text(
                _lang.t("Cours actuel", "Current course"),
                style: TextStyle(
                  color:      Colors.white,
                  fontSize:   h * 0.030,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: h * 0.01),
              if (chapterTitle.isNotEmpty)
                Container(
                  width:   double.infinity,
                  padding: EdgeInsets.all(h * 0.015),
                  decoration: BoxDecoration(
                    color:        Colors.blue.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _lang.t(
                      "Contenu de $chapterTitle",
                      "Content of $chapterTitle",
                    ),
                    style: TextStyle(
                      color:    Colors.white,
                      fontSize: h * 0.022,
                    ),
                  ),
                ),
              SizedBox(height: h * 0.015),
              Expanded(
                child: lessons.isEmpty
                    ? Text(
                        _lang.t(
                          "Sélectionner un chapitre pour voir ses leçons.",
                          "Select a chapter to see its lessons.",
                        ),
                        style: TextStyle(
                          color:    Colors.white,
                          fontSize: h * 0.023,
                        ),
                      )
                    : ListView.builder(
                        itemCount: lessons.length,
                        itemBuilder: (context, index) => Container(
                          margin:  EdgeInsets.only(bottom: h * 0.015),
                          padding: EdgeInsets.all(h * 0.018),
                          decoration: BoxDecoration(
                            color:        Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border:       Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            children: [
                              Text("${index + 1}",
                                  style: TextStyle(
                                    color:      Colors.blue,
                                    fontSize:   h * 0.020,
                                    fontWeight: FontWeight.bold,
                                  )),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(lessons[index],
                                    style: TextStyle(
                                      color:    Colors.white70,
                                      fontSize: h * 0.016,
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Widget progression dans le panel droit
  Widget _buildProgressionPanel(double h) {
    final algo1 = ProgressService.getAlgo1Progress();
    final algo2 = ProgressService.getAlgo2Progress();
    final global = ProgressService.getGlobalProgress();

    return Container(
      padding: EdgeInsets.all(h * 0.015),
      decoration: BoxDecoration(
        color:        Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _lang.t("Votre progression", "Your progress"),
            style: TextStyle(
              color:      Colors.white,
              fontSize:   h * 0.018,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: h * 0.01),
          _buildProgressRow(h, "Algo 1", algo1, const Color(0xFF00E5FF)),
          SizedBox(height: h * 0.008),
          _buildProgressRow(h, "Algo 2", algo2, Colors.purple),
          SizedBox(height: h * 0.008),
          _buildProgressRow(h, "Global", global, Colors.green),
        ],
      ),
    );
  }

  Widget _buildProgressRow(double h, String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: h * 0.06,
          child: Text(
            label,
            style: TextStyle(color: Colors.white60, fontSize: h * 0.014),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value:           value,
              minHeight:       h * 0.007,
              backgroundColor: Colors.white12,
              valueColor:      AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        SizedBox(width: h * 0.01),
        Text(
          "${(value * 100).toInt()}%",
          style: TextStyle(
            color:      color,
            fontSize:   h * 0.014,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}