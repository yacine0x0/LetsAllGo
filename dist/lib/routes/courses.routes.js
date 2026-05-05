"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// lib/routes/courses.routes.ts
const express_1 = require("express");
const auth_middleware_1 = require("../middlewares/auth.middleware");
const courses_controller_1 = require("../controllers/courses_study/courses.controller");
const router = (0, express_1.Router)();
router.post('/visit', auth_middleware_1.requireAuth, courses_controller_1.recordChapterVisit);
router.post('/complete', auth_middleware_1.requireAuth, courses_controller_1.completeChapter);
router.get('/progress', auth_middleware_1.requireAuth, courses_controller_1.getChapterProgress); // ✅ cette ligne doit exister
exports.default = router;
