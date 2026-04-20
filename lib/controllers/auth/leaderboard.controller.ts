import { Response } from 'express';
import { AuthRequest } from '../../middlewares/auth.middleware';
import { getLeaderboardWithUser } from '../../service/leaderboard/leaderboard.service';

export async function getLeaderboardData(
  req: AuthRequest,
  res: Response
): Promise<void> {
  try {
    const result = await getLeaderboardWithUser(req.userId!);
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