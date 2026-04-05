// models/quiz/algo2_quiz_model.dart

class Algo2ChapterModel {
  final String id;
  final String title;
  final String icon;
  final List<String> lessons;

  Algo2ChapterModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.lessons,
  });
}

class Algo2QuizModel {
  final List<Algo2ChapterModel> chapters;
  List<String> selectedChapters;
  int selectedIntensity;
  int currentStep;

  Algo2QuizModel({
    required this.chapters,
    this.selectedChapters = const [],
    this.selectedIntensity = 10,
    this.currentStep = 1,
  });

  Algo2ChapterModel? getChapterById(String id) {
    try {
      return chapters.firstWhere((chapter) => chapter.id == id);
    } catch (e) {
      return null;
    }
  }

  bool isChapterSelected(String id) {
    return selectedChapters.contains(id);
  }

  void toggleChapterSelection(String id) {
    if (isChapterSelected(id)) {
      selectedChapters.remove(id);
    } else {
      selectedChapters.add(id);
    }
  }

  void resetSelection() {
    selectedChapters.clear();
    currentStep = 1;
  }

  void setIntensity(int intensity) {
    selectedIntensity = intensity;
  }

  void nextStep() {
    if (currentStep < 3) {
      currentStep++;
    }
  }

  void previousStep() {
    if (currentStep > 1) {
      currentStep--;
    }
  }

  int get totalQuestions => selectedChapters.length * selectedIntensity;
  
  bool get canProceedToNextStep {
    if (currentStep == 1) {
      return selectedChapters.isNotEmpty;
    }
    return true;
  }
}