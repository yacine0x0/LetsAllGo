import 'package:flutter/material.dart';
import 'dart:ui';
import '../../controllers/dashboard/algo2_controller.dart';
import '../../views/courses_study_page/courses_study_page.dart';

class Algo2Grid extends StatefulWidget {
  final double h;
  final double w;
  final Function(int) onChapterSelected; // ← callback vers dashboard

  const Algo2Grid({
    super.key,
    required this.h,
    required this.w,
    required this.onChapterSelected,
  });

  @override
  State<Algo2Grid> createState() => _Algo2GridState();
}

class _Algo2GridState extends State<Algo2Grid> {
  final Algo2Controller _controller = Algo2Controller();

  @override
  Widget build(BuildContext context) {
    final chapters = _controller.model.chapters;

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 60,
        mainAxisSpacing: 25,
        childAspectRatio: 3.5,
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
                  chapterSubtitle: chapter.number,
                  xmlPath: chapter.xmlPath, // ← dynamique
                  chapterIcon: chapter.icon,
                ),
              ),
            );
          },
          onTap: () {
            setState(() => _controller.selectChapter(index));
            widget.onChapterSelected(index);
          },
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(13),
              topRight: Radius.circular(13),
              bottomLeft: Radius.circular(27),
              bottomRight: Radius.circular(27),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: EdgeInsets.only(
                  top: widget.h * 0.005,
                  left: widget.h * 0.02,
                  right: widget.h * 0.02,
                  bottom: widget.h * 0.02,
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
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              chapter.number,
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: widget.h * 0.025,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: widget.h * 0.005),
                            Text(
                              chapter.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: widget.h * 0.02,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: widget.h * 0.010),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Image.asset(
                        chapter.icon,
                        width: widget.h * 0.08,
                        height: widget.h * 0.08,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.image_not_supported,
                          color: Colors.white38,
                          size: widget.h * 0.04,
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

  // Exposer le controller pour que le dashboard récupère les leçons
  Algo2Controller get controller => _controller;
}
