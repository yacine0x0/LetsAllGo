import { PrismaClient } from '@prisma/client';

// ✅ Singleton Prisma — évite les fuites mémoire
const globalForPrisma = global as unknown as { prisma: PrismaClient };
const prisma = globalForPrisma.prisma ?? new PrismaClient();
if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;

const JOURS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

export const getAnalytics = async () => {

  // ✅ Requêtes parallèles — plus rapide
  const [chapitres, totalQuizzesDone, quizParJour] = await Promise.all([

    prisma.chapitre.findMany({
      select: {
        titre:               true,
        pourcentagechapitre: true,
        id_module:           true,
        module: {
          select: { nom: true },
        },
      },
      orderBy: { titre: 'asc' },
    }),

    prisma.passe.count(),

    prisma.suividuchapitre.groupBy({
      by:      ['datepassage'],
      _count:  { id_s: true },
      where:   {
        datepassage: {
          gte: (() => {
            const d = new Date();
            d.setDate(d.getDate() - 6);
            d.setHours(0, 0, 0, 0);
            return d;
          })(),
        },
      },
      orderBy: { datepassage: 'asc' },
    }),

  ]);

  // ✅ 7 jours complets dans le bon ordre, avec 0 pour les jours sans données
  const quizStats = Array.from({ length: 7 }, (_, i) => {
    const d = new Date();
    d.setDate(d.getDate() - (6 - i));
    d.setHours(0, 0, 0, 0);
    const found = quizParJour.find(q =>
      q.datepassage && new Date(q.datepassage).toDateString() === d.toDateString()
    );
    return {
      day:         JOURS[d.getDay()],
      quizzesDone: found?._count.id_s ?? 0,
    };
  });

  // ✅ Filtrage des chapitres par module
  const algo1 = chapitres.filter(c => {
    const nom = c.module?.nom?.toLowerCase() ?? '';
    return nom.includes('1') || nom.includes('algo') || nom.includes('algorithmique');
  });

  const algo2 = chapitres.filter(c => {
    const nom = c.module?.nom?.toLowerCase() ?? '';
    return nom.includes('2');
  });

  // ✅ Fallback : si aucun filtre ne correspond, tout mettre dans algo1
  const finalAlgo1 = algo1.length > 0 ? algo1 : chapitres;
  const finalAlgo2 = algo2.length > 0 ? algo2 : [];

  return {
    totalQuizzesDone,
    quizStats,
    algo1Chapters: finalAlgo1.map(c => ({
      label:      c.titre,
      completion: (c.pourcentagechapitre ?? 0) / 100,
    })),
    algo2Chapters: finalAlgo2.map(c => ({
      label:      c.titre,
      completion: (c.pourcentagechapitre ?? 0) / 100,
    })),
  };
};