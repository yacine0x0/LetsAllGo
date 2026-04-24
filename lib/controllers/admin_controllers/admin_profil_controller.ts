import { Response } from 'express';
import { AuthRequest } from '../../middlewares/auth.middleware';
import { getAdminById, updateAdminProfile } from '../../service/admin/admin.service';

// GET /api/admin/me
export async function getAdminMe(
  req: AuthRequest,
  res: Response
): Promise<void> {
  try {
    const user = await getAdminById(req.userId!);
    res.status(200).json({ success: true, data: user });
  } catch (error) {
    res.status(403).json({
      success: false,
      message: error instanceof Error ? error.message : 'Erreur serveur',
    });
  }
}

// PUT /api/admin/me
export async function updateAdminMe(
  req: AuthRequest,
  res: Response
): Promise<void> {
  try {
    const { nom, prenom, email } = req.body;
    const updated = await updateAdminProfile(req.userId!, { nom, prenom, email });
    res.status(200).json({ success: true, data: updated });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error instanceof Error ? error.message : 'Erreur serveur',
    });
  }
}