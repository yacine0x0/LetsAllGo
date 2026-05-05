"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const AuthController_1 = require("../controllers/auth/AuthController");
const auth_reset_controller_1 = require("../controllers/auth/auth_reset.controller");
// Ajouter ces 3 routes
const router = (0, express_1.Router)();
router.post('/forgot-password', auth_reset_controller_1.forgotPassword);
router.post('/verify-reset-otp', auth_reset_controller_1.verifyResetCode);
router.post('/reset-password', auth_reset_controller_1.resetPassword);
router.post('/login', AuthController_1.login);
router.post('/register', AuthController_1.register);
router.post('/verify-email', AuthController_1.verifyEmail);
exports.default = router;
