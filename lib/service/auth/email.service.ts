import { BrevoClient, BrevoError } from '@getbrevo/brevo';

if (!process.env.BREVO_API_KEY) {
  throw new Error('BREVO_API_KEY is missing in environment variables');
}

const brevo = new BrevoClient({
  apiKey: process.env.BREVO_API_KEY,
});

export async function sendVerificationEmail(
  email: string,
  nom: string,
  code: string
): Promise<void> {
  try {
    const result = await brevo.transactionalEmails.sendTransacEmail({
      subject: 'LetsAllGo — Code de vérification',
      htmlContent: buildEmailTemplate(nom, code),
      sender: {
        name: 'LetsAllGo',
        email: 'no.reply.letsallgo@gmail.com', // ⚠️ must be verified
      },
      to: [{ email, name: nom }],
    });

    console.log('✅ Email sent:', result);
  } catch (err: any) {
    // ✅ Safe universal error handling
    if (err instanceof BrevoError) {
      console.error(`❌ Brevo API Error ${err.statusCode}:`, err.message);
      console.error('Details:', err.body);
    } else {
      console.error('❌ Unknown error:', err);
    }
  }
}

// Escape helper
function escapeHtml(str: string): string {
  return str
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;');
}

// Template
function buildEmailTemplate(nom: string, code: string): string {
  const safeNom = escapeHtml(nom);

  return `
    <!DOCTYPE html>
    <html lang="fr">
      <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>Vérification de compte</title>
      </head>
      <body style="margin:0; padding:0; background-color:#f4f4f4; font-family: Arial, sans-serif;">
        <table width="100%" cellpadding="0" cellspacing="0">
          <tr>
            <td align="center" style="padding: 40px 0;">
              <table width="480" cellpadding="0" cellspacing="0"
                style="background:#ffffff; border-radius:8px; overflow:hidden;
                       box-shadow: 0 2px 8px rgba(0,0,0,0.08);">
                <tr>
                  <td style="background:#4F46E5; padding:32px; text-align:center;">
                    <h1 style="color:#ffffff; margin:0; font-size:24px;">LetsAllGo</h1>
                  </td>
                </tr>
                <tr>
                  <td style="padding:32px;">
                    <p style="font-size:16px; color:#333333;">
                      Bonjour <strong>${safeNom}</strong>,
                    </p>
                    <p style="font-size:15px; color:#555555; line-height:1.6;">
                      Merci de vous être inscrit sur <strong>LetsAllGo</strong>.
                      Utilisez le code ci-dessous pour vérifier votre adresse email.
                    </p>
                    <div style="text-align:center; margin:32px 0;">
                      <span style="
                        display:inline-block;
                        font-size:36px;
                        font-weight:bold;
                        letter-spacing:12px;
                        color:#4F46E5;
                        background:#F0EFFF;
                        padding:16px 32px;
                        border-radius:8px;">
                        ${code}
                      </span>
                    </div>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
        </table>
      </body>
    </html>
  `;
}

// Ajouter à ton email.service.ts existant

// Store séparé pour le reset password
const resetStore = new Map<string, { code: string; expiresAt: Date; email: string }>();

export async function sendResetPasswordEmail(
  userId: string,
  email: string,
  prenom: string
): Promise<void> {
  const code      = Math.floor(100000 + Math.random() * 900000).toString();
  const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 min

  resetStore.set(userId, { code, expiresAt, email });

  await brevo.transactionalEmails.sendTransacEmail({
  subject: '🔑 Réinitialisation de mot de passe LetsAllGo',
  htmlContent: `
    <div style="font-family: Arial; max-width: 500px; margin: 0 auto;
                padding: 20px; background: #0D0D2B; color: white; border-radius: 12px;">
      <h2 style="color: #2196F3; text-align: center;">LetsAllGo 🚀</h2>
      <p>Bonjour <strong>${prenom}</strong>,</p>
      <p>Voici ton code pour réinitialiser ton mot de passe :</p>
      <div style="text-align: center; margin: 30px 0;">
        <span style="font-size: 40px; font-weight: bold; letter-spacing: 10px;
                     color: #2196F3; background: rgba(33,150,243,0.1);
                     padding: 15px 30px; border-radius: 8px;
                     border: 2px solid #2196F3;">
          ${code}
        </span>
      </div>
      <p style="color: #888;">Ce code expire dans <strong>10 minutes</strong>.</p>
    </div>
  `,
  sender: {
    name: 'LetsAllGo',
    email: 'no.reply.letsallgo@gmail.com',
  },
  to: [{ email, name: prenom }],
});

  console.log(`✅ Reset password OTP envoyé à ${email}: ${code}`);
}

export function verifyResetOTP(userId: string, code: string): boolean {
  const stored = resetStore.get(userId);
  if (!stored)                       return false;
  if (new Date() > stored.expiresAt) { resetStore.delete(userId); return false; }
  if (stored.code !== code)          return false;
  resetStore.delete(userId);
  return true;
}