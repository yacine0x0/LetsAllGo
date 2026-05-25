import '../../models/files/files_model.dart';

class FilesController {
  late FilesModel model;

  FilesController() {
    model = FilesModel(
      username: "Zaki",
      role: "Student",
      files: [
        // ── Algo 1 (assets disponibles dans assets/files/)
        FileItem(
          id: "f01",
          title: "Cours — Notions de base",
          chapterId: "Chapitre 01",
          chapterTitle: "Notions de base",
          filePath: "assets/files/td1algo1.pdf",
          type: FileType.pdf,
          algo: "algo1",
          category: "courses",
        ),
        FileItem(
          id: "f02",
          title: "Cours — Conditions",
          chapterId: "Chapitre 02",
          chapterTitle: "Conditions",
          filePath: "assets/files/Fiche_TP2.pdf",
          type: FileType.pdf,
          algo: "algo1",
          category: "courses",
        ),
        FileItem(
          id: "f03",
          title: "Cours — Boucles",
          chapterId: "Chapitre 03",
          chapterTitle: "Boucles",
          filePath: "assets/files/TD3.pdf",
          type: FileType.pdf,
          algo: "algo1",
          category: "courses",
        ),
        // ── TD's Algo 1
        FileItem(
          id: "f04",
          title: "TD 1 — Algo 1",
          chapterId: "Chapitre 01",
          chapterTitle: "Notions de base",
          filePath: "assets/files/td1algo1.pdf",
          type: FileType.pdf,
          algo: "algo1",
          category: "tds",
        ),
        FileItem(
          id: "f05",
          title: "TD — Algo 1",
          chapterId: "Chapitre 02",
          chapterTitle: "Conditions",
          filePath: "assets/files/TD,TP-05_Algo_Avril.2018.pdf",
          type: FileType.pdf,
          algo: "algo1",
          category: "tds",
        ),
        FileItem(
          id: "f10",
          title: "TD 4 — Algo 1",
          chapterId: "Chapitre 04",
          chapterTitle: "Vecteurs & Matrices",
          filePath: "assets/files/algo1td4.pdf",
          type: FileType.pdf,
          algo: "algo1",
          category: "tds",
        ),
        FileItem(
          id: "f11",
          title: "TD 5 — Algo 1",
          chapterId: "Chapitre 05",
          chapterTitle: "Sous-programmes",
          filePath: "assets/files/algo1td5.pdf",
          type: FileType.pdf,
          algo: "algo1",
          category: "tds",
        ),
        FileItem(
          id: "f12",
          title: "TD 3 — Algo 1",
          chapterId: "Chapitre 03",
          chapterTitle: "Boucles",
          filePath: "assets/files/td3algo1.pdf",
          type: FileType.pdf,
          algo: "algo1",
          category: "tds",
        ),

        // ── Examens Algo 1
        FileItem(
          id: "f06",
          title: "Examen algo1",
          chapterId: "Chapitre 01",
          chapterTitle: "Basics",
          filePath: "assets/files/Examenalgo1.pdf",
          type: FileType.pdf,
          algo: "algo1",
          category: "examen",
        ),
        // ── Fiches (image)
        FileItem(
          id: "f08",
          title: "Fiche — aperçu",
          chapterId: "Chapitre 03",
          chapterTitle: "Boucles",
          filePath: "assets/files/image.png",
          type: FileType.image,
          algo: "algo1",
          category: "sheatsheet",
        ),

        FileItem(
  id: "f13",
  title: "Fiche — Types d'algorithmes",
  chapterId: "Chapitre 01",
  chapterTitle: "Notions de base",
  filePath: "assets/files/typealgos.jpg",
  type: FileType.image,
  algo: "algo1",
  category: "sheatsheet",
),
FileItem(
  id: "f14",
  title: "Fiche — Types de matrices",
  chapterId: "Chapitre 04",
  chapterTitle: "Vecteurs & Matrices",
  filePath: "assets/files/Typesmatrices.jpg",
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