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
- Node.js 22.x (backend engine >=22 <23)
- Docker Desktop
- Flutter compatible with Dart >=3.10 (audit: Flutter 3.41.6 / Dart 3.11.4)

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
flutter run --flavor dev --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
```


## API Documentation
Swagger UI is available at `http://localhost:3000/api/docs` when the backend is running.

## Pilot Validation

See [pilot readiness](docs/pilot-readiness/09_PILOT_READINESS_REPORT.md) for the audit, pending acceptance criteria and exact local verification commands. Existing Jest suites use mocked persistence, not a real PostgreSQL database. Do not reset or seed production from the local setup instructions.

## Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md) for branching model, commit conventions, and PR process.

## Setup
See [SETUP.md](SETUP.md) for a full environment reference including all environment variables.
