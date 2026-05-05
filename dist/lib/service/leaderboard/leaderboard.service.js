"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getLeaderboardWithUser = exports.getLeaderboard = void 0;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
const getLeaderboard = async () => {
    // ✅ Filtre uniquement les étudiants
    const users = await prisma.utilisateur.findMany({
        where: {
            role: 'etudiant',
        },
        select: {
            id: true,
            nom: true,
            prenom: true,
            scoretotal: true,
            rang: true,
        },
        orderBy: { scoretotal: 'desc' },
        take: 15,
    });
    return users.map((user, index) => ({
        rank: index + 1,
        username: `${user.prenom} ${user.nom}`,
        totalPoints: user.scoretotal ?? 0,
        algo1Progress: 0.0,
        algo2Progress: 0.0,
        avatarInitial: user.prenom[0].toUpperCase(),
        userId: user.id,
    }));
};
exports.getLeaderboard = getLeaderboard;
const getLeaderboardWithUser = async (userId) => {
    const entries = await (0, exports.getLeaderboard)();
    const currentUser = entries.find(e => e.userId === userId) ?? null;
    return { entries, currentUser };
};
exports.getLeaderboardWithUser = getLeaderboardWithUser;
