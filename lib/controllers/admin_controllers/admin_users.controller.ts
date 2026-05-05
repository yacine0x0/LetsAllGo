import { Response } from 'express';
import { AuthRequest } from '../../middlewares/auth.middleware';
import {
  getAllStudents,
  deleteStudent,
  searchStudents,
  blockStudent,
  unblockStudent,
} from '../../service/admin/admin_users.service';

// ── GET /api/admin/users — récupérer tous les étudiants
export async function getUsers(
  req: AuthRequest,
  res: Response
): Promise<void> {
  try {
    const query = req.query.search as string | undefined;

    const students = query && query.trim() !== ''
      ? await searchStudents(query.trim())
      : await getAllStudents();

    res.status(200).json({
      success: true,
      data:    students,
      total:   students.length,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error instanceof Error ? error.message : 'Erreur serveur',
    });
  }
}

// ── DELETE /api/admin/users/:id — supprimer un étudiant
export async function deleteUser(
  req: AuthRequest,
  res: Response
): Promise<void> {
  try {
    const { id } = req.params;

    // Validation de l'ID
    if (!id || typeof id !== 'string' || id.trim() === '') {
      res.status(400).json({ 
        success: false, 
        message: 'ID manquant ou invalide' 
      });
      return;
    }

    // Appel du service (id est string, comme attendu dans le service)
    await deleteStudent(id.trim());

    res.status(200).json({
      success: true,
      message: 'Étudiant supprimé avec succès',
    });
  } catch (error) {
    console.error('Erreur lors de la suppression:', error);

    const message = error instanceof Error 
      ? error.message 
      : 'Erreur lors de la suppression de l\'étudiant';

    res.status(400).json({
      success: false,
      message,
    });
  }
}

export async function blockUser(
  req: AuthRequest,
  res: Response
): Promise<void> {
  try {
    if (req.userRole !== 'admin') {
      res.status(403).json({ success: false, message: 'Acces refuse' });
      return;
    }

    const { id } = req.params;
    if (!id || typeof id !== 'string' || id.trim() === '') {
      res.status(400).json({ success: false, message: 'ID manquant ou invalide' });
      return;
    }

    await blockStudent(req.userId ?? '', id.trim());
    res.status(200).json({ success: true, message: 'Utilisateur bloque avec succes' });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error instanceof Error ? error.message : 'Erreur lors du blocage',
    });
  }
}

export async function unblockUser(
  req: AuthRequest,
  res: Response
): Promise<void> {
  try {
    if (req.userRole !== 'admin') {
      res.status(403).json({ success: false, message: 'Acces refuse' });
      return;
    }

    const { id } = req.params;
    if (!id || typeof id !== 'string' || id.trim() === '') {
      res.status(400).json({ success: false, message: 'ID manquant ou invalide' });
      return;
    }

    await unblockStudent(id.trim());
    res.status(200).json({ success: true, message: 'Utilisateur debloque avec succes' });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error instanceof Error ? error.message : 'Erreur lors du deblocage',
    });
  }
}