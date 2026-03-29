import '../../models/dashboard/algo2_model.dart';

class Algo2Controller {
  late Algo2Model model;

  Algo2Controller() {
    model = Algo2Model(
      username: "Zaki",
      role: "Student",
      chapters: [
        ChapterModel(
          number: "Chapitre 01",
          title: "Data Structure",
          icon: "assets/images/icons_algo2/data_structure_icone.png",
          xmlPath: "assets/data/algo1/chapitre04.xml", // ← ajouté
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
          number: "Chapitre 02",
          title: "Files",
          icon: "assets/images/icons_algo2/files_icone.png",
          xmlPath: "assets/data/algo1/chapitre05.xml", // ← ajouté
          lessons: [
            "Introduction aux files",
            "Pile et files",
            "File circulaire",
            "Implémentation",
          ],
        ),
        ChapterModel(
          number: "Chapitre 03",
          title: "Linked List",
          icon: "assets/images/icons_algo2/listes_icones.png",
          xmlPath: "assets/data/algo1/chapitre03.xml", // ← ajouté
          lessons: [
            "Introduction linked list",
            "Liste simple",
            "Liste doublement chaînée",
            "Liste circulaire",
          ],
        ),
        ChapterModel(
          number: "Chapitre 04",
          title: "Queues and Stacks",
          icon: "assets/images/icons_algo2/stacks_icone.png",
          xmlPath: "assets/data/algo1/chapitre04.xml", // ← ajouté
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
}