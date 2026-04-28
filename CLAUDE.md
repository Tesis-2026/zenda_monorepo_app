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
│       │   ├── ai/         # AiModule + LocalRulesProvider stubs (Phase 8+)
│       │   ├── email/      # EmailModule + EmailService (nodemailer)
│       │   └── prisma/     # Global PrismaModule + PrismaService
│       ├── modules/        # DDD bounded contexts (7 modules)
│       │   ├── auth/       # Register, login, JWT, forgot/reset password
│       │   ├── budgets/    # Monthly budgets per category with progress tracking
│       │   ├── categories/ # System + custom categories with soft delete
│       │   ├── goals/      # Savings goals + contribute endpoint
│       │   ├── insights/   # Monthly summary aggregation
│       │   ├── transactions/ # CRUD + filters (type, date, category)
│       │   └── users/      # User profile read/update
│       └── shared/         # Shared utilities (not a bounded context)
│           ├── config/     # Typed ConfigFactory
│           ├── dto/        # SuccessResponseDto
│           ├── exceptions/ # GlobalExceptionFilter
│           ├── guards/     # JwtAuthGuard
│           ├── logger/     # AppLogger + RequestLoggingInterceptor
│           └── middleware/ # (reserved)
│
├── zenda_fronted_app/      # Flutter + Riverpod mobile app (folder name has typo — keep as-is)
│   └── lib/
│       ├── core/
│       │   ├── models/     # User, Transaction, Account, Streak, Breakdown503020
│       │   ├── services/   # ApiClient, AuthApiService, UserApiService,
│       │   │               # AccountsRepository, TransactionsRepository,
│       │   │               # StreakRepository, AiAdviceService, LocalKvStore, OcrService
│       │   └── theme/      # AppTheme, LightTheme, DarkTheme
│       ├── features/
│       │   ├── auth/       # LoginScreen, RegisterScreen, ForgotPasswordScreen,
│       │   │               # ResetPasswordScreen, AuthGate, AuthController, LocalAuthService
│       │   ├── budget/     # BudgetScreen, BudgetCard, budget providers
│       │   ├── categories/ # CategoryManagementScreen
│       │   ├── dashboard/  # DashboardScreen + widgets (SummaryCard, StreakCard,
│       │   │               # BudgetPieChart, ZendaAiCard, AccountCard)
│       │   ├── goals/      # GoalsScreen, GoalDetailScreen, goal providers
│       │   ├── onboarding/ # OnboardingScreen, OnboardingPage, SplashDecider, OnboardingPrefs
│       │   ├── profile/    # ProfileScreen
│       │   ├── progress/   # ProgressScreen (stub)
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
- All code, comments, variable names, and user-facing strings must be in **English**.
- Enum values in `transaction.dart` (e.g., `comida`, `necesidad`) are kept as-is for serialization compatibility — only display labels are translated.
- Currency remains PEN (Peruvian Sol) with `S/` symbol.

## Backend (zenda_backend_app)
- **Stack**: NestJS 11, Prisma ORM, PostgreSQL 15 (Docker), JWT auth
- **Run**: `npm run start:dev` — serves on `http://localhost:3000`
- **API docs**: `http://localhost:3000/api/docs` (Swagger)
- **Database**: `docker compose up -d`, then `npm run prisma:migrate && npm run prisma:seed`
- **Conventions**:
  - 7 bounded contexts in `src/modules/`: `auth`, `budgets`, `categories`, `goals`, `insights`, `transactions`, `users`
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
  - Theme: Light/dark themes in `lib/core/theme/`
  - Models in `lib/core/models/`, API services in `lib/core/services/`
  - API client: `ApiClient` in `lib/core/services/api_client.dart` — base HTTP wrapper
  - i18n: `flutter_localizations` with `app_en.arb` + `app_es.arb`; access via `context.l10n.*` (L10nX extension)
  - No hardcoded UI strings in `build()` methods — all strings come from `AppLocalizations`
  - Run `flutter gen-l10n` after adding new ARB keys

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
- `phase-1a` — Backend scaffolding and core infrastructure (NestJS, Prisma, JWT auth, 6 feature modules)
- `phase-1b` — Database design (full Prisma schema: 19 models, 9 enums, seed data)
- `phase-2` — Flutter frontend foundation (auth flows, onboarding, dashboard, transactions, profile, i18n EN+ES)
- `phase-3` — Transaction recording: backend GET/:id + PUT/:id, Flutter TransactionListScreen, fire-and-forget API sync
- `phase-4` — Categorization: backend PUT /api/categories/:id (rename), Flutter CategoryManagementScreen (create/rename/delete custom categories)
- `phase-5` — Reports: backend monthly insights aggregation, Flutter ReportsScreen with pie chart + PDF export
- `phase-6` — Budgets and goals: backend BudgetsModule + GoalsModule, Flutter BudgetScreen + GoalsScreen + GoalDetailScreen

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


### Feature READMEs (Frontend)
- [`zenda_fronted_app/README.md`](zenda_fronted_app/README.md) — Frontend setup and overview
- [`zenda_fronted_app/lib/features/auth/README.md`](zenda_fronted_app/lib/features/auth/README.md) — Auth feature structure
- [`zenda_fronted_app/lib/features/onboarding/README.md`](zenda_fronted_app/lib/features/onboarding/README.md) — Onboarding flow
