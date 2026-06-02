# Zenda — Architecture Overview

One-page summary of the system. For deeper detail follow the links into the active tracking docs and the DSL/ERD/diagram artifacts in this folder.

---

## 1. Context

Zenda is an AI-assisted personal-finance app for Peruvian university students (18–24). The product is a thesis project at UPC with a December-2026 demo target. The codebase is a monorepo with a NestJS backend, a Flutter mobile frontend, and design/diagram artifacts in this `docs/` folder.

| Concern | Choice |
|---------|--------|
| Target audience | Spanish-speaking Peruvian university students |
| Locale | Spanish-only (forced in `app.dart`; no language switcher) |
| Currency | PEN only (MVP) |
| AI provider | Azure OpenAI (GPT-4o-mini) with `LocalRulesProvider` as fallback |
| Compliance | Peru's Ley 29733 (data protection): consent + audit trail |

---

## 2. Containers (Structurizr DSL → [`zenda.dsl`](zenda.dsl))

```
┌────────────────────┐        ┌────────────────────┐
│  Flutter Mobile    │ HTTPS  │  NestJS REST API   │
│  (Android target)  │ ─────► │  (Node 22, Express)│
│  Riverpod state    │ JWT    │                    │
│  GoRouter routing  │        │                    │
└────────────────────┘        └─────────┬──────────┘
                                        │
                              ┌─────────┴─────────┐
                              │                   │
                              ▼                   ▼
                       ┌────────────┐      ┌──────────────┐
                       │ PostgreSQL │      │ Azure OpenAI │
                       │  15 + JSON │      │ GPT-4o-mini  │
                       └────────────┘      └──────────────┘
                              │
                              └─► nodemailer (SMTP for password reset)
```

The dev environment uses Docker for Postgres only (`docker-compose.yml`). There is no production `Dockerfile` — the backend runs locally (`npm run start:dev`) against the docker-composed PostgreSQL; production containerization was removed by product decision (2026-05-31).

---

## 3. Backend — DDD bounded contexts

**Rule of thumb:** every `src/modules/<context>/` is a NestJS module that exports only its facade. Cross-context imports must go through that facade (current debt: see ARCH-17 / B19).

### Layer template (per module)

```
src/modules/<context>/
├── application/
│   └── use-cases/        # Orchestration. Inject domain ports + cross-cutting infra. NO direct PrismaService.
├── domain/
│   ├── <entity>.entity.ts # Pure TS. Zero NestJS / Prisma / class-validator imports.
│   ├── <enum>.enum.ts
│   └── ports/             # Abstract classes — repository contracts.
├── infrastructure/
│   └── persistence/
│       └── prisma-<entity>.repository.ts # Implements the port. Owns the Decimal→number boundary.
├── interface/
│   ├── <name>.controller.ts # HTTP. Routes through use cases.
│   └── dto/
└── <context>.module.ts    # Wires providers; exports facade token only.
```

### Bounded contexts (15)

| Context | Purpose | Key entities |
|---------|---------|--------------|
| **auth** | Register, login, password reset, JWT, refresh tokens | `User`, `RefreshToken`, `AuthChallenge` |
| **users** | Profile read/update, notification prefs, account deletion | `User` (profile slice), `notificationPrefs` JSON |
| **categories** | System + custom categories with soft delete | `Category` |
| **transactions** | CRUD + filters + AI classification + idempotent create | `Transaction` (+ AI fields: `suggestedCategoryId`, `aiConfidence`, `categorySource`) |
| **budgets** | Monthly budgets per category with progress tracking | `Budget` (unique per user × category × period) |
| **goals** | Savings goals + contribute + complete | `SavingsGoal`, `GoalContribution` |
| **insights** | Day / week / month summaries + comparisons + PDF export | (Read-only over Transaction/Budget) |
| **predictions** | Expense prediction for next month + accuracy check | `Prediction` (unique per user × period × type) |
| **recommendations** | AI advice with lifecycle (active/viewed/dismissed) + chat | `Recommendation`, `AiConversation`, `AiMessage` |
| **education** | Topics + per-topic quizzes + personalized AI quiz + surveys (PRE/POST/SUS) | `EducationalTopic`, `QuizQuestion`, `QuizAttempt`, `UserTopicProgress`, `Survey`, `SurveyResponse` |
| **challenges** | Challenge catalog + accept/complete (status derived from timestamps) | `Challenge`, `UserChallenge` |
| **badges** | Badge catalog + awarding | `Badge`, `UserBadge` |
| **feedback** | App feedback (bug/suggestion/general) — B8 extracted into own module | `Feedback` |
| **financial-progress** | Monthly snapshot for observation #9 correlation (literacy vs behavior) | `UserFinancialProgress` |
| **surveys** | Reserved (current survey logic lives inside `education/`; extraction pending — B7) | — |

### Cross-cutting infra (`src/infra/`)

| Folder | Purpose |
|--------|---------|
| `ai/` | `AiProvider` interface, `AzureFoundryProvider` (timeout + try/catch fallback), `LocalRulesProvider` |
| `analytics/` | `AnalyticsService` for product telemetry |
| `email/` | `EmailService` (nodemailer) — password reset emails |
| `prisma/` | Global `PrismaService` |
| `spending-alert/` | Anomaly detection on transactions (>20% over category 3-month avg) |
| `telemetry/` | Request correlation + structured logging support |

### Cross-cutting utilities (`src/shared/`)

| Folder | Purpose | Batch |
|--------|---------|-------|
| `audit/` | `AuditLogService` (singleton, fire-and-forget) + `RequestContextService` (AsyncLocalStorage) — records 14+ mutations | B27 |
| `config/` | `configuration.ts` + `EnvSchema` (class-validator, validates at boot) | B24 |
| `exceptions/` | `GlobalExceptionFilter` — maps `PrismaClientKnownRequestError` to HTTP semantics | B22 |
| `guards/` | `JwtAuthGuard` — reloads user on every request, rejects soft-deleted + stale tokenVersion | B21/B25 |
| `idempotency/` | `IdempotencyKey` table + `IdempotencyInterceptor` — RFC-draft `Idempotency-Key` header | B28 |
| `logger/` | `RequestLoggingInterceptor` — redacts sensitive query params, captures HTTP status | B26 |
| `swagger/` | `ApiErrorResponseDto` + composable `@ApiResponse` helpers | B23 |

---

## 4. Frontend — feature-based + Riverpod

```
lib/
├── app.dart                  # MaterialApp.router + forced Locale('es')
├── main.dart                 # Bootstrap + Intl.defaultLocale = 'es'
├── core/
│   ├── models/               # User, Transaction, Account, Budget, SavingsGoal, etc.
│   ├── services/             # ApiClient (JWT secure storage + 401 refresh + retry), per-entity API services
│   ├── theme/                # AppTheme (light only)
│   └── widgets/              # Reusable widgets (app_card, app_toast, ...)
├── features/                 # Feature-scoped folders
│   ├── auth/                 # login/register/forgot/reset + AuthGate
│   ├── budget/               # BudgetScreen + providers
│   ├── categories/           # CategoryManagementScreen
│   ├── dashboard/            # Bottom-nav shell + widgets (summary, streak, pie, AI tip)
│   ├── education/            # Topics + quizzes + learning path
│   ├── goals/                # GoalsScreen + GoalDetailScreen
│   ├── onboarding/           # SplashDecider + onboarding carousel + profile setup
│   ├── profile/              # ProfileScreen (edit demographics + financial-literacy level)
│   ├── reports/              # Reports + PDF export
│   ├── surveys/              # Pre / Post / SUS
│   └── transactions/         # Add / list / edit / delete
├── l10n/                     # ARB files (es authoritative; en is the codegen template)
├── providers/                # Global Riverpod providers
└── routing/                  # GoRouter (all routes declared centrally)
```

State management: Riverpod 3 (`Notifier` + `Provider`). Local persistence: `flutter_secure_storage` for tokens / financial data; `SharedPreferences` for non-sensitive flags only. Offline writes go through `PendingTransactionQueue` (still missing exponential backoff — see ARCH-07).

---

## 5. Request lifecycle (backend)

For an authenticated mutation like `POST /api/transactions`:

1. **Helmet** sets security headers (`main.ts`).
2. **CORS** check (currently localhost-only — production needs config).
3. **Global `ThrottlerModule`** + per-route `@Throttle` (B30) reject if over the limit.
4. **`RequestContextInterceptor`** (B27) generates/preserves `requestId`, captures IP + UA + method + path, binds them to AsyncLocalStorage for the rest of the request tree.
5. **`RequestLoggingInterceptor`** (B26) logs the request line on completion (redacts password/token query params).
6. **`IdempotencyInterceptor`** (B28) — if the `Idempotency-Key` header is present and the request is POST/PUT/PATCH, look up + replay or proceed.
7. **`JwtAuthGuard`** (B21/B25) — verifies the JWT signature + expiry, re-loads the user, rejects when `deletedAt != null` or `tokenVersion` mismatches.
8. **Pipes** — `ValidationPipe` runs class-validator on the DTO (e.g. `@IsBoundedAnswersMap()` from B20).
9. **Controller** — calls the use case.
10. **Use case** — orchestrates domain logic, talks to repositories (always through the abstract port), records an audit event via `AuditLogService.record(...)` (B27).
11. **Repository** — Prisma query with `deletedAt: null` for soft-deletable models.
12. **`GlobalExceptionFilter`** (B22) — catches every thrown exception, normalizes shape, maps Prisma errors to proper HTTP codes.

---

## 6. Pending architectural work

See [`architecture-compliance-plan.md`](architecture-compliance-plan.md) for the full list with status, effort, and PR references. Highest-leverage open items:

- **B5** — frontend `setState` → Riverpod for `ai_chat`, `quiz`, login lockout (in progress on another branch)
- **B7** — extract `surveys/` module + move `AiConversation/Message` out of `recommendations/` (in progress on another branch)
- **B19** — introduce ACL facade tokens across module boundaries (supersedes B9; ARCH-17)
- **B10 / B11 / B12** — frontend model alignment with new backend response fields (post-B5 to avoid conflicts)
- **B17** — `Prediction.confidenceInterval` (closes ARCH-04 + ARCH-15 together)

Out-of-scope deferrals are tracked in [`audit-issues.md`](audit-issues.md) (ARCH-05/06/07 + GAP-01/03/04/05/06).
