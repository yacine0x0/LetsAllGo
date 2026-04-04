import { Router } from 'express';
import { requireAuth } from '../middlewares/auth.middleware';
import { getMe, updateMe, updatePassword, requestEmailChange, confirmEmailChange } from '../controllers/auth/usercontroller';

const router = Router();

router.get('/me',                requireAuth, getMe);
router.patch('/me',              requireAuth, updateMe);
router.patch('/me/password',     requireAuth, updatePassword);
router.post('/me/email/request', requireAuth, requestEmailChange);
router.post('/me/email/confirm', requireAuth, confirmEmailChange);

export default router;