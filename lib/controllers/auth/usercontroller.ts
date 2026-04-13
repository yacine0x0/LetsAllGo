import { Response } from 'express';
import { AuthRequest } from '../../middlewares/auth.middleware';
import { getUserById, updateUserName, updateUserPassword, requestUserEmailChange, confirmUserEmailChange } from '../../service/auth/user.service';

// GET /api/users/me
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

// PATCH /api/users/me
export async function updateMe(req: AuthRequest, res: Response): Promise<void> {
  try {
    const { prenom, nom } = req.body;
    if (!prenom && !nom) {
      res.status(400).json({ success: false, message: 'Aucune donnée à mettre à jour' });
      return;
    }
    const updated = await updateUserName(req.userId!, { prenom, nom });
    res.status(200).json({ success: true, data: updated });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error instanceof Error ? error.message : 'Erreur serveur',
    });
  }
}

// PATCH /api/users/me/password
export async function updatePassword(req: AuthRequest, res: Response): Promise<void> {
  try {
    const { oldPassword, newPassword } = req.body;
    if (!oldPassword || !newPassword) {
      res.status(400).json({ success: false, message: 'Champs manquants' });
      return;
    }
    if (newPassword.length < 6) {
      res.status(400).json({ success: false, message: 'Le mot de passe doit contenir au moins 6 caractères' });
      return;
    }
    await updateUserPassword(req.userId!, oldPassword, newPassword);
    res.status(200).json({ success: true, message: 'Mot de passe mis à jour' });
  } catch (error) {
    const msg = error instanceof Error ? error.message : 'Erreur serveur';
    const status = msg.includes('incorrect') ? 401 : 500;
    res.status(status).json({ success: false, message: msg });
  }
}

// POST /api/users/me/email/request
export async function requestEmailChange(req: AuthRequest, res: Response): Promise<void> {
  try {
    const { newEmail } = req.body;
    if (!newEmail || !newEmail.includes('@')) {
      res.status(400).json({ success: false, message: 'Email invalide' });
      return;
    }
    await requestUserEmailChange(req.userId!, newEmail);
    res.status(200).json({ success: true, message: 'Code de vérification envoyé' });
  } catch (error) {
    const msg = error instanceof Error ? error.message : 'Erreur serveur';
    const status = msg.includes('déjà utilisé') ? 409 : 500;
    res.status(status).json({ success: false, message: msg });
  }
}

// POST /api/users/me/email/confirm
export async function confirmEmailChange(req: AuthRequest, res: Response): Promise<void> {
  try {
    const { newEmail, code } = req.body;
    if (!newEmail || !code) {
      res.status(400).json({ success: false, message: 'Champs manquants' });
      return;
    }
    await confirmUserEmailChange(req.userId!, newEmail, code);
    res.status(200).json({ success: true, message: 'Email mis à jour' });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error instanceof Error ? error.message : 'Erreur serveur',
    });
  }
}