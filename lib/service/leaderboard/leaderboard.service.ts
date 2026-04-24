import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const getLeaderboard = async () => {
  // ✅ Filtre uniquement les étudiants
  const users = await prisma.utilisateur.findMany({
    where: {
      role: 'etudiant',
    },
    select: {
      id:         true,
      nom:        true,
      prenom:     true,
      scoretotal: true,
      rang:       true,
    },
    orderBy: { scoretotal: 'desc' },
    take: 15,
  });

  return users.map((user, index) => ({
    rank:          index + 1,
    username:      `${user.prenom} ${user.nom}`,
    totalPoints:   user.scoretotal ?? 0,
    algo1Progress: 0.0,
    algo2Progress: 0.0,
    avatarInitial: user.prenom[0].toUpperCase(),
    userId:        user.id,
  }));
};

export const getLeaderboardWithUser = async (userId: string) => {
  const entries = await getLeaderboard();

  const currentUser = entries.find(e => e.userId === userId) ?? null;

  return { entries, currentUser };
};