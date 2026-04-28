// views/admin/analytics_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../controllers/admin_controllers/analytics_controller.dart';
import '../../models/admin_models/analytics_model.dart';
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
  bool _isLoading            = true; // ✅

  @override
  void initState() {
    super.initState();
    // ✅ Charger les vraies données depuis la BDD
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
                    // ✅ Spinner pendant le chargement
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: Colors.greenAccent))
                    // ✅ Contenu après chargement
                    : _controller.model.chapters.isEmpty &&
                              _controller.model.quizStats.isEmpty
                        // ✅ État vide
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bar_chart,
                                    color: Colors.white24,
                                    size: h * 0.08),
                                SizedBox(height: h * 0.02),
                                Text(
                                  lang.t(
                                    "Aucune donnée disponible",
                                    "No data available",
                                  ),
                                  style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: h * 0.02),
                                ),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            padding: EdgeInsets.symmetric(
                              horizontal: w * 0.03,
                              vertical:   h * 0.03,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lang.t("Analytique", "Analytics"),
                                  style: TextStyle(
                                    color:      Colors.white,
                                    fontSize:   h * 0.04,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: h * 0.005),
                                Text(
                                  lang.t(
                                    "Visualisez les performances des étudiants par chapitre et par quiz.",
                                    "View student performance by chapter and quiz.",
                                  ),
                                  style: TextStyle(
                                      color:    Colors.white54,
                                      fontSize: h * 0.016),
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
                width:  h * 0.13,
                height: h * 0.13,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.school, color: Colors.blue, size: 40),
              ),
              SizedBox(height: h * 0.04),

              ...items.asMap().entries.map(
                (entry) => GestureDetector(
                  onTap: () {
                    setState(() => _selectedSidebarIndex = entry.key);
                    if (entry.key == 0) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (_) => const AdminPage()),
                      );
                    } else if (entry.key == 2) {
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const ProfilePage(),
                        transitionsBuilder: (_, animation, __, child) =>
                            SlideTransition(
                          position: Tween(
                                  begin: const Offset(0.0, 1.0),
                                  end: Offset.zero)
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

              // ── Logout
              GestureDetector(
                onTap: () => Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const LoginPage(),
                    transitionsBuilder: (_, anim, __, child) =>
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
                    size: h * 0.04),
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
  // COURSES STATISTICS
  // ══════════════════════════════════════════
  Widget _buildCoursesSection(double h, double w, LanguageService lang) {
    // ✅ Fallback si chapters vide
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
                lang.t("Taux de complétion des chapitres",
                    "Chapters completion rate"),
                style: TextStyle(
                    color:      Colors.white70,
                    fontSize:   h * 0.018,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(height: h * 0.02),

              // ✅ Afficher message si pas de données
              chapters.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(h * 0.04),
                        child: Text(
                          lang.t("Aucun chapitre disponible",
                              "No chapters available"),
                          style: TextStyle(
                              color: Colors.white38,
                              fontSize: h * 0.018),
                        ),
                      ),
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          flex: 3,
                          child: SizedBox(
                            height: h * 0.28,
                            child: _BarChart(
                              chapters:    chapters,
                              completions: completions,
                              h:           h,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: w * 0.12,
                          child: Image.asset(
                            "assets/images/masscott02.png",
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(
                                Icons.emoji_nature,
                                color: Colors.white24,
                                size: h * 0.12),
                          ),
                        ),
                      ],
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
        padding: EdgeInsets.symmetric(
            horizontal: h * 0.02, vertical: h * 0.010),
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
  // QUIZ STATISTICS
  // ══════════════════════════════════════════
  Widget _buildQuizSection(double h, double w, LanguageService lang) {
    final quizStats = _controller.model.quizStats;

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
                  Text(
                    lang.t("Total quizzes réalisés → ",
                            "Total Quizzes done → ") +
                        _formatNumber(
                            _controller.model.totalQuizzesDone),
                    style: TextStyle(
                        color:      Colors.white70,
                        fontSize:   h * 0.016,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              SizedBox(height: h * 0.025),

              // ✅ Afficher message si pas de données
              quizStats.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(h * 0.04),
                        child: Text(
                          lang.t("Aucun quiz disponible",
                              "No quiz data available"),
                          style: TextStyle(
                              color:    Colors.white38,
                              fontSize: h * 0.018),
                        ),
                      ),
                    )
                  : SizedBox(
                      height: h * 0.28,
                      child: _LineChart(stats: quizStats, h: h),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(int n) {
    return n.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');
  }
}

// ══════════════════════════════════════════
// CUSTOM PAINTER — Bar Chart
// ══════════════════════════════════════════
class _BarChart extends StatelessWidget {
  final List<ChapterStat> chapters;
  final List<double>      completions;
  final double            h;

  const _BarChart({
    required this.chapters,
    required this.completions,
    required this.h,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return CustomPaint(
        size: Size(constraints.maxWidth, constraints.maxHeight),
        painter: _BarChartPainter(
            chapters: chapters, completions: completions, h: h),
      );
    });
  }
}

class _BarChartPainter extends CustomPainter {
  final List<ChapterStat> chapters;
  final List<double>      completions;
  final double            h;

  _BarChartPainter({
    required this.chapters,
    required this.completions,
    required this.h,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ✅ Axe Y : 0% / 25% / 50% / 75% / 100%
    const yLabels = ["100%", "75%", "50%", "25%", "0%"];
    const yValues = [1.0, 0.75, 0.50, 0.25, 0.0];

    final leftPad   = size.width  * 0.10;
    final bottomPad = size.height * 0.18;
    final chartH    = size.height - bottomPad - size.height * 0.05;
    final chartW    = size.width  - leftPad;

    final gridPaint = Paint()
      ..color       = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 0.8;

    final textStyle = TextStyle(
        color: Colors.white54, fontSize: h * 0.013);

    // ── Grille horizontale + labels Y
    for (int i = 0; i < yValues.length; i++) {
      final y = size.height * 0.05 + chartH * (1.0 - yValues[i]);
      canvas.drawLine(
          Offset(leftPad, y), Offset(size.width, y), gridPaint);
      _drawText(canvas, yLabels[i], Offset(0, y - 7), textStyle);
    }

    if (completions.isEmpty) return;

    final n    = completions.length;
    final slotW = chartW / n;
    final barW  = slotW * 0.45;

    for (int i = 0; i < n; i++) {
      final ratio = completions[i].clamp(0.0, 1.0);
      final barH  = chartH * ratio;
      final x     = leftPad + slotW * i + (slotW - barW) / 2;
      final y     = size.height * 0.05 + chartH - barH;

      // ── Barre dégradée
      final gradient = LinearGradient(
        begin:  Alignment.topCenter,
        end:    Alignment.bottomCenter,
        colors: [const Color(0xFF8B7FE8), const Color(0xFF5B52C8)],
      ).createShader(Rect.fromLTWH(x, y, barW, barH));

      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(x, y, barW, barH),
          topLeft:  const Radius.circular(5),
          topRight: const Radius.circular(5),
        ),
        Paint()..shader = gradient,
      );

      // ── Label X (titre chapitre)
      _drawText(
        canvas,
        // ✅ Titre court pour l'axe X
        chapters[i].label.length > 10
            ? '${chapters[i].label.substring(0, 10)}...'
            : chapters[i].label,
        Offset(x + barW / 2,
            size.height * 0.05 + chartH + size.height * 0.03),
        textStyle,
        centered: true,
      );

      // ── Valeur % au-dessus de la barre
      _drawText(
        canvas,
        "${(ratio * 100).round()}%",
        Offset(x + barW / 2, y - h * 0.018),
        TextStyle(
            color:      Colors.white70,
            fontSize:   h * 0.013,
            fontWeight: FontWeight.bold),
        centered: true,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    TextStyle style, {
    bool centered = false,
  }) {
    final tp = TextPainter(
      text:            TextSpan(text: text, style: style),
      textDirection:   TextDirection.ltr,
    )..layout();
    final dx = centered ? offset.dx - tp.width / 2 : offset.dx;
    tp.paint(canvas, Offset(dx, offset.dy));
  }

  @override
  bool shouldRepaint(_BarChartPainter old) =>
      old.completions != completions || old.chapters != chapters;
}

// ══════════════════════════════════════════
// CUSTOM PAINTER — Line Chart
// ══════════════════════════════════════════
class _LineChart extends StatelessWidget {
  final List<QuizStat> stats;
  final double         h;

  const _LineChart({required this.stats, required this.h});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return CustomPaint(
        size: Size(constraints.maxWidth, constraints.maxHeight),
        painter: _LineChartPainter(stats: stats, h: h),
      );
    });
  }
}

class _LineChartPainter extends CustomPainter {
  final List<QuizStat> stats;
  final double         h;

  _LineChartPainter({required this.stats, required this.h});

  @override
  void paint(Canvas canvas, Size size) {
    if (stats.isEmpty) return;

    final leftPad   = size.width  * 0.09;
    final bottomPad = size.height * 0.15;
    final chartH    = size.height - bottomPad - size.height * 0.05;
    final chartW    = size.width  - leftPad - size.width * 0.02;

    final textStyle = TextStyle(
        color: Colors.white54, fontSize: h * 0.013);
    final gridPaint = Paint()
      ..color       = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 0.8;

    // ✅ Axe Y dynamique basé sur le max réel
    final maxVal = stats
        .map((s) => s.quizzesDone)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    final maxY     = maxVal < 10 ? 10.0 : maxVal * 1.2;
    final ySteps   = 5;
    final stepSize = maxY / ySteps;

    for (int i = 0; i <= ySteps; i++) {
      final val   = stepSize * i;
      final ratio = val / maxY;
      final y     = size.height * 0.05 + chartH * (1.0 - ratio);
      canvas.drawLine(
          Offset(leftPad, y), Offset(size.width, y), gridPaint);
      final label = val >= 1000
          ? "${(val ~/ 1000)}k"
          : val.toInt().toString();
      _drawText(canvas, label, Offset(0, y - 7), textStyle);
    }

    // ── Points
    final points = <Offset>[];
    for (int i = 0; i < stats.length; i++) {
      final ratio = stats[i].quizzesDone / maxY;
      final x     = leftPad +
          chartW * (stats.length == 1 ? 0.5 : i / (stats.length - 1));
      final y = size.height * 0.05 + chartH * (1.0 - ratio);
      points.add(Offset(x, y));
    }

    // ── Remplissage
    final fillPath = Path()
      ..moveTo(points.first.dx, size.height * 0.05 + chartH);
    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        fillPath.lineTo(points[i].dx, points[i].dy);
      } else {
        final cp1 = Offset(
            (points[i - 1].dx + points[i].dx) / 2, points[i - 1].dy);
        final cp2 = Offset(
            (points[i - 1].dx + points[i].dx) / 2, points[i].dy);
        fillPath.cubicTo(
            cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i].dx, points[i].dy);
      }
    }
    fillPath
      ..lineTo(points.last.dx, size.height * 0.05 + chartH)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin:  Alignment.topCenter,
          end:    Alignment.bottomCenter,
          colors: [
            const Color(0xFF4A90D9).withValues(alpha: 0.3),
            const Color(0xFF4A90D9).withValues(alpha: 0.0),
          ],
        ).createShader(
            Rect.fromLTWH(leftPad, size.height * 0.05, chartW, chartH)),
    );

    // ── Ligne
    final linePath = Path();
    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        linePath.moveTo(points[i].dx, points[i].dy);
      } else {
        final cp1 = Offset(
            (points[i - 1].dx + points[i].dx) / 2, points[i - 1].dy);
        final cp2 = Offset(
            (points[i - 1].dx + points[i].dx) / 2, points[i].dy);
        linePath.cubicTo(
            cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i].dx, points[i].dy);
      }
    }

    canvas.drawPath(
      linePath,
      Paint()
        ..color       = const Color(0xFF4A90D9)
        ..strokeWidth = 2.5
        ..style       = PaintingStyle.stroke
        ..strokeCap   = StrokeCap.round,
    );

    // ── Point maximum
    int maxIdx = 0;
    for (int i = 1; i < stats.length; i++) {
      if (stats[i].quizzesDone > stats[maxIdx].quizzesDone) maxIdx = i;
    }
    canvas.drawCircle(
        points[maxIdx], 5, Paint()..color = const Color(0xFF4A90D9));
    canvas.drawCircle(
        points[maxIdx],
        5,
        Paint()
          ..color       = Colors.white
          ..style       = PaintingStyle.stroke
          ..strokeWidth = 2);

    // ── Labels X (jours)
    for (int i = 0; i < stats.length; i++) {
      final x = leftPad +
          chartW * (stats.length == 1 ? 0.5 : i / (stats.length - 1));
      _drawText(
        canvas,
        stats[i].day,
        Offset(x, size.height * 0.05 + chartH + size.height * 0.04),
        textStyle,
        centered: true,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    TextStyle style, {
    bool centered = false,
  }) {
    final tp = TextPainter(
      text:          TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = centered ? offset.dx - tp.width / 2 : offset.dx;
    tp.paint(canvas, Offset(dx, offset.dy));
  }

  @override
  bool shouldRepaint(_LineChartPainter old) => old.stats != stats;
}