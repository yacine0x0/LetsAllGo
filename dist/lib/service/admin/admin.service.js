"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateAdminProfile = exports.getAdminById = void 0;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
const getAdminById = async (userId) => {
    const user = await prisma.utilisateur.findUnique({
        where: { id: userId },
        select: {
            id: true,
            nom: true,
            prenom: true,
            email: true,
            role: true,
            dateinscription: true,
        },
    });
    if (!user)
        throw new Error('Admin introuvable');
    if (user.role !== 'admin')
        throw new Error('Accès refusé');
    return user;
};
exports.getAdminById = getAdminById;
const updateAdminProfile = async (userId, data) => {
    const updated = await prisma.utilisateur.update({
        where: { id: userId },
        data: {
            nom: data.nom?.trim(),
            prenom: data.prenom?.trim(),
            email: data.email?.trim(),
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
exports.updateAdminProfile = updateAdminProfile;
