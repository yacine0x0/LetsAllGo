// views/quiz/widgets/quiz_chapters_grid.dart
import 'package:flutter/material.dart';
import 'dart:ui';

class QuizChaptersGrid extends StatelessWidget {
  final double h;
  final double w;
  final List<Map<String, String>> chapters;
  final List<String> selectedChapters;
  final Function(String) onChapterToggled;

  const QuizChaptersGrid({
    super.key,
    required this.h,
    required this.w,
    required this.chapters,
    required this.selectedChapters,
    required this.onChapterToggled,
  });

  @override
  Widget build(BuildContext context) {
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
        final isSelected = selectedChapters.contains(chapter["id"]);

        return GestureDetector(
          onTap: () => onChapterToggled(chapter["id"]!),
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
                  top: h * 0.005,
                  left: h * 0.02,
                  right: h * 0.02,
                  bottom: h * 0.02,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color.fromARGB(255, 33, 150, 243).withValues(alpha: 0.3)
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
                              chapter["id"]!,
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: h * 0.025,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: h * 0.005),
                            Text(
                              chapter["title"]!,
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
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Image.asset(
                            chapter["icon"]!,
                            width: h * 0.08,
                            height: h * 0.08,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.image_not_supported,
                              color: Colors.white38,
                              size: h * 0.04,
                            ),
                          ),
                        ),
                        Container(
                          width: h * 0.025,
                          height: h * 0.025,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? Colors.blue : Colors.white24,
                            border: Border.all(
                              color: isSelected ? Colors.blue : Colors.white54,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: h * 0.015,
                                )
                              : null,
                        ),
                      ],
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