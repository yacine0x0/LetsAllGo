import 'dotenv/config';
import express from 'express';
import cors    from 'cors';

import authRoutes        from './lib/routes/authroutes';
import userRoutes        from './lib/routes/user.routes';
import leaderboardRoutes from './lib/routes/leaderboard.routes';
import adminRoutes       from './lib/routes/admin.routes';
import quizRoutes        from './lib/routes/quiz.routes';
import coursesRoutes     from './lib/routes/courses.routes'; // ✅ NOUVEAU

const app  = express();
const PORT = process.env.PORT ?? 3000;

app.use(cors({
  origin:         '*',
  methods:        ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

app.use(express.json());

app.use('/api/auth',        authRoutes);
app.use('/api/users',       userRoutes);
app.use('/api/leaderboard', leaderboardRoutes);
app.use('/api/quiz',        quizRoutes);
app.use('/api/courses',     coursesRoutes); // ✅ NOUVEAU
app.use('/api/admin',       adminRoutes);

app.get('/', (_req, res) =>
  res.json({ message: 'LetsAllGo API is running 🚀' }));

app.use((_req, res) =>
  res.status(404).json({ success: false, message: 'Route introuvable' }));

app.listen(PORT, () =>
  console.log(`✅ Serveur démarré sur http://localhost:${PORT}`));

export default app;