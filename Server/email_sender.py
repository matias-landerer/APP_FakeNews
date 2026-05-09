import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import parametros

def send_verification_email(to_email: str, token: str):
    link = f"{parametros.APP_BASE_URL}/verify?token={token}"

    msg = MIMEMultipart("alternative")
    msg["Subject"] = "Verifica tu cuenta – Fake News Detector"
    msg["From"] = parametros.EMAIL_SENDER
    msg["To"] = to_email

    html = f"""
    <html><body>
      <h2>Bienvenido a Fake News Detector</h2>
      <p>Haz click en el siguiente enlace para verificar tu cuenta:</p>
      <a href="{link}" style="
        background:#EF342A; color:white; padding:12px 24px;
        border-radius:8px; text-decoration:none; font-weight:bold;
      ">Verificar cuenta</a>
      <p style="color:#999; margin-top:24px; font-size:12px;">
        Si no creaste esta cuenta, ignora este mensaje.
      </p>
    </body></html>
    """

    msg.attach(MIMEText(html, "html"))

    with smtplib.SMTP_SSL("smtp.gmail.com", 465) as server:
        server.login(parametros.EMAIL_SENDER, parametros.EMAIL_PASSWORD)
        server.sendmail(parametros.EMAIL_SENDER, to_email, msg.as_string())