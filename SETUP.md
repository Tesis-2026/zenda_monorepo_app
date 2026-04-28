# Setup Guide

## Environment Variables — Backend

Copy `zenda_backend_app/.env.example` to `zenda_backend_app/.env` and fill in:

| Variable | Example | Description |
|----------|---------|-------------|
| `DATABASE_URL` | `postgresql://postgres:postgres@localhost:5433/zenda_db` | PostgreSQL connection string |
| `JWT_SECRET` | `change-me-in-production` | JWT signing secret (min 32 chars in prod) |
| `JWT_EXPIRES_IN` | `30d` | Token lifetime |
| `BCRYPT_ROUNDS` | `12` | Password hashing rounds (10 dev / 12 prod) |
| `AZURE_OPENAI_ENDPOINT` | `https://...` | Azure OpenAI endpoint (optional) |
| `AZURE_OPENAI_KEY` | `...` | Azure OpenAI API key (optional) |
| `PORT` | `3000` | Backend server port |

## Docker

The backend requires PostgreSQL 15. Start it with:

```bash
cd zenda_backend_app
docker compose up -d
```

The `docker-compose.yml` exposes PostgreSQL on port **5433** (not 5432) to avoid conflicts with local installs.

## Database

After Docker is running:

```bash
npm run prisma:migrate   # apply migrations
npm run prisma:seed      # seed categories, badges, challenges, topics, surveys
```

To reset and reseed:

```bash
npx prisma migrate reset  # drops and recreates the DB
npm run prisma:seed
```

## Running Tests

```bash
# Backend unit tests
cd zenda_backend_app
npm run test

# Backend e2e tests
npm run test:e2e
```

