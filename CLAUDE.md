# Zenda  — Project Conventions

## Active Standards
@skills/assistant/pre-work-audit/SKILL.md
@skills/universal/core-coding-standards/SKILL.md
@skills/universal/lang-typescript/SKILL.md
@skills/platform/platform-backend/SKILL.md
@skills/platform/platform-backend/domain-driven-design-nestjs/SKILL.md
@skills/platform/platform-database/SKILL.md
@skills/platform/platform-testing/SKILL.md
@skills/platform/platform-mobile/flutter/SKILLS.md
@skills/assistant/agent-add-rule/SKILL.md
@skills/assistant/agent-init-deep/SKILL.md
@skills/assistant/agent-pr-creator/SKILL.md
@skills/assistant/pr-comments-address/SKILL.md
@skills/assistant/promptify/SKILL.md
@skills/assistant/rewrite-commit-history/SKILL.md
@skills/_drafts/framework/tech-prisma/SKILL.md
@skills/_drafts/platform/platform-mobile/SKILL.md

## Overview
Zenda is an AI-powered mobile finance app (thesis project) targeting Peruvian university students (18-24). The codebase is a monorepo with a NestJS backend and Flutter frontend.

## Structure
```
Tesis2026/
├── zenda_backend_app/      # NestJS + Prisma + PostgreSQL API
│   └── src/
│       ├── health/         # GET /api/health endpoint
│       ├── infra/          # Cross-cutting infrastructure (not bounded contexts)
│       │   ├── ai/             # AiModule + Azure Foundry / LocalRules providers
│       │   ├── analytics/      # AnalyticsService (event capture)
│       │   ├── email/          # EmailModule + EmailService (nodemailer)
│       │   ├── prisma/         # Global PrismaModule + PrismaService
│       │   ├── spending-alert/ # Anomaly detection on transactions
│       │   └── telemetry/      # Request correlation + structured logging
│       ├── modules/        # DDD bounded contexts (16 modules)
│       │   ├── auth/             # Register, login, JWT (with tokenVersion + consentGiven claims),
│       │   │                     # password reset (OTP + token), refresh tokens
│       │   ├── badges/           # Badge catalog + awarding (US-1003)
│       │   ├── budgets/          # Monthly budgets per category with progress tracking
│       │   ├── categories/       # System + custom categories with soft delete
│       │   ├── challenges/       # Challenge catalog + user acceptance/completion + EXPIRED status (B36)
│       │   ├── conversations/    # Persistent AI chat (/ai/chat/*) — extracted from recommendations (B7)
│       │   ├── education/        # Topics + per-topic quizzes + personalized quiz (HIGH score → topic complete cascade)
│       │   ├── feedback/         # App feedback submission (US-1501)
│       │   ├── financial-progress/ # Monthly snapshots for obs. #9 correlation
│       │   ├── goals/            # Savings goals + contribute + complete
│       │   ├── insights/         # Day/week/month summaries + comparison + PDF export
│       │   ├── predictions/      # Expense prediction + accuracy check (US-0801)
│       │   ├── recommendations/  # AI recommendations + lifecycle (viewed/dismissed/feedback) + AI traceability
│       │   ├── surveys/          # PRE/POST literacy surveys + SUS usability instrument (academic validation) — filled in B7
│       │                         #   NOTE: surveys.controller still injects PrismaService directly (ARCH-01, open)
│       │   ├── transactions/     # CRUD + filters + AI classification + idempotent create
│       │   └── users/            # Profile read/update + notifications preferences + account deletion
│       └── shared/         # Cross-cutting utilities (not bounded contexts)
│           ├── audit/         # AuditLogService + RequestContextService (AsyncLocalStorage) — B27
│           ├── config/        # configuration.ts + EnvSchema validated at boot — B24
│           ├── dto/           # SuccessResponseDto
│           ├── exceptions/    # GlobalExceptionFilter with Prisma error mapping — B22
│           ├── guards/        # Reserved for future cross-cutting guards (README only). JwtAuthGuard actually
│           │                  #   lives in modules/auth/infrastructure — it depends on the auth-context IUserRepository
│           │                  #   port, so it intentionally stays in the auth module (see shared/guards/README.md)
│           ├── idempotency/   # IdempotencyService + IdempotencyInterceptor (RFC draft header) — B28
│           ├── logger/        # AppLogger + RequestLoggingInterceptor (redacts secrets) — B26
│           └── swagger/       # ApiErrorResponseDto + composable @ApiResponse helpers — B23
│
├── zenda_fronted_app/      # Flutter + Riverpod mobile app (folder name has typo — keep as-is)
│   └── lib/
│       ├── core/
│       │   ├── models/     # User, Transaction, Streak, Breakdown503020
│       │   ├── services/   # ApiClient, AuthApiService, UserApiService,
│       │   │               # TransactionsRepository, StreakRepository,
│       │   │               # AiAdviceService, LocalKvStore, OcrService
│       │   └── theme/      # AppTheme (light only)
│       ├── features/
│       │   ├── auth/       # LoginScreen, RegisterScreen, ForgotPasswordScreen,
│       │   │               # ResetPasswordScreen, AuthGate, AuthController, LocalAuthService
│       │   ├── budget/     # BudgetScreen, BudgetCard, budget providers
│       │   ├── categories/ # CategoryManagementScreen
│       │   ├── dashboard/  # DashboardScreen + widgets (SummaryCard, StreakCard,
│       │   │               # BudgetPieChart, ZendaAiCard)
│       │   ├── goals/      # GoalsScreen, GoalDetailScreen, goal providers (embedded in Gestión)
│       │   ├── management/ # ManagementScreen — "Gestión" nav tab hosting Progreso/Presupuestos/Metas as 3 chip sub-tabs (each screen rendered embedded:true)
│       │   ├── onboarding/ # OnboardingScreen, OnboardingPage, SplashDecider, OnboardingPrefs
│       │   ├── profile/    # ProfileScreen
│       │   ├── progress/   # ProgressScreen (embedded in Gestión)
│       │   ├── reports/    # ReportsScreen with monthly summary + PDF export
│       │   ├── streak/     # StreakNotifier
│       │   └── transactions/ # AddTransactionScreen, TransactionListScreen,
│       │                     # NewTransactionController (TransactionCreateScreen is stub)
│       ├── l10n/           # app_en.arb, app_es.arb + generated AppLocalizations
│       ├── providers/      # Global Riverpod providers + repository providers
│       ├── routing/        # AppRouter (GoRouter) — all named routes declared here
│       └── services/       # Legacy service layer (AuthService, TransactionsService,
│                           # AiService, OcrService) — being migrated to core/services
│
├── docs/                   # Architecture docs + AI integration docs
├── skills/                 # Custom Claude Code skills
│   ├── assistant/          # pre-work-audit, promptify, agent-pr-creator, etc.
│   ├── platform/           # platform-backend, platform-mobile, platform-database, platform-testing
│   ├── universal/          # core-coding-standards, lang-typescript
│   └── _drafts/            # In-progress skills
├── .claude/
│   └── specs/              # Phase implementation specs (phase-1a, phase-1b, ...)
└── CLAUDE.md               # This file
```

## Language
- All code, comments, and variable names must be in **English**.
- All user-facing strings (UI text, ARB values, mocked/seed data shown to the user) must be in **Spanish only** — the app targets a Spanish-speaking audience (Peruvian university students). The locale is forced to `es` in `lib/app.dart`; there is no language switcher.
- Enum values in `transaction.dart` (e.g., `comida`, `necesidad`) are kept as-is for serialization compatibility — display labels come from `CategoryUtils.labelEs()` or `AppLocalizations`.
- Currency remains PEN (Peruvian Sol) with `S/` symbol.

## Backend (zenda_backend_app)
- **Stack**: NestJS 11, Prisma ORM, PostgreSQL 15 (Docker), JWT auth
- **Run**: `npm run start:dev` — serves on `http://localhost:3000`
- **API docs**: `http://localhost:3000/api/docs` (Swagger)
- **Database**: `docker compose up -d`, then `npm run prisma:migrate && npm run prisma:seed`
- **Conventions**:
  - 16 bounded contexts in `src/modules/`: `auth`, `badges`, `budgets`, `categories`, `challenges`, `conversations`, `education`, `feedback`, `financial-progress`, `goals`, `insights`, `predictions`, `recommendations`, `surveys`, `transactions`, `users` (`conversations` was extracted from `recommendations` in B7; `surveys` was filled from the previously-empty folder in the same batch)
  - Each module uses strict DDD layers: `application/use-cases/`, `domain/`, `infrastructure/`, `interface/`
  - Cross-cutting infrastructure lives in `src/infra/` (prisma, email, ai) — not bounded contexts
  - Shared utilities live in `src/shared/` (config, guards, logger, exceptions, dto)
  - Domain layer has zero NestJS decorators and zero `@prisma/client` imports — pure TypeScript
  - Domain enums live in `src/modules/<module>/domain/` — never imported from `@prisma/client`
  - `Decimal` → `number` conversion happens at the repository boundary (infrastructure layer)
  - Repository ports are abstract classes in `domain/ports/` — implementations in `infrastructure/`
  - All entities use soft deletes (`deletedAt` field)
  - DTOs use `class-validator` decorators; responses use `SuccessResponseDto` wrapper
  - `@UserId()` decorator extracts user from JWT payload

## Frontend (zenda_fronted_app)
- **Stack**: Flutter 3.10+, Dart, Riverpod 3, GoRouter 17, fl_chart
- **Run**: `flutter run` (requires Flutter SDK)
- **Conventions**:
  - Feature-based directory structure under `lib/features/`
  - State management: Riverpod `Notifier` + `Provider` patterns
  - Routing: GoRouter in `lib/routing/app_router.dart` — all routes declared there
  - Local storage: SharedPreferences via `LocalKvStore`
  - Theme: Light theme only in `lib/core/theme/` (dark mode is not supported)
  - Models in `lib/core/models/`, API services in `lib/core/services/`
  - API client: `ApiClient` in `lib/core/services/api_client.dart` — base HTTP wrapper
  - i18n: `flutter_localizations` infrastructure kept but **locale is forced to `es` only** in `lib/app.dart` (no runtime switch, device locale is ignored). `app_es.arb` is the authoritative source; `app_en.arb` remains as the codegen template only.
  - Prefer `context.l10n.*` (L10nX extension) for UI strings. Hardcoded Spanish strings in `build()` are tolerated only for one-off demo/mock copy — never English.
  - Run `flutter gen-l10n` after adding new ARB keys

## Key Design Decisions
- 50/30/20 budget rule: Needs / Wants / Savings
- Category-to-bucket mapping is in `transaction.dart:bucketForCategory()`
- No "accounts" concept: the backend does not model bank/cash accounts. Total available money = sum of per-category budgets. (Account model/repository/`AccountCard` were removed; a residual `TransactionModel.accountId` defaults to `''`.)
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
- `phase-1a` — Backend scaffolding and core infrastructure (NestJS, Prisma, JWT auth, 6 feature modules)
- `phase-1b` — Database design (full Prisma schema: 19 models, 9 enums, seed data)
- `phase-2` — Flutter frontend foundation (auth flows, onboarding, dashboard, transactions, profile, Spanish-only localization)
- `phase-3` — Transaction recording: backend GET/:id + PUT/:id, Flutter TransactionListScreen, fire-and-forget API sync
- `phase-4` — Categorization: backend PUT /api/categories/:id (rename), Flutter CategoryManagementScreen (create/rename/delete custom categories)
- `phase-5` — Reports: backend monthly insights aggregation, Flutter ReportsScreen with pie chart + PDF export
- `phase-6` — Budgets and goals: backend BudgetsModule + GoalsModule, Flutter BudgetScreen + GoalsScreen + GoalDetailScreen
- `phase-11` — Notifications: backend NotificationsModule (DDD) + FcmService + 3 @Cron jobs + BUDGET_ALERT/ANOMALY_ALERT hooks; Flutter inbox screen + bell with unread badge + FCM token registration

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

### Architecture & Audit Tracking (`docs/`)
- [`docs/architecture-compliance-plan.md`](docs/architecture-compliance-plan.md) — Refactor batch tracker (B1–B32+); status, PR refs, recommended execution order
- [`docs/audit-issues.md`](docs/audit-issues.md) — Findings tracker: P1 (thesis validity), S (security), AC (acceptance criteria), UX, ARCH (architecture debt), GAP (phase-level gaps); fix log
- [`docs/frontend-backend-integration.md`](docs/frontend-backend-integration.md) — **FE↔BE integration status**: app runs in demo mode (`_kDemoMode`), how to wire to the real backend, verified contract compatibility, open data-mapping issues (challenge rewards, topic metadata), and debunked false positives. **Read this before connecting the Flutter app to the NestJS backend.**
- [`docs/testing-plan.md`](docs/testing-plan.md) — **Backend testing plan** (contract tests with mocked data, no DB): Jest + supertest + `@nestjs/testing` with mocked persistence + schema-shaped fixtures, asserting the response shapes the Flutter `fromJson` expects. Structure, scripts, per-module coverage map, rollout order. Addresses GAP-05 at the contract level.
- [`docs/zenda-erd.dbml`](docs/zenda-erd.dbml) — Logical ERD (DBML format)
- [`docs/zenda-erd-conceptual.{dbml,mmd}`](docs/) — Conceptual ERD (DBML + Mermaid)
- [`docs/zenda-schema.sql`](docs/zenda-schema.sql) — Auto-generated DDL from Prisma (B15 — regenerate via `npx prisma migrate diff`)
- [`docs/zenda-*-architecture.drawio`](docs/) — Layered, logical, and physical architecture diagrams
- [`docs/zenda.dsl`](docs/zenda.dsl) — Structurizr DSL model of the system

### Module READMEs (Backend)
- [`zenda_backend_app/README.md`](zenda_backend_app/README.md) — Backend setup and overview
- [`zenda_backend_app/src/shared/exceptions/`](zenda_backend_app/src/shared/exceptions/) — `GlobalExceptionFilter` (B22 maps Prisma errors)
- [`zenda_backend_app/src/shared/guards/`](zenda_backend_app/src/shared/guards/) — reserved folder (README only); the active `JwtAuthGuard` lives in `modules/auth/infrastructure/` (B21/B25 revalidate user — depends on the auth-context `IUserRepository`, so it stays in the auth module)
- [`zenda_backend_app/src/shared/audit/`](zenda_backend_app/src/shared/audit/) — Cross-cutting audit log writer (B27)
- [`zenda_backend_app/src/shared/idempotency/`](zenda_backend_app/src/shared/idempotency/) — `Idempotency-Key` header support (B28)
- [`zenda_backend_app/src/shared/swagger/`](zenda_backend_app/src/shared/swagger/) — Reusable `@ApiResponse` decorators (B23)
- Per-module READMEs (auth, transactions, recommendations, etc.) are pending — see B33 follow-up

### Feature READMEs (Frontend)
- [`zenda_fronted_app/README.md`](zenda_fronted_app/README.md) — Frontend setup and overview
- [`zenda_fronted_app/lib/features/onboarding/README.md`](zenda_fronted_app/lib/features/onboarding/README.md) — Onboarding flow
- [`zenda_fronted_app/lib/core/widgets/README.md`](zenda_fronted_app/lib/core/widgets/README.md) — **Modal & form standard** for all create/edit/delete flows (bottom-sheet pattern, design tokens, `AppFormSheet`/`showConfirmSheet`, migration map). Follow this for any new create/edit/delete UI.
- Per-feature READMEs (auth, dashboard, transactions, etc.) are pending — see B34 follow-up
