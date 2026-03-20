# Phase 1A: Development Environment Setup

## Context

Before this phase, the repository had no shared conventions, no CI/CD pipeline, a single-entry `.gitignore`, and no documentation beyond a Spanish-language backend README. There was no `ml/` directory for the Python pipeline, no `docs/` folder, and no environment variable reference. This phase establishes every piece of scaffolding that all future phases depend on: repository conventions, automation, environment configuration, and the health check endpoint. References: US-1801, US-1803, US-1804.

## Tasks Completed

1. Root `.gitignore` updated — comprehensive coverage for Node.js, Flutter/Dart, Python, env files, OS artifacts, and IDE folders
2. Root `README.md` created — monorepo overview, quick start for backend/frontend/ML, architecture summary, branch strategy table
3. `CONTRIBUTING.md` created — branching model, Conventional Commits format, PR process, and pointer to coding standards
4. `LICENSE` created — MIT license, 2026
5. `SETUP.md` created — full step-by-step setup with environment variable reference table and troubleshooting section
6. `zenda_backend_app/.env.example` updated — added `FCM_SERVER_KEY`, corrected `JWT_EXPIRES_IN` to `30d` per US-0102, added phase comments for each variable group
7. `zenda_backend_app/README.md` translated to English — setup instructions, scripts table, and endpoint table
8. `.github/workflows/ci.yml` created — two jobs: backend (Node 20 → `npm ci` → `prisma generate` → `nest build`) and frontend (Flutter 3.10 → `pub get` → `flutter analyze`)
9. `ml/` folder created — `README.md` with pipeline overview, feature set, model candidates, and implementation status; `requirements.txt` with Python dependencies
10. `docs/` folder created — documentation index referencing all pending architecture docs and the key design decisions table
11. `CLAUDE.md` updated — added `ml/`, `docs/`, `specs/` to Structure block; added Phase Documentation section with trigger conditions, output format, and rule summary; added `phase_docs_prompt.md` pointer to Documentation Index
12. `src/health/health.controller.ts` updated — response now includes `version: "1.0.0"`
13. `src/health/dto/health.response.dto.ts` updated — added `version` field with `@ApiProperty` decorator

## What Was Built

### REST API

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/health` | Returns `{ status: "ok", version: "1.0.0", timestamp: <ISO8601> }` |

### CI/CD Pipeline

| Job | Trigger | Steps |
|-----|---------|-------|
| `backend` | Push/PR to `main`, `develop` | checkout → Node 20 → `npm ci` → `prisma generate` → `nest build` |
| `frontend` | Push/PR to `main`, `develop` | checkout → Flutter 3.10 → `flutter pub get` → `flutter analyze --no-fatal-infos` |

### Monorepo Structure Established

```
Tesis2026/
├── zenda_backend_app/   — NestJS API
├── zenda_fronted_app/   — Flutter app
├── ml/                  — Python ML pipeline (Phase 7–8)
├── docs/                — Architecture and demo docs (Phase 16)
├── specs/               — Phase documentation (this system)
├── .github/workflows/   — CI/CD
├── README.md
├── CONTRIBUTING.md
├── LICENSE
├── SETUP.md
└── CLAUDE.md
```
