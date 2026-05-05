"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getAnalyticsData = getAnalyticsData;
const analytics_service_1 = require("../../service/admin/analytics.service");
async function getAnalyticsData(req, res) {
    try {
        const data = await (0, analytics_service_1.getAnalytics)();
        res.status(200).json({ success: true, data });
    }
    catch (error) {
        res.status(500).json({
            success: false,
            message: error instanceof Error ? error.message : 'Erreur serveur',
        });
    }
}
