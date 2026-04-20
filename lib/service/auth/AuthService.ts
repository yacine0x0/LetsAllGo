import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { LoginInput, RegisterInput, AuthResponse, VerifyEmailInput } from '../../models/auth/auth.model';
import { savePendingRegistration, getPendingRegistration, incrementAttempts, deletePendingRegistration } from '../../utils/verificationStore';
import { sendVerificationEmail } from './email.service';

const prisma = new PrismaClient();

function signToken(userId: string, email: string, role: string): string {
  return jwt.sign(
    { id: userId, email, role },
    process.env.JWT_SECRET!,
    { expiresIn: (process.env.JWT_EXPIRES_IN ?? '7d') as jwt.SignOptions['expiresIn'] }
  );
}

export const loginService = async (input: LoginInput): Promise<AuthResponse> => {
  const user = await prisma.utilisateur.findUnique({
    where: { email: input.email.trim() },
  });
  if (!user) throw new Error('Email ou mot de passe incorrect');

  const isMatch = await bcrypt.compare(input.password, user.motdepasse);
  if (!isMatch) throw new Error('Email ou mot de passe incorrect');

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

export const registerService = async (input: RegisterInput): Promise<{ message: string }> => {
  // 1. Check if email already exists in the database
  const existing = await prisma.utilisateur.findUnique({
    where: { email: input.email.trim() },
  });
  if (existing) throw new Error('Un compte avec cet email existe déjà');

  // 2. Hash the password before storing it anywhere
  const hashedPassword = await bcrypt.hash(input.password, 10);

  // 3. Generate a verification code, store everything temporarily in memory
  const code = await savePendingRegistration(
    input.nom.trim(),
    input.prenom.trim(),
    input.email.trim(),
    hashedPassword
  );

  // 4. Send the verification email
  await sendVerificationEmail(input.email.trim(), input.nom.trim(), code);

  return { message: 'Un code de vérification a été envoyé à votre adresse email' };
};

export const verifyEmailService = async (input: VerifyEmailInput): Promise<AuthResponse> => {
  const email = input.email.trim();
  const pending = getPendingRegistration(email);

  // 1. Check if a pending registration exists for this email
  if (!pending) throw new Error('Aucune inscription en attente pour cet email');

  // 2. Check if the 5 minute window has expired
  if (Date.now() > pending.expiresAt) {
    deletePendingRegistration(email);
    throw new Error('Le code a expiré, veuillez recommencer l\'inscription');
  }

  // 3. Check if the user has exceeded 3 attempts
  if (pending.attempts >= 3) {
    deletePendingRegistration(email);
    throw new Error('Nombre de tentatives dépassé, veuillez recommencer l\'inscription');
  }

  // 4. Check if the code is correct
  const isMatch = await bcrypt.compare(input.code, pending.hashedCode);
  if (!isMatch) {
    incrementAttempts(email);
    const remaining = 3 - (pending.attempts + 1);
    throw new Error(`Code incorrect, il vous reste ${remaining} tentative(s)`);
  }

  // 5. Calculate rang — new user has scoretotal 0, so we find the current MAX rang
  //    among users with score 0 and add 1 to place the new user at the bottom
  const maxRang = await prisma.utilisateur.aggregate({
    _max:  { rang: true },
  });
  const newRang = (maxRang._max.rang ?? 0) + 1;

  // 6. Everything is valid — create the user row in the database
  const newUser = await prisma.utilisateur.create({
    data: {
      nom:        pending.nom,
      prenom:     pending.prenom,
      email:      pending.email,
      motdepasse: pending.hashedPassword,
      role:       'etudiant',
      scoretotal: 0,
      rang:       newRang,
    },
  });

  // 7. Clean up the temporary store
  deletePendingRegistration(email);

  // 8. Generate JWT and return — user is now logged in
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