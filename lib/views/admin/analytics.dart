// views/admin/analytics_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import '../../controllers/admin_controllers/analytics_controller.dart';
import '../admin/admin_page.dart';
import '../admin/profil_admin_page.dart';
import '../auth/login_page.dart';
import '../../service/language_service.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final AnalyticsController _controller = AnalyticsController();
  int  _selectedSidebarIndex = 1;
  bool _isLoading            = true;

  @override
  void initState() {
    super.initState();
    _controller.loadAnalytics().then((_) {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageService>();
    final h    = MediaQuery.of(context).size.height;
    final w    = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFF0D0D2B)),
          Opacity(
            opacity: 0.60,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/background_admin.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Row(
            children: [
              _buildSidebar(h, w, lang),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.greenAccent))
                    : _controller.model.chapters.isEmpty &&
                              _controller.model.quizStats.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bar_chart,
                                    color: Colors.white24, size: h * 0.08),
                                SizedBox(height: h * 0.02),
                                Text(
                                  lang.t("Aucune donnée disponible", "No data available"),
                                  style: TextStyle(
                                      color: Colors.white54, fontSize: h * 0.02),
                                ),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            padding: EdgeInsets.symmetric(
                                horizontal: w * 0.03, vertical: h * 0.03),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lang.t("Analytique", "Analytics"),
                                  style: TextStyle(
                                      color:      Colors.white,
                                      fontSize:   h * 0.04,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: h * 0.005),
                                Text(
                                  lang.t(
                                    "Visualisez les performances des étudiants par chapitre et par quiz.",
                                    "View student performance by chapter and quiz.",
                                  ),
                                  style: TextStyle(
                                      color: Colors.white54, fontSize: h * 0.016),
                                ),
                                SizedBox(height: h * 0.03),
                                _buildCoursesSection(h, w, lang),
                                SizedBox(height: h * 0.03),
                                _buildQuizSection(h, w, lang),
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

  // ══════════════════════════════════════════
  // SIDEBAR
  // ══════════════════════════════════════════
  Widget _buildSidebar(double h, double w, LanguageService lang) {
    final items = [
      {"icon": Icons.people,    "label": lang.t("Utilisateurs", "Users")},
      {"icon": Icons.bar_chart, "label": lang.t("Analytique",   "Analytics")},
      {"icon": Icons.person,    "label": lang.t("Profil",       "Profile")},
    ];

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: w * 0.09,
          color: Colors.black.withValues(alpha: 0.4),
          child: Column(
            children: [
              SizedBox(height: h * 0.02),
              Image.asset(
                "assets/images/icone_dash.png",
                width: h * 0.13, height: h * 0.13,
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.school, color: Colors.blue, size: 40),
              ),
              SizedBox(height: h * 0.04),
              ...items.asMap().entries.map(
                (entry) => GestureDetector(
                  onTap: () {
                    setState(() => _selectedSidebarIndex = entry.key);
                    if (entry.key == 0) {
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const AdminPage()));
                    } else if (entry.key == 2) {
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (_, _, _) => const ProfilePage(),
                        transitionsBuilder: (_, animation, _, child) =>
                            SlideTransition(
                          position: Tween(
                                  begin: const Offset(0.0, 1.0),
                                  end:   Offset.zero)
                              .chain(CurveTween(curve: Curves.easeInOut))
                              .animate(animation),
                          child: child,
                        ),
                      ));
                    }
                  },
                  child: _buildSidebarItem(
                    icon:     entry.value["icon"]  as IconData,
                    label:    entry.value["label"] as String,
                    h:        h,
                    isActive: _selectedSidebarIndex == entry.key,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, _, _) => const LoginPage(),
                    transitionsBuilder: (_, anim, _, child) =>
                        FadeTransition(opacity: anim, child: child),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(bottom: h * 0.03),
                  child: Column(
                    children: [
                      Container(
                        width:  double.infinity,
                        height: 1,
                        color:  Colors.white.withValues(alpha: 0.08),
                        margin: EdgeInsets.only(bottom: h * 0.02),
                      ),
                      Icon(Icons.logout_rounded,
                          color: Colors.red.shade300, size: h * 0.035),
                      SizedBox(height: h * 0.005),
                      Text(
                        lang.t("Déconnexion", "Logout"),
                        style: TextStyle(
                          color:      Colors.red.shade300,
                          fontSize:   h * 0.014,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String   label,
    required double   h,
    bool isActive = false,
  }) {
    return Row(
      children: [
        Container(
          width: 3,
          height: h * 0.07,
          decoration: BoxDecoration(
            color: isActive ? Colors.greenAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: h * 0.02),
            child: Column(
              children: [
                Icon(icon,
                    color: isActive ? Colors.greenAccent : Colors.white38,
                    size:  h * 0.04),
                SizedBox(height: h * 0.005),
                Text(label,
                    style: TextStyle(
                      color:      isActive ? Colors.greenAccent : Colors.white38,
                      fontSize:   h * 0.015,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════
  // COURSES STATISTICS — BarChart fl_chart
  // ══════════════════════════════════════════
  Widget _buildCoursesSection(double h, double w, LanguageService lang) {
    final chapters    = _controller.model.displayedChapters;
    final completions = _controller.model.currentCompletions;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: EdgeInsets.all(h * 0.03),
          decoration: BoxDecoration(
            color:        Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(16),
            border:       Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.menu_book_outlined,
                      color: Colors.greenAccent, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    lang.t("Statistiques des Cours", "Courses Statistics"),
                    style: TextStyle(
                        color:      Colors.white,
                        fontSize:   h * 0.025,
                        fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Container(
                        margin: const EdgeInsets.only(left: 12),
                        height: 1,
                        color: Colors.white12),
                  ),
                  const SizedBox(width: 16),
                  _algoButton("Algo 1", 0, h),
                  const SizedBox(width: 8),
                  _algoButton("Algo 2", 1, h),
                ],
              ),
              SizedBox(height: h * 0.025),
              Text(
                lang.t("Taux de complétion des chapitres", "Chapters completion rate"),
                style: TextStyle(
                    color:      Colors.white70,
                    fontSize:   h * 0.018,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(height: h * 0.02),
              chapters.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(h * 0.04),
                        child: Text(
                          lang.t("Aucun chapitre disponible", "No chapters available"),
                          style: TextStyle(color: Colors.white38, fontSize: h * 0.018),
                        ),
                      ),
                    )
                  : SizedBox(
                      height: h * 0.30,
                      child: BarChart(
                        BarChartData(
                          alignment:     BarChartAlignment.spaceAround,
                          maxY:          1.0,
                          barTouchData:  BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (_) => const Color(0xFF1A1A3E),
                              getTooltipItem:  (group, groupIndex, rod, rodIndex) {
                                final label = chapters[groupIndex].label;
                                final pct   = (rod.toY * 100).round();
                                return BarTooltipItem(
                                  '$label\n$pct%',
                                  const TextStyle(
                                      color:      Colors.greenAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize:   12),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  if (value == 0 || value == 0.25 ||
                                      value == 0.5 || value == 0.75 ||
                                      value == 1.0) {
                                    return Text(
                                      '${(value * 100).toInt()}%',
                                      style: const TextStyle(
                                          color: Colors.white38, fontSize: 11),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles:   true,
                                reservedSize: 36,
                                getTitlesWidget: (value, meta) {
                                  final idx = value.toInt();
                                  if (idx < 0 || idx >= chapters.length) {
                                    return const SizedBox.shrink();
                                  }
                                  final lbl = chapters[idx].label;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      lbl.length > 8
                                          ? '${lbl.substring(0, 8)}…'
                                          : lbl,
                                      style: const TextStyle(
                                          color: Colors.white54, fontSize: 11),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                },
                              ),
                            ),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(
  show:                true,
  drawVerticalLine:    false,
  horizontalInterval:  1, // ← changer 0.25 par 1 pour quiz
  getDrawingHorizontalLine: (_) => FlLine(
    color:       Colors.white.withValues(alpha: 0.08),
    strokeWidth: 0.8,
  ),
),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(chapters.length, (i) {
                            final val = completions[i].clamp(0.0, 1.0);
                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY:           val,
                                  width:         22,
                                  borderRadius:  const BorderRadius.only(
                                    topLeft:  Radius.circular(6),
                                    topRight: Radius.circular(6),
                                  ),
                                  gradient: const LinearGradient(
                                    begin:  Alignment.topCenter,
                                    end:    Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFF8B7FE8),
                                      Color(0xFF5B52C8),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                        duration: const Duration(milliseconds: 400),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _algoButton(String label, int index, double h) {
    final isSelected = _controller.model.selectedAlgo == index;
    return GestureDetector(
      onTap: () => setState(() => _controller.selectAlgo(index)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: h * 0.02, vertical: h * 0.010),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.greenAccent.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isSelected ? Colors.greenAccent : Colors.white24),
        ),
        child: Text(label,
            style: TextStyle(
              color:      isSelected ? Colors.greenAccent : Colors.white54,
              fontSize:   h * 0.015,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            )),
      ),
    );
  }

  // ══════════════════════════════════════════
  // QUIZ STATISTICS — LineChart fl_chart
  // ══════════════════════════════════════════
  Widget _buildQuizSection(double h, double w, LanguageService lang) {
    final quizStats = _controller.model.currentQuizStats;

    // Calcul du max pour l'axe Y
    final maxY = quizStats.isEmpty
        ? 10.0
        : quizStats
                .map((s) => s.quizzesDone.toDouble())
                .reduce((a, b) => a > b ? a : b) *
            1.3;
    final safeMaxY = maxY < 5 ? 5.0 : maxY;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: EdgeInsets.all(h * 0.03),
          decoration: BoxDecoration(
            color:        Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(16),
            border:       Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.extension_outlined,
                      color: Colors.greenAccent, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    lang.t("Statistiques des Quiz", "Quiz Statistics"),
                    style: TextStyle(
                        color:      Colors.white,
                        fontSize:   h * 0.025,
                        fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Container(
                        margin: const EdgeInsets.only(left: 12),
                        height: 1,
                        color: Colors.white12),
                  ),
                  const SizedBox(width: 16),
                  _quizAlgoButton("Algo 1", 0, h),
                  const SizedBox(width: 8),
                  _quizAlgoButton("Algo 2", 1, h),
                  const SizedBox(width: 16),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: h * 0.02, vertical: h * 0.008),
                    decoration: BoxDecoration(
                      color:        Colors.greenAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.greenAccent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.quiz_outlined,
                            color: Colors.greenAccent, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          lang.t("Total → ", "Total → ") +
                              _formatNumber(_controller.model.totalQuizzesDone),
                          style: TextStyle(
                              color:      Colors.greenAccent,
                              fontSize:   h * 0.015,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: h * 0.025),
              Text(
                lang.t("Nombre de quiz par chapitre", "Number of quizzes per chapter"),
                style: TextStyle(
                    color:      Colors.white70,
                    fontSize:   h * 0.018,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(height: h * 0.02),
              quizStats.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(h * 0.04),
                        child: Text(
                          lang.t("Aucun quiz disponible", "No quiz data available"),
                          style: TextStyle(
                              color: Colors.white38, fontSize: h * 0.018),
                        ),
                      ),
                    )
                  : SizedBox(
                      height: h * 0.30,
                      child: LineChart(
                        LineChartData(
                          minX: 0,
                          maxX: (quizStats.length - 1).toDouble(),
                          minY: 0,
                          maxY: safeMaxY,
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipColor: (_) => const Color(0xFF1A1A3E),
                              getTooltipItems: (spots) => spots.map((spot) {
                                final idx = spot.x.toInt();
                                final lbl = idx < quizStats.length
                                    ? quizStats[idx].day
                                    : '';
                                return LineTooltipItem(
                                  '$lbl\n${spot.y.toInt()} quiz',
                                  const TextStyle(
                                      color:      Colors.greenAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize:   12),
                                );
                              }).toList(),
                            ),
                            handleBuiltInTouches: true,
                          ),
                          gridData: FlGridData(
                            show:             true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (_) => FlLine(
                              color:       Colors.white.withValues(alpha: 0.08),
                              strokeWidth: 0.8,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles:   true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  if (value == meta.max) return const SizedBox.shrink();
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(
                                        color: Colors.white38, fontSize: 11),
                                  );
                                },
                              ),
                            ),
                          bottomTitles: AxisTitles(
  sideTitles: SideTitles(
    showTitles:   true,
    reservedSize: 36,
    interval:     1, // ← ajouter ça
    getTitlesWidget: (value, meta) {
      final idx = value.toInt();
      // ← vérifier que c'est un entier exact
      if (value != value.toInt().toDouble()) return const SizedBox.shrink();
      if (idx < 0 || idx >= quizStats.length) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          quizStats[idx].day,
          style: const TextStyle(
              color: Colors.white54, fontSize: 11),
          textAlign: TextAlign.center,
        ),
      );
    },
  ),
),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: List.generate(
                                quizStats.length,
                                (i) => FlSpot(
                                    i.toDouble(),
                                    quizStats[i].quizzesDone.toDouble()),
                              ),
                              isCurved:       true,
                              curveSmoothness: 0.35,
                              color:          Colors.greenAccent,
                              barWidth:       2.5,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, bar, index) =>
                                    FlDotCirclePainter(
                                  radius:    4,
                                  color:     Colors.greenAccent,
                                  strokeColor: const Color(0xFF0D0D2B),
                                  strokeWidth: 2,
                                ),
                              ),
                              belowBarData: BarAreaData(
                                show:  true,
                                gradient: LinearGradient(
                                  begin:  Alignment.topCenter,
                                  end:    Alignment.bottomCenter,
                                  colors: [
                                    Colors.greenAccent.withValues(alpha: 0.25),
                                    Colors.greenAccent.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        duration: const Duration(milliseconds: 400),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quizAlgoButton(String label, int index, double h) {
    final isSelected = _controller.model.selectedQuizAlgo == index;
    return GestureDetector(
      onTap: () => setState(() => _controller.selectQuizAlgo(index)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: h * 0.02, vertical: h * 0.010),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.greenAccent.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isSelected ? Colors.greenAccent : Colors.white24),
        ),
        child: Text(label,
            style: TextStyle(
              color:      isSelected ? Colors.greenAccent : Colors.white54,
              fontSize:   h * 0.015,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            )),
      ),
    );
  }

  String _formatNumber(int n) {
    return n.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');
  }
}