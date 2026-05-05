"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.verifyEmailService = exports.registerService = exports.loginService = void 0;
const client_1 = require("@prisma/client");
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const verificationStore_1 = require("../../utils/verificationStore");
const email_service_1 = require("./email.service");
const prisma = new client_1.PrismaClient();
function signToken(userId, email, role) {
    return jsonwebtoken_1.default.sign({ id: userId, email, role }, process.env.JWT_SECRET, { expiresIn: (process.env.JWT_EXPIRES_IN ?? '7d') });
}
const loginService = async (input) => {
    const user = await prisma.utilisateur.findUnique({
        where: { email: input.email.trim() },
    });
    if (!user)
        throw new Error('Email ou mot de passe incorrect');
    const isMatch = await bcryptjs_1.default.compare(input.password, user.motdepasse);
    if (!isMatch)
        throw new Error('Email ou mot de passe incorrect');
    const token = signToken(user.id, user.email, user.role ?? 'etudiant');
    return {
        token,
        user: {
            id: user.id,
            nom: user.nom,
            prenom: user.prenom,
            email: user.email,
            role: user.role ?? 'etudiant',
            dateinscription: user.dateinscription,
            scoretotal: user.scoretotal,
            rang: user.rang,
        },
    };
};
exports.loginService = loginService;
const registerService = async (input) => {
    // 1. Check if email already exists in the database
    const existing = await prisma.utilisateur.findUnique({
        where: { email: input.email.trim() },
    });
    if (existing)
        throw new Error('Un compte avec cet email existe déjà');
    // 2. Hash the password before storing it anywhere
    const hashedPassword = await bcryptjs_1.default.hash(input.password, 10);
    // 3. Generate a verification code, store everything temporarily in memory
    const code = await (0, verificationStore_1.savePendingRegistration)(input.nom.trim(), input.prenom.trim(), input.email.trim(), hashedPassword);
    // 4. Send the verification email
    await (0, email_service_1.sendVerificationEmail)(input.email.trim(), input.nom.trim(), code);
    return { message: 'Un code de vérification a été envoyé à votre adresse email' };
};
exports.registerService = registerService;
const verifyEmailService = async (input) => {
    const email = input.email.trim();
    const pending = (0, verificationStore_1.getPendingRegistration)(email);
    // 1. Check if a pending registration exists for this email
    if (!pending)
        throw new Error('Aucune inscription en attente pour cet email');
    // 2. Check if the 5 minute window has expired
    if (Date.now() > pending.expiresAt) {
        (0, verificationStore_1.deletePendingRegistration)(email);
        throw new Error('Le code a expiré, veuillez recommencer l\'inscription');
    }
    // 3. Check if the user has exceeded 3 attempts
    if (pending.attempts >= 3) {
        (0, verificationStore_1.deletePendingRegistration)(email);
        throw new Error('Nombre de tentatives dépassé, veuillez recommencer l\'inscription');
    }
    // 4. Check if the code is correct
    const isMatch = await bcryptjs_1.default.compare(input.code, pending.hashedCode);
    if (!isMatch) {
        (0, verificationStore_1.incrementAttempts)(email);
        const remaining = 3 - (pending.attempts + 1);
        throw new Error(`Code incorrect, il vous reste ${remaining} tentative(s)`);
    }
    // 5. Calculate rang — new user has scoretotal 0, so we find the current MAX rang
    //    among users with score 0 and add 1 to place the new user at the bottom
    const maxRang = await prisma.utilisateur.aggregate({
        _max: { rang: true },
    });
    const newRang = (maxRang._max.rang ?? 0) + 1;
    // 6. Everything is valid — create the user row in the database
    const newUser = await prisma.utilisateur.create({
        data: {
            nom: pending.nom,
            prenom: pending.prenom,
            email: pending.email,
            motdepasse: pending.hashedPassword,
            role: 'etudiant',
            scoretotal: 0,
            rang: newRang,
        },
    });
    // 7. Clean up the temporary store
    (0, verificationStore_1.deletePendingRegistration)(email);
    // 8. Generate JWT and return — user is now logged in
    const token = signToken(newUser.id, newUser.email, newUser.role ?? 'etudiant');
    return {
        token,
        user: {
            id: newUser.id,
            nom: newUser.nom,
            prenom: newUser.prenom,
            email: newUser.email,
            role: newUser.role ?? 'etudiant',
            dateinscription: newUser.dateinscription,
            scoretotal: newUser.scoretotal,
            rang: newUser.rang,
        },
    };
};
exports.verifyEmailService = verifyEmailService;
