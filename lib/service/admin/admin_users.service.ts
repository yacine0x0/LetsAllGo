import { PrismaClient } from '@prisma/client';
import { getBlockedUserIds, setUserBlocked } from './blocked_users_store.service';

const prisma = new PrismaClient();

// ── Récupérer tous les étudiants triés par score
export const getAllStudents = async () => {
  const blockedIds = await getBlockedUserIds();
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
    isBlocked:   blockedIds.has(s.id),
  }));
};

// ── Supprimer un étudiant
// lib/service/admin/admin_users.service.ts
// Dans la fonction deleteStudent — remplace le prisma.utilisateur.delete par :

export const deleteStudent = async (userId: string) => {
  const user = await prisma.utilisateur.findUnique({
    where: { id: userId },
  });

  if (!user) throw new Error('Utilisateur introuvable');
  if (user.role === 'admin') throw new Error('Impossible de supprimer un admin');

  // ✅ Supprimer dans l'ordre pour respecter les FK
  await prisma.obtient.deleteMany({
    where: { id_etudiant: userId },
  });

  await prisma.suit.deleteMany({
    where: { id_etudiant: userId },
  });

  await prisma.etudie.deleteMany({
    where: { id_etudiant: userId },
  });

  await prisma.passe.deleteMany({
    where: { id_etudiant: userId },
  });

  await prisma.statistiquescours.deleteMany({
    where: { id_admin: userId },
  });

  await prisma.statistiquesetudiant.deleteMany({
    where: { id_admin: userId },
  });

  await prisma.statistiquesquiz.deleteMany({
    where: { id_admin: userId },
  });

  // ✅ Maintenant on peut supprimer l'utilisateur
  await prisma.utilisateur.delete({
    where: { id: userId },
  });

  console.log(`✅ Utilisateur supprimé: ${userId}`);
};

// ── Rechercher des étudiants
export const searchStudents = async (query: string) => {
  const blockedIds = await getBlockedUserIds();
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
    isBlocked:   blockedIds.has(s.id),
  }));
};

export const blockStudent = async (adminId: string, userId: string) => {
  if (adminId === userId) throw new Error('Vous ne pouvez pas vous bloquer vous-meme');

  const user = await prisma.utilisateur.findUnique({
    where: { id: userId },
    select: { id: true, role: true },
  });

  if (!user) throw new Error('Utilisateur introuvable');
  if (user.role === 'admin') throw new Error('Impossible de bloquer un admin');

  await setUserBlocked(userId, true);
};

export const unblockStudent = async (userId: string) => {
  const user = await prisma.utilisateur.findUnique({
    where: { id: userId },
    select: { id: true },
  });

  if (!user) throw new Error('Utilisateur introuvable');
  await setUserBlocked(userId, false);
};