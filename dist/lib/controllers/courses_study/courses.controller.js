"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getChapterProgress = exports.completeChapter = exports.recordChapterVisit = void 0;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
const TOTAL_ALGO1 = 5;
const TOTAL_ALGO2 = 4;
const CHAPTER_WEIGHT_ALGO1 = 100 / TOTAL_ALGO1; // 20%
const CHAPTER_WEIGHT_ALGO2 = 100 / TOTAL_ALGO2; // 25%
const CHAPTER_MAP_ALGO1 = {
    'Basics': "Introduction à l'algorithmique",
    'Conditions': 'Conditions',
    'Loops': 'Boucles',
    'Data Structures – Vectors and Matrices': 'Structures de données',
    'Subprograms (Functions and Procedures)': 'Sous-programmes',
};
const REVERSE_MAP_ALGO1 = {
    "introduction à l'algorithmique": 'Basics',
    'conditions': 'Conditions',
    'boucles': 'Loops',
    'structures de données': 'Data Structures – Vectors and Matrices',
    'sous-programmes': 'Subprograms (Functions and Procedures)',
};
const CHAPTER_MAP_ALGO2 = {
    'Les Enregistrements': 'Les Enregistrements',
    'Les Fichiers': 'Les Fichiers',
    'Les Listes chaînées': 'Les Listes chaînées',
    'Piles et Files': 'Piles et Files',
};
const REVERSE_MAP_ALGO2 = {
    'les enregistrements': 'Les Enregistrements',
    'les fichiers': 'Les Fichiers',
    'les listes chainees': 'Les Listes chaînées', // ✅ normalisé sans accents
    'piles et files': 'Piles et Files',
};
// ✅ Normalise un titre pour comparaison robuste (accents, tirets, casse)
const normalizeTitle = (str) => str
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[–—-]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim()
    .toLowerCase();
// ── Trouve le chapitre en DB avec normalisation
const findChapitre = async (chapterTitle, algoType) => {
    const map = algoType === 'algo2' ? CHAPTER_MAP_ALGO2 : CHAPTER_MAP_ALGO1;
    const titreBDD = map[chapterTitle] ?? chapterTitle;
    // ✅ Récupère tous les chapitres du module puis compare après normalisation
    const module = await prisma.module.findFirst({
        where: {
            nom: {
                contains: algoType === 'algo2' ? 'algorithmique 2' : 'algorithmique 1',
                mode: 'insensitive',
            },
        },
        include: {
            chapitre: {
                select: {
                    id_chapitre: true,
                    titre: true,
                    id_module: true,
                },
            },
        },
    });
    if (!module) {
        console.log(`❌ Module "${algoType}" introuvable`);
        return null;
    }
    const normalizedTarget = normalizeTitle(titreBDD);
    const found = module.chapitre.find(c => normalizeTitle(c.titre).includes(normalizedTarget) ||
        normalizedTarget.includes(normalizeTitle(c.titre)));
    if (found) {
        console.log(`✅ Chapitre trouvé: "${titreBDD}" → "${found.titre}"`);
    }
    else {
        console.log(`❌ Chapitre non trouvé: "${titreBDD}"`);
        console.log(`   Disponibles: ${module.chapitre.map(c => `"${c.titre}"`).join(', ')}`);
    }
    return found ?? null;
};
// ── Lie étudiant au module dans etudie
const ensureEtudie = async (userId, moduleId) => {
    await prisma.etudie.upsert({
        where: {
            id_etudiant_id_module: {
                id_etudiant: userId,
                id_module: moduleId,
            },
        },
        update: {},
        create: {
            id_etudiant: userId,
            id_module: moduleId,
        },
    });
};
// ── Trouve ou crée la progression d'un étudiant pour un module
const ensureProgression = async (userId, moduleId) => {
    const existing = await prisma.progression.findFirst({
        where: {
            concernem: { some: { id_module: moduleId } },
            suit: { some: { id_etudiant: userId } },
        },
    });
    if (existing)
        return existing;
    const progression = await prisma.progression.create({
        data: {
            pourcentage: 0,
            progressiontotale: 0,
        },
    });
    await prisma.concernem.upsert({
        where: {
            id_module_id_progression: {
                id_module: moduleId,
                id_progression: progression.id_progression,
            },
        },
        update: {},
        create: {
            id_module: moduleId,
            id_progression: progression.id_progression,
        },
    });
    await prisma.suit.upsert({
        where: {
            id_etudiant_id_progression: {
                id_etudiant: userId,
                id_progression: progression.id_progression,
            },
        },
        update: {},
        create: {
            id_etudiant: userId,
            id_progression: progression.id_progression,
        },
    });
    console.log(`✅ Progression créée: étudiant=${userId} → module=${moduleId}`);
    return progression;
};
// ── Trouve le suivi existant d'un étudiant pour un chapitre
const findExistingSuivi = async (userId, chapitreId) => {
    return prisma.suividuchapitre.findFirst({
        where: {
            id_chapitre: chapitreId,
            obtient: { some: { id_etudiant: userId } },
        },
    });
};
// ── Recalculer et persister la progression complète
const recalculerEtSauvegarderProgression = async (userId) => {
    const suivis = await prisma.obtient.findMany({
        where: { id_etudiant: userId },
        include: {
            suividuchapitre: {
                include: {
                    chapitre: { include: { module: true } },
                },
            },
        },
    });
    const completedAlgo1Ids = new Set();
    const completedAlgo2Ids = new Set();
    for (const o of suivis) {
        const suivi = o.suividuchapitre;
        const chapId = suivi.id_chapitre ?? '';
        const moduleNom = suivi.chapitre?.module?.nom?.toLowerCase() ?? '';
        if (!suivi.complete)
            continue;
        if (moduleNom.includes('algorithmique 1'))
            completedAlgo1Ids.add(chapId);
        if (moduleNom.includes('algorithmique 2'))
            completedAlgo2Ids.add(chapId);
    }
    const completedAlgo1 = completedAlgo1Ids.size;
    const completedAlgo2 = completedAlgo2Ids.size;
    const pourcentageAlgo1 = Math.min(completedAlgo1 * CHAPTER_WEIGHT_ALGO1, 100);
    const pourcentageAlgo2 = Math.min(completedAlgo2 * CHAPTER_WEIGHT_ALGO2, 100);
    const progressiontotale = Math.round((pourcentageAlgo1 + pourcentageAlgo2) / 2);
    // Mettre à jour progression algo1
    const progressionAlgo1 = await prisma.progression.findFirst({
        where: {
            suit: { some: { id_etudiant: userId } },
            concernem: {
                some: {
                    module: { nom: { contains: 'algorithmique 1', mode: 'insensitive' } },
                },
            },
        },
    });
    if (progressionAlgo1) {
        await prisma.progression.update({
            where: { id_progression: progressionAlgo1.id_progression },
            data: {
                pourcentage: Math.round(pourcentageAlgo1),
                progressiontotale: progressiontotale,
            },
        });
    }
    // Mettre à jour progression algo2
    const progressionAlgo2 = await prisma.progression.findFirst({
        where: {
            suit: { some: { id_etudiant: userId } },
            concernem: {
                some: {
                    module: { nom: { contains: 'algorithmique 2', mode: 'insensitive' } },
                },
            },
        },
    });
    if (progressionAlgo2) {
        await prisma.progression.update({
            where: { id_progression: progressionAlgo2.id_progression },
            data: {
                pourcentage: Math.round(pourcentageAlgo2),
                progressiontotale: progressiontotale,
            },
        });
    }
    // Mettre à jour progressionmodule
    const moduleAlgo1 = await prisma.module.findFirst({
        where: { nom: { contains: 'algorithmique 1', mode: 'insensitive' } },
    });
    const moduleAlgo2 = await prisma.module.findFirst({
        where: { nom: { contains: 'algorithmique 2', mode: 'insensitive' } },
    });
    if (moduleAlgo1) {
        await prisma.module.update({
            where: { id_module: moduleAlgo1.id_module },
            data: { progressionmodule: Math.round(pourcentageAlgo1) },
        });
    }
    if (moduleAlgo2) {
        await prisma.module.update({
            where: { id_module: moduleAlgo2.id_module },
            data: { progressionmodule: Math.round(pourcentageAlgo2) },
        });
    }
    // Mettre à jour chapitre.termine
    for (const chapId of [...completedAlgo1Ids, ...completedAlgo2Ids]) {
        await prisma.chapitre.update({
            where: { id_chapitre: chapId },
            data: { termine: true, pourcentagechapitre: 100 },
        });
    }
    console.log(`📊 Progression: algo1=${pourcentageAlgo1}% algo2=${pourcentageAlgo2}% total=${progressiontotale}%`);
    return {
        algo1: {
            completed: completedAlgo1,
            total: TOTAL_ALGO1,
            progress: parseFloat((pourcentageAlgo1 / 100).toFixed(2)),
        },
        algo2: {
            completed: completedAlgo2,
            total: TOTAL_ALGO2,
            progress: parseFloat((pourcentageAlgo2 / 100).toFixed(2)),
        },
        global: {
            completed: completedAlgo1 + completedAlgo2,
            total: TOTAL_ALGO1 + TOTAL_ALGO2,
            progress: parseFloat((progressiontotale / 100).toFixed(2)),
        },
    };
};
// ────────────────────────────────────────────────────────────
// POST /api/courses/visit
// ────────────────────────────────────────────────────────────
const recordChapterVisit = async (req, res) => {
    try {
        const userId = req.userId;
        const { chapterTitle, algoType } = req.body;
        if (!chapterTitle || !algoType) {
            res.status(400).json({ message: 'chapterTitle et algoType requis' });
            return;
        }
        const chapitre = await findChapitre(chapterTitle, algoType);
        if (!chapitre) {
            res.status(404).json({ message: `Chapitre "${chapterTitle}" introuvable` });
            return;
        }
        if (chapitre.id_module) {
            await ensureEtudie(userId, chapitre.id_module);
            await ensureProgression(userId, chapitre.id_module);
        }
        const existing = await findExistingSuivi(userId, chapitre.id_chapitre);
        if (!existing) {
            const suivi = await prisma.suividuchapitre.create({
                data: {
                    id_chapitre: chapitre.id_chapitre,
                    complete: false,
                    datepassage: new Date(),
                },
            });
            await prisma.obtient.create({
                data: {
                    id_etudiant: userId,
                    id_suivichapitre: suivi.id_s,
                },
            });
            console.log(`✅ Visite enregistrée: ${userId} → ${chapitre.titre}`);
        }
        res.status(200).json({
            success: true,
            chapterId: chapitre.id_chapitre,
            chapterTitle: chapitre.titre,
            alreadyVisited: !!existing,
            isCompleted: existing?.complete ?? false,
        });
    }
    catch (error) {
        console.error('❌ recordChapterVisit:', error);
        res.status(500).json({
            message: error instanceof Error ? error.message : 'Erreur serveur',
        });
    }
};
exports.recordChapterVisit = recordChapterVisit;
// ────────────────────────────────────────────────────────────
// POST /api/courses/complete
// ────────────────────────────────────────────────────────────
const completeChapter = async (req, res) => {
    try {
        const userId = req.userId;
        const { chapterTitle, algoType } = req.body;
        if (!chapterTitle || !algoType) {
            res.status(400).json({ message: 'chapterTitle et algoType requis' });
            return;
        }
        const chapitre = await findChapitre(chapterTitle, algoType);
        if (!chapitre) {
            res.status(404).json({ message: `Chapitre "${chapterTitle}" introuvable` });
            return;
        }
        if (chapitre.id_module) {
            await ensureEtudie(userId, chapitre.id_module);
            await ensureProgression(userId, chapitre.id_module);
        }
        const existing = await findExistingSuivi(userId, chapitre.id_chapitre);
        if (existing) {
            if (!existing.complete) {
                await prisma.suividuchapitre.update({
                    where: { id_s: existing.id_s },
                    data: { complete: true, datepassage: new Date() },
                });
                console.log(`✅ Chapitre complété: ${userId} → ${chapitre.titre}`);
            }
            else {
                console.log(`ℹ️ Déjà complété: ${userId} → ${chapitre.titre}`);
            }
        }
        else {
            const suivi = await prisma.suividuchapitre.create({
                data: {
                    id_chapitre: chapitre.id_chapitre,
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
            console.log(`✅ Chapitre complété (nouveau): ${userId} → ${chapitre.titre}`);
        }
        const progress = await recalculerEtSauvegarderProgression(userId);
        res.status(200).json({
            success: true,
            chapterId: chapitre.id_chapitre,
            chapterTitle: chapitre.titre,
            progress,
        });
    }
    catch (error) {
        console.error('❌ completeChapter:', error);
        res.status(500).json({
            message: error instanceof Error ? error.message : 'Erreur serveur',
        });
    }
};
exports.completeChapter = completeChapter;
// ────────────────────────────────────────────────────────────
// GET /api/courses/progress
// ────────────────────────────────────────────────────────────
const getChapterProgress = async (req, res) => {
    try {
        const userId = req.userId;
        const progressionAlgo1 = await prisma.progression.findFirst({
            where: {
                suit: { some: { id_etudiant: userId } },
                concernem: {
                    some: {
                        module: { nom: { contains: 'algorithmique 1', mode: 'insensitive' } },
                    },
                },
            },
        });
        const progressionAlgo2 = await prisma.progression.findFirst({
            where: {
                suit: { some: { id_etudiant: userId } },
                concernem: {
                    some: {
                        module: { nom: { contains: 'algorithmique 2', mode: 'insensitive' } },
                    },
                },
            },
        });
        const pAlgo1 = progressionAlgo1?.pourcentage ?? 0;
        const pAlgo2 = progressionAlgo2?.pourcentage ?? 0;
        const pTotal = progressionAlgo1?.progressiontotale ?? 0;
        const suivis = await prisma.obtient.findMany({
            where: { id_etudiant: userId },
            include: {
                suividuchapitre: {
                    include: {
                        chapitre: { include: { module: true } },
                    },
                },
            },
        });
        const completedChapters = [];
        const seenIds = new Set();
        for (const o of suivis) {
            const suivi = o.suividuchapitre;
            const chapId = suivi.id_chapitre ?? '';
            const moduleNom = suivi.chapitre?.module?.nom?.toLowerCase() ?? '';
            const titre = suivi.chapitre?.titre ?? '';
            if (!suivi.complete || seenIds.has(chapId))
                continue;
            seenIds.add(chapId);
            const algoType = moduleNom.includes('algorithmique 1') ? 'algo1' : 'algo2';
            const map = algoType === 'algo2' ? REVERSE_MAP_ALGO2 : REVERSE_MAP_ALGO1;
            const flutterTitle = map[normalizeTitle(titre)] ?? titre;
            completedChapters.push(`${algoType}_${flutterTitle}`);
        }
        res.status(200).json({
            success: true,
            algo1: {
                completed: Math.round(pAlgo1 / CHAPTER_WEIGHT_ALGO1),
                total: TOTAL_ALGO1,
                progress: parseFloat((pAlgo1 / 100).toFixed(2)),
            },
            algo2: {
                completed: Math.round(pAlgo2 / CHAPTER_WEIGHT_ALGO2),
                total: TOTAL_ALGO2,
                progress: parseFloat((pAlgo2 / 100).toFixed(2)),
            },
            global: {
                completed: Math.round(pAlgo1 / CHAPTER_WEIGHT_ALGO1) + Math.round(pAlgo2 / CHAPTER_WEIGHT_ALGO2),
                total: TOTAL_ALGO1 + TOTAL_ALGO2,
                progress: parseFloat((pTotal / 100).toFixed(2)),
            },
            completedChapters,
        });
    }
    catch (error) {
        console.error('❌ getChapterProgress:', error);
        res.status(500).json({
            message: error instanceof Error ? error.message : 'Erreur serveur',
        });
    }
};
exports.getChapterProgress = getChapterProgress;
