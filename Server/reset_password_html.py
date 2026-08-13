RESET_PASSWORD_HTML = """<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Fake News Detector – Cambio de contraseña</title>
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      min-height: 100vh;
      background-color: #E4E4D8;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 20px;
      color: #1D1D1B;
    }
    .card {
      background: rgba(255,255,255,0.86);
      border-radius: 24px;
      padding: 36px 28px;
      max-width: 420px;
      width: 100%;
      box-shadow: 0 8px 20px rgba(0,0,0,0.08);
      border: 1px solid rgba(255,255,255,0.8);
    }
    .shield-wrap { display: flex; justify-content: center; margin-bottom: 10px; }
    .shield-wrap svg { width: 40px; height: 40px; }
    h1 {
      text-align: center;
      font-size: 26px;
      font-weight: 800;
      color: #1D1D1B;
      margin-bottom: 4px;
    }
    h2 {
      text-align: center;
      font-size: 15px;
      font-weight: 500;
      color: #666;
      margin-bottom: 28px;
    }
    .field { margin-bottom: 14px; }
    label { display: block; font-size: 13px; color: #555; margin-bottom: 5px; font-weight: 500; }
    input[type=password] {
      width: 100%;
      padding: 13px 15px;
      border: 1px solid #ddd;
      border-radius: 12px;
      font-size: 15px;
      outline: none;
      transition: border-color 0.2s;
      background: white;
    }
    input[type=password]:focus { border-color: #EF342A; }
    .btn {
      display: block;
      width: 100%;
      padding: 14px;
      background: #EF342A;
      color: white;
      border: none;
      border-radius: 14px;
      font-size: 16px;
      font-weight: 700;
      cursor: pointer;
      margin-top: 12px;
      transition: opacity 0.2s;
    }
    .btn:hover { opacity: 0.88; }
    .btn:disabled { opacity: 0.55; cursor: default; }
    .msg { text-align: center; margin-top: 16px; font-size: 14px; font-weight: 600; min-height: 20px; }
    .error { color: #EF342A; }
    .success { color: #2e7d32; }
  </style>
</head>
<body>
<div class="card">
  <div class="shield-wrap">
    <svg viewBox="0 0 24 24" fill="#EF342A" xmlns="http://www.w3.org/2000/svg">
      <path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4z"/>
    </svg>
  </div>
  <h1>Fake News Detector</h1>
  <h2>Cambio de contrase&ntilde;a</h2>
  <div class="field">
    <label for="password">Nueva contrase&ntilde;a</label>
    <input type="password" id="password" placeholder="Nueva contrase&ntilde;a">
  </div>
  <div class="field">
    <label for="confirm">Confirmar contrase&ntilde;a</label>
    <input type="password" id="confirm" placeholder="Confirmar contrase&ntilde;a">
  </div>
  <button class="btn" id="btn" onclick="submitForm()">Cambiar contrase&ntilde;a</button>
  <p class="msg" id="msg"></p>
</div>
<script>
  function validatePassword(p) {
    if (p.length < 8) return 'Mínimo 8 caracteres';
    if (!/[a-z]/.test(p)) return 'Debe incluir una minúscula';
    if (!/[A-Z]/.test(p)) return 'Debe incluir una mayúscula';
    if (!/[0-9]/.test(p)) return 'Debe incluir un número';
    if (!/[!@#$%^&*(),\\.?":{}|<>_\\-]/.test(p)) return 'Debe incluir un símbolo';
    return null;
  }
  async function submitForm() {
    var pw = document.getElementById('password').value;
    var cf = document.getElementById('confirm').value;
    var msgEl = document.getElementById('msg');
    var btn = document.getElementById('btn');
    var token = new URLSearchParams(window.location.search).get('token');
    var err = validatePassword(pw);
    if (err) { msgEl.className = 'msg error'; msgEl.textContent = err; return; }
    if (pw !== cf) { msgEl.className = 'msg error'; msgEl.textContent = 'Las contraseñas no coinciden.'; return; }
    btn.disabled = true;
    btn.textContent = 'Cargando...';
    msgEl.textContent = '';
    try {
      var res = await fetch('/reset-password', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ token: token, password: pw })
      });
      var data = await res.json();
      if (res.ok) {
        msgEl.className = 'msg success';
        msgEl.textContent = data.status;
        document.getElementById('password').value = '';
        document.getElementById('confirm').value = '';
        btn.style.display = 'none';
      } else {
        msgEl.className = 'msg error';
        msgEl.textContent = data.status;
        btn.disabled = false;
        btn.textContent = 'Cambiar contraseña';
      }
    } catch (e) {
      msgEl.className = 'msg error';
      msgEl.textContent = 'Error de conexión. Intenta de nuevo.';
      btn.disabled = false;
      btn.textContent = 'Cambiar contraseña';
    }
  }
</script>
</body>
</html>"""