import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// ── Récupérer tous les étudiants triés par score
export const getAllStudents = async () => {
  const students = await prisma.utilisateur.findMany({
    where: { role: 'etudiant' },
    select: {
      id:             true,
      nom:            true,
      prenom:         true,
      email:          true,
      scoretotal:     true,
      rang:           true,
      dateinscription: true,
    },
    orderBy: { scoretotal: 'desc' },
  });

  return students.map((s, index) => ({
    rank:        index + 1,
    id:          s.id,
    firstName:   s.prenom,
    lastName:    s.nom,
    email:       s.email,
    totalPoints: s.scoretotal ?? 0,
    rang:        s.rang,
    enrolledAt:  s.dateinscription,
  }));
};

// ── Supprimer un étudiant
export const deleteStudent = async (userId: string) => {
  const user = await prisma.utilisateur.findUnique({
    where: { id: userId },
  });

  if (!user) throw new Error('Utilisateur introuvable');
  if (user.role === 'admin') throw new Error('Impossible de supprimer un admin');

  await prisma.utilisateur.delete({
    where: { id: userId },
  });
};

// ── Rechercher des étudiants
export const searchStudents = async (query: string) => {
  const students = await prisma.utilisateur.findMany({
    where: {
      role: 'etudiant',
      OR: [
        { nom:    { contains: query, mode: 'insensitive' } },
        { prenom: { contains: query, mode: 'insensitive' } },
        { email:  { contains: query, mode: 'insensitive' } },
      ],
    },
    select: {
      id:             true,
      nom:            true,
      prenom:         true,
      email:          true,
      scoretotal:     true,
      rang:           true,
      dateinscription: true,
    },
    orderBy: { scoretotal: 'desc' },
  });

  return students.map((s, index) => ({
    rank:        index + 1,
    id:          s.id,
    firstName:   s.prenom,
    lastName:    s.nom,
    email:       s.email,
    totalPoints: s.scoretotal ?? 0,
    rang:        s.rang,
    enrolledAt:  s.dateinscription,
  }));
};