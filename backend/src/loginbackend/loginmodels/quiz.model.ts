// ─────────────────────────────────────────
// MODEL : quiz.model.ts
// ─────────────────────────────────────────

export interface ProgressionResult {
  scoreObtenu:        number;
  scoretotalUtilisateur: number;
  progressionChapitre: number; // 0-100
  progressionModule:   number; // 0-100
  chapitreComplete:    boolean;
}

export interface SubmitQuizInput {
  chapterName:    string;  // ✅ nom du chapitre au lieu des UUIDs
  score:          number;
  totalQuestions: number;
}

export function validateSubmitQuiz(input: SubmitQuizInput): string | null {
  if (!input.chapterName)        return 'Chapitre manquant';
  if (input.score < 0)           return 'Score invalide';
  if (input.totalQuestions <= 0) return 'Total questions invalide';
  return null;
}