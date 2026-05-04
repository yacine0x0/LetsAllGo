// lib/models/dashboard/algo2_model.dart
class ChapterModel {
  final String number;
  final String title;
  final String icon;
  final List<String> lessons;
  final String xmlPath;
  final bool isFinished; // ✅ ajouté

  ChapterModel({
    required this.number,
    required this.title,
    required this.icon,
    required this.lessons,
    required this.xmlPath,
    required this.isFinished, // ✅ ajouté
  });
}

class Algo2Model {
  final String username;
  final String role;
  final List<ChapterModel> chapters;
  int? selectedChapterIndex;

  Algo2Model({
    required this.username,
    required this.role,
    required this.chapters,
    this.selectedChapterIndex,
  });
}