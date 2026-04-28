# Zenda — AI-Powered Finance App

Zenda is a thesis project: an AI-powered mobile finance app for Peruvian university students (18–24). It helps users track income and expenses, follow the 50/30/20 budget rule, and improve financial literacy through personalized recommendations and gamification.

## Monorepo Structure

| Folder | Stack | Purpose |
|--------|-------|---------|
| `zenda_backend_app/` | NestJS 11, Prisma, PostgreSQL 15 | REST API |
| `zenda_fronted_app/` | Flutter 3.10+, Riverpod 3 | Mobile app (iOS/Android) |
| `docs/` | Markdown | Architecture and design docs |

## Quick Start

### Prerequisites
- Node.js 20+
- Docker Desktop
- Flutter SDK 3.10+

### Backend
```bash
cd zenda_backend_app
cp .env.example .env        # fill in values
docker compose up -d        # start PostgreSQL
npm install
npm run prisma:migrate
npm run prisma:seed
npm run start:dev           # http://localhost:3000
```

### Frontend
```bash
cd zenda_fronted_app
flutter pub get
flutter run
```


## API Documentation
Swagger UI is available at `http://localhost:3000/api/docs` when the backend is running.

## Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md) for branching model, commit conventions, and PR process.

## Setup
See [SETUP.md](SETUP.md) for a full environment reference including all environment variables.
