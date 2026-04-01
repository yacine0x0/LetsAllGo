import 'dotenv/config';
import { Resend } from 'resend';

const resend = new Resend(process.env.RESEND_API_KEY!);

export async function sendVerificationEmail(
  email: string,
  nom:   string,
  code:  string
): Promise<void> {
  await resend.emails.send({
    from:    'onboarding@resend.dev',
    to:      email,
    subject: 'LetsAllGo — Code de vérification',
    html:    buildEmailTemplate(nom, code),
  });
}

function buildEmailTemplate(nom: string, code: string): string {
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
                      Bonjour <strong>${nom}</strong>,
                    </p>
                    <p style="font-size:15px; color:#555555; line-height:1.6;">
                      Merci de vous être inscrit sur <strong>LetsAllGo</strong>.
                      Utilisez le code ci-dessous pour vérifier votre adresse email.
                      Ce code est valable <strong>5 minutes</strong> et vous avez
                      <strong>3 tentatives</strong> maximum.
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

                    <p style="font-size:13px; color:#999999; text-align:center;">
                      Si vous n'êtes pas à l'origine de cette demande, ignorez cet email.
                    </p>
                  </td>
                </tr>

                <tr>
                  <td style="background:#f9f9f9; padding:16px 32px; text-align:center;">
                    <p style="font-size:12px; color:#aaaaaa; margin:0;">
                      © ${new Date().getFullYear()} LetsAllGo. Tous droits réservés.
                    </p>
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