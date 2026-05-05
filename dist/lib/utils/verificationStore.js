"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.savePendingRegistration = savePendingRegistration;
exports.getPendingRegistration = getPendingRegistration;
exports.incrementAttempts = incrementAttempts;
exports.deletePendingRegistration = deletePendingRegistration;
const crypto_1 = __importDefault(require("crypto"));
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const store = new Map();
async function savePendingRegistration(nom, prenom, email, hashedPassword) {
    const code = crypto_1.default.randomInt(100000, 999999).toString();
    const hashedCode = await bcryptjs_1.default.hash(code, 10);
    const expiresAt = Date.now() + 5 * 60 * 1000;
    store.set(email, {
        nom,
        prenom,
        email,
        hashedPassword,
        hashedCode,
        expiresAt,
        attempts: 0,
    });
    return code;
}
function getPendingRegistration(email) {
    return store.get(email);
}
function incrementAttempts(email) {
    const entry = store.get(email);
    if (entry) {
        entry.attempts += 1;
        store.set(email, entry);
    }
}
function deletePendingRegistration(email) {
    store.delete(email);
}
