import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import authRoutes       from './loginbackend/loginroutes/authroutes';
import userRoutes       from './loginbackend/loginroutes/user.routes';
import leaderboardRoutes from './loginbackend/loginroutes/leaderboard.routes'; 
import quizRoutes from './loginbackend/loginroutes/quiz.routes'; 

const app = express();
const PORT = process.env.PORT ?? 3000;

app.use(cors({ origin: '*', methods: ['GET', 'POST', 'PUT', 'DELETE'], allowedHeaders: ['Content-Type', 'Authorization'] }));
app.use(express.json());

app.use('/api/quiz', quizRoutes);
dotenv.config();
app.use('/api/auth',        authRoutes);
app.use('/api/users',       userRoutes);
app.use('/api/leaderboard', leaderboardRoutes); 

app.get('/', (_req, res) => res.json({ message: 'LetsAllGo API is running 🚀' }));
app.use((_req, res) => res.status(404).json({ success: false, message: 'Route introuvable' }));

app.listen(PORT, () => console.log(`✅  Serveur démarré sur http://localhost:${PORT}`));

export default app;