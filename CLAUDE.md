# Zenda (WalletWise) — Project Conventions

## Overview
Zenda is an AI-powered mobile finance app (thesis project) targeting Peruvian university students (18-24). The codebase is a monorepo with a NestJS backend and Flutter frontend.

## Structure
```
Tesis2026/
├── zenda_backend_app/   # NestJS + Prisma + PostgreSQL API
├── zenda_fronted_app/   # Flutter + Riverpod mobile app (note: "fronted" is the actual folder name)
└── CLAUDE.md            # This file
```

## Language
- All code, comments, variable names, and user-facing strings must be in **English**.
- Enum values in `transaction.dart` (e.g., `comida`, `necesidad`) are kept as-is for serialization compatibility — only display labels are translated.
- Currency remains PEN (Peruvian Sol) with `S/` symbol.

## Backend (zenda_backend_app)
- **Stack**: NestJS 11, Prisma ORM, PostgreSQL 15 (Docker), JWT auth
- **Run**: `npm run start:dev` — serves on `http://localhost:3000`
- **API docs**: `http://localhost:3000/api/docs` (Swagger)
- **Database**: `docker compose up -d`, then `npm run prisma:migrate && npm run prisma:seed`
- **Conventions**:
  - Modules in `src/modules/` follow NestJS module pattern (controller, service, DTOs)
  - All entities use soft deletes (`deletedAt` field)
  - DTOs use `class-validator` decorators
  - Responses use `SuccessResponseDto` wrapper
  - `@UserId()` decorator extracts user from JWT payload

## Frontend (zenda_fronted_app)
- **Stack**: Flutter 3.10+, Dart, Riverpod 3, GoRouter, fl_chart
- **Run**: `flutter run` (requires Flutter SDK)
- **Conventions**:
  - Feature-based directory structure under `lib/features/`
  - State management: Riverpod `Notifier` + `Provider` patterns
  - Routing: GoRouter in `lib/routing/app_router.dart`
  - Local storage: SharedPreferences via `LocalKvStore`
  - Theme: Light/dark themes in `lib/core/theme/`
  - Models in `lib/core/models/`, services in `lib/core/services/`
  - API services in `lib/core/services/` — one service per backend module (auth, transactions, budgets, goals, categories, insights, users)
  - Localization: `lib/l10n/` with English and Spanish via Flutter gen-l10n (`AppLocalizations`)

## Key Design Decisions
- 50/30/20 budget rule: Needs / Wants / Savings
- Category-to-bucket mapping is in `transaction.dart:bucketForCategory()`
- Account types: cash, debit, credit — each with different mutation rules
- Streak system for daily engagement gamification

## Thesis Success Metrics
| Metric | Target |
|--------|--------|
| AI prediction accuracy | >=80% |
| Daily active users | >=50% |
| Financial literacy improvement | >=20% |
| SUS usability score | >=4.0/5.0 |
| 30-day retention | >=40% |
| Critical error rate | <1% |
