import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const getUserById = async (userId: string) => {
  const user = await prisma.utilisateur.findUnique({
    where: { id: userId },
    select: {
      id:             true,
      nom:            true,
      prenom:         true,
      email:          true,
      role:           true,
      dateinscription: true,
      scoretotal:     true,
      rang:           true,
    },
  });

  if (!user) throw new Error('Utilisateur introuvable');
  return user;
};