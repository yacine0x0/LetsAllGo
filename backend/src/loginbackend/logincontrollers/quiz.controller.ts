// ─────────────────────────────────────────
// CONTROLLER : quiz.controller.ts
// ─────────────────────────────────────────

import { Response } from 'express';
import { AuthRequest } from '../loginmiddlewares/auth.middleware';
import { submitQuizService, getProgressionModule } from '../loginservices/quiz.service';
import { validateSubmitQuiz } from '../loginmodels/quiz.model';

// POST /api/quiz/submit
export async function submitQuiz(
  req: AuthRequest,
  res: Response
): Promise<void> {
  try {
    // Validation
    const error = validateSubmitQuiz(req.body);
    if (error) {
      res.status(400).json({ success: false, message: error });
      return;
    }

    const result = await submitQuizService(req.userId!, req.body);

    res.status(200).json({
      success: true,
      message: 'Quiz soumis avec succès',
      data: result,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error instanceof Error ? error.message : 'Erreur serveur',
    });
  }
}

// GET /api/quiz/progression/:moduleId
export async function getProgression(
  req: AuthRequest,
  res: Response
): Promise<void> {
  try {
    const moduleId = req.params.moduleId as string; // ✅ cast explicite

    if (!moduleId) {
      res.status(400).json({ success: false, message: 'Module ID manquant' });
      return;
    }

    const result = await getProgressionModule(moduleId);

    res.status(200).json({
      success: true,
      data: result,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error instanceof Error ? error.message : 'Erreur serveur',
    });
  }
}

