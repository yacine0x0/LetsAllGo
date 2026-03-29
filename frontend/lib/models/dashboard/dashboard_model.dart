class ChapterModel {
  final String id;
  final String title;
  final int chapterProgress;
  final bool isFinished;
  final String icon;
  final List<String> lessons;
  final String xmlPath; // ← ajouté

  ChapterModel({
    required this.id,
    required this.title,
    required this.chapterProgress,
    required this.isFinished,
    required this.icon,
    required this.lessons,
    required this.xmlPath, // ← ajouté
  });
}

class DashboardModel {
  final String username;
  final String role;
  final List<ChapterModel> chapters;
  int? selectedChapterIndex;

  DashboardModel({
    required this.username,
    required this.role,
    required this.chapters,
    this.selectedChapterIndex,
  });
}