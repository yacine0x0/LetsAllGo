class Algo2FileItem {
  final String id;
  final String title;
  final String chapterId;
  final String chapterTitle;
  final String filePath;
  final FileType type;
  final String algo;
  final String category;

  Algo2FileItem({
    required this.id,
    required this.title,
    required this.chapterId,
    required this.chapterTitle,
    required this.filePath,
    required this.type,
    required this.algo,
    required this.category,
  });
}

enum FileType { pdf, image }

class Algo2FilesModel {
  final String username;
  final String role;
  final List<Algo2FileItem> files;
  int? selectedFileIndex;
  String selectedAlgo;
  String selectedCategory;

  Algo2FilesModel({
    required this.username,
    required this.role,
    required this.files,
    this.selectedFileIndex,
    this.selectedAlgo = "algo2",
    this.selectedCategory = "courses",
  });
}