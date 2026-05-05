"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_middleware_1 = require("../middlewares/auth.middleware");
const leaderboard_controller_1 = require("../controllers/auth/leaderboard.controller");
const router = (0, express_1.Router)();
// GET /api/leaderboard → requireAuth → getLeaderboardData
router.get('/', auth_middleware_1.requireAuth, leaderboard_controller_1.getLeaderboardData);
exports.default = router;
