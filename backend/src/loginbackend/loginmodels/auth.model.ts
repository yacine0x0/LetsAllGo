// ─────────────────────────────────────────
// MODEL : auth.model.ts
// src/loginmodels/auth.model.ts
// ─────────────────────────────────────────

export interface LoginInput {
  email: string;
  password: string;
}

export interface RegisterInput {
  nom: string;
  prenom: string;
  email: string;
  password: string;
}

export interface UserPublic {
  id: string;
  nom: string;
  prenom: string;
  email: string;
  role: string;
  dateinscription: Date | null;
  scoretotal: number | null;
  rang: number | null;
}

export interface AuthResponse {
  token: string;
  user: UserPublic;
}

// ── Validation
function isValidEmail(email: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

export function validateLoginInput(input: LoginInput): string | null {
  if (!input.email || !isValidEmail(input.email.trim())) {
    return "Email invalide";
  }
  if (!input.password || input.password.length < 6) {
    return "Le mot de passe doit contenir au moins 6 caractères";
  }
  return null;
}

export function validateRegisterInput(input: RegisterInput): string | null {
  if (!input.nom || input.nom.trim().length < 2) {
    return "Le nom doit contenir au moins 2 caractères";
  }
  if (!input.prenom || input.prenom.trim().length < 2) {
    return "Le prénom doit contenir au moins 2 caractères";
  }
  if (!input.email || !isValidEmail(input.email.trim())) {
    return "Email invalide";
  }
  if (!input.password || input.password.length < 6) {
    return "Le mot de passe doit contenir au moins 6 caractères";
  }
  return null;
}