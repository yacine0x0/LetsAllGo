"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// lib/routes/quiz.routes.ts
const express_1 = require("express");
const client_1 = require("@prisma/client");
const auth_middleware_1 = require("../middlewares/auth.middleware");
const quiz_controller_1 = require("../controllers/quiz/quiz.controller");
const router = (0, express_1.Router)();
const prisma = new client_1.PrismaClient();
// POST /api/quiz/submit
router.post('/submit', auth_middleware_1.requireAuth, quiz_controller_1.submitQuiz);
// GET /api/quiz/total-questions/:userId
router.get('/total-questions/:userId', auth_middleware_1.requireAuth, async (req, res) => {
    try {
        const { userId } = req.params;
        // Requête SQL directe avec typage correct
        const result = await prisma.$queryRaw `
      SELECT COALESCE(SUM(q."nombrequestionsfaites"), 0) as total
      FROM "quizz" q
      INNER JOIN "passe" p ON q."id_quiz" = p."id_quiz"
      WHERE p."id_etudiant" = ${userId}::uuid
    `;
        const total = result[0]?.total ?? 0;
        res.json({
            success: true,
            total: Number(total)
        });
    }
    catch (error) {
        console.error('Erreur détaillée:', error);
        res.status(500).json({
            success: false,
            message: 'Erreur lors du calcul des statistiques'
        });
    }
});
exports.default = router;
