// lib/service/admin/analytics.service.ts
import { PrismaClient } from '@prisma/client';

const globalForPrisma = global as unknown as { prisma: PrismaClient };
const prisma = globalForPrisma.prisma ?? new PrismaClient();
if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;

const JOURS_FR = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];

export const getAnalytics = async () => {

  // ── 1. Chapitres avec taux de complétion
  const chapitres = await prisma.chapitre.findMany({
    select: {
      id_chapitre: true,
      titre: true,
      pourcentagechapitre: true,
      module: { select: { nom: true } },
      suividuchapitre: { select: { complete: true } },
    },
    orderBy: { titre: 'asc' },
  });

  const chapitresAvecProgression = chapitres.map(c => {
    const total = c.suividuchapitre.length;
    const termines = c.suividuchapitre.filter(
      s => s.complete === true
    ).length;

    const completion = total > 0
      ? termines / total
      : (c.pourcentagechapitre ?? 0) / 100;

    return {
      id_chapitre: c.id_chapitre,
      titre: c.titre,
      module_nom: c.module?.nom?.toLowerCase() ?? '',
      completion,
    };
  });

  // ── 2. Total quiz passés (global)
  const totalQuizzesDone = await prisma.passe.count();

  // ── 3. Récupérer les 100 derniers quiz passés
const passages = await prisma.passe.findMany({
  orderBy: {
    datepassage: 'desc',
  },
  take: 500,
  select: {
    datepassage: true,
    quizz: {
      select: {
        intensite: true,
        selectionne: {
          select: {
            chapitre: {
              select: {
                module: {
                  select: { nom: true },
                },
              },
            },
          },
        },
      },
    },
  },
});

  console.log('📊 100 derniers passages:', passages.length);

  // ── 4. Utiliser directement intensite
  // intensite = algo1 | algo2
  const passesAvecModule = passages
    .filter(p => p.datepassage !== null)
    .map(p => {
      const module_nom =
        p.quizz.intensite?.toLowerCase() ?? '';

      return {
        datepassage: p.datepassage as Date,
        module_nom,
      };
    });

  console.log(
    '📚 modules distincts:',
    [...new Set(passesAvecModule.map(e => e.module_nom))]
  );

  // ── 5. Builder courbe statistiques
  const buildWeekStats = (
    entries: { datepassage: Date }[]
  ) =>
    Array.from({ length: 7 }, (_, i) => {
      const d = new Date();
      d.setDate(d.getDate() - (6 - i));
      d.setHours(0, 0, 0, 0);

      const count = entries.filter(e => {
        const ed = new Date(e.datepassage);
        ed.setHours(0, 0, 0, 0);

        return ed.toDateString() === d.toDateString();
      }).length;

      return {
        day: JOURS_FR[d.getDay()],
        quizzesDone: count,
      };
    });

  // Stats globales
  const quizStats7Jours = buildWeekStats(passesAvecModule);

  // ── Algo1 via intensite
  const datesAlgo1 = passesAvecModule.filter(
    e => e.module_nom === 'algo1'
  );

  // ── Algo2 via intensite
  const datesAlgo2 = passesAvecModule.filter(
    e => e.module_nom === 'algo2'
  );

  // Fallback Algo1
  const quizStatsAlgo1 = buildWeekStats(
    datesAlgo1.length > 0
      ? datesAlgo1
      : passesAvecModule
  );

  // Fallback Algo2
  const quizStatsAlgo2 = buildWeekStats(
    datesAlgo2.length > 0
      ? datesAlgo2
      : passesAvecModule
  );

  console.log('📈 global  :', quizStats7Jours);
  console.log('📈 algo1   :', quizStatsAlgo1);
  console.log('📈 algo2   :', quizStatsAlgo2);

  // ── 6. Séparer chapitres Algo1 / Algo2
  const algo1Chapters = chapitresAvecProgression
    .filter(c =>
      c.module_nom.includes('algorithmique 1') ||
      c.module_nom.includes('algorithme 1') ||
      c.module_nom === 'algo1'
    )
    .map(c => ({
      label: c.titre,
      completion: c.completion,
    }));

  const algo2Chapters = chapitresAvecProgression
    .filter(c =>
      c.module_nom.includes('algorithmique 2') ||
      c.module_nom.includes('algorithme 2') ||
      c.module_nom === 'algo2'
    )
    .map(c => ({
      label: c.titre,
      completion: c.completion,
    }));

  // Fallback Algo1
  const finalAlgo1 = algo1Chapters.length > 0
    ? algo1Chapters
    : chapitresAvecProgression.map(c => ({
        label: c.titre,
        completion: c.completion,
      }));

  const finalAlgo2 = algo2Chapters.length > 0
    ? algo2Chapters
    : [];

  return {
    totalQuizzesDone,
    quizStats: quizStats7Jours,
    quizStatsAlgo1,
    quizStatsAlgo2,
    algo1Chapters: finalAlgo1,
    algo2Chapters: finalAlgo2,
  };
};