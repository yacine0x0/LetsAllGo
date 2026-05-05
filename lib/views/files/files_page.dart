import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../controllers/files/files_controller.dart';
import '../../models/files/files_model.dart';
import '../../service/language_service.dart';
import '../../service/sound/sound_settings_service.dart';

import '../auth/login_page.dart';
import '../dashboard/dashboard_page.dart';
import '../pdf_images_views/pdf_viewer_page.dart';
import '../pdf_images_views/image_viewer_page.dart';
import '../files/algo2_files_grid.dart';
import '../../controllers/files/files_algo2_controller.dart';
import '../quiz/quiz_selection_page.dart';
import '../leaderboard/leaderboard_page.dart';

class FilesPage extends StatefulWidget {
  const FilesPage({super.key});

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  final FilesController      _controller      = FilesController();
  final Algo2FilesController _algo2Controller = Algo2FilesController();
  final AudioPlayer          _audioPlayer     = AudioPlayer();

  int _selectedIndex = 3;
  int _selectedAlgo  = 1;

  // ══════════════════════════════════════════
  // SOUND — edit the file names here to change sounds
  // ══════════════════════════════════════════
  static const String _soundSidebarButton = 'sounds/PRESS_1.wav';

  Future<void> _playSound(String soundPath) async {
    if (!await SoundSettingsService.isSoundEnabled()) return;
    await _audioPlayer.play(AssetSource(soundPath));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageService>();
    final h    = MediaQuery.of(context).size.height;
    final w    = MediaQuery.of(context).size.width;

    final files = _controller.getFilesByCategory(
      _controller.model.selectedAlgo,
      _controller.model.selectedCategory,
    );

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
              _buildSidebar(h, w, lang),
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
                            _buildHeader(h, lang),
                            SizedBox(height: h * 0.02),
                            _buildAlgoFilter(h, lang),
                            SizedBox(height: h * 0.015),
                            _buildCategoryFilter(h, lang),
                            SizedBox(height: h * 0.02),
                            Expanded(
                              child: _selectedAlgo == 1
                                  ? (files.isEmpty
                                      ? _buildEmpty(h, lang)
                                      : _buildFilesGrid(h, w, files))
                                  : Algo2FilesGrid(
                                      h: h,
                                      w: w,
                                      controller: _algo2Controller,
                                      onFileSelected: (index) {
                                        setState(() =>
                                            _algo2Controller.selectFile(index));
                                      },
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
        ],
      ),
    );
  }

  Widget _buildSidebar(double h, double w, LanguageService lang) {
    final items = [
      {"icon": Icons.menu_book,    "label": lang.t("Cours",      "Courses")},
      {"icon": Icons.quiz,         "label": "Quiz"},
      {"icon": Icons.emoji_events, "label": lang.t("Classement", "Leaderboard")},
      {"icon": Icons.folder,       "label": lang.t("Fichiers",   "Files")},
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
                if (entry.key == 0) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(
                          builder: (_) => const DashboardPage()));
                } else if (entry.key == 1) {
                  Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const QuizSelectionPage()));
                } else if (entry.key == 2) {
                  Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const LeaderboardPage()));
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
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const LoginPage()));
            },
            child: _buildSidebarItem(
              icon:     Icons.logout,
              label:    lang.t("Déconnexion", "Logout"),
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
          color: isActive ? Colors.blue : Colors.transparent,
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
                Text(label,
                    style: TextStyle(
                        color: isActive
                            ? Colors.blue
                            : (isLogout ? Colors.red : Colors.white70),
                        fontSize: h * 0.02)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(double h, LanguageService lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(lang.t("Fichiers", "Files"),
            style: TextStyle(
                fontSize: h * 0.04,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        Text(lang.t("Supports de cours et ressources",
                "Course materials and resources"),
            style: TextStyle(fontSize: h * 0.016, color: Colors.white60)),
      ],
    );
  }

  Widget _buildAlgoFilter(double h, LanguageService lang) {
    return Row(
      children: [
        _filterChip(lang.t("Algo 1", "Algo 1"), h, _selectedAlgo == 1, () {
          setState(() {
            _selectedAlgo = 1;
            _controller.switchAlgo("algo1");
          });
        }),
        const SizedBox(width: 8),
        _filterChip(lang.t("Algo 2", "Algo 2"), h, _selectedAlgo == 2, () {
          setState(() => _selectedAlgo = 2);
        }),
      ],
    );
  }

  Widget _buildCategoryFilter(double h, LanguageService lang) {
    final categories = ["courses", "tds", "examen", "sheatsheet"];
    final labels = [
      lang.t("Cours", "Courses"),
      "TDs",
      lang.t("Examen", "Exam"),
      lang.t("Fiches", "Sheets"),
    ];
    return Row(
      children: List.generate(categories.length, (i) {
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _filterChip(labels[i], h, false, () {
            setState(() {
              if (_selectedAlgo == 1) {
                _controller.switchCategory(categories[i]);
              } else {
                _algo2Controller.switchCategory(categories[i]);
              }
            });
          }),
        );
      }),
    );
  }

  Widget _filterChip(
      String label, double h, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: 16, vertical: h * 0.008),
        decoration: BoxDecoration(
          color: selected ? Colors.blue : Colors.white12,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildEmpty(double h, LanguageService lang) {
    return Center(
      child: Text(lang.t("Aucun fichier disponible", "No files available"),
          style: TextStyle(color: Colors.white38, fontSize: h * 0.02)),
    );
  }

  Widget _buildFilesGrid(double h, double w, List<FileItem> files) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 1.2),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        return GestureDetector(
          onTap: () {
            if (file.type == FileType.pdf) {
              Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => PdfViewerPage(
                          filePath: file.filePath, title: file.title)));
            } else {
              Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => ImageViewerPage(
                          filePath: file.filePath, title: file.title)));
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: EdgeInsets.all(h * 0.02),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      file.type == FileType.pdf
                          ? Icons.picture_as_pdf
                          : Icons.image_outlined,
                      color: file.type == FileType.pdf
                          ? Colors.redAccent
                          : Colors.greenAccent,
                      size: h * 0.05,
                    ),
                    SizedBox(height: h * 0.01),
                    Text(file.title,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: h * 0.016,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    SizedBox(height: h * 0.005),
                    Text(file.chapterId,
                        style: TextStyle(
                            color: Colors.blue, fontSize: h * 0.013)),
                    SizedBox(height: h * 0.005),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8, vertical: h * 0.004),
                      decoration: BoxDecoration(
                        color: file.type == FileType.pdf
                            ? Colors.redAccent.withOpacity(0.2)
                            : Colors.greenAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        file.type == FileType.pdf ? "PDF" : "IMAGE",
                        style: TextStyle(
                            color: file.type == FileType.pdf
                                ? Colors.redAccent
                                : Colors.greenAccent,
                            fontSize: h * 0.012,
                            fontWeight: FontWeight.bold),
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
}