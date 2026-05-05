"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.login = login;
exports.register = register;
exports.verifyEmail = verifyEmail;
const AuthService_1 = require("../../service/auth/AuthService");
const auth_model_1 = require("../../models/auth/auth.model");
async function login(req, res) {
    try {
        const input = req.body;
        const validationError = (0, auth_model_1.validateLoginInput)(input);
        if (validationError) {
            res.status(400).json({ success: false, message: validationError });
            return;
        }
        const result = await (0, AuthService_1.loginService)(input);
        res.status(200).json({
            success: true,
            message: 'Connexion réussie',
            token: result.token,
            userId: result.user.id,
            nom: result.user.nom,
            prenom: result.user.prenom,
            role: result.user.role,
            data: result,
        });
    }
    catch (error) {
        res.status(401).json({
            success: false,
            message: error instanceof Error ? error.message : 'Erreur serveur',
        });
    }
}
async function register(req, res) {
    try {
        const input = req.body;
        const validationError = (0, auth_model_1.validateRegisterInput)(input);
        if (validationError) {
            res.status(400).json({ success: false, message: validationError });
            return;
        }
        const result = await (0, AuthService_1.registerService)(input);
        res.status(200).json({
            success: true,
            message: result.message,
        });
    }
    catch (error) {
        res.status(400).json({
            success: false,
            message: error instanceof Error ? error.message : 'Erreur serveur',
        });
    }
}
async function verifyEmail(req, res) {
    try {
        const input = req.body;
        const validationError = (0, auth_model_1.validateVerifyEmailInput)(input);
        if (validationError) {
            res.status(400).json({ success: false, message: validationError });
            return;
        }
        const result = await (0, AuthService_1.verifyEmailService)(input);
        res.status(201).json({
            success: true,
            message: 'Compte créé avec succès',
            token: result.token,
            userId: result.user.id,
            nom: result.user.nom,
            prenom: result.user.prenom,
            role: result.user.role,
            data: result,
        });
    }
    catch (error) {
        res.status(400).json({
            success: false,
            message: error instanceof Error ? error.message : 'Erreur serveur',
        });
    }
}
