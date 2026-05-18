import secrets
import bcrypt
from datetime import datetime, timedelta, timezone
from API import verificar_titular
from conexionBDD import get_db
from email_sender import send_verification_email, send_login_alert_email, send_password_reset_email
from flask import Flask, request, jsonify
from flask_cors import CORS
from funciones_extra import password_error, isvalidEmail
from reset_password_html import RESET_PASSWORD_HTML


app = Flask(__name__)
CORS(app)

@app.route("/login", methods=["POST"])
def login():
    data = request.json
    username_mail = data['username_mail']
    password = data['password']

    if username_mail == '' or password == '':
        return jsonify({"status": "Por favor, rellene todos los datos."}), 401

    password = password.encode("utf-8")

    conn = get_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT id, clave, verified, email, username FROM users WHERE username = %s",
            (username_mail,)
        )
        row = cur.fetchone()
    conn.close()

    if not row:
        conn = get_db()
        with conn.cursor() as cur:
            cur.execute(
                "SELECT id, clave, verified, email, username FROM users WHERE email = %s",
                (username_mail,)
            )
            row = cur.fetchone()
        conn.close()

        if not row:
            return jsonify({"status": "Usuario ingresado no existe."}), 401

    hashed = row[1].encode("utf-8") if isinstance(row[1], str) else row[1]

    if not bcrypt.checkpw(password, hashed):
        return jsonify({"status": "Contraseña incorrecta"}), 401

    if not row[2]:
        return jsonify({"status": "Debes verificar tu correo antes de iniciar sesión."}), 401

    user_id, user_email, username = row[0], row[3], row[4]
    revoke_token = secrets.token_urlsafe(32)

    conn = get_db()
    with conn.cursor() as cur:
        cur.execute(
            "UPDATE users SET revoke_token = %s, session_revoked = FALSE WHERE id = %s",
            (revoke_token, user_id)
        )
        conn.commit()
    conn.close()

    try:
        send_login_alert_email(user_email, username, revoke_token)
    except Exception as e:
        print(f"Error enviando email de alerta: {e}")

    return jsonify({
        "status": "InicioExitoso",
        "user_id": user_id
    }), 200


@app.route("/register", methods=["POST"])
def register():
    data = request.json
    username = data["username"]
    email = data["email"]
    password = data["password"]
    pass2 = data["pass2"]

    if username == '' or email == '' or password == '' or pass2 == '':
        return jsonify({"status": "Por favor, rellene todos los datos."}), 401

    if not isvalidEmail(email):
        return jsonify({"status": "Correo electrónico inválido."}), 401

    pass_error = password_error(password)
    if pass_error is not None:
        return jsonify({"status": pass_error}), 401

    conn = get_db()
    with conn.cursor() as cur:
        cur.execute("SELECT * FROM users WHERE username = %s", (username,))
        row = cur.fetchone()
    conn.close()

    if row:
        return jsonify({"status": "El usuario ingresado ya ha sido usado."}), 401

    conn = get_db()
    with conn.cursor() as cur:
        cur.execute("SELECT * FROM users WHERE email = %s", (email,))
        row = cur.fetchone()
    conn.close()

    if row:
        return jsonify({"status": "El email ingresado ya ha sido usado."}), 401

    if password != pass2:
        return jsonify({"status": "Contraseñas No Coinciden"}), 401

    password = password.encode("utf-8")
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(password, salt).decode("utf-8")
    token = secrets.token_urlsafe(32)

    conn = get_db()
    with conn.cursor() as cur:
        cur.execute(
            "INSERT INTO users (username, email, clave, verified, verify_token) VALUES (%s, %s, %s, FALSE, %s)",
            (username, email, hashed, token)
        )
        conn.commit()
    conn.close()

    # Enviar email de verificación
    try:
        send_verification_email(email, token)
    except Exception as e:
        print(f"Error enviando email: {e}")
        # No bloqueamos el registro si falla el email, avisamos nomás
        return jsonify({"status": "Cuenta creada, pero hubo un error al enviar el email de verificación. Contacta soporte."}), 500

    return jsonify({
        "status": "RegistroExitoso"
        # Ya no devolvemos user_id porque la cuenta no está activa todavía
    }), 200


@app.route("/verify", methods=["GET"])
def verify_email():
    token = request.args.get("token")

    if not token:
        return "<h2>Token inválido.</h2>", 400

    conn = get_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT id FROM users WHERE verify_token = %s AND verified = FALSE",
            (token,)
        )
        row = cur.fetchone()
    conn.close()

    if not row:
        return "<h2>El enlace ya fue usado o es inválido.</h2>", 400

    conn = get_db()
    with conn.cursor() as cur:
        cur.execute(
            "UPDATE users SET verified = TRUE, verify_token = NULL WHERE id = %s",
            (row[0],)
        )
        conn.commit()
    conn.close()

    return "<h2>✅ Cuenta verificada. Ya puedes iniciar sesión en la app.</h2>", 200


@app.route("/revoke-session", methods=["GET"])
def revoke_session():
    token = request.args.get("token")

    if not token:
        return "<h2>Enlace inválido.</h2>", 400

    conn = get_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT id FROM users WHERE revoke_token = %s AND session_revoked = FALSE",
            (token,)
        )
        row = cur.fetchone()
    conn.close()

    if not row:
        return "<h2>El enlace ya fue usado o es inválido.</h2>", 400

    conn = get_db()
    with conn.cursor() as cur:
        cur.execute(
            "UPDATE users SET session_revoked = TRUE, revoke_token = NULL WHERE id = %s",
            (row[0],)
        )
        conn.commit()
    conn.close()

    return """
    <html><body style="font-family:sans-serif; max-width:480px; margin:60px auto; text-align:center;">
      <h2>✅ Sesión cerrada</h2>
      <p>La sesión ha sido cerrada correctamente.</p>
      <p style="color:#999; font-size:13px;">
        Si no reconoces este acceso, te recomendamos cambiar tu contraseña lo antes posible.
      </p>
    </body></html>
    """, 200


@app.route("/analyze", methods=["POST"])
def analyze():
    data = request.json
    titular = data["titular"]
    user_id = data["user_id"]

    conn = get_db()
    with conn.cursor() as cur:
        cur.execute("SELECT creditos, session_revoked FROM users WHERE ID = %s", (user_id,))
        row = cur.fetchone()
    conn.close()
    creditos, session_revoked = row[0], row[1]

    if session_revoked:
        return jsonify({"status": "Sesión revocada. Por favor, vuelve a iniciar sesión."}), 401

    if creditos > 0:
        resultado = verificar_titular(titular)
        conn = get_db()
        with conn.cursor() as cur:
            cur.execute(
                "INSERT INTO consultas (user_id, titular, score, label) VALUES (%s, %s, %s, %s)",
                (user_id, titular, resultado["score"], resultado["label"])
            )
            conn.commit()
        conn.close()

        conn = get_db()
        with conn.cursor() as cur:
            cur.execute(
                "UPDATE users SET creditos = creditos - 1 WHERE ID = %s", (user_id,)
            )
            conn.commit()
        conn.close()

        return jsonify({"resultado": resultado}), 200
    else:
        return jsonify({
            "resultado": {"score": None, "label": "Error: No tiene suficientes créditos", "fuentes": None}
        }), 401


@app.route("/user/<int:user_id>", methods=["GET"])
def get_user(user_id):
    conn = get_db()
    with conn.cursor() as cur:
        cur.execute("SELECT username, creditos FROM users WHERE ID = %s", (user_id,))
        row = cur.fetchone()
    conn.close()

    if not row:
        return jsonify({"status": "Usuario no encontrado"}), 404

    return jsonify({"username": row[0], "creditos": row[1]}), 200


@app.route("/forgot-password", methods=["POST"])
def forgot_password():
    data = request.json
    email = data.get("email", "").strip()

    if not email:
        return jsonify({"status": "Por favor, ingresa tu email."}), 400

    conn = get_db()
    with conn.cursor() as cur:
        cur.execute("SELECT id FROM users WHERE email = %s AND verified = TRUE", (email,))
        row = cur.fetchone()
    conn.close()

    # Siempre respondemos igual para no revelar si el email existe
    if row:
        token = secrets.token_urlsafe(32)
        expiry = datetime.now(timezone.utc).replace(tzinfo=None) + timedelta(hours=1)

        conn = get_db()
        with conn.cursor() as cur:
            cur.execute(
                "UPDATE users SET reset_token = %s, reset_token_expiry = %s WHERE id = %s",
                (token, expiry, row[0])
            )
            conn.commit()
        conn.close()

        try:
            send_password_reset_email(email, token)
        except Exception as e:
            print(f"Error enviando email de reset: {e}")

    return jsonify({"status": "Si el email está registrado, recibirás un correo con instrucciones."}), 200


@app.route("/reset-password", methods=["GET"])
def reset_password_page():
    token = request.args.get("token", "")

    if not token:
        return "<html><body style='font-family:sans-serif;text-align:center;margin-top:60px;background:#E4E4D8;'><h2>Enlace inválido.</h2></body></html>", 400

    conn = get_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT id FROM users WHERE reset_token = %s AND reset_token_expiry > %s",
            (token, datetime.now(timezone.utc).replace(tzinfo=None))
        )
        row = cur.fetchone()
    conn.close()

    if not row:
        return """<html><body style="font-family:sans-serif;text-align:center;margin-top:60px;background:#E4E4D8;">
        <h2>El enlace ha expirado o ya fue utilizado.</h2>
        <p>Solicita un nuevo enlace desde la app.</p>
        </body></html>""", 400

    return RESET_PASSWORD_HTML, 200


@app.route("/reset-password", methods=["POST"])
def reset_password():
    data = request.json
    token = data.get("token", "")
    password = data.get("password", "")

    if not token or not password:
        return jsonify({"status": "Datos incompletos."}), 400

    pass_error = password_error(password)
    if pass_error:
        return jsonify({"status": pass_error}), 400

    conn = get_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT id FROM users WHERE reset_token = %s AND reset_token_expiry > %s",
            (token, datetime.now(timezone.utc).replace(tzinfo=None))
        )
        row = cur.fetchone()
    conn.close()

    if not row:
        return jsonify({"status": "El enlace ha expirado o ya fue utilizado."}), 400

    hashed = bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")

    conn = get_db()
    with conn.cursor() as cur:
        cur.execute(
            "UPDATE users SET clave = %s, reset_token = NULL, reset_token_expiry = NULL WHERE id = %s",
            (hashed, row[0])
        )
        conn.commit()
    conn.close()

    return jsonify({"status": "Contraseña actualizada con éxito. Ya puedes iniciar sesión."}), 200


@app.route("/statistics", methods=["GET"])
def show_stats():
    user_id = request.args.get('id', type=int)
    if user_id is None:
        return jsonify({"error": "id requerido"}), 400

    conn = get_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT titular, score, label FROM consultas WHERE user_id = %s",
            (user_id,)
        )
        rows = cur.fetchall()
    conn.close()

    return jsonify({"data": rows}), 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)