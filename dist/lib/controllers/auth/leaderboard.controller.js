"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getLeaderboardData = getLeaderboardData;
const leaderboard_service_1 = require("../../service/leaderboard/leaderboard.service");
async function getLeaderboardData(req, res) {
    try {
        const result = await (0, leaderboard_service_1.getLeaderboardWithUser)(req.userId);
        res.status(200).json({
            success: true,
            data: result,
        });
    }
    catch (error) {
        res.status(500).json({
            success: false,
            message: error instanceof Error ? error.message : 'Erreur serveur',
        });
    }
}
