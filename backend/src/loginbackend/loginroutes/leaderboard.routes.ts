import { Router } from 'express';
import { requireAuth } from '../loginmiddlewares/auth.middleware';
import { getLeaderboardData } from '../logincontrollers/leaderboard.controller';

const router = Router();

// GET /api/leaderboard → requireAuth → getLeaderboardData
router.get('/', requireAuth, getLeaderboardData);

export default router;