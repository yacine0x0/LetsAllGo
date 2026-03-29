import { Request, Response } from 'express';
import { loginService, registerService } from '../loginservices/AuthService';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import 'dotenv/config';

export const login = async (req: Request, res: Response): Promise<void> => {
  const { email, password } = req.body;

  if (!email || !password) {
    res.status(400).json({ message: 'Email et mot de passe requis' });
    return;
  }

  try {
    // 1 — Récupérer l'utilisateur via le service
    const user = await loginService(email);

    if (!user) {
      res.status(401).json({ message: 'Email ou mot de passe incorrect' });
      return;
    }

    // 2 — Vérifier le mot de passe (logique)
    const isValid = await bcrypt.compare(password, user.motdepasse);
    if (!isValid) {
      res.status(401).json({ message: 'Email ou mot de passe incorrect' });
      return;
    }

    // 3 — Générer le token JWT (logique)
    const token = jwt.sign(
      { userId: user.id, email: user.email, role: user.role },
      process.env.JWT_SECRET as string,
      { expiresIn: '7d' }
    );

    res.status(200).json({
      token,
      userId: user.id,
      nom: user.nom,
      prenom: user.prenom,
      role: user.role,
    });
  } catch (error) {
    console.error('LOGIN ERROR:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

export const register = async (req: Request, res: Response): Promise<void> => {
  const { nom, prenom, email, password } = req.body;

  if (!nom || !prenom || !email || !password) {
    res.status(400).json({ message: 'Tous les champs sont requis' });
    return;
  }

  try {
    // 1 — Vérifier si l'email existe via le service
    const existing = await loginService(email);
    if (existing) {
      res.status(409).json({ message: 'Email déjà utilisé' });
      return;
    }

    // 2 — Hasher le mot de passe (logique)
    const hashed = await bcrypt.hash(password, 10);

    // 3 — Créer l'utilisateur via le service
    const user = await registerService(nom, prenom, email, hashed);

    res.status(201).json({ message: 'Compte créé', userId: user.id });
  } catch (error) {
    console.error('REGISTER ERROR:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};