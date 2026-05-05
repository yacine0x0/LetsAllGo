"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.completeChapter = exports.submitQuiz = void 0;
const client_1 = require("@prisma/client");
const globalForPrisma = global;
const prisma = globalForPrisma.prisma ?? new client_1.PrismaClient();
if (process.env.NODE_ENV !== 'production')
    globalForPrisma.prisma = prisma;
const GO_POINTS = {
    algo1: 250,
    algo2: 500,
};
const CHAPTER_MAP_ALGO1 = {
    'Chapitre 01': "Introduction à l'algorithmique",
    'Chapitre 02': 'Conditions',
    'Chapitre 03': 'Boucles',
    'Chapitre 04': 'Structures de données',
    'Chapitre 05': 'Sous-programmes',
};
const CHAPTER_MAP_ALGO2 = {
    'Chapitre 01': 'Les Enregistrements',
    'Chapitre 02': 'Les Fichiers',
    'Chapitre 03': 'Les Listes chaînées',
    'Chapitre 04': 'Piles et Files',
};
const submitQuiz = async (req, res) => {
    try {
        const userId = req.userId;
        const { correctAnswers, algoType, chapterName, totalQuestions, } = req.body;
        if (typeof correctAnswers !== 'number' || correctAnswers < 0) {
            res.status(400).json({ success: false, message: 'correctAnswers invalide' });
            return;
        }
        const pointsParReponse = GO_POINTS[algoType] ?? 250;
        const pointsGagnes = correctAnswers * pointsParReponse;
        const now = new Date();
        // ✅ 1. Cherche le chapitre AVANT de créer le quiz
        const chapterMap = algoType === 'algo2' ? CHAPTER_MAP_ALGO2 : CHAPTER_MAP_ALGO1;
        const titreBDD = chapterMap[chapterName] ?? chapterName;
        const chapitre = await prisma.chapitre.findFirst({
            where: { titre: { contains: titreBDD, mode: 'insensitive' } },
        });
        console.log(`🔍 Chapitre cherché: "${titreBDD}" → trouvé: ${chapitre?.id_chapitre ?? 'NON'}`);
        // ✅ 2. Crée le quiz dans `quizz`
        const quizzRecord = await prisma.quizz.create({
            data: {
                score: correctAnswers,
                nombrequestionstotal: totalQuestions ?? 0,
                nombrequestionsfaites: correctAnswers,
                chapitresselectionnees: chapterName ?? '',
                intensite: algoType,
            },
        });
        // ✅ 3. Remplit `selectionne` pour lier quiz ↔ chapitre
        if (chapitre) {
            await prisma.selectionne.create({
                data: {
                    id_quiz: quizzRecord.id_quiz,
                    id_chapitre: chapitre.id_chapitre,
                },
            });
            console.log(`✅ selectionne créé: quiz=${quizzRecord.id_quiz} ↔ chapitre=${chapitre.id_chapitre}`);
            // ✅ 4. Crée un suivi du chapitre + lie l'étudiant
            const suivi = await prisma.suividuchapitre.create({
                data: {
                    id_chapitre: chapitre.id_chapitre,
                    // Le chapitre est considéré terminé dès que le quiz est finalisé.
                    complete: true,
                    datepassage: now,
                },
            });
            await prisma.obtient.create({
                data: {
                    id_etudiant: userId,
                    id_suivichapitre: suivi.id_s,
                },
            });
        }
        // ✅ 5. Lie l'étudiant au quiz dans `passe` avec datepassage
        await prisma.passe.create({
            data: {
                id_etudiant: userId,
                id_quiz: quizzRecord.id_quiz,
                datepassage: now,
            },
        });
        // ✅ 6. Enregistre dans statistiquesquiz
        await prisma.statistiquesquiz.create({
            data: {
                moyennescores: correctAnswers,
                nombretentatives: 1,
                dategeneration: now,
                id_admin: null,
            },
        });
        // ✅ 7. Met à jour le score total
        const updatedUser = await prisma.utilisateur.update({
            where: { id: userId },
            data: { scoretotal: { increment: pointsGagnes } },
            select: { id: true, scoretotal: true, rang: true },
        });
        console.log(`✅ Quiz soumis: userId=${userId}, points=${pointsGagnes}, chapitre=${chapterName}, date=${now.toISOString()}`);
        res.status(200).json({
            success: true,
            pointsGagnes,
            pointsParReponse,
            newScore: updatedUser.scoretotal,
            currentRank: updatedUser.rang,
            message: `+${pointsGagnes} Go Points !`,
        });
    }
    catch (error) {
        console.error('❌ Erreur submitQuiz:', error);
        res.status(500).json({
            success: false,
            message: error instanceof Error ? error.message : 'Erreur serveur',
        });
    }
};
exports.submitQuiz = submitQuiz;
const completeChapter = async (req, res) => {
    try {
        const userId = req.userId;
        const { chapterId } = req.body;
        if (!chapterId) {
            res.status(400).json({ success: false, message: 'chapterId requis' });
            return;
        }
        const updated = await prisma.chapitre.update({
            where: { id_chapitre: chapterId },
            data: { termine: true, pourcentagechapitre: 100 },
        });
        const suivi = await prisma.suividuchapitre.create({
            data: {
                id_chapitre: chapterId,
                complete: true,
                datepassage: new Date(),
            },
        });
        await prisma.obtient.create({
            data: {
                id_etudiant: userId,
                id_suivichapitre: suivi.id_s,
            },
        });
        console.log(`✅ Chapitre terminé: userId=${userId}, chapterId=${chapterId}`);
        res.status(200).json({
            success: true,
            termine: updated.termine,
            pourcentagechapitre: updated.pourcentagechapitre,
        });
    }
    catch (error) {
        console.error('❌ Erreur completeChapter:', error);
        res.status(500).json({
            success: false,
            message: error instanceof Error ? error.message : 'Erreur serveur',
        });
    }
};
exports.completeChapter = completeChapter;
