// lib/service/quiz/quiz.service.ts
import { PrismaClient } from '@prisma/client';

const globalForPrisma = global as unknown as { prisma: PrismaClient };
const prisma = globalForPrisma.prisma ?? new PrismaClient();
if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;

// ── Soumettre un quiz ─────────────────────────────────────────────────────────
// Enregistre dans `passe` + met à jour le scoretotal de l'utilisateur
export const submitQuizService = async ({
  userId,
  quizId,
  correctAnswers,
}: {
  userId:         string;
  quizId:         string;
  correctAnswers: number;
}) => {

  // Vérifie que le quiz existe
  const quiz = await prisma.quizz.findUnique({
    where: { id_quiz: quizId },
  });
  if (!quiz) throw new Error('Quiz introuvable');

  // Upsert dans `passe` — évite les doublons si l'utilisateur repasse le quiz
  await prisma.passe.upsert({
    where:  { id_etudiant_id_quiz: { id_etudiant: userId, id_quiz: quizId } },
    update: {},
    create: { id_etudiant: userId, id_quiz: quizId },
  });

  // Incrémente le scoretotal de l'utilisateur
  const utilisateur = await prisma.utilisateur.update({
    where: { id: userId },
    data:  { scoretotal: { increment: correctAnswers } },
    select: { scoretotal: true },
  });

  return {
    pointsGagnes: correctAnswers,
    scoretotal:   utilisateur.scoretotal,
  };
};

// ── Terminer un chapitre ──────────────────────────────────────────────────────
// Met termine = true dans `chapitre` + met à jour pourcentagechapitre
export const completeChapterService = async ({
  chapterId,
  userId,
}: {
  chapterId: string;
  userId:    string;
}) => {

  // Vérifie que le chapitre existe
  const chapitre = await prisma.chapitre.findUnique({
    where: { id_chapitre: chapterId },
  });
  if (!chapitre) throw new Error('Chapitre introuvable');

  // Marque le chapitre comme terminé
  const updated = await prisma.chapitre.update({
    where: { id_chapitre: chapterId },
    data: {
      termine:             true,
      pourcentagechapitre: 100,
    },
  });

  // Enregistre dans suividuchapitre
  await prisma.suividuchapitre.create({
    data: {
      id_chapitre: chapterId,
      complete:    true,
      datepassage: new Date(),
      obtient: {
        create: { id_etudiant: userId },
      },
    },
  });

  return { termine: updated.termine, pourcentagechapitre: updated.pourcentagechapitre };
};