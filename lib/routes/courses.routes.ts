// lib/routes/courses.routes.ts
import { Router }      from 'express';
import { requireAuth } from '../middlewares/auth.middleware';
import {
  recordChapterVisit,
  completeChapter,
  getChapterProgress,
} from '../controllers/courses_study/courses.controller';

const router = Router();

router.post('/visit',    requireAuth, recordChapterVisit);
router.post('/complete', requireAuth, completeChapter);
router.get('/progress',  requireAuth, getChapterProgress); // ✅ cette ligne doit exister

export default router;