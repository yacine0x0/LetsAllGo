class FileItem {
  final String id;
  final String title;
  final String chapterId;
  final String chapterTitle;
  final String filePath;
  final FileType type;
  final String algo;       // ← ajouté
  final String category;   // ← ajouté

  FileItem({
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

class FilesModel {
  final String username;
  final String role;
  final List<FileItem> files;
  int? selectedFileIndex;
  String selectedAlgo;
  String selectedCategory; // ← ajouté

  FilesModel({
    required this.username,
    required this.role,
    required this.files,
    this.selectedFileIndex,
    this.selectedAlgo = "algo1",
    this.selectedCategory = "courses", // ← ajouté
  });
}