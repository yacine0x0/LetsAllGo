"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_middleware_1 = require("../middlewares/auth.middleware");
const admin_profil_controller_1 = require("../controllers/admin_controllers/admin_profil_controller");
const admin_users_controller_1 = require("../controllers/admin_controllers/admin_users.controller");
const analytics_controller_1 = require("../controllers/admin_controllers/analytics_controller");
const router = (0, express_1.Router)();
// ── Profil admin
router.get('/me', auth_middleware_1.requireAuth, admin_profil_controller_1.getAdminMe);
router.put('/me', auth_middleware_1.requireAuth, admin_profil_controller_1.updateAdminMe);
// ── Gestion utilisateurs
router.get('/users', auth_middleware_1.requireAuth, admin_users_controller_1.getUsers);
router.delete('/users/:id', auth_middleware_1.requireAuth, admin_users_controller_1.deleteUser);
// ── Analytics ✅
router.get('/analytics', auth_middleware_1.requireAuth, analytics_controller_1.getAnalyticsData);
exports.default = router;
