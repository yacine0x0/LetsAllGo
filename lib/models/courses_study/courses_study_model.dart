// lib/models/courses_study/courses_study_model.dart

class section {
  final String        id;
  final String        title;
  final String        content;
  final String?       imagePath;
  final List<String>? bulletPoints;

  const section({
    required this.id,
    required this.title,
    required this.content,
    this.imagePath,
    this.bulletPoints,
  });
}

class CourseStudyModel {
  final String        chapterTitle;
  final String        chapterSubtitle;
  final String        xmlPath;
  final List<section> pages;
  int                 currentPage;
  bool                isCompleted; // ✅ NOUVEAU : état local de complétion

  CourseStudyModel({
    required this.chapterTitle,
    required this.chapterSubtitle,
    required this.xmlPath,
    required this.pages,
    this.currentPage = 0,
    this.isCompleted = false, // ✅ false par défaut
  });
}