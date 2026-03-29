import '../../models/dashboard/dashboard_model.dart';
import '../../controllers/auth/login_controller.dart';

class DashboardController {
  late DashboardModel model;

  DashboardController() {
    final user = LoginController.currentUser;

    model = DashboardModel(
      username: user != null ? '${user.prenom} ${user.nom}' : 'Étudiant',
      role: user?.role ?? 'etudiant',
      chapters: [
        ChapterModel(
          id: "Chapitre 01",
          title: "Basics",
          chapterProgress: 100,
          isFinished: false,
          icon: "assets/images/icons_algo1/basics_icone.png",
          xmlPath: "assets/data/algo1/chapitre01.xml",
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
          id: "Chapitre 02",
          title: "Conditions",
          chapterProgress: 120,
          isFinished: false,
          icon: "assets/images/icons_algo1/si_sinon_icon.png",
          xmlPath: "assets/data/algo1/chapitre02.xml",
          lessons: [
            "Introduction aux conditions",
            "If / Else",
            "Switch Case",
            "Conditions imbriquées",
          ],
        ),
        ChapterModel(
          id: "Chapitre 03",
          title: "Loops",
          chapterProgress: 150,
          isFinished: false,
          icon: "assets/images/icons_algo1/loops_icone.png",
          xmlPath: "assets/data/algo1/chapitre03.xml",
          lessons: [
            "Introduction aux boucles",
            "Boucle For",
            "Boucle While",
            "Boucle Do While",
            "boucle de qlawi",
          ],
        ),
        ChapterModel(
          id: "Chapitre 04",
          title: "Data Structures – Vectors and Matrices",
          chapterProgress: 180,
          isFinished: false,
          icon: "assets/images/icons_algo1/vectors_matris_icon.png",
          xmlPath: "assets/data/algo1/chapitre04.xml",
          lessons: [
            "Introduction aux structures",
            "Vecteurs",
            "Matrices",
            "Opérations sur les matrices",
          ],
        ),
        ChapterModel(
          id: "Chapitre 05",
          title: "Subprograms (Functions and Procedures)",
          chapterProgress: 200,
          isFinished: false,
          icon: "assets/images/icons_algo1/fonction_procedure_icone.png",
          xmlPath: "assets/data/algo1/chapitre05.xml",
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
}