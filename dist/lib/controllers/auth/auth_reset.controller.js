"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.forgotPassword = forgotPassword;
exports.verifyResetCode = verifyResetCode;
exports.resetPassword = resetPassword;
const client_1 = require("@prisma/client");
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const email_service_1 = require("../../service/auth/email.service");
const prisma = new client_1.PrismaClient();
// ✅ Store pour les userId dont l'OTP a été vérifié
const verifiedResets = new Set();
// ── POST /api/auth/forgot-password
async function forgotPassword(req, res) {
    try {
        const { email } = req.body;
        if (!email) {
            res.status(400).json({ success: false, message: 'Email manquant' });
            return;
        }
        const user = await prisma.utilisateur.findUnique({
            where: { email: email.trim().toLowerCase() },
        });
        if (!user) {
            res.status(200).json({ success: true, message: 'Si cet email existe, un code a été envoyé.' });
            return;
        }
        await (0, email_service_1.sendResetPasswordEmail)(user.id, user.email, user.prenom);
        res.status(200).json({
            success: true,
            message: 'Code envoyé à votre email.',
            userId: user.id,
        });
    }
    catch (error) {
        res.status(500).json({
            success: false,
            message: error instanceof Error ? error.message : 'Erreur serveur',
        });
    }
}
// ── POST /api/auth/verify-reset-otp
async function verifyResetCode(req, res) {
    try {
        const { userId, code } = req.body;
        if (!userId || !code) {
            res.status(400).json({ success: false, message: 'Données manquantes' });
            return;
        }
        const isValid = (0, email_service_1.verifyResetOTP)(userId, code);
        if (!isValid) {
            res.status(400).json({ success: false, message: 'Code invalide ou expiré' });
            return;
        }
        // ✅ Marquer cet userId comme vérifié
        verifiedResets.add(userId);
        res.status(200).json({ success: true, message: 'Code vérifié' });
    }
    catch (error) {
        res.status(500).json({
            success: false,
            message: error instanceof Error ? error.message : 'Erreur serveur',
        });
    }
}
// ── POST /api/auth/reset-password
async function resetPassword(req, res) {
    try {
        const { userId, newPassword } = req.body;
        if (!userId || !newPassword) {
            res.status(400).json({ success: false, message: 'Données manquantes' });
            return;
        }
        if (newPassword.length < 6) {
            res.status(400).json({
                success: false,
                message: 'Le mot de passe doit contenir au moins 6 caractères',
            });
            return;
        }
        // ✅ Vérifier que l'OTP a bien été validé à l'étape 2
        if (!verifiedResets.has(userId)) {
            res.status(400).json({ success: false, message: 'Vérification requise' });
            return;
        }
        // Hash + update BDD
        const hashed = await bcryptjs_1.default.hash(newPassword, 10);
        await prisma.utilisateur.update({
            where: { id: userId },
            data: { motdepasse: hashed },
        });
        // ✅ Nettoyer le store après usage
        verifiedResets.delete(userId);
        res.status(200).json({
            success: true,
            message: 'Mot de passe réinitialisé avec succès',
        });
    }
    catch (error) {
        res.status(500).json({
            success: false,
            message: error instanceof Error ? error.message : 'Erreur serveur',
        });
    }
}
