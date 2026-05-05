"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getAnalytics = void 0;
// lib/service/admin/analytics.service.ts
const client_1 = require("@prisma/client");
const globalForPrisma = global;
const prisma = globalForPrisma.prisma ?? new client_1.PrismaClient();
if (process.env.NODE_ENV !== 'production')
    globalForPrisma.prisma = prisma;
const JOURS_FR = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];
const getAnalytics = async () => {
    // ── 1. Chapitres avec moyenne de progression (étudiants distincts)
    const totalStudents = await prisma.utilisateur.count({
        where: { role: 'etudiant' },
    });
    const chapitres = await prisma.chapitre.findMany({
        select: {
            id_chapitre: true,
            titre: true,
            module: { select: { nom: true } },
            suividuchapitre: {
                select: {
                    complete: true,
                    obtient: { select: { id_etudiant: true } },
                },
            },
        },
        orderBy: { titre: 'asc' },
    });
    const chapitresAvecProgression = chapitres.map(c => {
        // Etudiants ayant au moins une completion sur ce chapitre
        const completedStudentIds = new Set();
        for (const suivi of c.suividuchapitre) {
            if (!suivi.complete)
                continue;
            for (const o of suivi.obtient) {
                completedStudentIds.add(o.id_etudiant);
            }
        }
        // Moyenne de progression = nb étudiants qui ont complété / nb étudiants total
        const completion = totalStudents > 0
            ? completedStudentIds.size / totalStudents
            : 0;
        return {
            id_chapitre: c.id_chapitre,
            titre: c.titre,
            module_nom: c.module?.nom?.toLowerCase() ?? '',
            completion,
            completedStudents: completedStudentIds.size,
            totalStudents,
        };
    });
    // ── 2. Total quiz passés (global)
    const totalQuizzesDone = await prisma.passe.count();
    // ── 3. Récupérer les 100 derniers quiz passés
    const passages = await prisma.passe.findMany({
        orderBy: {
            datepassage: 'desc',
        },
        take: 500,
        select: {
            datepassage: true,
            quizz: {
                select: {
                    intensite: true,
                    selectionne: {
                        select: {
                            chapitre: {
                                select: {
                                    module: {
                                        select: { nom: true },
                                    },
                                },
                            },
                        },
                    },
                },
            },
        },
    });
    console.log('📊 100 derniers passages:', passages.length);
    // ── 4. Utiliser directement intensite
    // intensite = algo1 | algo2
    const passesAvecModule = passages
        .filter(p => p.datepassage !== null)
        .map(p => {
        const module_nom = p.quizz.intensite?.toLowerCase() ?? '';
        return {
            datepassage: p.datepassage,
            module_nom,
        };
    });
    console.log('📚 modules distincts:', [...new Set(passesAvecModule.map(e => e.module_nom))]);
    // ── 5. Builder courbe statistiques
    const buildWeekStats = (entries) => Array.from({ length: 7 }, (_, i) => {
        const d = new Date();
        d.setDate(d.getDate() - (6 - i));
        d.setHours(0, 0, 0, 0);
        const count = entries.filter(e => {
            const ed = new Date(e.datepassage);
            ed.setHours(0, 0, 0, 0);
            return ed.toDateString() === d.toDateString();
        }).length;
        return {
            day: JOURS_FR[d.getDay()],
            quizzesDone: count,
        };
    });
    // Stats globales
    const quizStats7Jours = buildWeekStats(passesAvecModule);
    // ── Algo1 via intensite
    const datesAlgo1 = passesAvecModule.filter(e => e.module_nom === 'algo1');
    // ── Algo2 via intensite
    const datesAlgo2 = passesAvecModule.filter(e => e.module_nom === 'algo2');
    // Fallback Algo1
    const quizStatsAlgo1 = buildWeekStats(datesAlgo1.length > 0
        ? datesAlgo1
        : passesAvecModule);
    // Fallback Algo2
    const quizStatsAlgo2 = buildWeekStats(datesAlgo2.length > 0
        ? datesAlgo2
        : passesAvecModule);
    console.log('📈 global  :', quizStats7Jours);
    console.log('📈 algo1   :', quizStatsAlgo1);
    console.log('📈 algo2   :', quizStatsAlgo2);
    // ── 6. Séparer chapitres Algo1 / Algo2
    const algo1Chapters = chapitresAvecProgression
        .filter(c => c.module_nom.includes('algorithmique 1') ||
        c.module_nom.includes('algorithme 1') ||
        c.module_nom === 'algo1')
        .map(c => ({
        label: c.titre,
        completion: c.completion,
        completedStudents: c.completedStudents,
        totalStudents: c.totalStudents,
    }));
    const algo2Chapters = chapitresAvecProgression
        .filter(c => c.module_nom.includes('algorithmique 2') ||
        c.module_nom.includes('algorithme 2') ||
        c.module_nom === 'algo2')
        .map(c => ({
        label: c.titre,
        completion: c.completion,
        completedStudents: c.completedStudents,
        totalStudents: c.totalStudents,
    }));
    // Fallback Algo1
    const finalAlgo1 = algo1Chapters.length > 0
        ? algo1Chapters
        : chapitresAvecProgression.map(c => ({
            label: c.titre,
            completion: c.completion,
            completedStudents: c.completedStudents,
            totalStudents: c.totalStudents,
        }));
    const finalAlgo2 = algo2Chapters.length > 0
        ? algo2Chapters
        : [];
    return {
        totalQuizzesDone,
        quizStats: quizStats7Jours,
        quizStatsAlgo1,
        quizStatsAlgo2,
        algo1Chapters: finalAlgo1,
        algo2Chapters: finalAlgo2,
    };
};
exports.getAnalytics = getAnalytics;
