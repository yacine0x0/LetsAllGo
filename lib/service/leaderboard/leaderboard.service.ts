import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const getLeaderboard = async () => {
  // Récupère tous les utilisateurs triés par scoretotal
  const users = await prisma.utilisateur.findMany({
    select: {
      id:         true,
      nom:        true,
      prenom:     true,
      scoretotal: true,
      rang:       true,
    },
    orderBy: { scoretotal: 'desc' },
    take: 15, // top 15
  });

  return users.map((user, index) => ({
    rank:          index + 1,
    username:      `${user.prenom} ${user.nom}`,
    totalPoints:   user.scoretotal ?? 0,
    algo1Progress: 0.0, // à ajouter plus tard
    algo2Progress: 0.0,
    avatarInitial: user.prenom[0].toUpperCase(),
    userId:        user.id,
  }));
};

export const getLeaderboardWithUser = async (userId: string) => {
  const entries = await getLeaderboard();

  // Trouver l'utilisateur connecté dans le classement
  const currentUser = entries.find(e => e.userId === userId) ?? null;

  return { entries, currentUser };
};