import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';

// On pré-hashe dans une fonction async séparée
let fakeUser: { id: number; email: string; password: string };

const initMock = async () => {
    fakeUser = {
        id: 1,
        email: 'test@letsallgo.com',
        password: await bcrypt.hash('password123', 10),
    };
};
initMock(); // appelé au démarrage

export const loginService = async (email: string, password: string) => {
    if (email !== fakeUser.email) return { error: "Utilisateur non trouvé" };

    const isValid = await bcrypt.compare(password, fakeUser.password);
    if (!isValid) return { error: "Mot de passe incorrect" };

    const token = jwt.sign({ id: fakeUser.id }, process.env.JWT_SECRET || 'secret', { expiresIn: '1h' });
    return { token, email: fakeUser.email };
};