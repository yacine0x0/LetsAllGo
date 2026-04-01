
import 'package:flutter/material.dart';
import 'package:flutter_project_1/views/profil/profil_page.dart';
import '../leaderboard/leaderboard_page.dart';
import 'dart:ui';
import '../../controllers/dashboard/dashboard_controller.dart';
import '../courses_study_page/courses_study_page.dart';

import '../auth/login_page.dart';
import 'algo2_grid.dart';
import '../../controllers/dashboard/algo2_controller.dart';
import '../files/files_page.dart';
import '../quiz/quiz_selection_page.dart';


class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardController _controller = DashboardController();
  final Algo2Controller _algo2Controller = Algo2Controller();
  int _selectedIndex = 0;// 0 = Courses, 1 = Quiz, 2 = Leaderboard, 3 = Files
  int _selectedAlgo = 1; // 1 = Algo 1, 2 = Algo 2 (en construction)

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          // Background
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

          // Contenu principal
          Row(
            children: [
              // ── Sidebar gauche
              _buildSidebar(h, w),

              // ── Contenu central avec effet verre
              Expanded(
                child: ClipRRect(
                  // ← ajouté
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    // ← ajouté
                    filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: Container(
                      margin: EdgeInsets.all(h * 0.02), // ← ajouté
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
                           : Algo2Grid(
                            h: h,
                               w: w,
                               onChapterSelected: (index) {
                                setState(() {
                                  _algo2Controller.selectChapter(index);
                                });
                                 },
                               ),
                              ),

                        _buildContinueButton(h, w),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Panneau droit
              _buildRightPanel(h, w),
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

          // Logo
          Image.asset(
            "assets/images/icone_dash.png",
            width: h * 0.15,
            height: h * 0.15,
          ),
          SizedBox(height: h * 0.04),

          // Items navigation
          ...items.asMap().entries.map(
            (entry) => GestureDetector(
              onTap: () {
                setState(() => _selectedIndex = entry.key);

                // Navigation selon l'index
                if (entry.key == 1) {
                  // Quiz
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const QuizSelectionPage() ),
                  );
                } else if (entry.key == 2) {
                   Navigator.push(
                     context,
                     MaterialPageRoute(builder: (_) => const LeaderboardPage()),
                   );
                } else if (entry.key == 3) {
                  // Files
                   Navigator.push(
                     context,
                     MaterialPageRoute(builder: (_) => const FilesPage()),
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

          // Logout
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
        // Ligne verticale bleue
        Container(
          width: 4,
          height: h * 0.08,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        

        // Icône + label
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
  Widget _buildHeader(double h, double w) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hey ${_controller.model.username} ,",
          style: TextStyle(
            fontSize: h * 0.04,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          "Let's start your algorithm journey.",
          style: TextStyle(fontSize: h * 0.016, color: Colors.white60),
        ),
      ],
    );
  }

  // ── SEARCH BAR
  Widget _buildSearchBar(double h, double w) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: h * 0.055,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white24),
          ),
          child: TextField(
            style: TextStyle(color: Colors.white, fontSize: h * 0.016),
            decoration: InputDecoration(
              hintText: "Search",
              hintStyle: TextStyle(color: Colors.white38, fontSize: h * 0.016),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.white38,
                size: h * 0.025,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: h * 0.015),
            ),
          ),
        ),
      ),
    );
  }

  // ── FILTRES
  Widget _buildFilters(double h) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => setState(() => _selectedAlgo = 1),
          child: _filterChip("Algo 1", h, selected: _selectedAlgo == 1),
        ),
        SizedBox(width: 8),
        GestureDetector(
          onTap: () => setState(() => _selectedAlgo = 2),
          child: _filterChip("Algo 2", h, selected: _selectedAlgo == 2),
        ),
      ],
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

  // ── GRILLE DES CHAPITRES
  Widget _buildChaptersGrid(double h, double w) {
    final chapters = _controller.model.chapters;

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 60,
        mainAxisSpacing: 25,
        childAspectRatio: 3.5, // ← pas changé
      ),
      itemCount: chapters.length,
      itemBuilder: (context, index) {
        final chapter = chapters[index];
        final isSelected = _controller.model.selectedChapterIndex == index;

        return GestureDetector(


          onDoubleTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => CourseStudyPage(
        chapterTitle: chapter.title,
        chapterSubtitle: chapter.id,
        xmlPath: chapter.xmlPath,
        chapterIcon: chapter.icon, // ← dynamique maintenant
      ),
    ),
  );
},


onTap: () => setState(() => _controller.selectChapter(index)),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(13), // ← coin haut gauche
              topRight: Radius.circular(13), // ← coin haut droit
              bottomLeft: Radius.circular(27), // ← coin bas gauche
              bottomRight: Radius.circular(27), // ← coin bas droit
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                // ← conteneur du chapitre
                padding: EdgeInsets.only(
                  top: h * 0.005, // pour espacer le contenu du bord supérieur
                  left: h * 0.02,
                  right: h * 0.02,
                  bottom: h * 0.02,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue.withValues(alpha: 0.3)
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
                        // ← adapte le contenu automatiquement
                        fit: BoxFit.scaleDown, // ← pour éviter les débordements
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start, // ← aligner à gauche
                          mainAxisAlignment:
                              MainAxisAlignment.start, // ← pour aligner en haut
                          children: [
                            Text(
                              chapter.id,
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: h * 0.025,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: h * 0.005),
                            Text(
                              chapter.title,
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

                    // Image sécurisée
                    FittedBox(
                      // ← adapte l'image automatiquement
                      fit: BoxFit.scaleDown,
                      child: Image.asset(
                        chapter.icon,
                        width: h * 0.08,
                        height: h * 0.08,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.image_not_supported,
                          color: Colors.white38,
                          size: h * 0.04,
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


// ── BOUTON CONTINUER
  Widget _buildContinueButton(double h, double w) {
    return Padding(
      padding: EdgeInsets.only(top: h * 0.02),
      child: Center(
        child: SizedBox(
          width: w * 0.25,
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

            icon: const Icon(Icons.play_circle_outline, color: Colors.white),
            label: Text(
              "Continuer le dernier chapitre",
              style: TextStyle(color: Colors.white, fontSize: h * 0.016),
            ),
          ),
        ),
      ),
    );
  }

  // ── PANNEAU DROIT
  Widget _buildRightPanel(double h, double w) {
    final lessons = _selectedAlgo == 1
        ? _controller.getSelectedLessons() //pour faire le lien entre les deux algos et afficher les leçons du chapitre sélectionné
        : _algo2Controller.getSelectedLessons(); //pour faire le lien entre les deux algos et afficher les leçons du chapitre sélectionné
    final chapterTitle = _selectedAlgo == 1
        ? _controller.getSelectedChapterTitle() //pour faire le lien entre les deux algos et afficher le titre du chapitre sélectionné
        : _algo2Controller.getSelectedChapterTitle();

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: w * 0.27,
          color: Colors.white.withValues(alpha: 0.08),
          padding: EdgeInsets.all(h * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profil
              GestureDetector(
                onTap: () {
                  // TODO: Navigation vers ProfilePage
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfilePage()), // ← temporaire
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(h * 0.025),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: h * 0.035, // ← agrandi
                        backgroundColor: Colors.blue,
                        child: Text(
                          _controller.model.username[0],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: h * 0.025, // ← agrandi
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        // ← ajouté pour éviter overflow
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _controller.model.username, // controller de l'algo 1 
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    h *
                                    0.023, // ← corrigé (était 0.06 trop grand)
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis, // ← sécurisé
                            ),
                            Text(
                              _controller.model.role,
                              style: TextStyle(

                                color: const Color.fromARGB(255, 223, 220, 220),
                                fontSize: h * 0.020,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: h * 0.03),

              // Cours actuel
              Text(
                "cours actuel",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: h * 0.030, // ← agrandi
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: h * 0.01),

              // Titre chapitre sélectionné
              if (chapterTitle.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(h * 0.015), // ← agrandi
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "content of $chapterTitle",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: h * 0.022, // ← agrandi
                    ),
                  ),
                ),
              SizedBox(height: h * 0.015),

              // Liste des leçons
              Expanded(
                child: lessons.isEmpty
                    ? Text(
                        "Selection a chapter to see its lessons.",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 255, 254, 254),
                          fontSize: h * 0.023, // ← agrandi
                        ),
                      )
                    : ListView.builder(
                        itemCount: lessons.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {},
                            child: Container(
                              margin: EdgeInsets.only(
                                bottom: h * 0.015,
                              ), // ← agrandi
                              padding: EdgeInsets.all(h * 0.018), // ← agrandi
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    "${index + 1}", // Numéro de la leçon
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: h * 0.020,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ), //l'espacement entre le numéro et le titre
                                  Expanded(
                                    child: Text(
                                      lessons[index],
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: h * 0.016, // ← agrandi
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}