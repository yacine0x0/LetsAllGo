"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.searchStudents = exports.deleteStudent = exports.getAllStudents = void 0;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
// ── Récupérer tous les étudiants triés par score
const getAllStudents = async () => {
    const students = await prisma.utilisateur.findMany({
        where: { role: 'etudiant' },
        select: {
            id: true,
            nom: true,
            prenom: true,
            email: true,
            scoretotal: true,
            rang: true,
            dateinscription: true,
        },
        orderBy: { scoretotal: 'desc' },
    });
    return students.map((s, index) => ({
        rank: index + 1,
        id: s.id,
        firstName: s.prenom,
        lastName: s.nom,
        email: s.email,
        totalPoints: s.scoretotal ?? 0,
        rang: s.rang,
        enrolledAt: s.dateinscription,
    }));
};
exports.getAllStudents = getAllStudents;
// ── Supprimer un étudiant
const deleteStudent = async (userId) => {
    const user = await prisma.utilisateur.findUnique({
        where: { id: userId },
    });
    if (!user)
        throw new Error('Utilisateur introuvable');
    if (user.role === 'admin')
        throw new Error('Impossible de supprimer un admin');
    await prisma.utilisateur.delete({
        where: { id: userId },
    });
};
exports.deleteStudent = deleteStudent;
// ── Rechercher des étudiants
const searchStudents = async (query) => {
    const students = await prisma.utilisateur.findMany({
        where: {
            role: 'etudiant',
            OR: [
                { nom: { contains: query, mode: 'insensitive' } },
                { prenom: { contains: query, mode: 'insensitive' } },
                { email: { contains: query, mode: 'insensitive' } },
            ],
        },
        select: {
            id: true,
            nom: true,
            prenom: true,
            email: true,
            scoretotal: true,
            rang: true,
            dateinscription: true,
        },
        orderBy: { scoretotal: 'desc' },
    });
    return students.map((s, index) => ({
        rank: index + 1,
        id: s.id,
        firstName: s.prenom,
        lastName: s.nom,
        email: s.email,
        totalPoints: s.scoretotal ?? 0,
        rang: s.rang,
        enrolledAt: s.dateinscription,
    }));
};
exports.searchStudents = searchStudents;
