# 🛡️ Fake News Detector

**Fake News Detector** es una aplicación móvil y web que permite verificar la veracidad de titulares de noticias utilizando inteligencia artificial. El sistema analiza el texto ingresado, realiza búsquedas web en tiempo real y entrega un puntaje de credibilidad junto con una breve explicación y las fuentes consultadas.

Proyecto desarrollado por **Matías**, estudiante de Ciencia de la Computación.

🌐 **App en producción:** [fake-news-detector.com](https://fake-news-detector.com)
📱 **Disponible en Google Play**

---

## ✨ Características

- **Verificación de titulares con IA**: análisis de credibilidad mediante Claude (Anthropic) con búsqueda web integrada, retornando porcentaje de veracidad, explicación y fuentes citables.
- **Autenticación completa**: registro con verificación por correo, inicio de sesión con usuario o email, JWT para manejo de sesiones.
- **Seguridad reforzada**:
  - Contraseñas hasheadas con bcrypt.
  - Rate limiting global y por endpoint (Redis).
  - Bloqueo temporal de cuenta tras múltiples intentos fallidos de login.
  - Alerta por correo en cada inicio de sesión, con opción de revocar la sesión con un click.
  - Recuperación de contraseña vía email con tokens de un solo uso y expiración de 1 hora.
  - Validación de contraseñas robustas (mayúscula, minúscula, número, símbolo, largo mínimo).
- **Historial de consultas**: cada usuario puede revisar los titulares que ha analizado previamente y sus resultados.
- **Sistema de créditos y pagos**:
  - Modelo freemium: créditos gratuitos al registrarse, consumo de 1 crédito por consulta.
  - Compra de créditos adicionales vía **Mercado Pago Checkout Pro**.
  - Verificación de pagos por webhook (con validación de firma HMAC) y por verificación activa al reabrir la app, con protección contra doble acreditación.
- **Multiplataforma**: funciona en Android y en la Web con una única base de código Flutter.

---

## 🧱 Stack Tecnológico

| Capa | Tecnología |
|---|---|
| Frontend | Flutter (Dart) — Android y Web |
| Backend | Flask (Python) + Gunicorn |
| Base de datos | PostgreSQL 16 |
| Cache / Rate limiting | Redis 7 |
| Pagos | Mercado Pago (Checkout Pro) |
| LLM | Anthropic Claude Haiku 4.5 con web search |
| Infraestructura | AWS EC2, Docker Compose, Nginx, Let's Encrypt |
| DNS | Cloudflare |

---

## 🏗️ Arquitectura
```
APP_FakeNews/
├── Client/                   # Aplicación Flutter (Android + Web)
├── DataBase/
│   └── Tablas.sql            # Esquema de base de datos PostgreSQL
├── Server/                   # Backend Flask
│   ├── main.py               # Rutas y lógica principal de la API
│   ├── API.py                # Integración con el LLM (Anthropic/Gemini)
│   ├── conexionBDD.py        # Conexión a PostgreSQL
│   ├── email_sender.py       # Envío de correos transaccionales
│   ├── funciones_extra.py    # Validaciones, JWT, rate limiting
│   ├── parametros.py         # Capa de configuración (.env)
│   └── Dockerfile
├── docker-compose.yml
├── .env
└── README.md
```

En producción, el backend corre en contenedores Docker (Flask/Gunicorn, PostgreSQL, Redis) detrás de un **Nginx** en el host que se encarga de la terminación SSL y del reverse proxy hacia el backend, además de servir los archivos estáticos de Flutter Web.

---

## 🔐 Modelo de negocio

Cada usuario recibe créditos gratuitos al registrarse. Cada consulta de un titular consume 1 crédito. Cuando se agotan, el usuario puede comprar créditos adicionales a través de Mercado Pago.

Este modelo permite mantener el proyecto operativo (cubriendo los costos de la API del LLM) sin dejar de ser accesible para el usuario promedio.

---

## 📦 Open Source, Closed Service

Este proyecto sigue el modelo **"open source, closed service"**: el código es público, pero el servicio desplegado en `fake-news-detector.com` es una instancia propia y privada. Las credenciales (API keys, secretos de base de datos, credenciales de Mercado Pago, etc.) se gestionan mediante variables de entorno (`.env`, excluido del repositorio) y no se incluyen en el código fuente.

Si quieres correr tu propia instancia, necesitarás tus propias credenciales de:
- Anthropic API (Claude)
- Base de datos PostgreSQL
- Redis
- Cuenta de correo (SMTP, ej. Gmail con contraseña de aplicación)
- Mercado Pago (Access Token y Webhook Secret)

---

## 🚀 Levantar el proyecto localmente

### Requisitos
- Docker y Docker Compose
- Flutter SDK (para el cliente)
- Cuenta de Anthropic con API key
- Cuenta de Mercado Pago (modo sandbox para pruebas)

### Backend

1. Clona el repositorio y ubícate en `Server/`.
2. Crea un archivo `.env` con las siguientes variables:

```env
DB_HOST=
DB_NAME=
DB_USER=
DB_PASSWORD=

JWT_SECRET=
LOCKOUT_MAX_ATTEMPTS=5
LOCKOUT_DURATION=15

EMAIL_SENDER=
EMAIL_PASSWORD=

APP_BASE_URL=

ANTHROPIC_API_KEY=
MODEL_ID=claude-haiku-4-5

MP_ACCESS_TOKEN=
MP_WEBHOOK_SECRET=
```

3. Levanta los servicios:

```bash
docker compose up --build
```

Esto inicia el backend (Flask/Gunicorn), PostgreSQL y Redis.

4. Aplica el esquema de base de datos:

```bash
psql -h localhost -U <usuario> -d <db> -f DataBase/Tablas.sql
```

### Frontend

1. Ubícate en `Client/`.
2. Ajusta `API_BASE_URL` en `parametros.dart` para apuntar a tu backend local.
3. Ejecuta:

```bash
flutter pub get
flutter run
```

Para compilar la versión Android release, asegúrate de tener el permiso de Internet declarado explícitamente en `AndroidManifest.xml` y de usar un JDK (no solo un JRE) configurado en `android/gradle.properties`.

---

## 🗄️ Esquema de base de datos

- **users**: credenciales, créditos, estado de verificación, tokens de sesión/reset.
- **consultas**: historial de titulares analizados por usuario, con score y explicación.
- **pagos_procesados**: registro de pagos acreditados, usado para prevenir doble acreditación de créditos.

---

## 🔗 Endpoints principales de la API

| Método | Ruta | Descripción |
|---|---|---|
| POST | `/register` | Crear cuenta (requiere verificación por email) |
| GET | `/verify` | Verificar cuenta desde el link enviado por correo |
| POST | `/login` | Iniciar sesión, retorna JWT |
| GET | `/revoke-session` | Revocar sesión activa desde el correo de alerta |
| POST | `/forgot-password` | Solicitar link de recuperación de contraseña |
| POST | `/reset-password` | Establecer nueva contraseña |
| POST | `/analyze` | Analizar un titular (requiere autenticación y créditos) |
| GET | `/statistics` | Historial de consultas del usuario |
| GET | `/user/me` | Información del usuario autenticado |
| POST | `/buy-credits` | Generar preferencia de pago en Mercado Pago |
| POST | `/webhook/mp` | Webhook de notificaciones de Mercado Pago |
| POST | `/verify-pending-payments` | Verificación activa de pagos pendientes |

Todas las rutas protegidas requieren el header `Authorization: Bearer <token>`.

---

## 🌳 Convención de ramas

- `feature/` — nuevas funcionalidades
- `fix/` — corrección de bugs
- `chore/` — tareas de mantenimiento
- `security/` — parches de seguridad
- `docs/` — documentación

Los nombres de rama van en minúscula, en inglés, separados por guiones, sin tildes ni caracteres especiales. Los Pull Requests se dirigen a la rama `develop`.
