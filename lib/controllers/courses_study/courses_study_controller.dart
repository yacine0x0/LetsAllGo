// lib/controllers/courses_study/courses_study_controller.dart
import '../../models/courses_study/courses_study_model.dart';
import '../../service/files/serviceXML.dart';
import '../../service/quiz/quiz_score_service.dart';

class CourseStudyController {
  CourseStudyModel? model;

  // ── Chargement XML ──────────────────────────────────────────────────────────
  Future<void> loadFromXml({
    required String xmlPath,
    required String chapterTitle,
    required String chapterSubtitle,
  }) async {
    final sections = await XmlService.loadChapterSections(xmlPath);
    model = CourseStudyModel(
      chapterTitle:    chapterTitle,
      chapterSubtitle: chapterSubtitle,
      xmlPath:         xmlPath,
      pages:           sections,
    );
  }

  // ── Navigation ──────────────────────────────────────────────────────────────
  section? get currentSection {
    if (model == null) return null;
    return model!.pages[model!.currentPage];
  }

  void nextPage() {
    if (model != null && !isLastPage) model!.currentPage++;
  }

  void prevPage() {
    if (model != null && !isFirstPage) model!.currentPage--;
  }

  bool get isFirstPage => model?.currentPage == 0;
  bool get isLastPage  =>
      model != null && model!.currentPage == model!.pages.length - 1;
  int  get totalPages  => model?.pages.length ?? 0;

  // ── Terminer un chapitre ────────────────────────────────────────────────────
  /// À appeler quand l'utilisateur clique sur "Terminer"
  /// [chapterId] : l'UUID du chapitre dans la BDD
  /// Retourne true si l'enregistrement a réussi
  Future<bool> completeChapter({ required String chapterId }) async {
    final success = await QuizScoreService.completeChapter(
      chapterId: chapterId,
    );

    if (success && model != null) {
      model!.isCompleted = true; 
    }

    return success;
  }
}