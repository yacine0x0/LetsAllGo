import { Router } from 'express';
import { requireAuth } from '../middlewares/auth.middleware';
import { submitQuiz } from '../controllers/auth/quiz.controller';

const router = Router();

// POST /api/quiz/submit
router.post('/submit', requireAuth, submitQuiz);

export default router;