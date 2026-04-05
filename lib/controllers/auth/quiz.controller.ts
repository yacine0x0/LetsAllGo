import { Response } from 'express';
import { AuthRequest } from '../../middlewares/auth.middleware';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// Algo 1 → 250 Go Points / bonne réponse
// Algo 2 → 500 Go Points / bonne réponse
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
    const pointsGagnes     = correctAnswers * pointsParReponse;

    // Récupère le score actuel
    const user = await prisma.utilisateur.findUnique({
      where:  { id: userId },
      select: { scoretotal: true },
    });
    if (!user) {
      res.status(404).json({ success: false, message: 'Utilisateur introuvable' });
      return;
    }

    const newScore = (user.scoretotal ?? 0) + pointsGagnes;

    await prisma.utilisateur.update({
      where: { id: userId },
      data:  { scoretotal: newScore },
    });

    // Recalcule les rangs
    const allUsers = await prisma.utilisateur.findMany({
      select:  { id: true, scoretotal: true },
      orderBy: { scoretotal: 'desc' },
    });
    for (let i = 0; i < allUsers.length; i++) {
      await prisma.utilisateur.update({
        where: { id: allUsers[i].id },
        data:  { rang: i + 1 },
      });
    }

    res.status(200).json({
      success:          true,
      pointsGagnes,
      pointsParReponse,
      newScore,
      message: `+${pointsGagnes} Go Points !`,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error instanceof Error ? error.message : 'Erreur serveur',
    });
  }
};