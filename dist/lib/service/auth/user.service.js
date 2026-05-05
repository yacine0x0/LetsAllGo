"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.confirmUserEmailChange = exports.requestUserEmailChange = exports.updateUserPassword = exports.updateUserName = exports.getUserById = void 0;
const client_1 = require("@prisma/client");
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const email_service_1 = require("./email.service");
const prisma = new client_1.PrismaClient();
// Store OTP email change
const otpStore = new Map();
// ── GET user avec TOUTES les statistiques
const getUserById = async (userId) => {
    // 1. Récupérer l'utilisateur
    const user = await prisma.utilisateur.findUnique({
        where: { id: userId },
        select: {
            id: true,
            nom: true,
            prenom: true,
            email: true,
            role: true,
            dateinscription: true,
            scoretotal: true,
            rang: true,
        },
    });
    if (!user)
        throw new Error('Utilisateur introuvable');
    // 2. Calculer le vrai rang basé sur scoretotal
    const usersAvecScoreSuperieur = await prisma.utilisateur.count({
        where: {
            role: 'etudiant',
            scoretotal: { gt: user.scoretotal ?? 0 },
        },
    });
    const vraiRang = usersAvecScoreSuperieur + 1;
    // 3. Mettre à jour le rang si différent
    if (user.rang !== vraiRang) {
        await prisma.utilisateur.update({
            where: { id: userId },
            data: { rang: vraiRang },
        });
    }
    // 5. Calculer le nombre de quiz réussis et questions correctes
    const passesUser = await prisma.passe.findMany({
        where: { id_etudiant: userId },
        include: { quizz: true },
    });
    const quizReussis = passesUser.filter((p) => (p.quizz?.score ?? 0) > 0).length;
    const totalQuestionsCorrectes = passesUser.reduce((sum, p) => sum + (p.quizz?.score ?? 0), 0);
    // 7. Spécialité et niveau (valeurs par défaut)
    const speciality = 'Informatique';
    const studyLevel = 'L3';
    console.log(`📊 Statistiques de ${user.prenom} ${user.nom}:`);
    console.log(`  - Score total: ${user.scoretotal ?? 0} XP`);
    console.log(`  - Rang: ${vraiRang}`);
    console.log(`  - Quiz réussis: ${quizReussis}`);
    console.log(`  - Questions correctes: ${totalQuestionsCorrectes}`);
    // 🔥 RETOURNE TOUS LES CHAMPS ATTENDUS PAR FLUTTER
    return {
        id: user.id,
        nom: user.nom,
        prenom: user.prenom,
        email: user.email,
        role: user.role,
        dateinscription: user.dateinscription,
        scoretotal: user.scoretotal ?? 0,
        rang: vraiRang,
        quizReussis: quizReussis,
        totalQuestionsCorrectes: totalQuestionsCorrectes,
        speciality: speciality,
        studyLevel: studyLevel,
    };
};
exports.getUserById = getUserById;
// ── UPDATE nom / prénom
const updateUserName = async (userId, data) => {
    const updated = await prisma.utilisateur.update({
        where: { id: userId },
        data: {
            ...(data.prenom && { prenom: data.prenom.trim() }),
            ...(data.nom && { nom: data.nom.trim() }),
        },
        select: {
            id: true,
            nom: true,
            prenom: true,
            email: true,
            role: true,
        },
    });
    return updated;
};
exports.updateUserName = updateUserName;
// ── UPDATE mot de passe
const updateUserPassword = async (userId, oldPassword, newPassword) => {
    const user = await prisma.utilisateur.findUnique({
        where: { id: userId },
        select: { motdepasse: true },
    });
    if (!user)
        throw new Error('Utilisateur introuvable');
    const isValid = await bcryptjs_1.default.compare(oldPassword, user.motdepasse);
    if (!isValid)
        throw new Error('Ancien mot de passe incorrect');
    const hashed = await bcryptjs_1.default.hash(newPassword, 10);
    await prisma.utilisateur.update({
        where: { id: userId },
        data: { motdepasse: hashed },
    });
};
exports.updateUserPassword = updateUserPassword;
// ── REQUEST email change
const requestUserEmailChange = async (userId, newEmail) => {
    const normalizedEmail = newEmail.trim().toLowerCase();
    const existing = await prisma.utilisateur.findUnique({
        where: { email: normalizedEmail },
    });
    if (existing && existing.id !== userId) {
        throw new Error('Cet email est déjà utilisé');
    }
    const code = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000);
    otpStore.set(userId, { code, expiresAt });
    const user = await prisma.utilisateur.findUnique({
        where: { id: userId },
        select: { prenom: true, nom: true },
    });
    if (!user) {
        throw new Error('Utilisateur introuvable');
    }
    const recipientName = user.prenom?.toString().trim() ||
        user.nom?.toString().trim() ||
        'Utilisateur';
    await (0, email_service_1.sendVerificationEmail)(normalizedEmail, recipientName, code);
    console.log(`✅ OTP email change envoyé à ${normalizedEmail}: ${code}`);
    return { code, expiresAt };
};
exports.requestUserEmailChange = requestUserEmailChange;
// ── CONFIRM email change
const confirmUserEmailChange = async (userId, newEmail, code) => {
    const stored = otpStore.get(userId);
    if (!stored)
        throw new Error('Code expiré ou invalide');
    if (new Date() > stored.expiresAt) {
        otpStore.delete(userId);
        throw new Error('Code expiré');
    }
    if (stored.code !== code)
        throw new Error('Code invalide');
    otpStore.delete(userId);
    await prisma.utilisateur.update({
        where: { id: userId },
        data: { email: newEmail.trim().toLowerCase() },
    });
    console.log(`✅ Email mis à jour: ${newEmail}`);
};
exports.confirmUserEmailChange = confirmUserEmailChange;
