# Zenda MVP Roadmap — Execution Plan by Phases

**Goal:** A functional mobile application where university students record transactions, view reports, receive AI-powered spending predictions (>= 80% accuracy), complete gamified educational challenges, and demonstrate a >= 20% increase in financial knowledge measured by pre/post usage survey. The app meets usability (SUS >= 4.0/5.0), security (Law 29733), and quality (ISO 25010) standards.

**Duration:** 10.5 months (February 2026 — December 2026)
**Team:** 2 part-time developers (20 hrs/week each)
**Budget:** S/ 14,241 (general expenses + goods and subcontracting)

**Critical Path:** Infrastructure → Auth → Transaction Recording → Categorization → Reports → Budgets → ML Pipeline → Predictions → Recommendations → Education/Gamification → Notifications → Pre/Post Evaluation → User Validation → Demo

---

## Technical Foundation

**Stack:**
- Mobile Frontend: Flutter 3.10+ (Dart) — iOS and Android, feature-based architecture with Riverpod 3
- Backend: NestJS 11 + Prisma ORM + PostgreSQL 15 (Docker locally, cloud TBD for production)
- State Management: Riverpod 3 (AsyncNotifierProvider, NotifierProvider, FutureProvider)
- Navigation: GoRouter 17
- Charts: fl_chart 1.1.1
- AI/ML: Azure AI Foundry — fine-tuned GPT-4o-mini (or Phi-4-mini) for predictions and advice; statistical moving average layer for numeric forecasts
- Authentication: JWT (Passport + bcrypt) — no Firebase
- Notifications: Firebase Cloud Messaging (FCM) — Phase 11
- CI/CD: GitHub Actions + deployment TBD

**Standards:**
- ISO 25010: Software product quality
- ISO 27001: Information security
- IEEE 829: Test documentation
- WCAG 2.1 Level AA: Mobile accessibility
- Law 29733: Personal data protection

---

## Phase 1: Project Infrastructure and Initial Setup

### 1A. Development Environment Setup

> **Impact: Critical** — Without infrastructure there is no development. Blocks all subsequent phases.

- [x] `P0` `infra` `backend` -- **Git repository setup** -- Monorepo on GitHub: `zenda_backend_app/` (NestJS API), `zenda_fronted_app/` (Flutter app), `ml/` (AI models), `docs/` (documentation). Includes `.gitignore`, `README.md`, `CONTRIBUTING.md`, `SETUP.md`, `LICENSE`. Branch strategy: `main` (protected), `feature/*`, `chore/*`. Refs: [US-1801](./user_stories.md#US-1801)

- [x] `P0` `infra` `backend` -- **PostgreSQL database setup** -- PostgreSQL 15 via Docker Compose (`docker-compose.yml`). Prisma ORM manages schema (`prisma/schema.prisma`). Migrations via `npx prisma migrate dev`. Azure provisioning deferred to production deployment. Refs: [US-1802](./user_stories.md#US-1802)

- [x] `P0` `infra` `flutter` -- **Base Flutter project** -- Flutter 3.10+ project (`zenda_fronted_app/`). Architecture: feature-based under `lib/features/`. State management: Riverpod 3 (NotifierProvider, AsyncNotifierProvider). Navigation: GoRouter 17 (`lib/routing/app_router.dart`). Local storage: SharedPreferences via `LocalKvStore`. Theme: Material Design 3 light/dark in `lib/core/theme/`. Refs: [US-1803](./user_stories.md#US-1803)

- [x] `P0` `infra` `backend` -- **Base REST API** -- NestJS 11 server. Health check: `GET /api/health` returns `{ status: "ok", timestamp, version: "1.0.0" }`. Global prefix `/api` (no `/v1`). CORS (localhost regex), rate limiting (ThrottlerModule: 120 req/min global), Helmet security headers, ValidationPipe (strict), centralized GlobalExceptionFilter. Swagger at `/api/docs`. Refs: [US-1804](./user_stories.md#US-1804)

- [x] `P1` `infra` -- **CI/CD setup** -- `.github/workflows/ci.yml`: backend (build + tsc typecheck) and frontend (`flutter analyze`) on each PR. Deployment to production deferred. Refs: Best practices

- [x] `P1` `infra` -- **Environment variables and secrets** -- `.env.example` with all required variables. Documented in `SETUP.md`. Refs: Security best practices

---

### 1B. Database Design and Data Model

> **Impact: Critical** — The schema defines the structure of the entire application.

- [x] `P0` `backend` `database` -- **Users schema** -- Model `User`: `id` (UUID PK), `email` (UNIQUE NOT NULL), `passwordHash` (TEXT), `fullName` (VARCHAR), `age` (INT?), `university` (VARCHAR?), `incomeType` (ENUM: SCHOLARSHIP, PART_TIME, FAMILY, MIXED), `averageMonthlyIncome` (Decimal 12,2), `financialLiteracyLevel` (ENUM: LOW, MEDIUM, HIGH), `profileCompleted` (Boolean default false), `currency` (VARCHAR 3 default 'PEN'), `consentGiven` (Boolean), `consentAt` (DateTime?), `createdAt`, `updatedAt`, `deletedAt`. Refs: [US-0101](./user_stories.md#US-0101)

- [x] `P0` `backend` `database` -- **Transactions schema** -- Model `Transaction`: `id` (UUID PK), `userId` (FK → User, Cascade), `type` (ENUM: INCOME, EXPENSE), `amount` (Decimal 12,2 NOT NULL), `categoryId` (FK → Category, SetNull), `description` (TEXT?), `occurredAt` (DateTime default now()), `deletedAt` (DateTime?), `createdAt`, `updatedAt`. Indexes: `(userId, occurredAt, deletedAt)`, `(userId, categoryId)`, `(userId, type, occurredAt, deletedAt)`. Refs: [US-0201](./user_stories.md#US-0201)

- [x] `P0` `backend` `database` -- **Categories, budgets, goals schema** -- Models `Category`, `Budget` (@@unique userId+categoryId+month+year), `SavingsGoal`. Soft deletes on all. Foreign keys with appropriate onDelete strategies. Refs: [US-0301](./user_stories.md#US-0301)

- [x] `P1` `backend` `database` -- **Gamification, AI, and evaluation schema** -- Models: `EducationalTopic`, `UserTopicProgress`, `Challenge`, `UserChallenge`, `Badge`, `UserBadge`, `Prediction`, `Recommendation`, `RecommendationFeedback`, `Survey`, `SurveyQuestion`, `SurveyResponse`, `AnalyticsEvent`, `AuditLog`, `Feedback`, `NotificationPreference`. Schema complete; backend services/endpoints implemented in their respective phases. Refs: [US-0901](./user_stories.md#US-0901)

---

## Phase 2: Authentication and User Management

> **Impact: Critical** — Without authentication there is no access to the app. Blocks all user functions.

- [x] `P0` `backend` `security` -- **Registration endpoint** -- `POST /api/auth/register` accepts `email`, `password`, `fullName`. Validates email format, password >= 8 chars. Creates user. Returns JWT token. bcrypt password hashing. Refs: [US-0101](./user_stories.md#US-0101)

- [x] `P0` `backend` `security` -- **Login endpoint** -- `POST /api/auth/login` accepts `email`, `password`. Validates credentials. Returns JWT. Refs: [US-0102](./user_stories.md#US-0102)

- [x] `P0` `backend` `security` -- **JWT authentication middleware** -- `JwtAuthGuard` protects all routes under `/api/*` except `/api/auth/*` and `/api/health`. Validates signature and expiration. Injects `userId` via `@UserId()` decorator. Returns 401 if invalid. Refs: [US-0103](./user_stories.md#US-0103)

- [x] `P0` `flutter` `ui` -- **Registration and login screens** -- Forms with real-time validation, loading states, error handling. `AuthApiService` calls `/auth/register` and `/auth/login`. JWT stored in `flutter_secure_storage`. Profile fetched from `/users/me` after login. Refs: [US-0101](./user_stories.md#US-0101), [US-0102](./user_stories.md#US-0102)

- [x] `P1` `backend` -- **Password recovery** -- `POST /api/auth/forgot-password` generates a 32-byte token (1h expiry), stores it, sends email via `EmailService`. `POST /api/auth/reset-password` validates token, hashes new password, deletes token. Both rate-limited (5 req/min). Refs: [US-0104](./user_stories.md#US-0104)

- [x] `P1` `flutter` `ui` -- **Initial profile onboarding** -- Multi-page onboarding screen after first launch. Captures age, university, income type, average income. Saves `profileCompleted = true`. Refs: [US-0105](./user_stories.md#US-0105)

- [x] `P1` `flutter` `ui` -- **Profile editing** -- `ProfileScreen` displays and edits full name, age, university, currency, income type, monthly income, financial literacy. Calls `UserApiService.updateProfile()` → `PUT /api/users/me`. Backend: `GetProfileUseCase` (`GET /api/users/me`) and `UpdateProfileUseCase` (`PUT /api/users/me`) fully wired with DDD layers. Refs: [US-0106](./user_stories.md#US-0106)

---

## Phase 3: Transaction Recording (Core Feature)

> **Impact: Critical** — This is the app's primary action. Without transactions there is no data for anything else.

- [x] `P0` `backend` `api` -- **Transaction CRUD** -- `POST /api/transactions` (create), `GET /api/transactions` (list with filters: type, categoryId, from/to date), `DELETE /api/transactions/:id` (soft delete). Ownership validated via `@UserId()`. Refs: [US-0201](./user_stories.md#US-0201) to [US-0206](./user_stories.md#US-0206)

- [x] `P0` `flutter` `ui` -- **Transaction recording screen** -- `AddTransactionScreen`: kind selector (Expense/Income/Transfer), amount, category grid, account picker, date picker, note. `NewTransactionController` saves locally then fire-and-forget syncs EXPENSE/INCOME to `POST /api/transactions` via `TransactionApiService`. Refs: [US-0201](./user_stories.md#US-0201)

- [x] `P0` `flutter` `ui` -- **Main dashboard** -- `DashboardScreen`: 4-tab PageView (Home, Transactions, Budget, Profile). Shows balance summary, last transactions, streak card, 50/30/20 pie chart, AI advice card. Refs: [US-0204](./user_stories.md#US-0204)

- [x] `P1` `flutter` `ui` -- **History with filters** -- `TransactionListScreen`: type filter chips (All/Expenses/Income), date range chips (This week/This month/All time), loads from `GET /api/transactions`, Dismissible swipe-to-delete, pull-to-refresh. Dashboard Transactions tab renders this screen. Refs: [US-0203](./user_stories.md#US-0203)

- [x] `P2` `backend` `api` -- **Transaction detail and edit** -- `GET /api/transactions/:id` (`GetTransactionUseCase`, ownership verified) and `PUT /api/transactions/:id` (`UpdateTransactionUseCase`, optional field updates, category re-resolution). Refs: [US-0205](./user_stories.md#US-0205), [US-0206](./user_stories.md#US-0206)

---

## Phase 4: Categorization System

> **Impact: High** — Foundation for reports, predictions, and budgets.

- [x] `P0` `backend` -- **Default categories (seed)** -- 9 expense categories (comida, transporte, vivienda, servicios, salud, ocio, compras, suscripciones, antojos) and 5 income categories seeded via `prisma/seed.ts`. Idempotent seeding. Refs: [US-0301](./user_stories.md#US-0301)

- [x] `P0` `backend` `api` -- **Custom categories CRUD** -- `POST /api/categories` (create), `GET /api/categories` (list system + user custom), `PUT /api/categories/:id` (rename, ownership + name-collision guard), `DELETE /api/categories/:id` (soft delete). `ResolveCategoryUseCase` creates on-the-fly during transaction creation. Refs: [US-0302](./user_stories.md#US-0302)

- [x] `P0` `flutter` `ui` -- **Category selector** -- Grid with icons/colors in `AddTransactionScreen`. Maps to 50/30/20 buckets via `bucketForCategory()`. Refs: [US-0301](./user_stories.md#US-0301)

- [x] `P1` `flutter` `ui` -- **Category management screen** -- `CategoryManagementScreen`: lists system (read-only) and custom categories. FAB to create, edit icon to rename, swipe-to-delete. Routes to `/categories` from `ProfileScreen`. `CategoryApiService` calls `GET/POST/PUT/DELETE /api/categories`. Refs: [US-0302](./user_stories.md#US-0302)

---

## Phase 5: Financial Reports and Visualization

> **Impact: High** — Visibility into financial habits. Prerequisite for predictions to have context.

- [x] `P0` `backend` `api` -- **Monthly summary endpoint** -- `GET /api/summary/month?year=&month=` returns total income, total expense, net balance, top 5 categories by spend, savings goals progress. Uses `Promise.all` for parallel aggregation queries. Refs: [US-0401](./user_stories.md#US-0401)

- [ ] `P0` `backend` `api` -- **Weekly and daily summary endpoints** -- `GET /api/summary/week` and `GET /api/summary/day`. Breakdown by category. Response < 2 sec. Refs: [US-0402](./user_stories.md#US-0402), [US-0403](./user_stories.md#US-0403)

- [ ] `P0` `backend` `api` -- **Multi-month comparison endpoint** -- `GET /api/summary/comparison?months=3`. Refs: [US-0404](./user_stories.md#US-0404)

- [x] `P0` `flutter` `ui` -- **Monthly summary in dashboard** -- 50/30/20 `BudgetPieChart` (fl_chart), `SummaryCard` (today/week totals). Refs: [US-0401](./user_stories.md#US-0401)

- [ ] `P1` `flutter` `ui` -- **Interactive charts screen** -- Bar charts by category, comparative line charts by month using fl_chart. Tap for detail. Backend integration required. Refs: [US-0405](./user_stories.md#US-0405)

- [ ] `P2` `backend` `api` -- **PDF export** -- Generates PDF with complete summary. Temporary download URL (24h). Refs: [US-0406](./user_stories.md#US-0406)

---

## Phase 6: Budget and Financial Goal Management

> **Impact: High** — Prerequisite for intelligent alerts. Goals give purpose to savings.

- [ ] `P0` `backend` `api` -- **Budget CRUD** -- `POST /api/budgets`, `GET /api/budgets` (with `currentSpent` and `percentageUsed`), `PUT /api/budgets/:id`, `DELETE /api/budgets/:id`. Budget model and schema ready (`@@unique([userId, categoryId, month, year])`). Refs: [US-0501](./user_stories.md#US-0501)

- [ ] `P0` `flutter` `ui` -- **Budget screen** -- List with progress bars (green/yellow/red). Creation modal. Backend integration required. Refs: [US-0501](./user_stories.md#US-0501)

- [x] `P1` `backend` `api` -- **Financial goals CRUD** -- `POST /api/goals`, `GET /api/goals`, `POST /api/goals/:id/contribute`, `DELETE /api/goals/:id`. Ownership validated. Contribution updates `currentAmount` (Decimal arithmetic). Refs: [US-0502](./user_stories.md#US-0502)

- [ ] `P1` `flutter` `ui` -- **Goals screen** -- Cards with progress, contribute button, completion animation. Backend integration required. Refs: [US-0502](./user_stories.md#US-0502)

- [ ] `P2` `flutter` `ui` -- **Goal detail** -- Contribution history, progress chart, completion projection. Refs: [US-0503](./user_stories.md#US-0503)

---

## Phase 7: AI Pipeline — Fine-Tuning Dataset and Azure AI Foundry Setup

> **Impact: Critical** — Prepares the fine-tuned model that powers predictions and advice. Replaces the custom Python ML pipeline with Azure AI Foundry fine-tuning.

- [ ] `P0` `backend` `ai` -- **Synthetic JSONL dataset** -- Generate 1,000+ prompt-completion pairs representing Peruvian university student financial profiles (spending by category, income type, month-over-month trends). Format: `{ "messages": [{ "role": "user", "content": "<spending context>" }, { "role": "assistant", "content": "<structured JSON prediction + advice>" }] }`. Covers all 11 categories, all income types (SCHOLARSHIP, PART_TIME, FAMILY, MIXED), realistic PEN amounts. Stored in `docs/ai-training/`. Refs: [US-0701](./user_stories.md#US-0701), [US-0702](./user_stories.md#US-0702)

- [ ] `P0` `ai` -- **Azure AI Foundry fine-tuning run** -- Fine-tune GPT-4o-mini (or Phi-4-mini for cost efficiency) on the JSONL dataset via Azure AI Foundry. Validate on a held-out 20% split. Target: >= 80% prediction accuracy measured as mean absolute percentage error on category spend forecasts. Document model version, training loss, and evaluation metrics in `docs/ai-training/results.md`. Refs: [US-0703](./user_stories.md#US-0703)

- [ ] `P0` `backend` `ai` -- **AiModule wired to Azure endpoint** -- Complete `src/infra/ai/` stub: `AzureFoundryProvider` calls the deployed fine-tuned model endpoint. Config via `AZURE_AI_ENDPOINT` + `AZURE_AI_KEY` env vars. Input: structured spending context (last 3 months per category). Output: `{ predictedTotal, predictedByCategory, confidenceLevel, advice }`. Refs: [US-0704](./user_stories.md#US-0704)

- [ ] `P1` `ai` -- **Fine-tuning refresh pipeline** -- Document process for resubmitting a new fine-tuning job when >= 500 new real user records are available. Azure Foundry handles infrastructure; this task is the runbook and automation trigger. Refs: [US-0705](./user_stories.md#US-0705)

---

## Phase 8: AI Predictions and Advice

> **Impact: Critical** — Main differentiator. The fine-tuned Azure model provides both numeric forecasts (via statistical trend layer) and natural language spending insights in Spanish.

- [ ] `P0` `backend` `ai` `api` -- **Expense prediction** -- `GET /api/predictions/expenses?period=next_month` computes a 3-month weighted moving average per category (statistical layer) then enriches with confidence level and category narrative from the Azure fine-tuned model. Returns: `predictedTotal`, `predictedByCategory`, `confidenceLevel`, `modelVersion`. Requires >= 2 months of history. Accuracy >= 80%. `Prediction` schema ready. Refs: [US-0801](./user_stories.md#US-0801)

- [ ] `P0` `backend` `ai` `api` -- **Income prediction** -- `GET /api/predictions/income?period=next_month` projects income using rolling average weighted by income type variability. Enriched with Azure model narrative. Refs: [US-0802](./user_stories.md#US-0802)

- [ ] `P0` `flutter` `ui` -- **Predictions screen** -- Monthly expense and income forecast, breakdown by category, projected balance, confidence indicator, and a natural language insight card powered by the fine-tuned model. Refs: [US-0801](./user_stories.md#US-0801)

- [ ] `P1` `backend` `ai` -- **Anomaly detection** -- If spending in a category exceeds >20% of its 3-month rolling average, generates an alert via the Azure model with a contextual explanation. Refs: [US-0803](./user_stories.md#US-0803)

- [ ] `P1` `backend` -- **Real accuracy tracking** -- When period completes, compare predicted vs actual. Store `actualTotal` and `accuracy` in `Prediction` model. Feeds back into dataset for next fine-tuning refresh. Refs: [US-0804](./user_stories.md#US-0804)

---

## Phase 9: Personalized Recommendations

> **Impact: High** — Closes the loop: data → analysis → concrete action.

- [ ] `P0` `backend` `ai` `api` -- **Recommendation engine** -- `GET /api/recommendations` calls the Azure fine-tuned model with the user's last 30 days of categorized spend, active goals, and budget status. Returns 1-5 recommendations in Spanish. Types: SAVINGS, BUDGET, GOAL. `Recommendation` schema ready. Refs: [US-0901](./user_stories.md#US-0901)

- [ ] `P0` `flutter` `ui` -- **Recommendations section** -- Cards with message, suggested action, feedback button ("Helpful"/"Not relevant"). Integrated into Dashboard. Refs: [US-0901](./user_stories.md#US-0901)

- [ ] `P1` `backend` -- **Acceptance tracking** -- `POST /api/recommendations/:id/feedback`. `RecommendationFeedback` schema ready. Target acceptance rate >= 60%. Refs: [US-0902](./user_stories.md#US-0902)

- [ ] `P2` `backend` `ai` -- **Feedback-driven improvement** -- Accepted/rejected recommendation feedback is included in the next fine-tuning refresh dataset, improving model relevance over time. Refs: [US-0903](./user_stories.md#US-0903)

---

## Phase 10: Educational Module and Gamification

> **Impact: High** — Key differentiator. Required to demonstrate >= 20% knowledge improvement.

- [ ] `P0` `backend` `api` -- **Educational content** -- `GET /api/education/topics`, `POST /api/education/topics/:id/complete`. Seed data ready (8 topics: Personal budget, Savings, Credit/debt, Inflation, Interest rates, Basic investing, Responsible consumption, Digital wallets in Peru). `EducationalTopic` and `UserTopicProgress` schemas ready. Refs: [US-1001](./user_stories.md#US-1001)

- [ ] `P0` `flutter` `ui` -- **Educational module** -- Topic list with difficulty and completion status. Content in readable mobile format. Mark as completed. Refs: [US-1001](./user_stories.md#US-1001)

- [ ] `P0` `backend` `api` -- **Challenge system** -- `GET /api/challenges`, `POST /api/challenges/:id/accept`, automatic completion verification. Seed data ready (4 challenges). `Challenge` and `UserChallenge` schemas ready (state machine: AVAILABLE → ACTIVE → COMPLETED). Refs: [US-1002](./user_stories.md#US-1002)

- [ ] `P0` `flutter` `ui` -- **Challenges screen** -- Active challenges with progress, available with accept button, completed with date. Refs: [US-1002](./user_stories.md#US-1002)

- [ ] `P1` `backend` `api` -- **Badge system** -- Automatic assignment by criteria. `GET /api/badges`. Seed data ready (7 badges: First Transaction, Consistency, Goal Achieved, Challenger, Financial Sage, Predictor, Budgeter). `Badge` and `UserBadge` schemas ready. Refs: [US-1003](./user_stories.md#US-1003)

- [ ] `P1` `flutter` `ui` -- **Badges screen** -- Grid with badges (colored if earned, gray if not). Detail with criteria. Refs: [US-1003](./user_stories.md#US-1003)

---

## Phase 11: Notifications and Alerts

> **Impact: Medium-High** — Maintain engagement and prevent financial problems.

- [ ] `P0` `backend` `notifications` -- **Push notification service** -- Integration with Firebase Cloud Messaging (FCM). Methods for: BUDGET_ALERT, ANOMALY_ALERT, PREDICTION_READY, CHALLENGE_REMINDER, DAILY_REMINDER, BADGE_EARNED. `NotificationPreference` schema ready. Refs: [US-1101](./user_stories.md#US-1101)

- [ ] `P0` `backend` -- **Budget alert at 80%** -- Scheduled job checks budgets. Notifies once per budget per period. Refs: [US-1102](./user_stories.md#US-1102)

- [ ] `P0` `backend` -- **Excessive spending alert** -- Trigger on transaction creation. If category exceeds >20% average of last 3 months, notify. Refs: [US-1103](./user_stories.md#US-1103)

- [ ] `P1` `flutter` `ui` -- **Notification preferences** -- Toggles per notification type. Configurable daily reminder time. `NotificationPreference` schema ready. Refs: [US-1104](./user_stories.md#US-1104)

- [ ] `P2` `backend` -- **Daily recording reminder** -- If no transaction recorded today, send reminder at configured time. Refs: [US-1105](./user_stories.md#US-1105)

---

## Phase 12: Pre/Post Usage Evaluation (Impact Measurement)

> **Impact: Critical** — Without evaluation, OE4 cannot be demonstrated. Validates educational objective.

- [ ] `P0` `backend` `api` -- **Pre-usage survey** -- `POST /api/surveys/pre/response`. 15-20 financial knowledge questions. Score 0-100. Present during onboarding. `Survey`, `SurveyQuestion`, `SurveyResponse` schemas ready. Refs: [US-1201](./user_stories.md#US-1201)

- [ ] `P0` `backend` `api` -- **Post-usage survey** -- `POST /api/surveys/post/response`. Same questionnaire variant + SUS. Present after 4-8 weeks. Refs: [US-1202](./user_stories.md#US-1202)

- [ ] `P0` `backend` `api` -- **Improvement calculation** -- Individual and aggregate pre/post comparison. Target: >= 20% improvement. Refs: [US-1203](./user_stories.md#US-1203)

- [ ] `P0` `flutter` `ui` -- **Survey screens** -- Multiple choice, one question per screen, progress bar. Score on completion with interpretation. Refs: [US-1201](./user_stories.md#US-1201)

- [ ] `P1` `backend` -- **SUS questionnaire** -- 10 standard questions. Automatic 0-100 calculation. Refs: [US-1204](./user_stories.md#US-1204)

---

## Phase 13: Security, Privacy, and Compliance

> **Impact: Critical** — Without security, handling financial data violates the law.

- [ ] `P0` `backend` `security` -- **Encryption in transit and at rest** -- Mandatory TLS. Database encryption at rest. Encrypted backup. Refs: [US-1301](./user_stories.md#US-1301)

- [ ] `P0` `flutter` `security` -- **Secure storage** -- `flutter_secure_storage` for JWT tokens and sensitive credentials. ProGuard/R8 enabled for release builds. Refs: [US-1302](./user_stories.md#US-1302)

- [x] `P0` `backend` `security` -- **Law 29733 consent** -- `consentGiven` and `consentAt` fields on `User` model. Explicit consent recorded at registration. Refs: [US-1303](./user_stories.md#US-1303)

- [x] `P1` `backend` -- **Rate limiting** -- ThrottlerModule: 120 req/min global, 10 req/min for registration, 20 req/min for login. Refs: [US-1304](./user_stories.md#US-1304)

- [ ] `P1` `backend` -- **Access auditing** -- Log sensitive actions to `AuditLog` model. Schema ready. Refs: [US-1305](./user_stories.md#US-1305)

- [ ] `P2` `backend` -- **Right to deletion** -- `DELETE /api/account` complete deletion with 30-day grace period. Refs: [US-1306](./user_stories.md#US-1306)

---

## Phase 14: Testing and Quality

> **Impact: Critical** — Without tests there is no confidence. Required by ISO 25010.

- [ ] `P0` `backend` `testing` -- **Unit tests** -- Core use cases. Coverage >= 80%. Refs: [US-1401](./user_stories.md#US-1401)

- [ ] `P0` `backend` `testing` -- **Integration tests** -- Complete pipeline: registration → login → transaction → summary → goal. Refs: [US-1402](./user_stories.md#US-1402)

- [ ] `P0` `ml` `testing` -- **Model validation** -- Accuracy >= 80%, no overfitting, coherent predictions. Refs: [US-1403](./user_stories.md#US-1403)

- [ ] `P0` `flutter` `testing` -- **Usability tests** -- 30 students, 4-8 weeks, SUS >= 4.0/5.0. Refs: [US-1404](./user_stories.md#US-1404)

- [ ] `P1` `backend` `testing` -- **Security tests** -- JWT, ownership, SQL injection, XSS, rate limiting. Refs: [US-1405](./user_stories.md#US-1405)

- [ ] `P1` `flutter` `testing` -- **Performance tests** -- Dashboard < 2s, transaction < 3s, predictions < 5s. Refs: [US-1406](./user_stories.md#US-1406)

- [ ] `P2` `flutter` `testing` -- **Compatibility tests** -- iOS 16+, Android 9+. Multiple screen resolutions. Refs: [US-1407](./user_stories.md#US-1407)

---

## Phase 15: Feedback and Continuous Improvement

> **Impact: Medium** — Enables iteration before final release.

- [ ] `P0` `backend` `api` -- **Feedback endpoint** -- `POST /api/feedback`. Type (BUG/SUGGESTION/GENERAL), message, screenName, rating (1-5). `Feedback` schema ready. Refs: [US-1501](./user_stories.md#US-1501)

- [ ] `P0` `flutter` `ui` -- **Feedback button** -- Accessible from any screen. Modal with form. Refs: [US-1501](./user_stories.md#US-1501)

- [ ] `P1` `backend` -- **Event analytics** -- Log key actions to `AnalyticsEvent` model without affecting performance. Schema ready. Refs: [US-1502](./user_stories.md#US-1502)

- [ ] `P1` `backend` -- **Internal metrics dashboard** -- Active users, transactions/day, pre/post scores, recommendation acceptance rate. Refs: [US-1503](./user_stories.md#US-1503)

---

## Phase 16: Demo Readiness and Documentation

> **Impact: Critical** — Validation requires realistic data and reproducible scenarios.

- [ ] `P0` `database` -- **Test data script** -- 5 varied student profiles, 200+ transactions per user (3 months), budgets, goals, pre-usage surveys. Refs: [US-1601](./user_stories.md#US-1601)

- [ ] `P0` `docs` -- **Installation guide** -- Step by step: clone, Docker, env vars, backend (`npm run start:dev`), Flutter app (`flutter run`). Refs: [US-1602](./user_stories.md#US-1602)

- [ ] `P0` `docs` -- **Demo script** -- 15-20 min: registration → onboarding → survey → transactions → report → budget → prediction → recommendation → challenge → badges. Refs: [US-1603](./user_stories.md#US-1603)

- [ ] `P1` `docs` -- **Technical documentation** -- Context diagram, component diagram, DB schema, AI flow, key technical decisions. Refs: [US-1604](./user_stories.md#US-1604)

---

## Global Timeline

| Phase | Name | Sprint(s) | Duration | Status |
|-------|------|-----------|----------|--------|
| 1 | Infrastructure and Setup | Sprint 1 | 3 weeks | ✅ Done |
| 2 | Authentication and Users | Sprint 1-2 | 3 weeks | ✅ Done |
| 3 | Transaction Recording | Sprint 2-3 | 4 weeks | ✅ Done |
| 4 | Categorization | Sprint 3 | 2 weeks | ✅ Done |
| 5 | Reports and Visualization | Sprint 4-5 | 4 weeks | 🔄 Partial (monthly summary done; weekly/daily/comparison pending) |
| 6 | Budgets and Goals | Sprint 5-6 | 3 weeks | 🔄 Partial (goals backend done; budgets backend + all frontend pending) |
| 7 | ML Pipeline (Data) | Sprint 6-7 | 4 weeks | -- |
| 8 | AI Predictions | Sprint 7-8 | 4 weeks | -- |
| 9 | Recommendations | Sprint 8-9 | 3 weeks | -- |
| 10 | Education and Gamification | Sprint 9-10 | 4 weeks | -- |
| 11 | Notifications | Sprint 10 | 2 weeks | -- |
| 12 | Pre/Post Evaluation | Sprint 11 | 3 weeks | -- |
| 13 | Security and Compliance | Sprint 11-12 | 3 weeks | 🔄 Partial (consent + rate limiting done) |
| 14 | Testing and Quality | Sprint 12-13 | 3 weeks | -- |
| 15 | Feedback and Analytics | Sprint 13 | 2 weeks | -- |
| 16 | Demo Readiness | Sprint 14 | 2 weeks | -- |

---

## Risk Mitigation

| Risk | Prob. | Impact | Mitigation | Owner |
|------|-------|--------|------------|-------|
| **Cloud AI integration failures** | Medium | High | REST API inference endpoint as primary; TFLite fallback | Fernando |
| **ML complexity delays** | High | High | Short sprints, rapid prototyping, MVP prioritization | Fernando |
| **Team availability** | Medium | Medium | Fixed schedules, backup plan, workload monitoring | Both |
| **Data vulnerabilities** | Medium | High | E2E encryption, security audits, Law 29733 compliance | Paolo |
| **Low model accuracy** | Medium | High | Cross-validation, data augmentation | Fernando |
| **Requirement changes** | High | Medium | Formal change process | Both |
| **Insufficient data** | Low | High | Synthetic data, university collaboration | Fernando |
| **Low adoption** | Medium | Medium | Early pilot tests, gamification | Paolo |
| **Frontend-backend integration lag** | Medium | High | Integrate early (Phase 2 completion), not at end | Paolo |
| **Library obsolescence** | Low | Medium | Continuous updates | Fernando |

---

## Success Metrics (Post-Demo)

| Metric | Target | Actual |
|--------|--------|--------|
| **Prediction accuracy** | >= 80% | ___ |
| **Knowledge improvement** | >= 20% | ___ |
| **SUS score** | >= 4.0/5.0 | ___ |
| **Critical error rate** | < 1% | ___ |
| **Test coverage** | Services 80%+ | ___ |
| **Pilot users** | >= 30 | ___ |
| **Completed surveys** | >= 100 pairs | ___ |
| **Demo duration** | 15-20 min | ___ |

---

**See also:**
- [mission.md](./mission.md) — Product vision and objectives
- [user_stories.md](./user_stories.md) — Detailed user stories (18 epics)
