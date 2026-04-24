import '../../models/files/files_model.dart';

class FilesController {
  late FilesModel model;

  FilesController() {
    model = FilesModel(
      username: "Zaki",
      role: "Student",
      files: [
        // ── Courses Algo 1
        FileItem(
          id: "f01",
          title: "Cours Basics",
          chapterId: "Chapitre 01",
          chapterTitle: "Basics",
          filePath: "assets/files/Fiche_Tp2.pdf",
          type: FileType.pdf,
          algo: "algo1",
          category: "courses",
        ),
        FileItem(
          id: "f02",
          title: "Cours Conditions",
          chapterId: "Chapitre 02",
          chapterTitle: "Conditions",
          filePath: "assets/files/Fiche_Tp2.pdf",
          type: FileType.pdf,
          algo: "algo1",
          category: "courses",
        ),
        FileItem(
          id: "f03",
          title: "Cours Loops",
          chapterId: "Chapitre 03",
          chapterTitle: "Loops",
          filePath: "assets/files/algo1/loops.pdf",
          type: FileType.pdf,
          algo: "algo1",
          category: "courses",
        ),
        // ── TD's Algo 1
        FileItem(
          id: "f04",
          title: "TD Basics",
          chapterId: "Chapitre 01",
          chapterTitle: "Basics",
          filePath: "assets/files/algo1/td_basics.pdf",
          type: FileType.pdf,
          algo: "algo1",
          category: "tds",
        ),
        FileItem(
          id: "f05",
          title: "TD Conditions",
          chapterId: "Chapitre 02",
          chapterTitle: "Conditions",
          filePath: "assets/files/algo1/td_conditions.pdf",
          type: FileType.pdf,
          algo: "algo1",
          category: "tds",
        ),
        // ── Examens Algo 1
        FileItem(
          id: "f06",
          title: "Examen 2023",
          chapterId: "Chapitre 01",
          chapterTitle: "Basics",
          filePath: "assets/files/algo1/examen2023.pdf",
          type: FileType.pdf,
          algo: "algo1",
          category: "examen",
        ),
        FileItem(
          id: "f07",
          title: "Examen 2024",
          chapterId: "Chapitre 01",
          chapterTitle: "Basics",
          filePath: "assets/files/algo1/examen2024.pdf",
          type: FileType.pdf,
          algo: "algo1",
          category: "examen",
        ),
        // ── Sheatsheets Algo 1
        FileItem(
          id: "f08",
          title: "Sheatsheet Loops",
          chapterId: "Chapitre 03",
          chapterTitle: "Loops",
          filePath: "assets/files/algo1/sheatsheet_loops.pdf",
          type: FileType.pdf,
          algo: "algo1",
          category: "sheatsheet",
        ),
        FileItem(
          id: "f09",
          title: "Sheatsheet Basics",
          chapterId: "Chapitre 01",
          chapterTitle: "Basics",
          filePath: "assets/files/image.png",
          type: FileType.image,
          algo: "algo1",
          category: "sheatsheet",
        ),
      ],
    );
  }

  void selectFile(int index) {
    model.selectedFileIndex = index;
  }

  void switchAlgo(String algo) {
    model.selectedAlgo = algo;
    model.selectedFileIndex = null;
  }

  void switchCategory(String category) { // ← ajouté
    model.selectedCategory = category;
    model.selectedFileIndex = null;
  }

  List<FileItem> getFilesByCategory(String algo, String category) { // ← ajouté
    return model.files
        .where((f) => f.algo == algo && f.category == category)
        .toList();
  }
}