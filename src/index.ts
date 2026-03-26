import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import authRoutes from './loginbackend/loginroutes/authroutes';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.use('/api/auth', authRoutes);

app.listen(PORT, () => {
  console.log(`✅ Serveur démarré sur http://localhost:${PORT}`);
});