// lib/controllers/dashboard/algo2_controller.dart
import '../../models/dashboard/algo2_model.dart';
import '../../service/progress/progress_service.dart';

class Algo2Controller {
  late Algo2Model model;

  Algo2Controller() {
    model = Algo2Model(
      username: "Zaki",
      role:     "Student",
      chapters: [
        ChapterModel(
          number:     "Chapitre 01",
          title:      "Les Enregistrements",
          icon:       "assets/images/icons_algo2/data_structure_icone.png",
          xmlPath:    "assets/data/algo2/cours/chapitre01.xml",
          isFinished: ProgressService.isAlreadyCompleted('algo2', 'Les Enregistrements'), // ✅
          lessons: [
            "Enregistrement de données",
            "Caractéristiques d'un algorithme",
            "Types d'algorithmes",
            "Tableaux",
            "Structures",
            "Pointeurs",
            "Récursivité",
          ],
        ),
        ChapterModel(
          number:     "Chapitre 02",
          title:      "Les Fichiers",
          icon:       "assets/images/icons_algo2/files_icone.png",
          xmlPath:    "assets/data/algo2/cours/chapitre02.xml",
          isFinished: ProgressService.isAlreadyCompleted('algo2', 'Les Fichiers'), // ✅
          lessons: [
            "Introduction aux files",
            "Pile et files",
            "File circulaire",
            "Implémentation",
          ],
        ),
        ChapterModel(
          number:     "Chapitre 03",
          title:      "Les Listes chaînées",
          icon:       "assets/images/icons_algo2/listes_icones.png",
          xmlPath:    "assets/data/algo2/cours/chapitre03.xml",
          isFinished: ProgressService.isAlreadyCompleted('algo2', 'Les Listes chaînées'), // ✅
          lessons: [
            "Introduction linked list",
            "Liste simple",
            "Liste doublement chaînée",
            "Liste circulaire",
          ],
        ),
        ChapterModel(
          number:     "Chapitre 04",
          title:      "Piles et Files",
          icon:       "assets/images/icons_algo2/stacks_icone.png",
          xmlPath:    "assets/data/algo2/cours/chapitre04.xml",
          isFinished: ProgressService.isAlreadyCompleted('algo2', 'Piles et Files'), // ✅
          lessons: [
            "Introduction aux structures",
            "Vecteurs",
            "Matrices",
            "Opérations sur les matrices",
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

  int get completedAlgo2Count =>
      model.chapters.where((c) => c.isFinished).length;
}