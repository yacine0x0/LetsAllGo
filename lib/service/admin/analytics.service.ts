// lib/service/admin/analytics.service.ts
import { PrismaClient } from '@prisma/client';

const globalForPrisma = global as unknown as { prisma: PrismaClient };
const prisma = globalForPrisma.prisma ?? new PrismaClient();
if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;

const CHAPTER_LABELS_ALGO1: Record<string, string> = {
  'Chapitre 01': 'Intro',
  'Chapitre 02': 'Conditions',
  'Chapitre 03': 'Boucles',
  'Chapitre 04': 'Structures',
  'Chapitre 05': 'Sous-prog',
};

const CHAPTER_LABELS_ALGO2: Record<string, string> = {
  'Chapitre 01': 'Tri',
  'Chapitre 02': 'Recherche',
  'Chapitre 03': 'Récursivité',
  'Chapitre 04': 'Listes',
  'Chapitre 05': 'Piles/Files',
};

export const getAnalytics = async () => {

  // ── 1. Chapitres avec progression depuis suividuchapitre
  const chapitres = await prisma.chapitre.findMany({
    select: {
      id_chapitre:         true,
      titre:               true,
      pourcentagechapitre: true,
      module:              { select: { nom: true } },
      suividuchapitre:     { select: { complete: true } },
    },
    orderBy: { titre: 'asc' },
  });

  const chapitresAvecProgression = chapitres.map(c => {
    const total    = c.suividuchapitre.length;
    const termines = c.suividuchapitre.filter(s => s.complete === true).length;
    const completion = total > 0
      ? termines / total
      : (c.pourcentagechapitre ?? 0) / 100;
    return {
      titre:      c.titre,
      module_nom: c.module?.nom?.toLowerCase() ?? '',
      completion,
    };
  });

  // ── 2. Total questions dans tous les quiz (somme nombrequestionstotal)
  const totalResult = await prisma.quizz.aggregate({
    _sum: { nombrequestionstotal: true },
  });
  const totalQuizzesDone = totalResult._sum.nombrequestionstotal ?? 0;

  // ── 3. Quiz groupés par chapitre — Algo1
  const quizzAlgo1 = await prisma.quizz.groupBy({
    by:     ['chapitresselectionnees'],
    where:  { intensite: 'algo1' },
    _count: { id_quiz: true },
    _sum:   { nombrequestionstotal: true },
  });

  // ── 4. Quiz groupés par chapitre — Algo2
  const quizzAlgo2 = await prisma.quizz.groupBy({
    by:     ['chapitresselectionnees'],
    where:  { intensite: 'algo2' },
    _count: { id_quiz: true },
    _sum:   { nombrequestionstotal: true },
  });

  // ── Debug : afficher les vraies valeurs de chapitresselectionnees
  console.log('quizzAlgo1 raw:', JSON.stringify(quizzAlgo1, null, 2));
  console.log('quizzAlgo2 raw:', JSON.stringify(quizzAlgo2, null, 2));

  // ── 5. Formater quizStatsAlgo1 — valeur = somme nombrequestionstotal
  const quizStatsAlgo1 = Object.entries(CHAPTER_LABELS_ALGO1).map(([key, label]) => {
    const found = quizzAlgo1.find(q => q.chapitresselectionnees === key);
    return {
      day:            label,
      quizzesDone:    found?._sum.nombrequestionstotal ?? 0,
      totalQuestions: found?._sum.nombrequestionstotal ?? 0,
    };
  });

  // ── 6. Formater quizStatsAlgo2 — valeur = somme nombrequestionstotal
  const quizStatsAlgo2 = Object.entries(CHAPTER_LABELS_ALGO2).map(([key, label]) => {
    const found = quizzAlgo2.find(q => q.chapitresselectionnees === key);
    return {
      day:            label,
      quizzesDone:    found?._sum.nombrequestionstotal ?? 0,
      totalQuestions: found?._sum.nombrequestionstotal ?? 0,
    };
  });

  // ── 7. Séparer chapitres Algo1 / Algo2 par module_nom
  const algo1Chapters = chapitresAvecProgression
    .filter(c => c.module_nom.includes('algo1') || c.module_nom.includes('algorithme 1'))
    .map(c => ({ label: c.titre, completion: c.completion }));

  const algo2Chapters = chapitresAvecProgression
    .filter(c => c.module_nom.includes('algo2') || c.module_nom.includes('algorithme 2'))
    .map(c => ({ label: c.titre, completion: c.completion }));

  const finalAlgo1 = algo1Chapters.length > 0
    ? algo1Chapters
    : chapitresAvecProgression.map(c => ({ label: c.titre, completion: c.completion }));

  const finalAlgo2 = algo2Chapters.length > 0
    ? algo2Chapters
    : [];

  return {
    totalQuizzesDone,
    quizStats:      quizStatsAlgo1,
    quizStatsAlgo1,
    quizStatsAlgo2,
    algo1Chapters:  finalAlgo1,
    algo2Chapters:  finalAlgo2,
  };
};