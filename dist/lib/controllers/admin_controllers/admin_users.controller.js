"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getUsers = getUsers;
exports.deleteUser = deleteUser;
const admin_users_service_1 = require("../../service/admin/admin_users.service");
// ── GET /api/admin/users — récupérer tous les étudiants
async function getUsers(req, res) {
    try {
        const query = req.query.search;
        const students = query && query.trim() !== ''
            ? await (0, admin_users_service_1.searchStudents)(query.trim())
            : await (0, admin_users_service_1.getAllStudents)();
        res.status(200).json({
            success: true,
            data: students,
            total: students.length,
        });
    }
    catch (error) {
        res.status(500).json({
            success: false,
            message: error instanceof Error ? error.message : 'Erreur serveur',
        });
    }
}
// ── DELETE /api/admin/users/:id — supprimer un étudiant
async function deleteUser(req, res) {
    try {
        const { id } = req.params;
        // Validation de l'ID
        if (!id || typeof id !== 'string' || id.trim() === '') {
            res.status(400).json({
                success: false,
                message: 'ID manquant ou invalide'
            });
            return;
        }
        // Appel du service (id est string, comme attendu dans le service)
        await (0, admin_users_service_1.deleteStudent)(id.trim());
        res.status(200).json({
            success: true,
            message: 'Étudiant supprimé avec succès',
        });
    }
    catch (error) {
        console.error('Erreur lors de la suppression:', error);
        const message = error instanceof Error
            ? error.message
            : 'Erreur lors de la suppression de l\'étudiant';
        res.status(400).json({
            success: false,
            message,
        });
    }
}
