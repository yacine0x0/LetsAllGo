import { Request, Response } from 'express';
import { PrismaClient }      from '@prisma/client';
import bcrypt                from 'bcryptjs';
import { sendResetPasswordEmail, verifyResetOTP } from '../../service/auth/email.service';

const prisma = new PrismaClient();

// ✅ Store pour les userId dont l'OTP a été vérifié
const verifiedResets = new Set<string>();

// ── POST /api/auth/forgot-password
export async function forgotPassword(req: Request, res: Response): Promise<void> {
  try {
    const { email } = req.body as { email?: string };
    if (!email) {
      res.status(400).json({ success: false, message: 'Email manquant' });
      return;
    }

    const user = await prisma.utilisateur.findUnique({
      where: { email: email.trim().toLowerCase() },
    });

    if (!user) {
      res.status(200).json({ success: true, message: 'Si cet email existe, un code a été envoyé.' });
      return;
    }

    await sendResetPasswordEmail(user.id, user.email, user.prenom);

    res.status(200).json({
      success: true,
      message: 'Code envoyé à votre email.',
      userId:  user.id,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error instanceof Error ? error.message : 'Erreur serveur',
    });
  }
}

// ── POST /api/auth/verify-reset-otp
export async function verifyResetCode(req: Request, res: Response): Promise<void> {
  try {
    const { userId, code } = req.body as { userId?: string; code?: string };

    if (!userId || !code) {
      res.status(400).json({ success: false, message: 'Données manquantes' });
      return;
    }

    const isValid = verifyResetOTP(userId, code);

    if (!isValid) {
      res.status(400).json({ success: false, message: 'Code invalide ou expiré' });
      return;
    }

    // ✅ Marquer cet userId comme vérifié
    verifiedResets.add(userId);

    res.status(200).json({ success: true, message: 'Code vérifié' });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error instanceof Error ? error.message : 'Erreur serveur',
    });
  }
}

// ── POST /api/auth/reset-password
export async function resetPassword(req: Request, res: Response): Promise<void> {
  try {
    const { userId, newPassword } = req.body as {
      userId?:      string;
      newPassword?: string;
    };

    if (!userId || !newPassword) {
      res.status(400).json({ success: false, message: 'Données manquantes' });
      return;
    }

    if (newPassword.length < 6) {
      res.status(400).json({
        success: false,
        message: 'Le mot de passe doit contenir au moins 6 caractères',
      });
      return;
    }

    // ✅ Vérifier que l'OTP a bien été validé à l'étape 2
    if (!verifiedResets.has(userId)) {
      res.status(400).json({ success: false, message: 'Vérification requise' });
      return;
    }

    // Hash + update BDD
    const hashed = await bcrypt.hash(newPassword, 10);
    await prisma.utilisateur.update({
      where: { id: userId },
      data:  { motdepasse: hashed },
    });

    // ✅ Nettoyer le store après usage
    verifiedResets.delete(userId);

    res.status(200).json({
      success: true,
      message: 'Mot de passe réinitialisé avec succès',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error instanceof Error ? error.message : 'Erreur serveur',
    });
  }
}