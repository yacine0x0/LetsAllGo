import '../../models/courses_study/courses_study_model.dart';
import '../../service/serviceXML.dart';

class CourseStudyController {
  CourseStudyModel? model;

  // Charge les sections depuis XML
  Future<void> loadFromXml({
    required String xmlPath,
    required String chapterTitle,
    required String chapterSubtitle,
  }) async {
    final sections = await XmlService.loadChapterSections(xmlPath);
    model = CourseStudyModel(
      chapterTitle: chapterTitle,
      chapterSubtitle: chapterSubtitle,
      xmlPath :xmlPath,
      pages: sections,
    );
  }
// Page actuelle
  section? get currentSection {
    if (model == null) return null;
    return model!.pages[model!.currentPage]; // ← section actuelle
  }

  void nextPage() {
    if (model != null && !isLastPage) model!.currentPage++;
  }

  void prevPage() {
    if (model != null && !isFirstPage) model!.currentPage--;
  }

  bool get isFirstPage => model?.currentPage == 0;
  bool get isLastPage =>
      model != null && model!.currentPage == model!.pages.length - 1;

  int get totalPages => model?.pages.length ?? 0;
}