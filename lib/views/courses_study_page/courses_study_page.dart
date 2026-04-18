import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import '../../service/language_service.dart';

import '../../models/courses_study/courses_study_model.dart';
import '../../controllers/courses_study/courses_study_controller.dart';
import '../../controllers/auth/login_controller.dart';
import '../dashboard/dashboard_page.dart';
import '../../views/leaderboard/leaderboard_page.dart';
import '../files/files_page.dart';

class CourseStudyPage extends StatefulWidget {
  final String chapterTitle;
  final String chapterSubtitle;
  final String xmlPath;
  final String chapterIcon;

  const CourseStudyPage({
    super.key,
    required this.chapterTitle,
    required this.chapterSubtitle,
    required this.xmlPath,
    required this.chapterIcon,
  });

  @override
  State<CourseStudyPage> createState() => _CourseStudyPageState();
}

class _CourseStudyPageState extends State<CourseStudyPage> {
  final CourseStudyController _controller = CourseStudyController();
  final _user = LoginController.currentUser;
  bool _isLoading = true;

  late LanguageService _lang;

  @override
  void initState() {
    super.initState();
    _lang = Provider.of<LanguageService>(context, listen: false);
    _loadSections();
  }

  Future<void> _loadSections() async {
    await _controller.loadFromXml(
      xmlPath: widget.xmlPath,
      chapterTitle: widget.chapterTitle,
      chapterSubtitle: widget.chapterSubtitle,
    );
    setState(() => _isLoading = false);
  }

  void _nextPage() => setState(() => _controller.nextPage());
  void _prevPage() => setState(() => _controller.prevPage());

  @override
  Widget build(BuildContext context) {
    _lang = context.watch<LanguageService>();

    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D0D2B),
        body: Center(child: CircularProgressIndicator(color: Colors.blue)),
      );
    }

    final page = _controller.currentSection!;

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

          Column(
            children: [
              _buildTopNavBar(h, w),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: h * 0.01),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildChapterHeader(h, w),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: w * 0.03),
                              child: Container(height: 1.5, color: Colors.blue.withValues(alpha: 0.5)),
                            ),
                            SizedBox(height: h * 0.02),
                            Expanded(child: _buildPageContent(h, w, page)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _buildBottomNavBar(h, w),
            ],
          ),
        ],
      ),
    );
  }

  // ───────── TOP NAV ─────────
  Widget _buildTopNavBar(double h, double w) {
    final initiale = _user != null ? _user.prenom[0].toUpperCase() : "?";
    final nomComplet = _user != null ? '${_user.prenom} ${_user.nom}' : 'Student';

    return Container(
      height: h * 0.11,
      padding: EdgeInsets.symmetric(horizontal: w * 0.02),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          Image.asset("assets/images/icone_dash.png", height: h * 0.12, width: w * 0.12),

          SizedBox(width: w * 0.02),

          GestureDetector(
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardPage())),
            child: _buildNavButton(Icons.home_outlined, _lang.t("Acceuil", "Home"), h),
          ),

          SizedBox(width: w * 0.02),

          GestureDetector(
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LeaderboardPage())),
            child: _buildNavButton(Icons.emoji_events_outlined, _lang.t("Classement", "Leaderboard"), h),
          ),

          SizedBox(width: w * 0.02),

          GestureDetector(
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const FilesPage())),
            child: _buildNavButton(Icons.folder_outlined, _lang.t("Files", "Files"), h),
          ),

          const Spacer(),

          Text(nomComplet, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, String label, double h) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: h * 0.035),
        SizedBox(width: 6),
        Text(label, style: TextStyle(color: Colors.white70, fontSize: h * 0.020)),
      ],
    );
  }

  // ───────── HEADER CHAPITRE ─────────
  Widget _buildChapterHeader(double h, double w) {
    return Padding(
      padding: EdgeInsets.all(h * 0.02),
      child: Row(
        children: [
          Container(
            width: h * 0.07,
            height: h * 0.07,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(widget.chapterIcon),
          ),

          SizedBox(width: w * 0.015),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _lang.t(widget.chapterTitle, widget.chapterTitle),
                style: TextStyle(color: Colors.white, fontSize: h * 0.025, fontWeight: FontWeight.bold),
              ),
              Text(
                _lang.t(widget.chapterSubtitle, widget.chapterSubtitle),
                style: TextStyle(color: Colors.white54, fontSize: h * 0.017),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────── CONTENT ─────────
  Widget _buildPageContent(double h, double w, section page) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: w * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _lang.t(page.title, page.title),
            style: TextStyle(color: Colors.white, fontSize: h * 0.038, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: h * 0.025),

          Text(
            _lang.t(page.content, page.content),
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: h * 0.025, height: 1.6),
          ),

          if (page.imagePath != null) ...[
            SizedBox(height: h * 0.03),
            Image.asset(page.imagePath!),
          ],

          if (page.bulletPoints != null)
            ...page.bulletPoints!.map(
              (point) => Padding(
                padding: EdgeInsets.only(bottom: h * 0.012),
                child: Text(
                  _lang.t(point, point),
                  style: TextStyle(color: Colors.white70, fontSize: h * 0.022),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ───────── BOTTOM NAV ─────────
  Widget _buildBottomNavBar(double h, double w) {
    return Container(
      height: h * 0.08,
      color: Colors.black.withValues(alpha: 0.5),
      child: Row(
        children: [
          IconButton(
            onPressed: _prevPage,
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),

          const Spacer(),

          Text(
            "${_controller.model!.currentPage + 1}/${_controller.totalPages}",
            style: const TextStyle(color: Colors.white),
          ),

          const Spacer(),

          IconButton(
            onPressed: _nextPage,
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
          ),
        ],
      ),
    );
  }
}