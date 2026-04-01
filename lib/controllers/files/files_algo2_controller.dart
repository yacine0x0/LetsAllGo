import '../../models/files/files_algo2_model.dart';

class Algo2FilesController {
  late Algo2FilesModel model;

  Algo2FilesController() {
    model = Algo2FilesModel(
      username: "Zaki",
      role: "Student",
      files: [
        // ── Courses Algo 2
        Algo2FileItem(
          id: "a2f01",
          title: "Cours Data Structures",
          chapterId: "Chapitre 01",
          chapterTitle: "Arrays & Lists",
          filePath: "assets/files/Fiche_Tp2.pdf",
          type: FileType.pdf,
          algo: "algo2",
          category: "courses",
        ),
        Algo2FileItem(
          id: "a2f02",
          title: "Cours Trees & Graphs",
          chapterId: "Chapitre 02",
          chapterTitle: "Trees",
          filePath: "assets/files/algo2/trees.pdf",
          type: FileType.pdf,
          algo: "algo2",
          category: "courses",
        ),
        Algo2FileItem(
          id: "a2f03",
          title: "Cours Sorting Algorithms",
          chapterId: "Chapitre 03",
          chapterTitle: "Sorting",
          filePath: "assets/files/algo2/sorting.pdf",
          type: FileType.pdf,
          algo: "algo2",
          category: "courses",
        ),
        // ── TD's Algo 2
        Algo2FileItem(
          id: "a2f04",
          title: "TD Arrays",
          chapterId: "Chapitre 01",
          chapterTitle: "Arrays & Lists",
          filePath: "assets/files/algo2/td_arrays.pdf",
          type: FileType.pdf,
          algo: "algo2",
          category: "tds",
        ),
        Algo2FileItem(
          id: "a2f05",
          title: "TD Trees",
          chapterId: "Chapitre 02",
          chapterTitle: "Trees",
          filePath: "assets/files/algo2/td_trees.pdf",
          type: FileType.pdf,
          algo: "algo2",
          category: "tds",
        ),
        // ── Examens Algo 2
        Algo2FileItem(
          id: "a2f06",
          title: "Examen 2023",
          chapterId: "Chapitre 01",
          chapterTitle: "Arrays & Lists",
          filePath: "assets/files/algo2/examen2023.pdf",
          type: FileType.pdf,
          algo: "algo2",
          category: "examen",
        ),
        Algo2FileItem(
          id: "a2f07",
          title: "Examen 2024",
          chapterId: "Chapitre 02",
          chapterTitle: "Trees",
          filePath: "assets/files/algo2/examen2024.pdf",
          type: FileType.pdf,
          algo: "algo2",
          category: "examen",
        ),
        // ── Sheatsheets Algo 2
        Algo2FileItem(
          id: "a2f08",
          title: "Sheatsheet Arrays",
          chapterId: "Chapitre 01",
          chapterTitle: "Arrays & Lists",
          filePath: "assets/files/algo2/sheatsheet_arrays.pdf",
          type: FileType.pdf,
          algo: "algo2",
          category: "sheatsheet",
        ),
        Algo2FileItem(
          id: "a2f09",
          title: "Sheatsheet Trees",
          chapterId: "Chapitre 02",
          chapterTitle: "Trees",
          filePath: "assets/files/algo2/sheatsheet_trees.png",
          type: FileType.image,
          algo: "algo2",
          category: "sheatsheet",
        ),
        Algo2FileItem(
          id: "a2f10",
          title: "Sheatsheet Sorting",
          chapterId: "Chapitre 03",
          chapterTitle: "Sorting",
          filePath: "assets/files/algo2/sheatsheet_sorting.pdf",
          type: FileType.pdf,
          algo: "algo2",
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

  void switchCategory(String category) {
    model.selectedCategory = category;
    model.selectedFileIndex = null;
  }

  List<Algo2FileItem> getFilesByCategory(String algo, String category) {
    return model.files
        .where((f) => f.algo == algo && f.category == category)
        .toList();
  }
}