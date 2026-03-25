import express from 'express';
import { loginController } from './logincontrollers/authController';
import cors from 'cors';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

// Route login
app.post('/api/login', loginController);

app.listen(3000, () => console.log('Server running on http://localhost:3000'));