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
  - Currently local-only (no API integration yet)

## Key Design Decisions
- 50/30/20 budget rule: Needs / Wants / Savings
- Category-to-bucket mapping is in `transaction.dart:bucketForCategory()`
- Account types: cash, debit, credit — each with different mutation rules
- Streak system for daily engagement gamification

## Roadmap Documentation

Phase specs live in `.claude/specs/<phase>/`. **After implementing any roadmap phase, Claude must create or update all four spec files for that phase.**

### File responsibilities

| File | What goes in it |
|------|----------------|
| `spec.md` | Context (what existed before), tasks completed (numbered list), what was built (tables/diagrams per model/feature) |
| `shape.md` | Every non-obvious architecture or data-model decision with rationale; constraints enforced and where (DB vs service layer) |
| `standards.md` | Coding patterns applied: naming, validation, error handling, testing — anything a future dev must follow to stay consistent |
| `references.md` | Key files changed and what changed in each; test files added; external standards or skills referenced |

### Templates

**`spec.md`**
```markdown
# Phase <id>: <title>

## Context
<What existed before this phase. What gap it closes. User stories covered (e.g. US-XXXX).>

## Tasks Completed
1. `<file path>` — <what changed>
2. ...

## What Was Built
### <Feature / Model name> (<user story>)
<Description. Tables for fields, state machines for flows.>
```

**`shape.md`**
```markdown
# Shape: Phase <id> — <title>

## Decisions
- **<Decision title>** — <what was chosen and why; what the alternative was and why it was rejected>

## Constraints
- <Invariant> — enforced by <schema @@unique / service layer / controller guard>
```

**`standards.md`**
```markdown
# Standards Applied: Phase <id> — <title>

## <Layer (Database / Service / API / Frontend)>
- **<Pattern name>:** <rule and rationale>
```

**`references.md`**
```markdown
# References: Phase <id> — <title>

## Key Files
| File | Change |
|------|--------|
| `<path>` | <what changed> |

## Test Files
<List test files added, or "No test files were created in this phase.">

## Standards Applied
- `<skill or doc path>` — <which rules from it were applied>
```

### Rules
- Read the existing spec (if any) before implementing — it defines the expected shape.
- Write specs **after** implementation, using the actual code as the source of truth.
- Every decision in `shape.md` must state the alternative that was considered.
- `references.md` must list every file that was created or modified.
- Update the **Current phases** list below when a new phase spec is added.

### Current phases
- `phase-1a` — Backend scaffolding and core infrastructure (NestJS, Prisma, JWT auth, 5 feature modules)
- `phase-1b` — Database design (Prisma schema, PostgreSQL)

## Thesis Success Metrics
| Metric | Target |
|--------|--------|
| AI prediction accuracy | >=80% |
| Daily active users | >=50% |
| Financial literacy improvement | >=20% |
| SUS usability score | >=4.0/5.0 |
| 30-day retention | >=40% |
| Critical error rate | <1% |
