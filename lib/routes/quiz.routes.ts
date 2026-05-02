// lib/routes/quiz.routes.ts
import { Router } from 'express';
import { PrismaClient } from '@prisma/client';
import { requireAuth } from '../middlewares/auth.middleware';
import { submitQuiz } from '../controllers/quiz/quiz.controller';

const router = Router();
const prisma = new PrismaClient();

// POST /api/quiz/submit
router.post('/submit', requireAuth, submitQuiz);

// GET /api/quiz/total-questions/:userId
router.get('/total-questions/:userId', requireAuth, async (req, res) => {
  try {
    const { userId } = req.params;
    
    // Requête SQL directe avec typage correct
    const result = await prisma.$queryRaw<Array<{ total: number }>>`
      SELECT COALESCE(SUM(q."nombrequestionsfaites"), 0) as total
      FROM "quizz" q
      INNER JOIN "passe" p ON q."id_quiz" = p."id_quiz"
      WHERE p."id_etudiant" = ${userId}::uuid
    `;
    
    const total = result[0]?.total ?? 0;
    
    res.json({
      success: true,
      total: Number(total)
    });
    
  } catch (error) {
    console.error('Erreur détaillée:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors du calcul des statistiques'
    });
  }
});

export default router;