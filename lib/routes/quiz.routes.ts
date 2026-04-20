import { Router } from 'express';
import { requireAuth } from '../middlewares/auth.middleware';

const router = Router();

router.post('/submit', requireAuth);

export default router;