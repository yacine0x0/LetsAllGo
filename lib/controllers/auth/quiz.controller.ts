import { Response } from 'express';
import { AuthRequest } from '../../middlewares/auth.middleware';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const GO_POINTS: Record<string, number> = {
  algo1: 250,
  algo2: 500,
};

export const submitQuiz = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.userId!;
    const { correctAnswers, algoType } = req.body as {
      correctAnswers: number;
      algoType: 'algo1' | 'algo2';
    };

    if (typeof correctAnswers !== 'number' || correctAnswers < 0) {
      res.status(400).json({ success: false, message: 'correctAnswers invalide' });
      return;
    }

    const pointsParReponse = GO_POINTS[algoType] ?? 250;
    const pointsGagnes = correctAnswers * pointsParReponse;

    // Mise à jour simple du score uniquement
    const updatedUser = await prisma.utilisateur.update({
      where: { id: userId },
      data: {
        scoretotal: {
          increment: pointsGagnes,   // + les points gagnés
        },
      },
      select: {
        id: true,
        scoretotal: true,
        rang: true,
      },
    });

    res.status(200).json({
      success: true,
      pointsGagnes,
      pointsParReponse,
      newScore: updatedUser.scoretotal,
      currentRank: updatedUser.rang,
      message: `+${pointsGagnes} Go Points !`,
    });

  } catch (error: any) {
    console.error('Erreur submitQuiz:', error);
    res.status(500).json({
      success: false,
      message: error instanceof Error ? error.message : 'Erreur serveur',
    });
  }
};