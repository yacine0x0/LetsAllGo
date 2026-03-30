import { PrismaClient } from '@prisma/client';
import { SubmitQuizInput, ProgressionResult } from '../loginmodels/quiz.model';

const prisma = new PrismaClient();

export const submitQuizService = async (
  userId: string,
  input: SubmitQuizInput
): Promise<ProgressionResult> => {

  // ── Chercher le chapitre par son titre
  const chapitre = await prisma.chapitre.findFirst({
    where: { titre: { contains: input.chapterName } },
  });

  // ── Chercher ou créer le quiz
  let quiz = chapitre
    ? await prisma.quiz.findFirst({
        where: {
          chapitre: { some: { id_chapitre: chapitre.id_chapitre } }
        }
      })
    : null;

  if (!quiz) {
    quiz = await prisma.quiz.create({
      data: {
        nombrequestionstotal:  input.totalQuestions,
        nombrequestionsfaites: input.totalQuestions,
        score:                 input.score,
      },
    });
  } else {
    await prisma.quiz.update({
      where: { id_quiz: quiz.id_quiz },
      data: {
        score:                 input.score,
        nombrequestionsfaites: input.totalQuestions,
      },
    });
  }

  // ── Sauvegarder le passage
  await prisma.passe.upsert({
    where: {
      id_etudiant_id_quiz: {
        id_etudiant: userId,
        id_quiz:     quiz.id_quiz,
      },
    },
    update: { datepassage: new Date() },
    create: {
      id_etudiant: userId,
      id_quiz:     quiz.id_quiz,
      datepassage: new Date(),
    },
  });

  // ── Mettre à jour scoretotal
  const utilisateur = await prisma.utilisateur.update({
    where: { id: userId },
    data: { scoretotal: { increment: input.score * 100 } },
  });

  // ── Progression chapitre et module
  const chapitreId = chapitre?.id_chapitre ?? '';
  const moduleId   = chapitre?.id_module   ?? '';

  const progressionChapitre = chapitreId
    ? await _calculerProgressionChapitre(userId, chapitreId, input.score, input.totalQuestions)
    : Math.round((input.score / input.totalQuestions) * 100);

  const progressionModule = moduleId
    ? await _calculerProgressionModule(moduleId)
    : 0;

  return {
    scoreObtenu:           input.score,
    scoretotalUtilisateur: utilisateur.scoretotal ?? 0,
    progressionChapitre:   progressionChapitre,
    progressionModule:     progressionModule,
    chapitreComplete:      progressionChapitre >= 70,
  };
};

// ─────────────────────────────────────────
// Calcul progression chapitre
// ─────────────────────────────────────────
async function _calculerProgressionChapitre(
  userId: string,
  chapitreId: string,
  score: number,
  totalQuestions: number
): Promise<number> {

  // Vérifier que le chapitre existe
  const chapitre = await prisma.chapitre.findUnique({
    where: { id_chapitre: chapitreId },
  });

  // Si le chapitre n'existe pas → retourner le % calculé sans BDD
  if (!chapitre) {
    return totalQuestions > 0
      ? Math.round((score / totalQuestions) * 100)
      : 0;
  }

  const pourcentage = totalQuestions > 0
    ? Math.round((score / totalQuestions) * 100)
    : 0;

  const complete = pourcentage >= 70;

  // Créer suivi du chapitre
  const suivi = await prisma.suividuchapitre.create({
    data: {
      id_chapitre: chapitreId,
      complete:    complete,
      datepassage: new Date(),
    },
  });

  // Lier à l'utilisateur
  await prisma.obtient.upsert({
    where: {
      id_etudiant_id_suivichapitre: {
        id_etudiant:      userId,
        id_suivichapitre: suivi.id_s,
      },
    },
    update: {},
    create: {
      id_etudiant:      userId,
      id_suivichapitre: suivi.id_s,
    },
  });

  // Mettre à jour progression du chapitre
  await prisma.chapitre.update({
    where: { id_chapitre: chapitreId },
    data:  { progressionchapitre: pourcentage },
  });

  return pourcentage;
}

// ─────────────────────────────────────────
// Calcul progression module
// ─────────────────────────────────────────
async function _calculerProgressionModule(moduleId: string): Promise<number> {

  // Vérifier que le module existe
  const module = await prisma.module.findUnique({
    where: { id_module: moduleId },
  });

  // Module pas encore en BDD → retourner 0
  if (!module) return 0;

  const chapitres = await prisma.chapitre.findMany({
    where: { id_module: moduleId },
    select: {
      id_chapitre:         true,
      progressionchapitre: true,
    },
  });

  if (chapitres.length === 0) return 0;

  const total = chapitres.reduce(
    (sum, c) => sum + (c.progressionchapitre ?? 0), 0
  );
  const moyenne = Math.round(total / chapitres.length);

  await prisma.module.update({
    where: { id_module: moduleId },
    data:  { progressionmodule: moyenne },
  });

  return moyenne;
}

// ─────────────────────────────────────────
// Récupérer progression d'un module
// ─────────────────────────────────────────
export const getProgressionModule = async (
  moduleId: string
): Promise<{ chapitres: any[]; progressionGlobale: number }> => {

  const chapitres = await prisma.chapitre.findMany({
    where: { id_module: moduleId },
    select: {
      id_chapitre:         true,
      titre:               true,
      progressionchapitre: true,
      termine:             true,
    },
    orderBy: { titre: 'asc' },
  });

  const progressionGlobale = chapitres.length > 0
    ? Math.round(
        chapitres.reduce((sum, c) => sum + (c.progressionchapitre ?? 0), 0)
        / chapitres.length
      )
    : 0;

  return { chapitres, progressionGlobale };
};


