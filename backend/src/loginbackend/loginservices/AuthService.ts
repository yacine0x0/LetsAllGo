import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// Appel API : récupérer un utilisateur par email
export const loginService = async (email: string) => {
  return await prisma.utilisateur.findUnique({ where: { email } });
};

// Appel API : créer un utilisateur
export const registerService = async (
  nom: string,
  prenom: string,
  email: string,
  hashedPassword: string
) => {
  return await prisma.utilisateur.create({
    data: {
      nom,
      prenom,
      email,
      motdepasse: hashedPassword,
      role: 'etudiant',
    },
  });
};