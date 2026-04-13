import { Router } from 'express';
import { requireAuth } from '../middlewares/auth.middleware';
import { getAdminMe, updateAdminMe } from '../controllers/admin_controllers/admin_profil_controller';

const router = Router();

router.get('/me',  requireAuth, getAdminMe);
router.put('/me',  requireAuth, updateAdminMe);

export default router;