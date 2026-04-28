import { Response }    from 'express';
import { AuthRequest } from '../../middlewares/auth.middleware';
import { getAnalytics } from '../../service/admin/analytics.service';

export async function getAnalyticsData(
  req: AuthRequest,
  res: Response
): Promise<void> {
  try {
    const data = await getAnalytics();
    res.status(200).json({ success: true, data });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error instanceof Error ? error.message : 'Erreur serveur',
    });
  }
}