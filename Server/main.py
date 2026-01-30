from API import verificar_titular
from conexionBDD import get_db
from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route("/login", methods = ["POST"])
def login():
    data = request.json
    username = data['username']
    password = data['password']

    conn = get_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT id, clave FROM users WHERE username = %s",
            (username,)
        )
        row = cur.fetchone()
    conn.close()

    if not row:
        return jsonify({"status": "UsuarioNoExiste"}), 401

    if password != row[1]:
        return jsonify({"status": "ContraseñaIncorrecta"}), 401

    return jsonify({
        "status": "InicioExitoso",
        "user_id": row[0]
    }), 200

@app.route("/register", methods=["POST"])
def register():
    data = request.json
    username = data["username"]
    email = data["email"]
    password = data["password"]  # luego se hashea

    conn = get_db()
    with conn.cursor() as cur:
        cur.execute(
            "INSERT INTO users (username, email, clave) VALUES (%s, %s, %s)",
            (username, email, password)
        )
        conn.commit()
    conn.close()

    return jsonify({"status": "RegistroExitoso"}), 200


@app.route("/analyze", methods=["POST"])
def analyze():
    data = request.json
    titular = data["titular"]

    resultado = verificar_titular(titular)

    return jsonify({
        "resultado": resultado
    })

if __name__ == '__main__':
    app.run()