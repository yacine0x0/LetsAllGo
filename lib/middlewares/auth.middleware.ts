import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { isUserBlocked } from '../service/admin/blocked_users_store.service';

export interface AuthRequest extends Request {
  userId?: string;
  userRole?: string;
  userEmail?: string;
}

export async function requireAuth(
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    res.status(401).json({ success: false, message: 'Token manquant' });
    return;
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as {
      id: string;
      email: string;
      role: string;
    };

    req.userId    = decoded.id;
    req.userEmail = decoded.email;
    req.userRole  = decoded.role;

    if (await isUserBlocked(decoded.id)) {
      res.status(403).json({ success: false, message: 'Compte bloque par l administrateur' });
      return;
    }

    next();
  } catch {
    res.status(401).json({ success: false, message: 'Token invalide ou expiré' });
  }
}