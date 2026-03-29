// ─────────────────────────────────────────
// SERVICE : auth.service.ts
// src/loginservices/auth.service.ts
// ─────────────────────────────────────────

import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { LoginInput, RegisterInput, AuthResponse } from '../loginmodels/auth.model';

const prisma = new PrismaClient();

// ── Helper JWT
function signToken(userId: string, email: string, role: string): string {
  return jwt.sign(
    { id: userId, email, role },
    process.env.JWT_SECRET!,
    { expiresIn: (process.env.JWT_EXPIRES_IN ?? '7d') as jwt.SignOptions['expiresIn'] }
  );
}

// ── Login
export const loginService = async (input: LoginInput): Promise<AuthResponse> => {
  // 1. Chercher l'utilisateur par email
  const user = await prisma.utilisateur.findUnique({
    where: { email: input.email.trim() },
  });

  if (!user) throw new Error('Email ou mot de passe incorrect');

  // 2. Vérifier le mot de passe
  const isMatch = await bcrypt.compare(input.password, user.motdepasse);
  if (!isMatch) throw new Error('Email ou mot de passe incorrect');

  // 3. Générer le token JWT
  const token = signToken(user.id, user.email, user.role ?? 'etudiant');

  return {
    token,
    user: {
      id:              user.id,
      nom:             user.nom,
      prenom:          user.prenom,
      email:           user.email,
      role:            user.role ?? 'etudiant',
      dateinscription: user.dateinscription,
      scoretotal:      user.scoretotal,
      rang:            user.rang,
    },
  };
};

// ── Register
export const registerService = async (input: RegisterInput): Promise<AuthResponse> => {
  // 1. Vérifier si l'email existe déjà
  const existing = await prisma.utilisateur.findUnique({
    where: { email: input.email.trim() },
  });
  if (existing) throw new Error('Un compte avec cet email existe déjà');

  // 2. Hasher le mot de passe
  const hashedPassword = await bcrypt.hash(input.password, 10);

  // 3. Créer l'utilisateur
  const newUser = await prisma.utilisateur.create({
    data: {
      nom:       input.nom.trim(),
      prenom:    input.prenom.trim(),
      email:     input.email.trim(),
      motdepasse: hashedPassword,
      role:      'etudiant',
    },
  });

  // 4. Générer le token JWT
  const token = signToken(newUser.id, newUser.email, newUser.role ?? 'etudiant');

  return {
    token,
    user: {
      id:              newUser.id,
      nom:             newUser.nom,
      prenom:          newUser.prenom,
      email:           newUser.email,
      role:            newUser.role ?? 'etudiant',
      dateinscription: newUser.dateinscription,
      scoretotal:      newUser.scoretotal,
      rang:            newUser.rang,
    },
  };
};