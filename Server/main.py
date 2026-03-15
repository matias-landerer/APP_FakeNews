import bcrypt
from API import verificar_titular
from conexionBDD import get_db
from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route("/login", methods = ["POST"])
def login():
    data = request.json
    username_mail = data['username_mail']
    password = data['password']

    if username_mail == ''or password == '':
        return jsonify({"status": "Por favor, rellene todos los datos."}), 401

    password = password.encode("utf-8")

    conn = get_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT id, clave FROM users WHERE username = %s",
            (username_mail,)
        )
        row = cur.fetchone()
    conn.close()

    if not row:
        conn = get_db()
        with conn.cursor() as cur:
            cur.execute(
                "SELECT id, clave FROM users WHERE email = %s",
                (username_mail,)
            )
            row = cur.fetchone()
        conn.close()

        if not row:
            return jsonify({"status": "Usuario ingresado no existe."}), 401

    hashed = row[1].encode("utf-8") if isinstance(row[1], str) else row[1]
    
    if not bcrypt.checkpw(password, hashed):
        return jsonify({"status": "Contraseña incorrecta"}), 401

    return jsonify({
        "status": "InicioExitoso",
        "user_id": row[0]
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

    conn = get_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT * FROM users WHERE username = %s",
            (username,)
        )
        row = cur.fetchone()
    conn.close()

    if row:
        return jsonify({"status": "El usuario ingresado ya ha sido usado."}), 401
    
    conn = get_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT * FROM users WHERE email = %s",
            (email,)
        )
        row = cur.fetchone()
    conn.close()

    if row:
        return jsonify({"status": "El email ingresado ya ha sido usado."}), 401

    if password != pass2:
        return jsonify({"status": "Contraseñas No Coinciden"}), 401

    password = password.encode("utf-8")
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(password, salt).decode("utf-8")

    conn = get_db()
    with conn.cursor() as cur:
        cur.execute(
            "INSERT INTO users (username, email, clave) VALUES (%s, %s, %s)",
            (username, email, hashed)
        )
        conn.commit()
    conn.close()

    conn = get_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT * FROM users WHERE username = %s",
            (username,)
        )
        row = cur.fetchone()
    conn.close()

    return jsonify({
        "status": "RegistroExitoso",
        "user_id": row[0]
        }), 200

@app.route("/analyze", methods=["POST"])
def analyze():
    data = request.json
    titular = data["titular"]
    user_id = data["user_id"]

    conn = get_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT creditos FROM users WHERE ID = %s",
            (user_id,)
        )
        row = cur.fetchone()
    conn.close()
    creditos = row[0]

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

        return jsonify({
            "resultado": resultado
        }), 200
    else:
        return jsonify({
            "resultado": {"score": None, "label": "Error: No tiene suficientes créditos", "fuentes": None}
        }), 401

@app.route("/statistics", methods=["GET"])
def show_stats():
    data = request.json
    user_id = data['id']
    
    conn = get_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT titular, score, label FROM consultas WHERE user_id = %s",
            (user_id,)
        )
        rows = cur.fetchall()
    conn.close()

    return jsonify({"data" : rows}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)