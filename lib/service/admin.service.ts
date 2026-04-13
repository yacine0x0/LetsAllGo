import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const getAdminById = async (userId: string) => {
  const user = await prisma.utilisateur.findUnique({
    where: { id: userId },
    select: {
      id:              true,
      nom:             true,
      prenom:          true,
      email:           true,
      role:            true,
      dateinscription: true,
    },
  });

  if (!user) throw new Error('Admin introuvable');
  if (user.role !== 'admin') throw new Error('Accès refusé');

  return user;
};

export const updateAdminProfile = async (
  userId: string,
  data: { nom?: string; prenom?: string; email?: string }
) => {
  const updated = await prisma.utilisateur.update({
    where: { id: userId },
    data: {
      nom:    data.nom?.trim(),
      prenom: data.prenom?.trim(),
      email:  data.email?.trim(),
    },
    select: {
      id:     true,
      nom:    true,
      prenom: true,
      email:  true,
      role:   true,
    },
  });
  return updated;
};