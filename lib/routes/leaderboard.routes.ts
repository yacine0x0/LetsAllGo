import { Router } from 'express';
import { requireAuth } from '../middlewares/auth.middleware';
import { getLeaderboardData } from '../controllers/auth/leaderboard.controller';

const router = Router();

// GET /api/leaderboard → requireAuth → getLeaderboardData
router.get('/', requireAuth, getLeaderboardData);

export default router;