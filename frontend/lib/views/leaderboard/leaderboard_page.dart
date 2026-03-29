// ─────────────────────────────────────────
// VIEW : leaderboard_page.dart
// lib/views/leaderboard/leaderboard_page.dart
// ─────────────────────────────────────────

import 'package:flutter/material.dart';

import 'package:flutter_project_1/views/profil/profil_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../../controllers/leaderboard/leaderboard_controller.dart';
import '../../models/leaderboard/leaderboard_model.dart';
import '../dashboard/dashboard_page.dart';
import '../files/files_page.dart';
import '../quiz/quiz_selection_page.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final LeaderboardController _controller = LeaderboardController();
  bool _isLoading = true;
  int _selectedIndex = 2;

  // ── Font Orbitron — identique à la maquette
  TextStyle _orbitron({
    double size = 14,
    FontWeight weight = FontWeight.normal,
    Color color = Colors.white,
    double letterSpacing = 0,
  }) =>
      GoogleFonts.orbitron(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );

  @override
  void initState() {
    super.initState();
    _controller.loadLeaderboard().then((_) {
      setState(() => _isLoading = false);
    });
  }

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
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.blue))
              : Row(
                  children: [
                    _buildSidebar(h, w),
                    Expanded(child: _buildMainContent(h, w)),
                    _buildRightPanel(h, w),
                  ],
                ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  // SIDEBAR
  // ══════════════════════════════════════════
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
          Image.asset("assets/images/icone_dash.png",
              width: h * 0.15, height: h * 0.15),
          SizedBox(height: h * 0.04),
          ...items.asMap().entries.map(
            (entry) => GestureDetector(
              onTap: () {
                setState(() => _selectedIndex = entry.key);
                if (entry.key == 0) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const DashboardPage()));


                } else if (entry.key == 1) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const QuizSelectionPage()));
                }else if (entry.key == 3) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const FilesPage()));
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
            onTap: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const DashboardPage())),
            child: _buildSidebarItem(
                icon: Icons.logout, label: "Logout", h: h, isLogout: true),
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
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════
  // CONTENU PRINCIPAL — tableau leaderboard
  // ══════════════════════════════════════════
  Widget _buildMainContent(double h, double w) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Container(
          margin: EdgeInsets.all(h * 0.02),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.15), width: 1.5),
          ),
          child: Padding(
            padding: EdgeInsets.all(h * 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Leaderboard",
                    style: _orbitron(
                        size: h * 0.04,
                        weight: FontWeight.bold,
                        letterSpacing: 2)),
                SizedBox(height: h * 0.005),
                Text("Classement global des étudiants",
                    style: _orbitron(size: h * 0.018, color: const Color.fromARGB(200, 255, 255, 255))),
                SizedBox(height: h * 0.03),
                _buildTableHeader(h, w),
                SizedBox(height: h * 0.01),
                Container(height: 1.5, color: Colors.blue.withValues(alpha: 0.6)),
                SizedBox(height: h * 0.01),
                Expanded(
                  child: ListView.builder(
                    itemCount: _controller.model.entries.length,
                    itemBuilder: (context, index) =>
                        _buildTableRow(_controller.model.entries[index], h, w),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader(double h, double w) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: w * 0.01, vertical: h * 0.012),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: w * 0.06,
            child: Text("Rank",
                style: _orbitron(
                    size: h * 0.018,
                    weight: FontWeight.bold,
                    color: Colors.white70,
                    letterSpacing: 1.5)),
          ),
          Expanded(
            child: Text("User Name",
                style: _orbitron(
                    size: h * 0.018,
                    weight: FontWeight.bold,
                    color: Colors.white70,
                    letterSpacing: 1.5)),
          ),
          SizedBox(
            width: w * 0.15,
            child: Text("Total Points",
                textAlign: TextAlign.center,
                style: _orbitron(
                    size: h * 0.018,
                    weight: FontWeight.bold,
                    color: Colors.white70,
                    letterSpacing: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(LeaderboardEntry entry, double h, double w) {
    final isTop3 = entry.rank <= 3;
    final medal = LeaderboardController.medalEmoji(entry.rank);
    final medalColor = LeaderboardController.medalColor(entry.rank);

    return Container(
      margin: EdgeInsets.only(bottom: h * 0.008),
      padding: EdgeInsets.symmetric(horizontal: w * 0.01, vertical: h * 0.012),
      decoration: BoxDecoration(
        color: isTop3
            ? medalColor.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isTop3 ? medalColor.withValues(alpha: 0.3) : Colors.white12,
          width: isTop3 ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: w * 0.06,
            child: medal.isNotEmpty
                ? Text(medal, style: TextStyle(fontSize: h * 0.025))
                : Text(entry.rank.toString().padLeft(2, '0'),
                    style: _orbitron(
                        size: h * 0.018,
                        weight: FontWeight.bold,
                        color: Colors.white60)),
          ),
          Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: h * 0.022,
                  backgroundColor: isTop3
                      ? medalColor.withValues(alpha: 0.4)
                      : Colors.blue.withValues(alpha: 0.3),
                  child: Text(entry.avatarInitial,
                      style: _orbitron(
                          size: h * 0.016, weight: FontWeight.bold)),
                ),
                SizedBox(width: w * 0.01),
                Text(entry.username,
                    style: _orbitron(
                        size: h * 0.018,
                        weight: isTop3 ? FontWeight.bold : FontWeight.normal,
                        color: isTop3 ? Colors.white : Colors.white70)),
              ],
            ),
          ),
          SizedBox(
            width: w * 0.15,
            child: Text(entry.totalPoints.toString(),
                textAlign: TextAlign.center,
                style: _orbitron(
                    size: h * 0.018,
                    weight: isTop3 ? FontWeight.bold : FontWeight.normal,
                    color: isTop3 ? medalColor : Colors.white60,
                    letterSpacing: 0.5)),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  // PANNEAU DROIT — amélioré
  // ══════════════════════════════════════════
  Widget _buildRightPanel(double h, double w) {
    final user = _controller.model.currentUser;
    if (user == null) return const SizedBox.shrink();

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: w * 0.27,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            border: Border(
              left: BorderSide(color: Colors.blue.withValues(alpha: 0.2)),
            ),
          ),
          padding: EdgeInsets.all(h * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Carte profil avec dégradé
             Material(
              color: Colors.transparent,
              child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                    MaterialPageRoute(
                    builder: (_) => const ProfilePage(), // change vers ProfilePage après
                  ),
                );
              },
            child: Container(
              padding: EdgeInsets.all(h * 0.02),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withValues(alpha: 0.25),
                    Colors.purple.withValues(alpha: 0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.4)),
              ),
            child: Row(
              children: [
                Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: h * 0.08,
                    height: h * 0.08,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue, width: 2),
                    ),
                  ),
                  CircleAvatar(
                    radius: h * 0.032,
                    backgroundColor: Colors.blue.withValues(alpha: 0.6),
                  child: Text(
                    user.avatarInitial,
                    style: _orbitron(
                      size: h * 0.025,
                      weight: FontWeight.bold,
                    ),
                ),
              ),
            ],
          ),
          SizedBox(width: w * 0.012),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username,
                  style: _orbitron(
                    size: h * 0.020,
                    weight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    "Student",
                    style: _orbitron(
                      size: h * 0.013,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
),
              SizedBox(height: h * 0.025),

              // ── Titre progression
              Row(
                children: [
                  Icon(Icons.trending_up, color: Colors.blue, size: h * 0.025),
                  SizedBox(width: 8),
                  Text("Your progression",
                      style: _orbitron(
                          size: h * 0.020,
                          weight: FontWeight.bold,
                          letterSpacing: 1)),
                ],
              ),
              SizedBox(height: h * 0.02),

              // ── Score
              _buildStatCard(
                h: h,
                icon: Icons.stars_rounded,
                label: "Score",
                value: user.totalPoints.toString(),
                color: const Color.fromARGB(255, 251, 255, 0),
              ),
              SizedBox(height: h * 0.015),

              // ── Rank
              _buildStatCard(
                h: h,
                icon: Icons.emoji_events,
                label: "Rank",
                value: user.rank.toString().padLeft(2, '0'),
                color: const Color.fromARGB(255, 71, 255, 92),
              ),
              SizedBox(height: h * 0.025),

              // ── Divider décoratif
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.transparent,
                    Colors.blue.withValues(alpha: 0.5),
                    Colors.transparent,
                  ]),
                ),
              ),
              SizedBox(height: h * 0.025),

              // ── Algo progress
              _buildProgressSection(
                h: h, w: w,
                label: "Algorithmic Progress",
                value: user.algo1Progress,
                color: const Color.fromARGB(255, 0, 255, 247),
                labelColor: const Color.fromARGB(200, 255, 255, 255), // ← ta couleur ici
              ),
              SizedBox(height: h * 0.025),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required double h,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: h * 0.015, vertical: h * 0.012),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: h * 0.028),
          SizedBox(width: h * 0.012),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: _orbitron(size: h * 0.013, color: Colors.white54)),
              Text(value,
                  style: _orbitron(
                      size: h * 0.026,
                      weight: FontWeight.bold,
                      color: color,
                      letterSpacing: 1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection({
    required double h,
    required double w,
    required String label,
    required double value,
    required Color color,
    Color? labelColor,
  }) {
    return Row(
      children: [
        // Cercle
        SizedBox(
          width: h * 0.10,
          height: h * 0.10,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: h * 0.10,
                height: h * 0.10,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: h * 0.009,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Text("${(value * 100).toInt()}%",
                  style: _orbitron(
                      size: h * 0.018,
                      weight: FontWeight.bold,
                      color: color)),
            ],
          ),
        ),
        SizedBox(width: w * 0.012),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: _orbitron(
                      size: h * 0.015,
                      weight: FontWeight.bold,
                      color: labelColor ?? Colors.white70)),
              SizedBox(height: h * 0.008),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: h * 0.008,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              SizedBox(height: h * 0.005),
              Text("${(value * 100).toInt()}% complété",
                  style: _orbitron(size: h * 0.015, color: const Color.fromARGB(200, 255, 255, 255))),
            ],
          ),
        ),
      ],
    );
  }
}