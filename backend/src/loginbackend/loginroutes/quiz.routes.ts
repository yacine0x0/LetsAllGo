import { Router } from 'express';
import { requireAuth } from '../loginmiddlewares/auth.middleware';
import { submitQuiz, getProgression } from '../logincontrollers/quiz.controller';

const router = Router();

// POST /api/quiz/submit
router.post('/submit', requireAuth, submitQuiz);

// GET /api/quiz/progression/:moduleId
router.get('/progression/:moduleId', requireAuth, getProgression);

export default router;