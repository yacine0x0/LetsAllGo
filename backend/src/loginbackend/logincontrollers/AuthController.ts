// ─────────────────────────────────────────
// CONTROLLER : AuthController.ts
// src/logincontrollers/AuthController.ts
// ─────────────────────────────────────────

import { Request, Response } from 'express';
import { loginService, registerService } from '../loginservices/AuthService';
import { LoginInput, RegisterInput } from '../loginmodels/auth.model';

// ── POST /api/auth/login
export async function login(req: Request, res: Response): Promise<void> {
  try {
    const input: LoginInput = req.body;
    const result = await loginService(input);

    res.status(200).json({
      success: true,
      message: 'Connexion réussie',
      token:   result.token,
      userId:  result.user.id,
      nom:     result.user.nom,
      prenom:  result.user.prenom,
      role:    result.user.role,
      data:    result,
    });
  } catch (error) {
    res.status(401).json({
      success: false,
      message: error instanceof Error ? error.message : 'Erreur serveur',
    });
  }
}

// ── POST /api/auth/register
export async function register(req: Request, res: Response): Promise<void> {
  try {
    const input: RegisterInput = req.body;
    const result = await registerService(input);

    res.status(201).json({
      success: true,
      message: 'Compte créé avec succès',
      token:   result.token,
      userId:  result.user.id,
      nom:     result.user.nom,
      prenom:  result.user.prenom,
      role:    result.user.role,
      data:    result,
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error instanceof Error ? error.message : 'Erreur serveur',
    });
  }
}