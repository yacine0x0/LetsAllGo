import { Request, Response } from 'express';
import { loginService, registerService, verifyEmailService } from '../../service/AuthService';
import { LoginInput, RegisterInput, VerifyEmailInput, validateLoginInput, validateRegisterInput, validateVerifyEmailInput } from '../../models/auth/auth.model';

export async function login(req: Request, res: Response): Promise<void> {
  try {
    const input: LoginInput = req.body;

    const validationError = validateLoginInput(input);
    if (validationError) {
      res.status(400).json({ success: false, message: validationError });
      return;
    }

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

export async function register(req: Request, res: Response): Promise<void> {
  try {
    const input: RegisterInput = req.body;

    const validationError = validateRegisterInput(input);
    if (validationError) {
      res.status(400).json({ success: false, message: validationError });
      return;
    }

    const result = await registerService(input);
    res.status(200).json({
      success: true,
      message: result.message,
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error instanceof Error ? error.message : 'Erreur serveur',
    });
  }
}

export async function verifyEmail(req: Request, res: Response): Promise<void> {
  try {
    const input: VerifyEmailInput = req.body;

    const validationError = validateVerifyEmailInput(input);
    if (validationError) {
      res.status(400).json({ success: false, message: validationError });
      return;
    }

    const result = await verifyEmailService(input);
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