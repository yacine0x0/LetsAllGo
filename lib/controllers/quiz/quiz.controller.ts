// lib/controllers/auth/quiz.controller.ts
import { Response }    from 'express';
import { AuthRequest } from '../../middlewares/auth.middleware';
import { submitQuizService, completeChapterService } from '../../service/quiz/quiz.service';

// POST /api/quiz/submit
export async function submitQuiz(req: AuthRequest, res: Response): Promise<void> {
  try {
    const userId = req.userId;
    if (!userId) {
      res.status(401).json({ success: false, message: 'Non authentifié' });
      return;
    }

    const { quizId, correctAnswers } = req.body;

    if (!quizId || correctAnswers === undefined) {
      res.status(400).json({ success: false, message: 'quizId et correctAnswers requis' });
      return;
    }

    const result = await submitQuizService({ userId, quizId, correctAnswers });
    res.status(200).json({ success: true, ...result });

  } catch (error) {
    res.status(500).json({
      success: false,
      message: error instanceof Error ? error.message : 'Erreur serveur',
    });
  }
}

// POST /api/courses/complete
export async function completeChapter(req: AuthRequest, res: Response): Promise<void> {
  try {
    const userId = req.userId;
    if (!userId) {
      res.status(401).json({ success: false, message: 'Non authentifié' });
      return;
    }

    const { chapterId } = req.body;
    if (!chapterId) {
      res.status(400).json({ success: false, message: 'chapterId requis' });
      return;
    }

    const result = await completeChapterService({ chapterId, userId });
    res.status(200).json({ success: true, ...result });

  } catch (error) {
    res.status(500).json({
      success: false,
      message: error instanceof Error ? error.message : 'Erreur serveur',
    });
  }
}