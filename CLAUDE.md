# Zenda (WalletWise) — Project Conventions

## Overview
Zenda is an AI-powered mobile finance app (thesis project) targeting Peruvian university students (18-24). The codebase is a monorepo with a NestJS backend and Flutter frontend.

## Structure
```
Tesis2026/
├── zenda_backend_app/   # NestJS + Prisma + PostgreSQL API
├── zenda_fronted_app/   # Flutter + Riverpod mobile app (note: "fronted" is the actual folder name)
├── ml/                  # Python ML pipeline (Phase 7–8)
├── docs/                # Architecture docs, demo script (Phase 16)
├── specs/               # Phase documentation — one folder per completed phase
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

## Thesis Success Metrics
| Metric | Target |
|--------|--------|
| AI prediction accuracy | >=80% |
| Daily active users | >=50% |
| Financial literacy improvement | >=20% |
| SUS usability score | >=4.0/5.0 |
| 30-day retention | >=40% |
| Critical error rate | <1% |

## Phase Documentation

**After every roadmap phase is fully implemented and verified**, generate phase documentation by following the prompt in [`.claude/agent-os/phase_docs_prompt.md`](.claude/agent-os/phase_docs_prompt.md).

**When to trigger:** All tasks in the phase are done, all endpoints work, and the build passes. Do not document a partially complete phase.

**Output structure — always exactly four files:**
```
specs/{phase-name}/
├── spec.md         # What was built and why (prose + tables, no code)
├── shape.md        # Architectural decisions and hard constraints
├── references.md   # Every file created/modified + test files + standards applied
└── standards.md    # How each layer followed project coding standards
```

**Folder naming:** lowercase kebab-case matching the roadmap identifier exactly (e.g. `specs/phase-1a/`, `specs/phase-2/`, `specs/phase-3/`).

**Rules (summary — full rules in `phase_docs_prompt.md`):**
- Perform a full retrospective of every file changed before writing any doc
- `spec.md`: every user story in the phase must appear; state machines in ASCII diagrams; no code snippets
- `shape.md`: only non-obvious decisions; every constraint must map to a guard or validation in code
- `references.md`: every file touched must be listed — no omissions, no phantom entries
- `standards.md`: only include sections for layers actually touched; no generic statements
- Verify all four files before finishing: no extra files, no missing files

---

## Documentation Index

### Phase Documentation Prompt
- [`.claude/agent-os/phase_docs_prompt.md`](.claude/agent-os/phase_docs_prompt.md) — Full instructions for generating `specs/{phase}/` documentation after each completed phase. **Read this before writing any phase docs.**

### Product Docs (`.claude/agent-os/product/`)
- [`mission.md`](.claude/agent-os/product/mission.md) — Product vision, problem statement, target users, solution pillars, non-goals, and long-term vision. **Read this to understand why Zenda exists.**
- [`roadmap.md`](.claude/agent-os/product/roadmap.md) — 16-phase execution plan (Feb–Dec 2026) with task-level detail, acceptance criteria per phase, and global timeline. **Read this before starting any new feature.**
- [`user_stories.md`](.claude/agent-os/product/user_stories.md) — 18 epics, 55 user stories (302 story points) with acceptance criteria and status tracking. **Reference this for exact API contracts and screen requirements.**

### Coding Standards (`skills/`)
- [`skills/universal/core-coding-standards/`](skills/universal/core-coding-standards/) — General coding principles (no premature abstraction, comment why not what)
- [`skills/universal/lang-typescript/`](skills/universal/lang-typescript/) — TypeScript rules: no `any`, no type assertions, named exports only, prefer async/await, discriminated unions
- [`skills/platform/platform-backend/`](skills/platform/platform-backend/) — NestJS API rules: request lifecycle, output schemas, authorization vs authentication, security rules, validation at boundary
- [`skills/platform/platform-backend/domain-driven-design-nestjs/`](skills/platform/platform-backend/domain-driven-design-nestjs/) — DDD conventions for NestJS: structure, conventions, and anti-patterns
- [`skills/platform/platform-database/`](skills/platform/platform-database/) — Database rules: migration safety, query optimization, schema conventions, transaction handling
- [`skills/platform/platform-testing/`](skills/platform/platform-testing/) — Testing rules: use real database (no mocks), test factories, mock boundaries not internals
- [`skills/platform/platform-mobile/flutter/`](skills/platform/platform-mobile/flutter/) — Flutter/Dart conventions

### Module READMEs (Backend)
- [`zenda_backend_app/README.md`](zenda_backend_app/README.md) — Backend setup and overview
- [`zenda_backend_app/src/common/exceptions/README.md`](zenda_backend_app/src/common/exceptions/README.md) — Exception handling patterns
- [`zenda_backend_app/src/common/guards/README.md`](zenda_backend_app/src/common/guards/README.md) — Auth guard usage
- [`zenda_backend_app/src/common/middleware/README.md`](zenda_backend_app/src/common/middleware/README.md) — Middleware conventions
- [`zenda_backend_app/src/infra/telemetry/README.md`](zenda_backend_app/src/infra/telemetry/README.md) — Logging and telemetry setup

### Feature READMEs (Frontend)
- [`zenda_fronted_app/README.md`](zenda_fronted_app/README.md) — Frontend setup and overview
- [`zenda_fronted_app/lib/features/auth/README.md`](zenda_fronted_app/lib/features/auth/README.md) — Auth feature structure
- [`zenda_fronted_app/lib/features/onboarding/README.md`](zenda_fronted_app/lib/features/onboarding/README.md) — Onboarding flow
