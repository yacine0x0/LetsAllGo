// lib/controllers/auth/quiz.controller.ts
import { Response }     from 'express';
import { AuthRequest }  from '../../middlewares/auth.middleware';
import { PrismaClient } from '@prisma/client';

console.log('✅ quiz.controller.ts chargé'); // ← vérifie que le fichier est bien importé

const globalForPrisma = global as unknown as { prisma: PrismaClient };
const prisma = globalForPrisma.prisma ?? new PrismaClient();
if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;

const GO_POINTS: Record<string, number> = {
  algo1: 250,
  algo2: 500,
};

const CHAPTER_MAP: Record<string, string> = {
  'Chapitre 01': "Introduction à l'algorithmique",
  'Chapitre 02': 'Conditions',
  'Chapitre 03': 'Boucles',
  'Chapitre 04': 'Structures de données',
  'Chapitre 05': 'Sous-programmes',
};

// POST /api/quiz/submit
export const submitQuiz = async (req: AuthRequest, res: Response): Promise<void> => {
  console.log('🎯 submitQuiz appelé body:', JSON.stringify(req.body));
  try {
    const userId = req.userId!;
    const {
      correctAnswers,
      algoType,
      chapterName,
      totalQuestions,
    } = req.body as {
      correctAnswers: number;
      algoType:       'algo1' | 'algo2';
      chapterName:    string;
      totalQuestions: number;
    };

    console.log(`📊 userId: ${userId}, correctAnswers: ${correctAnswers}, algoType: ${algoType}, chapterName: ${chapterName}`);

    if (typeof correctAnswers !== 'number' || correctAnswers < 0) {
      res.status(400).json({ success: false, message: 'correctAnswers invalide' });
      return;
    }

    const pointsParReponse = GO_POINTS[algoType] ?? 250;
    const pointsGagnes     = correctAnswers * pointsParReponse;

    // ✅ 1. Crée le quiz dans `quizz`
    console.log('📝 Création quizz...');
    const quizzRecord = await prisma.quizz.create({
      data: {
        score:                  correctAnswers,
        nombrequestionstotal:   totalQuestions ?? 0,
        nombrequestionsfaites:  correctAnswers,
        chapitresselectionnees: chapterName    ?? '',
        intensite:              algoType,
      },
    });
    console.log('✅ quizz créé:', quizzRecord.id_quiz);

    // ✅ 2. Cherche le chapitre dans la BDD via la map
    const titreBDD = CHAPTER_MAP[chapterName] ?? chapterName;
    console.log(`🔍 Recherche chapitre: "${titreBDD}"`);
    const chapitre = await prisma.chapitre.findFirst({
      where: { titre: { contains: titreBDD, mode: 'insensitive' } },
    });
    console.log('📚 Chapitre trouvé:', chapitre ? chapitre.id_chapitre : 'NON TROUVÉ');

    // ✅ 3. Crée un suivi du chapitre + lie l'étudiant
    if (chapitre) {
      console.log('📝 Création suividuchapitre...');
      const suivi = await prisma.suividuchapitre.create({
        data: {
          id_chapitre: chapitre.id_chapitre,
          complete:    correctAnswers >= Math.ceil(totalQuestions * 0.5),
          datepassage: new Date(),
        },
      });
      console.log('✅ suivi créé:', suivi.id_s);

      console.log('📝 Création obtient...');
      await prisma.obtient.create({
        data: {
          id_etudiant:      userId,
          id_suivichapitre: suivi.id_s,
        },
      });
      console.log('✅ obtient créé');
    }

    // ✅ 4. Lie l'étudiant au quiz dans `passe`
    console.log('📝 Création passe...');
    await prisma.passe.create({
      data: {
        id_etudiant: userId,
        id_quiz:     quizzRecord.id_quiz,
      },
    });
    console.log('✅ passe créé');

    // ✅ 5. Met à jour le score total
    console.log('📝 Mise à jour scoretotal...');
    const updatedUser = await prisma.utilisateur.update({
      where:  { id: userId },
      data:   { scoretotal: { increment: pointsGagnes } },
      select: { id: true, scoretotal: true, rang: true },
    });
    console.log('✅ scoretotal mis à jour:', updatedUser.scoretotal);

    res.status(200).json({
      success:         true,
      pointsGagnes,
      pointsParReponse,
      newScore:        updatedUser.scoretotal,
      currentRank:     updatedUser.rang,
      message:         `+${pointsGagnes} Go Points !`,
    });

  } catch (error: any) {
    console.error('❌ Erreur submitQuiz:', error);
    res.status(500).json({
      success: false,
      message: error instanceof Error ? error.message : 'Erreur serveur',
    });
  }
};

// POST /api/courses/complete
export const completeChapter = async (req: AuthRequest, res: Response): Promise<void> => {
  console.log('🎯 completeChapter appelé body:', JSON.stringify(req.body));
  try {
    const userId        = req.userId!;
    const { chapterId } = req.body as { chapterId: string };

    if (!chapterId) {
      res.status(400).json({ success: false, message: 'chapterId requis' });
      return;
    }

    console.log('📝 Mise à jour chapitre...');
    const updated = await prisma.chapitre.update({
      where: { id_chapitre: chapterId },
      data:  { termine: true, pourcentagechapitre: 100 },
    });
    console.log('✅ chapitre mis à jour');

    console.log('📝 Création suividuchapitre...');
    const suivi = await prisma.suividuchapitre.create({
      data: {
        id_chapitre: chapterId,
        complete:    true,
        datepassage: new Date(),
      },
    });
    console.log('✅ suivi créé:', suivi.id_s);

    console.log('📝 Création obtient...');
    await prisma.obtient.create({
      data: {
        id_etudiant:      userId,
        id_suivichapitre: suivi.id_s,
      },
    });
    console.log('✅ obtient créé');

    res.status(200).json({
      success:             true,
      termine:             updated.termine,
      pourcentagechapitre: updated.pourcentagechapitre,
    });

  } catch (error: any) {
    console.error('❌ Erreur completeChapter:', error);
    res.status(500).json({
      success: false,
      message: error instanceof Error ? error.message : 'Erreur serveur',
    });
  }
};