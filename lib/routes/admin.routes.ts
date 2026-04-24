import { Router } from 'express';
import { requireAuth } from '../middlewares/auth.middleware';
import { getAdminMe, updateAdminMe } from '../controllers/admin_controllers/admin_profil_controller';
import { getUsers, deleteUser } from '../controllers/admin_controllers/admin_users.controller'; // 🆕

const router = Router();

// ── Profil admin
router.get('/me',  requireAuth, getAdminMe);
router.put('/me',  requireAuth, updateAdminMe);

// ── Gestion utilisateurs 🆕
router.get('/users',       requireAuth, getUsers);
router.delete('/users/:id', requireAuth, deleteUser);

export default router;