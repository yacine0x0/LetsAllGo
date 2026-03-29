import 'package:flutter/material.dart';
import 'dart:ui';
import '../../models/courses_study/courses_study_model.dart';
import '../../controllers/courses_study/courses_study_controller.dart';
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
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
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.03,
                    vertical: h * 0.01,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildChapterHeader(h, w),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: w * 0.03),
                              child: Container(
                                height: 1.5,
                                color: Colors.blue.withValues(alpha: 0.5),
                              ),
                            ),
                            SizedBox(height: h * 0.02),
                            Expanded(
                              child: _buildPageContent(h, w, page),
                            ),
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

  Widget _buildTopNavBar(double h, double w) {
  return Container(
    height: h * 0.11, // ← agrandi
    padding: EdgeInsets.symmetric(horizontal: w * 0.02),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.4),
      border: Border(
        bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
    ),
    child: Row(
      children: [
        Image.asset(
          "assets/images/icone_dash.png",
          height: h * 0.12, // ← ajuste ici
          width: w * 0.12,  // ← ajuste ici
          errorBuilder: (_, __, ___) => const Icon(
            Icons.school,
            color: Colors.blue,
            size: 40,
          ),
        ),
        SizedBox(width: w * 0.02),
        Container(
          width: 1,
          height: h * 0.05, // ← ajuste ici
          color: Colors.white24,
        ),
        SizedBox(width: w * 0.02),
        GestureDetector(
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardPage()),
          ),
          child: _buildNavButton(Icons.home_outlined, "Home", h),
        ),
        SizedBox(width: w * 0.02),
        GestureDetector(
           onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LeaderboardPage()),
          ),
          child: _buildNavButton(Icons.emoji_events_outlined, "Leaderboard", h),
        ),
        SizedBox(width: w * 0.02),
        GestureDetector(
           onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const FilesPage()),
          ),
          child: _buildNavButton(Icons.folder_outlined, "Files", h),
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: w * 0.015,
            vertical: h * 0.008,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: h * 0.030, // ← agrandi
                backgroundColor: Colors.blue,
                child: Text(
                  "H",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: h * 0.025, // ← agrandi
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                "Hamid_09",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: h * 0.020, // ← agrandi
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
 Widget _buildNavButton(IconData icon, String label, double h) {
  return Row(
    children: [
      Icon(icon, color: Colors.white70, size: h * 0.035), // ← agrandi
      SizedBox(width: 6),
      Text(
        label,
        style: TextStyle(
          color: Colors.white70,
          fontSize: h * 0.020, // ← agrandi
        ),
      ),
    ],
  );
}

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
              border: Border.all(color: Colors.blue.withValues(alpha: 0.4)),
            ),
            child: Image.asset(
            widget.chapterIcon, // ← dynamique
            width: h * 0.05,
              height: h * 0.05,
             errorBuilder: (_, __, ___) => Icon(
                 Icons.smart_toy_outlined,
             color: Colors.blue,
             size: h * 0.04,
              ),
          ),
          ),
          SizedBox(width: w * 0.015),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.chapterTitle,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: h * 0.025,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.chapterSubtitle,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: h * 0.017,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(double h, double w, section page) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.01),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            page.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: h * 0.038,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: h * 0.025),
          Text(
            page.content,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: h * 0.025,
              height: 1.6,
            ),
          ),
          if (page.imagePath != null) ...[ 
            SizedBox(height: h * 0.03),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset( 
                page.imagePath!,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          ],
          if (page.bulletPoints != null && page.bulletPoints!.isNotEmpty)
            ...page.bulletPoints!.map<Widget>((point) => Padding(
                  padding: EdgeInsets.only(bottom: h * 0.012),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      Expanded(
                        child: Text(
                          point,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: h * 0.022,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          SizedBox(height: h * 0.04),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(double h, double w) {
    final isFirstPage = _controller.isFirstPage;
    final isLastPage = _controller.isLastPage;

    return Container(
      height: h * 0.08,
      padding: EdgeInsets.symmetric(horizontal: w * 0.03),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: isFirstPage ? null : _prevPage,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.015,
                vertical: h * 0.015,
              ),
              decoration: BoxDecoration(
                color: isFirstPage
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isFirstPage ? Colors.white12 : Colors.white30,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.chevron_left,
                    color: isFirstPage ? Colors.white24 : Colors.white,
                    size: h * 0.03,
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.menu,
                    color: isFirstPage ? Colors.white24 : Colors.white,
                    size: h * 0.025,
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.025,
              vertical: h * 0.012,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              "${_controller.model!.currentPage + 1}/${_controller.totalPages}",
              style: TextStyle(
                color: Colors.white,
                fontSize: h * 0.020,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: isLastPage ? null : _nextPage,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.025,
                vertical: h * 0.015,
              ),
              decoration: BoxDecoration(
                color: isLastPage
                    ? Colors.blue.withValues(alpha: 0.2)
                    : Colors.blue,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isLastPage
                      ? Colors.blue.withValues(alpha: 0.3)
                      : Colors.blue,
                ),
              ),
              child: Text(
                isLastPage ? "Terminé ✓" : "→ Suivant",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: h * 0.020,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}