"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getMe = getMe;
exports.updateMe = updateMe;
exports.updatePassword = updatePassword;
exports.requestEmailChange = requestEmailChange;
exports.confirmEmailChange = confirmEmailChange;
const user_service_1 = require("../../service/auth/user.service");
// GET /api/users/me
async function getMe(req, res) {
    try {
        const user = await (0, user_service_1.getUserById)(req.userId);
        console.log('📤 Réponse API:', JSON.stringify(user, null, 2));
        res.status(200).json(user);
    }
    catch (error) {
        res.status(404).json({
            message: error instanceof Error ? error.message : 'Erreur serveur',
        });
    }
}
// PATCH /api/users/me
async function updateMe(req, res) {
    try {
        const { prenom, nom } = req.body;
        if (!prenom && !nom) {
            res.status(400).json({ message: 'Aucune donnée à mettre à jour' });
            return;
        }
        const updated = await (0, user_service_1.updateUserName)(req.userId, { prenom, nom });
        res.status(200).json(updated);
    }
    catch (error) {
        res.status(500).json({
            message: error instanceof Error ? error.message : 'Erreur serveur',
        });
    }
}
// PATCH /api/users/me/password
async function updatePassword(req, res) {
    try {
        const { oldPassword, newPassword } = req.body;
        if (!oldPassword || !newPassword) {
            res.status(400).json({ message: 'Champs manquants' });
            return;
        }
        if (newPassword.length < 6) {
            res.status(400).json({ message: 'Le mot de passe doit contenir au moins 6 caractères' });
            return;
        }
        await (0, user_service_1.updateUserPassword)(req.userId, oldPassword, newPassword);
        res.status(200).json({ message: 'Mot de passe mis à jour' });
    }
    catch (error) {
        const msg = error instanceof Error ? error.message : 'Erreur serveur';
        const status = msg.includes('incorrect') ? 401 : 500;
        res.status(status).json({ message: msg });
    }
}
// POST /api/users/me/email/request
async function requestEmailChange(req, res) {
    try {
        const { newEmail } = req.body;
        if (!newEmail || !newEmail.includes('@')) {
            res.status(400).json({ message: 'Email invalide' });
            return;
        }
        await (0, user_service_1.requestUserEmailChange)(req.userId, newEmail);
        res.status(200).json({ message: 'Code de vérification envoyé' });
    }
    catch (error) {
        const msg = error instanceof Error ? error.message : 'Erreur serveur';
        const status = msg.includes('déjà utilisé') ? 409 : 500;
        res.status(status).json({ message: msg });
    }
}
// POST /api/users/me/email/confirm
async function confirmEmailChange(req, res) {
    try {
        const { newEmail, code } = req.body;
        if (!newEmail || !code) {
            res.status(400).json({ message: 'Champs manquants' });
            return;
        }
        await (0, user_service_1.confirmUserEmailChange)(req.userId, newEmail, code);
        res.status(200).json({ message: 'Email mis à jour' });
    }
    catch (error) {
        res.status(400).json({
            message: error instanceof Error ? error.message : 'Erreur serveur',
        });
    }
}
