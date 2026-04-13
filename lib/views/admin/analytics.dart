// views/admin/analytics_page.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';
import '../../controllers/admin_controllers/analytics_controller.dart';
import '../../models/admin_models/analytics_model.dart';
import '../admin/users_page.dart';
import '../admin/profil_admin_page.dart';
import '../auth/login_page.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final AnalyticsController _controller = AnalyticsController();
  int _selectedSidebarIndex = 1; // Analytics actif par défaut

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // ── Fond couleur
          Container(color: const Color(0xFF0D0D2B)),

          // ── Image de fond
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

          // ── Layout principal
          Row(
            children: [
              _buildSidebar(h, w),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.03,
                    vertical: h * 0.03,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre page
                      Text(
                        "Analytics",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: h * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: h * 0.005),
                      Text(
                        "Visualisez les performances des étudiants par chapitre et par quiz.",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: h * 0.016,
                        ),
                      ),
                      SizedBox(height: h * 0.03),

                      // ── Section Courses Statistics
                      _buildCoursesSection(h, w),
                      SizedBox(height: h * 0.03),

                      // ── Section Quiz Statistics
                      _buildQuizSection(h, w),
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

  // ═══════════════════════════════════════
  // SIDEBAR (identique aux autres pages)
  // ═══════════════════════════════════════
  Widget _buildSidebar(double h, double w) {
    final items = [
      {"icon": Icons.people, "label": "Users"},
      {"icon": Icons.bar_chart, "label": "Analytics"},
      {"icon": Icons.person, "label": "Profile"},
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

              // Logo
              Image.asset(
                "assets/images/icone_dash.png",
                width: h * 0.13,
                height: h * 0.13,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.school,
                  color: Colors.blue,
                  size: 40,
                ),
              ),
              SizedBox(height: h * 0.04),

              // Items
              ...items.asMap().entries.map(
                (entry) => GestureDetector(
                  onTap: () {
                    setState(() => _selectedSidebarIndex = entry.key);
                    if (entry.key == 0) {



                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => AdminPage(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, -1.0); 
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;

                          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                      ));



                    } else if (entry.key == 2) {
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => ProfilePage(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, 1.0); 
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;

                          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                      ));
                    }
                  },





                  child: _buildSidebarItem(
                    icon: entry.value["icon"] as IconData,
                    label: entry.value["label"] as String,
                    h: h,
                    isActive: _selectedSidebarIndex == entry.key,
                  ),
                ),
              ),

              const Spacer(),

              // ── Logout button
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const LoginPage(),
                      transitionsBuilder: (_, anim, __, child) =>
                          FadeTransition(opacity: anim, child: child),
                      transitionDuration: const Duration(milliseconds: 400),
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(bottom: h * 0.03),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.08),
                        margin: EdgeInsets.only(bottom: h * 0.02),
                      ),
                      Icon(
                        Icons.logout_rounded,
                        color: Colors.red.shade300,
                        size: h * 0.035,
                      ),
                      SizedBox(height: h * 0.005),
                      Text(
                        "Logout",
                        style: TextStyle(
                          color: Colors.red.shade300,
                          fontSize: h * 0.014,
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
    required String label,
    required double h,
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
                Icon(
                  icon,
                  color: isActive ? Colors.greenAccent : Colors.white38,
                  size: h * 0.04,
                ),
                SizedBox(height: h * 0.005),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? Colors.greenAccent : Colors.white38,
                    fontSize: h * 0.015,
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

  // ═══════════════════════════════════════
  // SECTION COURSES STATISTICS
  // ═══════════════════════════════════════
  Widget _buildCoursesSection(double h, double w) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: EdgeInsets.all(h * 0.03),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre + boutons Algo
              Row(
                children: [
                  const Icon(Icons.menu_book_outlined,
                      color: Colors.greenAccent, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    "Courses Statistics",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: h * 0.025,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 12),
                      height: 1,
                      color: Colors.white12,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Bouton Algo 1
                  _algoButton("Algo 1", 0, h),
                  const SizedBox(width: 8),

                  // Bouton Algo 2
                  _algoButton("Algo 2", 1, h),
                ],
              ),
              SizedBox(height: h * 0.025),

              // Titre graphe
              Text(
                "Chapters completion rate",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: h * 0.018,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: h * 0.02),

              // Graphe barres + mascotte
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Graphe en barres (custom painter)
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: h * 0.28,
                      child: _BarChart(
                        chapters: _controller.model.displayedChapters,
                        completions: _controller.model.currentCompletions,
                        h: h,
                      ),
                    ),
                  ),

                  // Mascotte
                  // ⚠️  Remplacez le chemin ci-dessous par le vrai path de votre PNG
                  SizedBox(
                    width: w * 0.12,
                    child: Image.asset(
                      "assets/images/masscott02.png", // ← METTEZ ICI LE PATH DE VOTRE MASCOTTE
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.emoji_nature,
                        color: Colors.white24,
                        size: h * 0.12,
                      ),
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
      onTap: () {
        setState(() => _controller.selectAlgo(index));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: h * 0.02,
          vertical: h * 0.010,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.greenAccent.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.greenAccent : Colors.white24,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.greenAccent : Colors.white54,
            fontSize: h * 0.015,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // SECTION QUIZ STATISTICS
  // ═══════════════════════════════════════
  Widget _buildQuizSection(double h, double w) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: EdgeInsets.all(h * 0.03),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre + total
              Row(
                children: [
                  const Icon(Icons.extension_outlined,
                      color: Colors.greenAccent, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    "Quiz Statistics",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: h * 0.025,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 12),
                      height: 1,
                      color: Colors.white12,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "Total Quizzes done → ${_formatNumber(_controller.model.totalQuizzesDone)}",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: h * 0.016,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: h * 0.025),

              // Courbe quiz
              SizedBox(
                height: h * 0.28,
                child: _LineChart(
                  stats: _controller.model.quizStats,
                  h: h,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(int n) {
    // ex: 569823 → "569 823"
    return n.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');
  }
}

// ═══════════════════════════════════════════════════════
// CUSTOM PAINTER – Histogramme (Chapters completion rate)
// ═══════════════════════════════════════════════════════
class _BarChart extends StatelessWidget {
  final List<ChapterStat> chapters;
  final List<double> completions; // 0.0 → 1.0
  final double h;

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
          chapters: chapters,
          completions: completions,
          h: h,
        ),
      );
    });
  }
}

class _BarChartPainter extends CustomPainter {
  final List<ChapterStat> chapters;
  final List<double> completions;
  final double h;

  _BarChartPainter({
    required this.chapters,
    required this.completions,
    required this.h,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const yLabels = ["100%", "75%", "50%", "25%", "0%"];
    const yValues = [1.0, 0.75, 0.50, 0.25, 0.0];

    final leftPad = size.width * 0.10;
    final bottomPad = size.height * 0.18;
    final chartH = size.height - bottomPad - size.height * 0.05;
    final chartW = size.width - leftPad;

    // Grille
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 0.8;

    final textStyle = TextStyle(
      color: Colors.white54,
      fontSize: h * 0.013,
    );

    for (int i = 0; i < yValues.length; i++) {
      final y = size.height * 0.05 + chartH * (1.0 - yValues[i]);
      canvas.drawLine(
        Offset(leftPad, y),
        Offset(size.width, y),
        gridPaint,
      );
      // Label Y
      _drawText(canvas, yLabels[i], Offset(0, y - 7), textStyle);
    }

    // Barres
    final n = completions.length;
    final slotW = chartW / n;
    final barW = slotW * 0.45;

    for (int i = 0; i < n; i++) {
      final ratio = completions[i].clamp(0.0, 1.0);
      final barH = chartH * ratio;
      final x = leftPad + slotW * i + (slotW - barW) / 2;
      final y = size.height * 0.05 + chartH - barH;

      // Dégradé vertical violet → bleu
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF8B7FE8),
          const Color(0xFF5B52C8),
        ],
      ).createShader(Rect.fromLTWH(x, y, barW, barH));

      final barPaint = Paint()..shader = gradient;

      final rrect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, barW, barH),
        topLeft: const Radius.circular(5),
        topRight: const Radius.circular(5),
      );
      canvas.drawRRect(rrect, barPaint);

      // Label X (chapitre)
      final labelY = size.height * 0.05 + chartH + size.height * 0.03;
      _drawText(
        canvas,
        chapters[i].label,
        Offset(x + barW / 2, labelY),
        textStyle,
        centered: true,
      );

      // Valeur en %
      _drawText(
        canvas,
        "${(ratio * 100).round()}%",
        Offset(x + barW / 2, y - h * 0.018),
        TextStyle(
          color: Colors.white70,
          fontSize: h * 0.013,
          fontWeight: FontWeight.bold,
        ),
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
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = centered ? offset.dx - tp.width / 2 : offset.dx;
    tp.paint(canvas, Offset(dx, offset.dy));
  }

  void _drawRotatedText(
      Canvas canvas, String text, Offset center, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-pi / 2);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BarChartPainter old) =>
      old.completions != completions || old.chapters != chapters;
}

// ═══════════════════════════════════════════════════════
// CUSTOM PAINTER – Courbe (Quiz Statistics)
// ═══════════════════════════════════════════════════════
class _LineChart extends StatelessWidget {
  final List<QuizStat> stats;
  final double h;

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
  final double h;

  _LineChartPainter({required this.stats, required this.h});

  @override
  void paint(Canvas canvas, Size size) {
    final leftPad = size.width * 0.09;
    final bottomPad = size.height * 0.15;
    final chartH = size.height - bottomPad - size.height * 0.05;
    final chartW = size.width - leftPad - size.width * 0.02;

    final maxVal = stats.map((s) => s.quizzesDone).reduce(max).toDouble();
    final yGridValues = [0, 5000, 10000, 15000, 20000, 25000];

    final textStyle =
        TextStyle(color: Colors.white54, fontSize: h * 0.013);

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 0.8;

    // Grille horizontale
    for (final val in yGridValues) {
      final ratio = val / 25000.0;
      final y = size.height * 0.05 + chartH * (1.0 - ratio);
      canvas.drawLine(Offset(leftPad, y), Offset(size.width, y), gridPaint);
      final label = val == 0
          ? "0"
          : val >= 1000
              ? "${val ~/ 1000}k"
              : "$val";
      _drawText(canvas, label, Offset(0, y - 7), textStyle);
    }

    // Points de la courbe
    List<Offset> points = [];
    for (int i = 0; i < stats.length; i++) {
      final ratio = stats[i].quizzesDone / 25000.0;
      final x = leftPad + chartW * (i / (stats.length - 1));
      final y = size.height * 0.05 + chartH * (1.0 - ratio);
      points.add(Offset(x, y));
    }

    // Remplissage sous la courbe
    final fillPath = Path();
    fillPath.moveTo(points.first.dx, size.height * 0.05 + chartH);
    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        fillPath.lineTo(points[i].dx, points[i].dy);
      } else {
        final cp1 = Offset(
          (points[i - 1].dx + points[i].dx) / 2,
          points[i - 1].dy,
        );
        final cp2 = Offset(
          (points[i - 1].dx + points[i].dx) / 2,
          points[i].dy,
        );
        fillPath.cubicTo(
            cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i].dx, points[i].dy);
      }
    }
    fillPath.lineTo(points.last.dx, size.height * 0.05 + chartH);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF4A90D9).withValues(alpha: 0.3),
          const Color(0xFF4A90D9).withValues(alpha: 0.0),
        ],
      ).createShader(
          Rect.fromLTWH(leftPad, size.height * 0.05, chartW, chartH));
    canvas.drawPath(fillPath, fillPaint);

    // Ligne de la courbe
    final linePath = Path();
    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        linePath.moveTo(points[i].dx, points[i].dy);
      } else {
        final cp1 = Offset(
          (points[i - 1].dx + points[i].dx) / 2,
          points[i - 1].dy,
        );
        final cp2 = Offset(
          (points[i - 1].dx + points[i].dx) / 2,
          points[i].dy,
        );
        linePath.cubicTo(
            cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i].dx, points[i].dy);
      }
    }

    final linePaint = Paint()
      ..color = const Color(0xFF4A90D9)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);

    // Point maximum (surligné)
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
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);

    // Labels X (mois)
    for (int i = 0; i < stats.length; i++) {
      final x = leftPad + chartW * (i / (stats.length - 1));
      final y = size.height * 0.05 + chartH + size.height * 0.04;
      _drawText(canvas, stats[i].day, Offset(x, y), textStyle,
          centered: true);
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
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = centered ? offset.dx - tp.width / 2 : offset.dx;
    tp.paint(canvas, Offset(dx, offset.dy));
  }

  void _drawRotatedText(
      Canvas canvas, String text, Offset center, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-pi / 2);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LineChartPainter old) => old.stats != stats;
}