import { Router } from 'express';
import { login, register, verifyEmail } from '../controllers/auth/AuthController';
import { forgotPassword, verifyResetCode, resetPassword }

  from '../controllers/auth/auth_reset.controller';
// Ajouter ces 3 routes

const router = Router();

router.post('/forgot-password',    forgotPassword);
router.post('/verify-reset-otp',   verifyResetCode);
router.post('/reset-password',     resetPassword);
router.post('/login',         login);
router.post('/register',      register);
router.post('/verify-email',  verifyEmail);

export default router;