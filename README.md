# Zenda — AI-Powered Financial Education App

Zenda is a mobile personal finance application that uses artificial intelligence to help Peruvian university students (ages 18–24) record, understand, and predict their financial behavior.

> **Thesis Project** · Universidad · 2026
> Team: Paolo Guillen Luna · Fernando Quispe Condori · Advisor: Diego Rojas Sihuay

---

## Project Structure

```
Tesis2026/
├── zenda_backend_app/    # NestJS 11 + Prisma + PostgreSQL REST API
├── zenda_fronted_app/    # Flutter 3.10+ mobile app (Android)
├── ml/                   # Python ML pipeline (predictions, anomaly detection)
├── docs/                 # Architecture, design docs, and demo scripts
├── .github/workflows/    # CI/CD (GitHub Actions)
└── CLAUDE.md             # Project conventions for AI-assisted development
```

---

## Quick Start

### Prerequisites

| Tool | Version |
|------|---------|
| Node.js | 20+ |
| Flutter SDK | 3.10+ |
| Docker Desktop | Latest |
| Python | 3.11+ |

### 1. Clone

```bash
git clone https://github.com/<org>/zenda.git
cd zenda
```

### 2. Backend

```bash
cd zenda_backend_app
cp .env.example .env          # fill in secrets
docker compose up -d          # start PostgreSQL
npm install
npm run prisma:migrate        # run migrations
npm run prisma:seed           # seed default data
npm run start:dev             # http://localhost:3000
```

API docs: [http://localhost:3000/api/docs](http://localhost:3000/api/docs)

### 3. Frontend

```bash
cd zenda_fronted_app
flutter pub get
flutter run                   # requires connected Android device or emulator
```

### 4. ML Pipeline

```bash
cd ml
python -m venv .venv
source .venv/bin/activate     # Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

---

## Architecture

```
Android App (Flutter)
      │  HTTPS / JWT
      ▼
NestJS REST API ──► PostgreSQL 15
      │
      ▼
Python ML Pipeline (Azure / TFLite)
```

**Key design decisions:**
- 50/30/20 budget rule: Needs / Wants / Savings
- AI suggests, the user decides — no automatic transactions
- Currency: PEN (Peruvian Sol, `S/`)
- Offline-first mobile with periodic API sync

---

## Branch Strategy

| Branch | Purpose |
|--------|---------|
| `main` | Protected — production-ready releases only |
| `develop` | Integration branch for completed features |
| `feature/<name>` | Individual feature development |

---

## Documentation

- [`docs/`](docs/) — Architecture diagrams, DB schema, AI flow, demo script
- [`zenda_backend_app/README.md`](zenda_backend_app/README.md) — Backend setup
- [`zenda_fronted_app/README.md`](zenda_fronted_app/README.md) — Frontend setup
- [`ml/README.md`](ml/README.md) — ML pipeline overview
- [`CONTRIBUTING.md`](CONTRIBUTING.md) — Contribution guidelines
- [`SETUP.md`](SETUP.md) — Detailed environment setup

---

## Thesis Success Metrics

| Metric | Target |
|--------|--------|
| AI prediction accuracy | ≥ 80% |
| Daily active users | ≥ 50% |
| Financial literacy improvement | ≥ 20% |
| SUS usability score | ≥ 4.0 / 5.0 |
| 30-day retention | ≥ 40% |
| Critical error rate | < 1% |
