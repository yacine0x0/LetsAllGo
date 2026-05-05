"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getAdminMe = getAdminMe;
exports.updateAdminMe = updateAdminMe;
const admin_service_1 = require("../../service/admin/admin.service");
// GET /api/admin/me
async function getAdminMe(req, res) {
    try {
        const user = await (0, admin_service_1.getAdminById)(req.userId);
        res.status(200).json({ success: true, data: user });
    }
    catch (error) {
        res.status(403).json({
            success: false,
            message: error instanceof Error ? error.message : 'Erreur serveur',
        });
    }
}
// PUT /api/admin/me
async function updateAdminMe(req, res) {
    try {
        const { nom, prenom, email } = req.body;
        const updated = await (0, admin_service_1.updateAdminProfile)(req.userId, { nom, prenom, email });
        res.status(200).json({ success: true, data: updated });
    }
    catch (error) {
        res.status(400).json({
            success: false,
            message: error instanceof Error ? error.message : 'Erreur serveur',
        });
    }
}
