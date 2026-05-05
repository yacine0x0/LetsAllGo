"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateLoginInput = validateLoginInput;
exports.validateRegisterInput = validateRegisterInput;
exports.validateVerifyEmailInput = validateVerifyEmailInput;
function isValidEmail(email) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}
function validateLoginInput(input) {
    if (!input.email || !isValidEmail(input.email.trim())) {
        return "Email invalide";
    }
    if (!input.password || input.password.length < 6) {
        return "Le mot de passe doit contenir au moins 6 caractères";
    }
    return null;
}
function validateRegisterInput(input) {
    if (!input.nom || input.nom.trim().length < 2) {
        return "Le nom doit contenir au moins 2 caractères";
    }
    if (!input.prenom || input.prenom.trim().length < 2) {
        return "Le prénom doit contenir au moins 2 caractères";
    }
    if (!input.email || !isValidEmail(input.email.trim())) {
        return "Email invalide";
    }
    if (!input.password || input.password.length < 6) {
        return "Le mot de passe doit contenir au moins 6 caractères";
    }
    return null;
}
function validateVerifyEmailInput(input) {
    if (!input.email || !isValidEmail(input.email.trim())) {
        return "Email invalide";
    }
    if (!input.code || !/^\d{6}$/.test(input.code.trim())) {
        return "Le code doit être composé de 6 chiffres";
    }
    return null;
}
