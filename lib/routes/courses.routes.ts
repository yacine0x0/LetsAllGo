// lib/routes/courses.routes.ts
import { Router }     from 'express';
import { requireAuth } from '../middlewares/auth.middleware';
import { completeChapter as completeChapterHandler } from '../controllers/auth/quiz.controller';

const router = Router();

// POST /api/courses/complete
router.post('/complete', requireAuth, completeChapterHandler);

export default router;