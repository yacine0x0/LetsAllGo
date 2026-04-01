import crypto from 'crypto';
import bcrypt from 'bcryptjs';

interface PendingRegistration {
  nom:          string;
  prenom:       string;
  email:        string;
  hashedPassword: string;
  hashedCode:   string;
  expiresAt:    number;
  attempts:     number;
}

const store = new Map<string, PendingRegistration>();

export async function savePendingRegistration(
  nom:      string,
  prenom:   string,
  email:    string,
  hashedPassword: string
): Promise<string> {
  const code       = crypto.randomInt(100000, 999999).toString();
  const hashedCode = await bcrypt.hash(code, 10);
  const expiresAt  = Date.now() + 5 * 60 * 1000;

  store.set(email, {
    nom,
    prenom,
    email,
    hashedPassword,
    hashedCode,
    expiresAt,
    attempts: 0,
  });

  return code;
}

export function getPendingRegistration(email: string): PendingRegistration | undefined {
  return store.get(email);
}

export function incrementAttempts(email: string): void {
  const entry = store.get(email);
  if (entry) {
    entry.attempts += 1;
    store.set(email, entry);
  }
}

export function deletePendingRegistration(email: string): void {
  store.delete(email);
}