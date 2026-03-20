# Zenda — Environment Setup Guide

Complete step-by-step guide to set up the development environment.

---

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Git | Latest | https://git-scm.com |
| Node.js | 20 LTS | https://nodejs.org |
| Docker Desktop | Latest | https://docker.com |
| Flutter SDK | 3.10+ | https://flutter.dev |
| Python | 3.11+ | https://python.org |
| Android Studio | Latest | For Android emulator |

---

## 1. Clone the Repository

```bash
git clone https://github.com/<org>/zenda.git
cd zenda
```

---

## 2. Backend Setup (`zenda_backend_app/`)

### 2.1 Environment Variables

```bash
cd zenda_backend_app
cp .env.example .env
```

Edit `.env` and fill in all required values (see variable reference below).

### 2.2 Start the Database

```bash
docker compose up -d
```

Verify it's running:
```bash
docker ps  # should show zenda-postgres
```

### 2.3 Install Dependencies

```bash
npm install
```

### 2.4 Run Migrations

```bash
npm run prisma:migrate
```

### 2.5 Seed Default Data

Loads system categories, challenges, badges, and educational topics:

```bash
npm run prisma:seed
```

### 2.6 Start the Server

```bash
npm run start:dev
```

- API: [http://localhost:3000/api](http://localhost:3000/api)
- Swagger docs: [http://localhost:3000/api/docs](http://localhost:3000/api/docs)
- Health check: [http://localhost:3000/api/health](http://localhost:3000/api/health)

---

## 3. Frontend Setup (`zenda_fronted_app/`)

### 3.1 Install Flutter Dependencies

```bash
cd zenda_fronted_app
flutter pub get
```

### 3.2 Run on Device/Emulator

```bash
flutter devices          # list available devices
flutter run -d <device>  # run on specific device
```

### 3.3 Analyze Code

```bash
flutter analyze
```

---

## 4. ML Pipeline Setup (`ml/`)

```bash
cd ml
python -m venv .venv
source .venv/bin/activate    # Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

---

## Backend Environment Variables Reference

| Variable | Description | Example |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://zenda:zenda@localhost:5433/zenda?schema=public` |
| `POSTGRES_DB` | Database name | `zenda` |
| `POSTGRES_USER` | Database user | `zenda` |
| `POSTGRES_PASSWORD` | Database password | `changeme` |
| `POSTGRES_PORT` | Host port for PostgreSQL | `5433` |
| `PORT` | API server port | `3000` |
| `NODE_ENV` | Runtime environment | `development` |
| `APP_NAME` | Application name shown in Swagger | `ZENDA API` |
| `JWT_SECRET` | Secret key for JWT signing — **must be >= 32 chars in production** | `replace-with-secure-random-string` |
| `JWT_EXPIRES_IN` | JWT token lifetime | `30d` |
| `BCRYPT_ROUNDS` | bcrypt cost factor (12 recommended) | `12` |
| `AZURE_OPENAI_ENDPOINT` | Azure OpenAI resource endpoint | `https://your-resource.openai.azure.com/` |
| `AZURE_OPENAI_KEY` | Azure OpenAI API key | `replace-with-key` |
| `FCM_SERVER_KEY` | Firebase Cloud Messaging server key (Phase 11) | `replace-with-fcm-key` |

---

## Secrets Management

- **Never commit `.env` files.** Only `.env.example` is tracked.
- For CI/CD, store secrets in GitHub Secrets (Settings → Secrets and variables → Actions).
- Required GitHub Secrets:
  - `AZURE_CREDENTIALS` — for Azure deployment
  - `GOOGLE_PLAY_KEY` — for Play Store deployment

---

## Common Issues

### Database connection refused
Make sure Docker is running and the container is healthy:
```bash
docker compose up -d
docker logs zenda-postgres
```

### `prisma generate` fails
Run manually before building:
```bash
npx prisma generate
```

### Flutter: `pub get` fails
```bash
flutter clean
flutter pub cache repair
flutter pub get
```
