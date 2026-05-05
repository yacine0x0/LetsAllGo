"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
require("dotenv/config");
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const authroutes_1 = __importDefault(require("./lib/routes/authroutes"));
const user_routes_1 = __importDefault(require("./lib/routes/user.routes"));
const leaderboard_routes_1 = __importDefault(require("./lib/routes/leaderboard.routes"));
const admin_routes_1 = __importDefault(require("./lib/routes/admin.routes"));
const quiz_routes_1 = __importDefault(require("./lib/routes/quiz.routes"));
const courses_routes_1 = __importDefault(require("./lib/routes/courses.routes")); // ✅ NOUVEAU
const app = (0, express_1.default)();
const PORT = process.env.PORT ?? 3000;
app.use((0, cors_1.default)({
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
    allowedHeaders: ['Content-Type', 'Authorization'],
}));
app.use(express_1.default.json());
app.use('/api/auth', authroutes_1.default);
app.use('/api/users', user_routes_1.default);
app.use('/api/leaderboard', leaderboard_routes_1.default);
app.use('/api/quiz', quiz_routes_1.default);
app.use('/api/courses', courses_routes_1.default); // ✅ NOUVEAU
app.use('/api/admin', admin_routes_1.default);
app.get('/', (_req, res) => res.json({ message: 'LetsAllGo API is running 🚀' }));
app.use((_req, res) => res.status(404).json({ success: false, message: 'Route introuvable' }));
app.listen(PORT, () => console.log(`✅ Serveur démarré sur http://localhost:${PORT}`));
exports.default = app;
