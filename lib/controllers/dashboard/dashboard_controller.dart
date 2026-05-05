// lib/controllers/dashboard/dashboard_controller.dart
import '../../models/dashboard/dashboard_model.dart';
import '../../service/auth/LoginService.dart';
import '../../service/progress/progress_service.dart';
import '../../service/language_service.dart';

class DashboardController {
  late DashboardModel model;
  late LanguageService _lang;

  DashboardController() {
    final prenom = LoginService.getPrenom() ?? '';
    final nom    = LoginService.getNom() ?? '';
    final role   = LoginService.getRole() ?? 'etudiant';

    model = DashboardModel(
      username: (prenom.isNotEmpty || nom.isNotEmpty)
          ? '${prenom} ${nom}'.trim()
          : 'Étudiant',
      role: role,
      chapters: [
        ChapterModel(
          id:              "Chapitre 01",
          title:           "Basics",
          chapterProgress: _getChapterProgress('algo1', 'Basics'),
          isFinished:      ProgressService.isAlreadyCompleted('algo1', 'Basics'),
          icon:            "assets/images/icons_algo1/basics_icone.png",
          xmlPath:         "assets/data/algo1/cours/chapitre01.xml",
          lessons: [
            "Définition de l'algorithmique",
            "Caractéristiques d'un algorithme",
            "Types d'algorithmes",
            "Variables types et constantes",
            "Opérateurs et expressions",
            "Structures conditionnelles",
            "Structures itératives (boucles)",
            "Représentation d'un algorithme",
            "Bonnes pratiques en algorithmique",
          ],
        ),
        ChapterModel(
          id:              "Chapitre 02",
          title:           "Conditions",
          chapterProgress: _getChapterProgress('algo1', 'Conditions'),
          isFinished:      ProgressService.isAlreadyCompleted('algo1', 'Conditions'),
          icon:            "assets/images/icons_algo1/si_sinon_icon.png",
          xmlPath:         "assets/data/algo1/cours/chapitre02.xml",
          lessons: [
            "Introduction aux conditions",
            "If / Else",
            "Switch Case",
            "Conditions imbriquées",
          ],
        ),
        ChapterModel(
          id:              "Chapitre 03",
          title:           "Loops",
          chapterProgress: _getChapterProgress('algo1', 'Loops'),
          isFinished:      ProgressService.isAlreadyCompleted('algo1', 'Loops'),
          icon:            "assets/images/icons_algo1/loops_icone.png",
          xmlPath:         "assets/data/algo1/cours/chapitre03.xml",
          lessons: [
            "Introduction aux boucles",
            "Boucle For",
            "Boucle While",
            "Boucle Do While",
            "Boucle de qlawi",
          ],
        ),
        ChapterModel(
          id:              "Chapitre 04",
          title:           "Data Structures – Vectors and Matrices",
          chapterProgress: _getChapterProgress('algo1', 'Data Structures – Vectors and Matrices'),
          isFinished:      ProgressService.isAlreadyCompleted('algo1', 'Data Structures – Vectors and Matrices'),
          icon:            "assets/images/icons_algo1/vectors_matris_icon.png",
          xmlPath:         "assets/data/algo1/cours/chapitre04.xml",
          lessons: [
            "Introduction aux structures",
            "Vecteurs",
            "Matrices",
            "Opérations sur les matrices",
          ],
        ),
        ChapterModel(
          id:              "Chapitre 05",
          title:           "Subprograms (Functions and Procedures)",
          chapterProgress: _getChapterProgress('algo1', 'Subprograms (Functions and Procedures)'),
          isFinished:      ProgressService.isAlreadyCompleted('algo1', 'Subprograms (Functions and Procedures)'),
          icon:            "assets/images/icons_algo1/fonction_procedure_icone.png",
          xmlPath:         "assets/data/algo1/cours/chapitre05.xml",
          lessons: [
            "Introduction aux sous-programmes",
            "Fonctions",
            "Procédures",
            "Récursivité",
          ],
        ),
      ],
    );
  }

  // ✅ Retourne 100 si complété, 0 sinon
  static int _getChapterProgress(String algoType, String chapterTitle) {
    return ProgressService.isAlreadyCompleted(algoType, chapterTitle) ? 100 : 0;
  }

  void selectChapter(int index) {
    model.selectedChapterIndex = index;
  }

  List<String> getSelectedLessons() {
    if (model.selectedChapterIndex == null) return [];
    return model.chapters[model.selectedChapterIndex!].lessons;
  }

  String getSelectedChapterTitle() {
    if (model.selectedChapterIndex == null) return '';
    return model.chapters[model.selectedChapterIndex!].title;
  }

  // ✅ Getter pour savoir si un chapitre est complété
  bool isChapterCompleted(int index) {
    return model.chapters[index].isFinished;
  }

  // ✅ Nombre de chapitres complétés algo1
  int get completedAlgo1Count =>
      model.chapters.where((c) => c.isFinished).length;
}