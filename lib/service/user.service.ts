import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';
import { savePendingRegistration, getPendingRegistration, incrementAttempts, deletePendingRegistration } from '../utils/verificationStore';
import { sendVerificationEmail } from './email.service';

const prisma = new PrismaClient();

// ─── GET ──────────────────────────────────────────────────────────────────────

export const getUserById = async (userId: string) => {
  const user = await prisma.utilisateur.findUnique({
    where: { id: userId },
    select: {
      id:              true,
      nom:             true,
      prenom:          true,
      email:           true,
      role:            true,
      dateinscription: true,
      scoretotal:      true,
      rang:            true,
    },
  });
  if (!user) throw new Error('Utilisateur introuvable');
  return user;
};

// ─── UPDATE NOM / PRÉNOM (sans vérification — remplacement direct) ─────────

export const updateUserName = async (
  userId: string,
  data: { prenom?: string; nom?: string }
) => {
  return await prisma.utilisateur.update({
    where: { id: userId },
    data: {
      ...(data.prenom ? { prenom: data.prenom.trim() } : {}),
      ...(data.nom    ? { nom:    data.nom.trim()    } : {}),
    },
    select: { id: true, nom: true, prenom: true, email: true },
  });
};

// ─── UPDATE MOT DE PASSE (vérifie l'ancien via bcrypt) ────────────────────

export const updateUserPassword = async (
  userId: string,
  oldPassword: string,
  newPassword: string
) => {
  // 1. Récupère le hash bcrypt stocké en BDD
  const user = await prisma.utilisateur.findUnique({
    where:  { id: userId },
    select: { motdepasse: true },
  });
  if (!user) throw new Error('Utilisateur introuvable');

  // 2. Compare l'ancien mdp entré avec le hash — bcrypt ne déchiffre pas,
  //    il rehash le mdp entré et compare les deux hash
  const isMatch = await bcrypt.compare(oldPassword, user.motdepasse);
  if (!isMatch) throw new Error('Ancien mot de passe incorrect');

  // 3. Hash le nouveau mdp et sauvegarde
  const hashed = await bcrypt.hash(newPassword, 10);
  await prisma.utilisateur.update({
    where: { id: userId },
    data:  { motdepasse: hashed },
  });
};

// ─── REQUEST EMAIL CHANGE — envoie OTP au nouvel email ────────────────────

export const requestUserEmailChange = async (userId: string, newEmail: string) => {
  const existing = await prisma.utilisateur.findUnique({
    where: { email: newEmail.trim() },
  });
  if (existing) throw new Error('Cet email est déjà utilisé par un autre compte');

  const user = await prisma.utilisateur.findUnique({
    where:  { id: userId },
    select: { prenom: true },
  });
  if (!user) throw new Error('Utilisateur introuvable');

  const code = await savePendingRegistration(
    `email_change:${userId}`,
    '',
    newEmail.trim(),
    ''
  );

  await sendVerificationEmail(newEmail.trim(), user.prenom, code);
};

// ─── CONFIRM EMAIL CHANGE — vérifie OTP et met à jour ────────────────────

export const confirmUserEmailChange = async (
  userId: string,
  newEmail: string,
  code: string
) => {
  const pending = getPendingRegistration(newEmail.trim());
  if (!pending) throw new Error('Aucune demande en attente pour cet email');

  if (Date.now() > pending.expiresAt) {
    deletePendingRegistration(newEmail.trim());
    throw new Error('Le code a expiré, veuillez recommencer');
  }

  if (pending.attempts >= 3) {
    deletePendingRegistration(newEmail.trim());
    throw new Error('Nombre de tentatives dépassé, veuillez recommencer');
  }

  const isMatch = await bcrypt.compare(code, pending.hashedCode);
  if (!isMatch) {
    incrementAttempts(newEmail.trim());
    const remaining = 3 - (pending.attempts + 1);
    throw new Error(`Code incorrect, il vous reste ${remaining} tentative(s)`);
  }

  await prisma.utilisateur.update({
    where: { id: userId },
    data:  { email: newEmail.trim() },
  });

  deletePendingRegistration(newEmail.trim());
};