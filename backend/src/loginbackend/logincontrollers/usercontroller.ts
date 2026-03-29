import { Response } from 'express';
import { AuthRequest } from '../loginmiddlewares/auth.middleware';
import { getUserById } from '../loginservices/user.service'; 

export async function getMe(req: AuthRequest, res: Response): Promise<void> {
  try {
    const user = await getUserById(req.userId!);
    res.status(200).json({ success: true, data: user });
  } catch (error) {
    res.status(404).json({
      success: false,
      message: error instanceof Error ? error.message : 'Erreur serveur',
    });
  }
}