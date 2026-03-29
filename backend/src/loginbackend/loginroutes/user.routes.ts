import { Router } from 'express';
import { requireAuth } from '../loginmiddlewares/auth.middleware';
import { getMe } from '../logincontrollers/usercontroller'; 

const router = Router();

router.get('/me', requireAuth, getMe);

export default router;