// lib/controllers/auth/quiz.controller.ts
import { Response }      from 'express';
import { AuthRequest }   from '../../middlewares/auth.middleware';
import { PrismaClient }  from '@prisma/client';

const globalForPrisma = global as unknown as { prisma: PrismaClient };
const prisma = globalForPrisma.prisma ?? new PrismaClient();
if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;

const GO_POINTS: Record<string, number> = {
  algo1: 250,
  algo2: 500,
};

export const submitQuiz = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.userId!;
    const { correctAnswers, algoType, quizId } = req.body as {
      correctAnswers: number;
      algoType:       'algo1' | 'algo2';
      quizId:         string;
    };

    if (typeof correctAnswers !== 'number' || correctAnswers < 0) {
      res.status(400).json({ success: false, message: 'correctAnswers invalide' });
      return;
    }

    const pointsParReponse = GO_POINTS[algoType] ?? 250;
    const pointsGagnes     = correctAnswers * pointsParReponse;

    if (quizId) {
      await prisma.passe.upsert({
        where:  { id_etudiant_id_quiz: { id_etudiant: userId, id_quiz: quizId } },
        update: {},
        create: { id_etudiant: userId, id_quiz: quizId },
      });
    }

    const updatedUser = await prisma.utilisateur.update({
      where:  { id: userId },
      data:   { scoretotal: { increment: pointsGagnes } },
      select: { id: true, scoretotal: true, rang: true },
    });

    res.status(200).json({
      success:         true,
      pointsGagnes,
      pointsParReponse,
      newScore:        updatedUser.scoretotal,
      currentRank:     updatedUser.rang,
      message:         `+${pointsGagnes} Go Points !`,
    });

  } catch (error: any) {
    console.error('Erreur submitQuiz:', error);
    res.status(500).json({
      success: false,
      message: error instanceof Error ? error.message : 'Erreur serveur',
    });
  }
};

// ✅ NOUVEAU — Terminer un chapitre
export const completeChapter = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId    = req.userId!;
    const { chapterId } = req.body as { chapterId: string };

    if (!chapterId) {
      res.status(400).json({ success: false, message: 'chapterId requis' });
      return;
    }

    const updated = await prisma.chapitre.update({
      where: { id_chapitre: chapterId },
      data:  { termine: true, pourcentagechapitre: 100 },
    });

    res.status(200).json({
      success:             true,
      termine:             updated.termine,
      pourcentagechapitre: updated.pourcentagechapitre,
    });

  } catch (error: any) {
    console.error('Erreur completeChapter:', error);
    res.status(500).json({
      success: false,
      message: error instanceof Error ? error.message : 'Erreur serveur',
    });
  }
};