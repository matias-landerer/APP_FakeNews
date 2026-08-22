VERIFY_SUCCESS_HTML = """<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Fake News Detector – Cuenta verificada</title>
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
      text-align: center;
    }
    .icon-wrap {
      display: flex;
      justify-content: center;
      margin-bottom: 14px;
    }
    .icon-wrap svg { width: 48px; height: 48px; }
    h1 {
      font-size: 24px;
      font-weight: 800;
      color: #1D1D1B;
      margin-bottom: 8px;
    }
    p {
      font-size: 15px;
      color: #666;
      line-height: 1.5;
    }
    .brand {
      margin-top: 24px;
      font-size: 12px;
      color: #999;
      font-weight: 600;
    }
  </style>
</head>
<body>
<div class="card">
  <div class="icon-wrap">
    <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4z" fill="#EF342A"/>
      <path d="M8 12.5l2.7 2.7L16.5 9" stroke="white" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
    </svg>
  </div>
  <h1>¡Cuenta verificada!</h1>
  <p>Tu cuenta ha sido verificada correctamente.<br>Ya puedes volver a la app e iniciar sesión.</p>
  <div class="brand">Fake News Detector</div>
</div>
</body>
</html>"""


REVOKE_SUCCESS_HTML = """<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Fake News Detector – Sesión cerrada</title>
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
      text-align: center;
    }
    .icon-wrap {
      display: flex;
      justify-content: center;
      margin-bottom: 14px;
    }
    .icon-wrap svg { width: 48px; height: 48px; }
    h1 {
      font-size: 24px;
      font-weight: 800;
      color: #1D1D1B;
      margin-bottom: 8px;
    }
    p {
      font-size: 15px;
      color: #666;
      line-height: 1.5;
    }
    .note {
      margin-top: 18px;
      font-size: 13px;
      color: #999;
      background: #E4E4D8;
      border-radius: 12px;
      padding: 10px 14px;
      border: 1px solid rgba(239,52,42,0.2);
    }
    .brand {
      margin-top: 20px;
      font-size: 12px;
      color: #999;
      font-weight: 600;
    }
  </style>
</head>
<body>
<div class="card">
  <div class="icon-wrap">
    <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4z" fill="#EF342A"/>
      <path d="M8 12.5l2.7 2.7L16.5 9" stroke="white" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
    </svg>
  </div>
  <h1>Sesión cerrada</h1>
  <p>La sesión ha sido cerrada correctamente.</p>
  <div class="note">Si no reconoces este acceso, te recomendamos cambiar tu contraseña lo antes posible.</div>
  <div class="brand">Fake News Detector</div>
</div>
</body>
</html>"""