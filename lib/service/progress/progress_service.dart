class ProgressService {
  // Tracks completed chapters as "algo1_Chapitre 01", "algo2_Chapitre 03" etc.
  static final Set<String> _completedChapters = {};

  static const int _algo1TotalChapters = 5;
  static const int _algo2TotalChapters = 4;

  // Call this when a chapter quiz is completed for the first time
  static void completeChapter(String algoType, String chapterTitle) {
    _completedChapters.add('${algoType}_$chapterTitle');
  }

  // Returns true if this chapter was already completed before this call
  static bool isAlreadyCompleted(String algoType, String chapterTitle) {
    return _completedChapters.contains('${algoType}_$chapterTitle');
  }

  // 0.0 to 1.0
  static double getAlgo1Progress() {
    final count = _completedChapters
        .where((k) => k.startsWith('algo1_'))
        .length;
    return (count / _algo1TotalChapters).clamp(0.0, 1.0);
  }

  static double getAlgo2Progress() {
    final count = _completedChapters
        .where((k) => k.startsWith('algo2_'))
        .length;
    return (count / _algo2TotalChapters).clamp(0.0, 1.0);
  }

  static double getGlobalProgress() {
    return (getAlgo1Progress() + getAlgo2Progress()) / 2;
  }
}