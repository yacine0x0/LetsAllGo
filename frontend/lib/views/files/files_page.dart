import 'package:flutter/material.dart';
import 'dart:ui';
import '../../controllers/files/files_controller.dart';
import '../../models/files/files_model.dart';
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
  final FilesController _controller = FilesController();
  final Algo2FilesController _algo2Controller = Algo2FilesController();
  int _selectedIndex = 3;
  int _selectedAlgo = 1; // 1 = Algo 1, 2 = Algo 2

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

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
              // ── Sidebar
              _buildSidebar(h, w),

              // ── Contenu principal
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
                            _buildAlgoFilter(h),
                            SizedBox(height: h * 0.015),
                            _buildCategoryFilter(h),
                            SizedBox(height: h * 0.02),
                            Expanded(
                              child: _selectedAlgo == 1
                                  ? (files.isEmpty
                                        ? _buildEmpty(h, "Algo 1")
                                        : _buildFilesGrid(h, w, files))
                                  : Algo2FilesGrid(
                                      h: h,
                                      w: w,
                                      controller: _algo2Controller,
                                      onFileSelected: (index) {
                                        setState(() {
                                          _algo2Controller.selectFile(index);
                                        });
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

  // ── SIDEBAR
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
          ),
          SizedBox(height: h * 0.04),
          ...items.asMap().entries.map(
            (entry) => GestureDetector(
              onTap: () {
                setState(() => _selectedIndex = entry.key);

                if (entry.key == 0) {
                  // Courses → Dashboard
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const DashboardPage()),
                  );
                } else if (entry.key == 1) {
                  // Quiz
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const QuizSelectionPage()),
                  );
                } else if (entry.key == 2) {
                 // Leaderboard
                   Navigator.push(
                     context,
                     MaterialPageRoute(builder: (_) => const LeaderboardPage()),
                   );
                } 
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

  // ── HEADER
  Widget _buildHeader(double h) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Files",
          style: TextStyle(
            fontSize: h * 0.04,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          "Course materials and resources",
          style: TextStyle(fontSize: h * 0.016, color: Colors.white60),
        ),
      ],
    );
  }

  // ── FILTRE ALGO
  Widget _buildAlgoFilter(double h) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => setState(() {
            _selectedAlgo = 1;
            _controller.switchAlgo("algo1");
          }),
          child: _filterChip("Algo 1", h, selected: _selectedAlgo == 1),
        ),
        SizedBox(width: 8),
        GestureDetector(
          onTap: () => setState(() {
            _selectedAlgo = 2;
          }),
          child: _filterChip("Algo 2", h, selected: _selectedAlgo == 2),
        ),
      ],
    );
  }

  // ── FILTRE CATEGORIE
  Widget _buildCategoryFilter(double h) {
    final categories = ["courses", "tds", "examen", "sheatsheet"];
    final labels = ["Courses", "Td's", "Examen", "Sheatsheet"];

    return Row(
      children: List.generate(categories.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => setState(() {
              if (_selectedAlgo == 1) {
                _controller.switchCategory(categories[index]);
              } else {
                _algo2Controller.switchCategory(categories[index]);
              }
            }),
            child: _filterChip(
              labels[index],
              h,
              selected: _selectedAlgo == 1
                  ? _controller.model.selectedCategory == categories[index]
                  : _algo2Controller.model.selectedCategory ==
                        categories[index],
            ),
          ),
        );
      }),
    );
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

  // ── GRILLE FILES ALGO 1
  Widget _buildFilesGrid(double h, double w, List<FileItem> files) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.2,
      ),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        final isSelected = _controller.model.selectedFileIndex == index;

        return GestureDetector(
          onTap: () {
            setState(() => _controller.selectFile(index));

            if (file.type == FileType.pdf) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PdfViewerPage(filePath: file.filePath, title: file.title),
                ),
              );
            } else if (file.type == FileType.image) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ImageViewerPage(
                    filePath: file.filePath,
                    title: file.title,
                  ),
                ),
              );
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: EdgeInsets.all(h * 0.02),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.white24,
                    width: isSelected ? 2 : 1,
                  ),
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
                    Text(
                      file.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: h * 0.016,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: h * 0.005),
                    Text(
                      file.chapterId,
                      style: TextStyle(color: Colors.blue, fontSize: h * 0.013),
                    ),
                    SizedBox(height: h * 0.005),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: h * 0.004,
                      ),
                      decoration: BoxDecoration(
                        color: file.type == FileType.pdf
                            ? Colors.redAccent.withValues(alpha: 0.2)
                            : Colors.greenAccent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        file.type == FileType.pdf ? "PDF" : "IMAGE",
                        style: TextStyle(
                          color: file.type == FileType.pdf
                              ? Colors.redAccent
                              : Colors.greenAccent,
                          fontSize: h * 0.012,
                          fontWeight: FontWeight.bold,
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

  // ── VIDE
  Widget _buildEmpty(double h, String algoName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, color: Colors.white24, size: h * 0.08),
          SizedBox(height: h * 0.02),
          Text(
            "No files available yet for $algoName",
            style: TextStyle(color: Colors.white38, fontSize: h * 0.02),
          ),
          Text(
            "Coming soon...",
            style: TextStyle(color: Colors.white24, fontSize: h * 0.016),
          ),
        ],
      ),
    );
  }
}
