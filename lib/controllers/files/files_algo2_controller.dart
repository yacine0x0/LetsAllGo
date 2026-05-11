import '../../models/files/files_algo2_model.dart';

class Algo2FilesController {
  late Algo2FilesModel model;

  Algo2FilesController() {
    model = Algo2FilesModel(
      username: "Zaki",
      role: "Student",
      files: [
        // ── Algo 2 (corrigé: chemins d’assets existants)
        Algo2FileItem(
          id: "a2f01",
          title: "Cours — Algo 2 (support)",
          chapterId: "Chapitre 01",
          chapterTitle: "Les Enregistrements",
          filePath: "assets/files/tdalgo2.pdf",
          type: FileType.pdf,
          algo: "algo2",
          category: "courses",
        ),
        Algo2FileItem(
          id: "a2f02",
          title: "Cours — Algo 2 (support)",
          chapterId: "Chapitre 02",
          chapterTitle: "Les Fichiers",
          filePath: "assets/files/td2algo2.pdf",
          type: FileType.pdf,
          algo: "algo2",
          category: "courses",
        ),
        Algo2FileItem(
          id: "a2f03",
          title: "Cours — Algo 2 (support)",
          chapterId: "Chapitre 03",
          chapterTitle: "Les Listes chaînées",
          filePath: "assets/files/td1algo2.pdf",
          type: FileType.pdf,
          algo: "algo2",
          category: "courses",
        ),
        // ── TD's Algo 2
        Algo2FileItem(
          id: "a2f04",
          title: "TD 1 — Algo 2",
          chapterId: "Chapitre 01",
          chapterTitle: "Les Enregistrements",
          filePath: "assets/files/td1algo2.pdf",
          type: FileType.pdf,
          algo: "algo2",
          category: "tds",
        ),
        Algo2FileItem(
          id: "a2f05",
          title: "TD 2 — Algo 2",
          chapterId: "Chapitre 02",
          chapterTitle: "Les Fichiers",
          filePath: "assets/files/td2algo2.pdf",
          type: FileType.pdf,
          algo: "algo2",
          category: "tds",
        ),
        // ── Examens Algo 2
        Algo2FileItem(
          id: "a2f06",
          title: "Examen — Algo 2",
          chapterId: "Chapitre 01",
          chapterTitle: "Les Enregistrements",
          filePath: "assets/files/tdalgo2.pdf",
          type: FileType.pdf,
          algo: "algo2",
          category: "examen",
        ),
        Algo2FileItem(
          id: "a2f07",
          title: "Examen — Algo 2",
          chapterId: "Chapitre 02",
          chapterTitle: "Les Fichiers",
          filePath: "assets/files/td2algo2.pdf",
          type: FileType.pdf,
          algo: "algo2",
          category: "examen",
        ),
        // ── Sheatsheets Algo 2
        Algo2FileItem(
          id: "a2f08",
          title: "Fiche — Algo 2",
          chapterId: "Chapitre 01",
          chapterTitle: "Les Enregistrements",
          filePath: "assets/files/Fiche_TP2.pdf",
          type: FileType.pdf,
          algo: "algo2",
          category: "sheatsheet",
        ),
        Algo2FileItem(
          id: "a2f09",
          title: "Fiche — Algo 2",
          chapterId: "Chapitre 02",
          chapterTitle: "Les Fichiers",
          filePath: "assets/files/Fiche_TP2.pdf",
          type: FileType.pdf,
          algo: "algo2",
          category: "sheatsheet",
        ),
        Algo2FileItem(
          id: "a2f10",
          title: "Fiche — Algo 2",
          chapterId: "Chapitre 03",
          chapterTitle: "Les Listes chaînées",
          filePath: "assets/files/Fiche_TP2.pdf",
          type: FileType.pdf,
          algo: "algo2",
          category: "sheatsheet",
        ),
        Algo2FileItem(
  id: "a2f11",
  title: "Fiche — Data Structure",
  chapterId: "Chapitre 01",
  chapterTitle: "Les Enregistrements",
  filePath: "assets/files/DATA STRUCTURE.jpg",
  type: FileType.image,
  algo: "algo2",
  category: "sheatsheet",
),
Algo2FileItem(
  id: "a2f12",
  title: "Fiche — Sheatsheets",
  chapterId: "Chapitre 02",
  chapterTitle: "Les Fichiers",
  filePath: "assets/files/sheatsheets.jpg",
  type: FileType.image,
  algo: "algo2",
  category: "sheatsheet",
),
Algo2FileItem(
  id: "a2f13",
  title: "Fiche — Structure de données",
  chapterId: "Chapitre 03",
  chapterTitle: "Les Listes chaînées",
  filePath: "assets/files/structuredonnees.jpg",
  type: FileType.image,
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