# Zenda MVP Roadmap — Execution Plan by Phases

**Goal:** A functional mobile application where university students record transactions, view reports, receive AI-powered spending predictions (>= 80% accuracy), complete gamified educational challenges, and demonstrate a >= 20% increase in financial knowledge measured by pre/post usage survey. The app meets usability (SUS >= 4.0/5.0), security (Law 29733), and quality (ISO 25010) standards.

**Duration:** 10.5 months (February 2026 — December 2026)
**Team:** 2 part-time developers (20 hrs/week each)
**Budget:** S/ 14,241 (general expenses + goods and subcontracting)

**Critical Path:** Infrastructure → Auth → Transaction Recording → Categorization → Reports → Budgets → AI Integration → Predictions → Recommendations → Education/Gamification → Notifications → Pre/Post Evaluation → User Validation → Demo

---

## Technical Foundation

**Stack:**
- Mobile Frontend: Flutter 3.10+ (Dart) — iOS and Android, feature-based architecture with Riverpod 3
- Backend: NestJS 11 + Prisma ORM + PostgreSQL 15 (Docker locally, cloud TBD for production)
- State Management: Riverpod 3 (AsyncNotifierProvider, NotifierProvider, FutureProvider)
- Navigation: GoRouter 17
- Charts: fl_chart 1.1.1
- AI: Azure AI Foundry — GPT-4o-mini (or Phi-4-mini) external API for predictions, advice, anomaly detection, and recommendations
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

- [x] `P0` `infra` `backend` -- **Git repository setup** -- Monorepo on GitHub: `zenda_backend_app/` (NestJS API), `zenda_fronted_app/` (Flutter app), `docs/` (documentation). Includes `.gitignore`, `README.md`, `CONTRIBUTING.md`, `SETUP.md`, `LICENSE`. Branch strategy: `main` (protected), `feature/*`, `chore/*`.

- [x] `P0` `infra` `backend` -- **PostgreSQL database setup** -- PostgreSQL 15 via Docker Compose (`docker-compose.yml`). Prisma ORM manages schema (`prisma/schema.prisma`). Migrations via `npx prisma migrate dev`. Azure provisioning deferred to production deployment.

- [x] `P0` `infra` `flutter` -- **Base Flutter project** -- Flutter 3.10+ project (`zenda_fronted_app/`). Architecture: feature-based under `lib/features/`. State management: Riverpod 3 (NotifierProvider, AsyncNotifierProvider). Navigation: GoRouter 17 (`lib/routing/app_router.dart`). Local storage: SharedPreferences via `LocalKvStore`. Theme: Material Design 3 light/dark in `lib/core/theme/`.

- [x] `P0` `infra` `backend` -- **Base REST API** -- NestJS 11 server. Health check: `GET /api/health` returns `{ status: "ok", timestamp, version: "1.0.0" }`. Global prefix `/api` (no `/v1`). CORS (localhost regex), rate limiting (ThrottlerModule: 120 req/min global), Helmet security headers, ValidationPipe (strict), centralized GlobalExceptionFilter. Swagger at `/api/docs`.

- [x] `P1` `infra` -- **CI/CD setup** -- `.github/workflows/ci.yml`: backend (build + tsc typecheck) and frontend (`flutter analyze`) on each PR. Deployment to production deferred.

- [x] `P1` `infra` -- **Environment variables and secrets** -- `.env.example` with all required variables. Documented in `SETUP.md`.

---

### 1B. Database Design and Data Model

> **Impact: Critical** — The schema defines the structure of the entire application.

- [x] `P0` `backend` `database` -- **Users schema** -- Model `User`: `id` (UUID PK), `email` (UNIQUE NOT NULL), `passwordHash` (TEXT), `fullName` (VARCHAR), `age` (INT?), `university` (VARCHAR?), `incomeType` (ENUM: SCHOLARSHIP, PART_TIME, FAMILY, MIXED), `averageMonthlyIncome` (Decimal 12,2), `financialLiteracyLevel` (ENUM: LOW, MEDIUM, HIGH), `profileCompleted` (Boolean default false), `currency` (VARCHAR 3 default 'PEN'), `consentGiven` (Boolean), `consentAt` (DateTime?), `createdAt`, `updatedAt`, `deletedAt`. Refs: US-027, US-028, US-029, US-030, US-031

- [x] `P0` `backend` `database` -- **Transactions schema** -- Model `Transaction`: `id` (UUID PK), `userId` (FK → User, Cascade), `type` (ENUM: INCOME, EXPENSE), `amount` (Decimal 12,2 NOT NULL), `categoryId` (FK → Category, SetNull), `description` (TEXT?), `occurredAt` (DateTime default now()), `deletedAt` (DateTime?), `createdAt`, `updatedAt`. Indexes: `(userId, occurredAt, deletedAt)`, `(userId, categoryId)`, `(userId, type, occurredAt, deletedAt)`. Refs: US-001, US-002, US-003, US-004

- [x] `P0` `backend` `database` -- **Categories, budgets, goals schema** -- Models `Category`, `Budget` (@@unique userId+categoryId+month+year), `SavingsGoal`. Soft deletes on all. Foreign keys with appropriate onDelete strategies. Refs: US-005, US-006, US-019, US-021, US-040, US-041, US-042, US-043, US-044, US-045

- [x] `P1` `backend` `database` -- **Gamification, AI, and evaluation schema** -- Models: `EducationalTopic`, `UserTopicProgress`, `Challenge`, `UserChallenge`, `Badge`, `UserBadge`, `Prediction`, `Recommendation`, `RecommendationFeedback`, `Survey`, `SurveyQuestion`, `SurveyResponse`, `AnalyticsEvent`, `AuditLog`, `Feedback`, `NotificationPreference`. Schema complete; backend services/endpoints implemented in their respective phases. Refs: US-017, US-023, US-024, US-025, US-026, US-033, US-034, US-036, US-037, US-046, US-047, US-048, US-049

---

## Phase 2: Authentication and User Management

> **Impact: Critical** — Without authentication there is no access to the app. Blocks all user functions.

- [x] `P0` `backend` `security` -- **Registration endpoint** -- `POST /api/auth/register` accepts `email`, `password`, `fullName`. Validates email format, password >= 12 chars. Creates user. Returns JWT token. bcrypt password hashing. Refs: US-027

- [x] `P0` `backend` `security` -- **Login endpoint** -- `POST /api/auth/login` accepts `email`, `password`. Validates credentials. Returns JWT. Temporary lockout after 3 consecutive failed attempts (15 min). Refs: US-028

- [x] `P0` `backend` `security` -- **JWT authentication middleware** -- `JwtAuthGuard` protects all routes under `/api/*` except `/api/auth/*` and `/api/health`. Validates signature and expiration. Injects `userId` via `@UserId()` decorator. Returns 401 if invalid. Refs: US-028, US-029

- [x] `P0` `flutter` `ui` -- **Registration and login screens** -- Forms with real-time validation, loading states, error handling. `AuthApiService` calls `/auth/register` and `/auth/login`. JWT stored in `flutter_secure_storage`. Profile fetched from `/users/me` after login. Refs: US-027, US-028

- [x] `P1` `backend` -- **Password recovery** -- `POST /api/auth/forgot-password` generates a 32-byte token (1h expiry), stores it, sends email via `EmailService`. `POST /api/auth/reset-password` validates token, hashes new password, deletes token. Both rate-limited (5 req/min).

- [x] `P1` `flutter` `ui` -- **Initial profile onboarding** -- Multi-page onboarding screen after first launch. Captures age, university, income type, average income. Saves `profileCompleted = true`. Skip option available. Refs: US-030, US-032

- [x] `P1` `flutter` `ui` -- **Profile editing** -- `ProfileScreen` displays and edits full name, age, university, currency, income type, monthly income, financial literacy. Calls `UserApiService.updateProfile()` → `PUT /api/users/me`. Backend: `GetProfileUseCase` (`GET /api/users/me`) and `UpdateProfileUseCase` (`PUT /api/users/me`) fully wired with DDD layers. Refs: US-031

---

## Phase 3: Transaction Recording (Core Feature)

> **Impact: Critical** — This is the app's primary action. Without transactions there is no data for anything else.

- [x] `P0` `backend` `api` -- **Transaction CRUD** -- `POST /api/transactions` (create), `GET /api/transactions` (list with filters: type, categoryId, dateFrom, dateTo, minAmount, maxAmount), `DELETE /api/transactions/:id` (soft delete). Ownership validated via `@UserId()`. Refs: US-001, US-002, US-003, US-004

- [x] `P0` `flutter` `ui` -- **Transaction recording screen** -- `AddTransactionScreen`: kind selector (Expense/Income/Transfer), amount, category grid, account picker, date picker, note. `NewTransactionController` saves locally then fire-and-forget syncs EXPENSE/INCOME to `POST /api/transactions` via `TransactionApiService`. Refs: US-001, US-002

- [x] `P0` `flutter` `ui` -- **Main dashboard** -- `DashboardScreen`: 4-tab PageView (Home, Transactions, Budget, Profile). Shows balance summary, last transactions, streak card, 50/30/20 pie chart, AI advice card.

- [x] `P1` `flutter` `ui` -- **History with filters** -- `TransactionListScreen`: type filter chips (All/Expenses/Income), date range chips (This week/This month/All time), category filter, amount range filter, loads from `GET /api/transactions`, Dismissible swipe-to-delete, pull-to-refresh. Dashboard Transactions tab renders this screen. Refs: US-012, US-039

- [x] `P2` `backend` `api` -- **Transaction detail and edit** -- `GET /api/transactions/:id` (`GetTransactionUseCase`, ownership verified) and `PUT /api/transactions/:id` (`UpdateTransactionUseCase`, optional field updates, category re-resolution). Refs: US-003, US-004

---

## Phase 4: Categorization System

> **Impact: High** — Foundation for reports, predictions, and budgets.

- [x] `P0` `backend` -- **Default categories (seed)** -- 9 expense categories (comida, transporte, vivienda, servicios, salud, ocio, compras, suscripciones, antojos) and 5 income categories seeded via `prisma/seed.ts`. Idempotent seeding. Refs: US-005, US-006

- [x] `P0` `backend` `api` -- **Custom categories CRUD** -- `POST /api/categories` (create, name-uniqueness guard), `GET /api/categories` (list system + user custom), `PUT /api/categories/:id` (rename, ownership + name-collision guard), `DELETE /api/categories/:id` (soft delete, blocked if transactions exist). `ResolveCategoryUseCase` creates on-the-fly during transaction creation. Refs: US-040, US-041

- [x] `P0` `flutter` `ui` -- **Category selector** -- Grid with icons/colors in `AddTransactionScreen`. Maps to 50/30/20 buckets via `bucketForCategory()`. Refs: US-005, US-006

- [x] `P1` `flutter` `ui` -- **Category management screen** -- `CategoryManagementScreen`: lists system (read-only) and custom categories. FAB to create, edit icon to rename, swipe-to-delete. Routes to `/categories` from `ProfileScreen`. `CategoryApiService` calls `GET/POST/PUT/DELETE /api/categories`. Refs: US-040, US-041

---

## Phase 5: Financial Reports and Visualization

> **Impact: High** — Visibility into financial habits. Prerequisite for predictions to have context.

- [x] `P0` `backend` `api` -- **Monthly summary endpoint** -- `GET /api/summary/month?year=&month=` returns total income, total expense, net balance, breakdownByCategory (name, amount, percentage), savings goals progress. Uses `Promise.all` for parallel aggregation queries. Response < 3 sec. Refs: US-009, US-038

- [x] `P0` `backend` `api` -- **Weekly and daily summary endpoints** -- `GET /api/summary/week` and `GET /api/summary/day`. Breakdown by category. Response < 2 sec. Refs: US-007, US-008

- [x] `P0` `backend` `api` -- **Multi-month comparison endpoint** -- `GET /api/summary/comparison?months=3`. Returns totals per month for comparison chart. Refs: US-011

- [x] `P0` `flutter` `ui` -- **Monthly summary in dashboard** -- 50/30/20 `BudgetPieChart` (fl_chart), `SummaryCard` (today/week totals), category breakdown list. Refs: US-009, US-038

- [x] `P1` `flutter` `ui` -- **Interactive charts screen** -- Bar charts by category (sorted highest to lowest), comparative line charts by month using fl_chart. Tap for detail. Period selector: week, month, quarter. Backend integration required. Refs: US-010, US-011

- [x] `P1` `backend` `api` -- **Financial progress indicator** -- `GET /api/insights/progress` returns current vs previous month: total expenses, savings, net balance with improvement/decline % and direction per metric. Requires minimum 2-month history; returns informative empty state otherwise. Refs: US-014

- [x] `P2` `backend` `api` -- **PDF export** -- Generates PDF with complete summary including charts, totals, and category breakdown. Share intent (native share sheet). Temporary download URL (24h). Refs: US-013

---

## Phase 6: Budget and Financial Goal Management

> **Impact: High** — Prerequisite for intelligent alerts. Goals give purpose to savings.

- [x] `P0` `backend` `api` -- **Budget CRUD** -- `POST /api/budgets` (create, amount > 0 validated), `GET /api/budgets` (with `currentSpent` and `percentageUsed`), `PUT /api/budgets/:id` (edit limit, ownership validated), `DELETE /api/budgets/:id` (removes budget and stops alerts). Budget model and schema ready (`@@unique([userId, categoryId, month, year])`). Refs: US-019, US-042, US-043

- [x] `P0` `flutter` `ui` -- **Budget screen** -- List with progress bars. Creation modal. Edit and delete actions. Empty state when no budgets. Backend integration required. Refs: US-019, US-042, US-043

- [x] `P1` `backend` `api` -- **Financial goals CRUD** -- `POST /api/goals` (create, future deadline validated), `GET /api/goals`, `POST /api/goals/:id/contribute` (amount > 0 validated), `PUT /api/goals/:id` (mark complete), `DELETE /api/goals/:id` (removes goal and all contributions). Ownership validated. Contribution updates `currentAmount` (Decimal arithmetic). Refs: US-021, US-044, US-045

- [x] `P1` `flutter` `ui` -- **Goals screen** -- Cards with progress, contribute button, mark-complete action, delete action, completion animation. Backend integration required. Refs: US-021, US-044, US-045

- [x] `P2` `flutter` `ui` -- **Goal detail** -- Contribution history, cumulative progress chart, completion projection ("At this pace you'll finish on {date}"), alert if projection misses deadline. Refs: US-022

---

## Phase 7: AI Integration — Azure AI Foundry Setup

> **Impact: Critical** — Connects the backend to the Azure AI external API that powers predictions, advice, anomaly detection, and recommendations.

- [x] `P0` `backend` `ai` -- **AiModule wired to Azure endpoint** -- Complete `src/infra/ai/` stub: `AzureFoundryProvider` calls the Azure AI API endpoint. Config via `AZURE_AI_ENDPOINT` + `AZURE_AI_KEY` env vars. Input: structured spending context (last 3 months per category). Output: `{ predictedTotal, predictedByCategory, confidenceLevel, advice }`. Error handling: timeout, quota exceeded, malformed response.

- [x] `P1` `backend` `ai` `api` -- **AI auto-categorization** -- When recording a transaction, send description + amount to Azure AI for category inference. Returns suggested `categoryId` with confidence level. Pre-selects suggestion in the form (user can override). Falls back gracefully if API unavailable or confidence < 60%. Refs: US-018

---

## Phase 8: AI Predictions and Advice

> **Impact: Critical** — Main differentiator. The Azure AI model provides both numeric forecasts (via statistical trend layer) and natural language spending insights in Spanish.

- [x] `P0` `backend` `ai` `api` -- **Expense prediction** -- `GET /api/predictions/expenses?period=next_month` computes a 3-month weighted moving average per category (statistical layer) then enriches with confidence level and category narrative from the Azure AI model. Returns: `predictedTotal`, `predictedByCategory`, `confidenceLevel`, `modelVersion`. Requires >= 2 months of history. Result only shown if confidence >= 60%. `Prediction` schema ready. Refs: US-015

- [x] `P0` `flutter` `ui` -- **Predictions screen** -- Monthly expense forecast, breakdown by category, projected balance, confidence indicator, and a natural language insight card powered by the Azure AI model. Empty state if insufficient history. Refs: US-015

- [ ] `P1` `backend` `ai` -- **Anomaly detection** -- If spending in a category exceeds >20% of its 3-month rolling average, generates an alert via the Azure AI model with a contextual explanation. Maximum one alert per category per month. Refs: US-016

- [ ] `P1` `backend` -- **Real accuracy tracking** -- When period completes, compare predicted vs actual. Store `actualTotal` and `accuracy` in `Prediction` model. Refs: US-015

---

## Phase 9: Personalized Recommendations

> **Impact: High** — Closes the loop: data → analysis → concrete action.

- [x] `P0` `backend` `ai` `api` -- **Recommendation engine** -- `GET /api/recommendations` calls the Azure AI model with the user's last 30 days of categorized spend, active goals, and budget status. Returns 1-5 recommendations in Spanish. Types: SAVINGS, BUDGET, GOAL. Requires >= 1 month history + at least one active goal or budget. `Recommendation` schema ready. Refs: US-017

- [x] `P0` `flutter` `ui` -- **Recommendations section** -- Cards with message, suggested action, feedback button ("Helpful"/"Not relevant"). Integrated into Dashboard. Empty state if insufficient data. Refs: US-017

- [x] `P1` `backend` -- **Acceptance tracking** -- `POST /api/recommendations/:id/feedback`. `RecommendationFeedback` schema ready. Target acceptance rate >= 60%.

---

## Phase 10: Educational Module and Gamification

> **Impact: High** — Key differentiator. Required to demonstrate >= 20% knowledge improvement.

- [x] `P0` `backend` `api` -- **Educational content** -- `GET /api/education/topics`, `GET /api/education/topics/:id`, `PATCH /api/education/topics/:id/complete`. Seed data ready (8 topics: Personal budget, Savings, Credit/debt, Inflation, Interest rates, Basic investing, Responsible consumption, Digital wallets in Peru). `EducationalTopic` and `UserTopicProgress` schemas ready. Refs: US-023

- [x] `P0` `flutter` `ui` -- **Educational module** -- Topic list with difficulty and completion status. Content in readable mobile format (text + icons + practical Peruvian examples). Mark as completed. Visual distinction between read and unread modules. Refs: US-023

- [x] `P0` `backend` `api` -- **Challenge system** -- `GET /api/challenges`, `POST /api/challenges/:id/accept`, automatic completion verification via criteria_json. Expired challenges move to expired state and become re-available. Seed data ready (4 challenges). `Challenge` and `UserChallenge` schemas ready (state machine: AVAILABLE → ACTIVE → COMPLETED/EXPIRED). Refs: US-024, US-046

- [x] `P0` `flutter` `ui` -- **Challenges screen** -- Active challenges with progress, available with accept button, completed with date, expired section. Prevents duplicate active challenges of same type. Refs: US-024, US-046

- [x] `P0` `backend` `api` -- **Knowledge quizzes** -- `GET /api/education/topics/:id/quiz?language=en|es` returns 5 questions (2 BEGINNER + 2 INTERMEDIATE + 1 ADVANCED) from a pool of 88 seeded bilingual questions (Peru-specific). `POST /api/education/topics/:id/quiz/submit` accepts answers map, returns score, correctCount, level, and per-question feedback. Refs: US-026

- [x] `P0` `flutter` `ui` -- **Quiz screen** -- State machine: answering → reviewing → results. Progress bar, per-question option tiles with animated color feedback (green/red). Results view with score, level badge, and full review list. Language auto-selected from device locale. Refs: US-026

- [x] `P1` `backend` `api` -- **Badge system** -- Automatic assignment by criteria. `GET /api/badges`. Seed data ready (7 badges: First Transaction, Consistency, Goal Achieved, Challenger, Financial Sage, Predictor, Budgeter). No duplicate badges. `Badge` and `UserBadge` schemas ready. 6/7 triggers wired via `awardIfNotEarned()`. **Gap:** "Predictor" badge not wired (no trigger on prediction view count). Refs: US-025

- [x] `P1` `flutter` `ui` -- **Badges screen** -- Grid with badges (colored if earned, gray if not). Tap for detail: name, description, criteria, date earned. Refs: US-025

- [ ] `P2` `backend` `ai` `api` -- **AI learning path** -- `GET /api/education/learning-path` calls Azure AI with user's spending history, active budgets, and goals to order modules by relevance. Each module includes a brief explanation of why it is prioritized. Returns default order with informative note if history is insufficient. Refs: US-048

- [ ] `P2` `backend` `ai` `api` -- **AI-generated contextual questions** -- `GET /api/education/quizzes/contextual` generates quiz questions via Azure AI based on the user's high-spend categories or exceeded budgets. Falls back to generic fundamental questions with note when history is insufficient. Questions generated in Spanish. Refs: US-049

---

## Phase 11: Notifications and Alerts

> **Impact: Medium-High** — Maintain engagement and prevent financial problems.

- [ ] `P0` `backend` `notifications` -- **Push notification service** -- Integration with Firebase Cloud Messaging (FCM). Methods for: BUDGET_ALERT, ANOMALY_ALERT, PREDICTION_READY, CHALLENGE_REMINDER, DAILY_REMINDER, BADGE_EARNED. `NotificationPreference` schema ready.

- [ ] `P0` `backend` -- **Budget alert at 80%** -- When spending in a category reaches 80% of the defined monthly limit, sends notification to the user. Refs: US-020

- [ ] `P0` `backend` -- **Excessive spending alert** -- Trigger on transaction creation. If category spending exceeds >20% average of last 3 months, notify. Maximum one alert per category per month. Refs: US-016

- [ ] `P1` `flutter` `ui` -- **Notification preferences** -- Toggles per notification type. Configurable daily reminder time. Refs: US-020

- [ ] `P2` `backend` -- **Daily recording reminder** -- If no transaction recorded today, send reminder at configured time.

---

## Phase 12: Pre/Post Usage Evaluation (Impact Measurement)

> **Impact: Critical** — Without evaluation, the educational objective cannot be demonstrated.

- [x] `P0` `backend` `api` -- **Pre-usage survey** -- `POST /api/surveys/pre/response`. Financial knowledge questions seeded with correct answers; score 0-100. Present during onboarding. `Survey`, `SurveyQuestion`, `SurveyResponse` schemas ready. Refs: US-033

- [x] `P0` `backend` `api` -- **Post-usage survey + final evaluation invitation** -- `POST /api/surveys/post/response`. Questions with correct answers. Answers linked to pre-survey for improvement % calculation. Non-intrusive invitation shown after 30 days. Invitation persists until completed or pilot ends. Refs: US-034, US-047

- [x] `P0` `backend` `api` -- **Improvement calculation** -- Individual and aggregate pre/post comparison. `GET /api/surveys/comparison` returns pre_score, post_score, improvement_percentage per user. Target: >= 20% improvement. Refs: US-033, US-047

- [x] `P0` `flutter` `ui` -- **Survey screens** -- Multiple choice, one question per screen, progress bar. Cannot advance without answering. Score on completion with interpretation and comparison to pre-survey. Refs: US-033, US-034, US-047

- [ ] `P1` `backend` `flutter` -- **SUS questionnaire** -- 10 standard questions. Automatic 0-100 calculation. Blocks submission if any question unanswered. Refs: US-035

---

## Phase 13: Security, Privacy, and Compliance

> **Impact: Critical** — Without security, handling financial data violates the law.

- [ ] `P0` `backend` `security` -- **Encryption in transit and at rest** -- Mandatory TLS. Database encryption at rest. Encrypted backup. 401 returned without exposing sensitive info when token invalid/absent. Refs: US-029

- [x] `P0` `flutter` `security` -- **Secure storage** -- `flutter_secure_storage` for JWT tokens and sensitive credentials. **Gap:** ProGuard/R8 not yet configured for release builds. Refs: US-029

- [x] `P0` `backend` `security` -- **Law 29733 consent** -- `consentGiven` and `consentAt` fields on `User` model. Explicit consent recorded at registration. Refs: US-029

- [x] `P1` `backend` -- **Rate limiting** -- ThrottlerModule: 120 req/min global, 10 req/min for registration, 20 req/min for login. Refs: US-029

- [ ] `P1` `backend` -- **Access auditing** -- Log sensitive actions to `AuditLog` model. Schema ready. Refs: US-029

- [x] `P2` `backend` -- **Right to deletion** -- `DELETE /api/users/me` implemented. **Gap:** 30-day grace period not implemented. Refs: US-029

---

## Phase 14: Testing and Quality

> **Impact: Critical** — Without tests there is no confidence. Required by ISO 25010.

- [ ] `P0` `backend` `testing` -- **Unit tests** -- Core use cases. Coverage >= 80%.

- [ ] `P0` `backend` `testing` -- **Integration tests** -- Complete pipeline: registration → login → transaction → summary → goal.

- [ ] `P0` `backend` `testing` -- **AI API integration validation** -- Response accuracy >= 80% against historical data, coherent predictions (non-negative, within PEN ranges), fallback behavior tested. Refs: US-015, US-016, US-017, US-018

- [ ] `P0` `flutter` `testing` -- **Usability tests** -- SUS questionnaire administered at end of pilot period. Target SUS score >= 4.0/5.0. Refs: US-035

- [ ] `P1` `backend` `testing` -- **Security tests** -- JWT, ownership, SQL injection, XSS, rate limiting. Refs: US-029

- [ ] `P1` `flutter` `testing` -- **Performance tests** -- Dashboard < 2s, transaction < 3s, predictions < 5s.

- [ ] `P2` `flutter` `testing` -- **Compatibility tests** -- iOS 16+, Android 9+. Multiple screen resolutions.

---

## Phase 15: Feedback and Continuous Improvement

> **Impact: Medium** — Enables iteration before final release.

- [x] `P0` `backend` `api` -- **Feedback endpoint** -- `POST /api/feedback`. Type (BUG/SUGGESTION/GENERAL), message, screenName, rating (1-5). Field validation: message required (>= 1 char). `Feedback` schema ready. Refs: US-036

- [x] `P0` `flutter` `ui` -- **Feedback button** -- Accessible from profile screen. Modal with form. Confirmation shown on submit. Submit blocked if message empty. Refs: US-036

- [x] `P1` `backend` -- **Event analytics** -- `AnalyticsService` (`@Global()`) logs 12 event types: `login`, `register`, `record_transaction`, `delete_transaction`, `create_goal`, `contribute_goal`, `complete_goal`, `accept_challenge`, `complete_challenge`, `complete_topic`, `create_budget`, `submit_feedback`. Async — does not block use-case response path. `AnalyticsEvent` schema ready. Refs: US-037

- [ ] `P1` `backend` -- **Internal metrics dashboard** -- Active users, transactions/day, pre/post scores, recommendation acceptance rate. Refs: US-037

---

## Phase 16: Demo Readiness and Documentation

> **Impact: Critical** — Validation requires realistic data and reproducible scenarios.

- [ ] `P0` `database` -- **Test data script** -- 5 varied student profiles, 200+ transactions per user (3 months), budgets, goals, pre-usage surveys completed.

- [ ] `P0` `docs` -- **Installation guide** -- Step by step: clone, Docker, env vars, backend (`npm run start:dev`), Flutter app (`flutter run`).

- [ ] `P0` `docs` -- **Demo script** -- 15-20 min: registration → onboarding → survey → transactions → report → budget → prediction → recommendation → challenge → badges.

- [ ] `P1` `docs` -- **Technical documentation** -- Context diagram, component diagram, DB schema, AI flow, key technical decisions.

---

## Global Timeline

| Phase | Name | Sprint(s) | Duration | Status |
|-------|------|-----------|----------|--------|
| 1 | Infrastructure and Setup | Sprint 1 | 3 weeks | Done |
| 2 | Authentication and Users | Sprint 1-2 | 3 weeks | Done |
| 3 | Transaction Recording | Sprint 2-3 | 4 weeks | Done |
| 4 | Categorization | Sprint 3 | 2 weeks | Done |
| 5 | Reports and Visualization | Sprint 4-5 | 4 weeks | Done (PDF export deferred to P2) |
| 6 | Budgets and Goals | Sprint 5-6 | 3 weeks | Done |
| 7 | AI Integration (Azure AI Foundry) | Sprint 6-7 | 4 weeks | Done |
| 8 | AI Predictions | Sprint 7-8 | 4 weeks | Partial (prediction endpoint + Flutter screen done; anomaly detection and accuracy tracking not done) |
| 9 | Recommendations | Sprint 8-9 | 3 weeks | Done |
| 10 | Education and Gamification | Sprint 9-10 | 4 weeks | Partial (topics + challenges + badges + quizzes done; 6/7 badge triggers wired; AI learning path not done) |
| 11 | Notifications | Sprint 10 | 2 weeks | -- |
| 12 | Pre/Post Evaluation | Sprint 11 | 3 weeks | Partial (survey endpoints + Flutter screen + improvement calc done; SUS not done) |
| 13 | Security and Compliance | Sprint 11-12 | 3 weeks | Partial (consent + rate limiting + secure storage + right-to-deletion done; TLS and AuditLog not done) |
| 14 | Testing and Quality | Sprint 12-13 | 3 weeks | -- |
| 15 | Feedback and Analytics | Sprint 13 | 2 weeks | Partial (feedback endpoint + Flutter modal + event analytics done; metrics dashboard not done) |
| 16 | Demo Readiness | Sprint 14 | 2 weeks | -- |

---

## Risk Mitigation

| Risk | Prob. | Impact | Mitigation | Owner |
|------|-------|--------|------------|-------|
| **Azure AI API unavailability** | Medium | High | Graceful degradation: disable AI features, notify user, retry on next request | Fernando |
| **AI API response quality** | Medium | High | Prompt engineering with validated examples, response schema validation, fallback message | Fernando |
| **Team availability** | Medium | Medium | Fixed schedules, backup plan, workload monitoring | Both |
| **Data vulnerabilities** | Medium | High | E2E encryption, security audits, Law 29733 compliance | Paolo |
| **AI API cost overrun** | Low | Medium | Rate limit per user, cache responses where appropriate, monitor usage | Fernando |
| **Requirement changes** | High | Medium | Formal change process | Both |
| **Low API response accuracy** | Medium | High | Improve prompt context, adjust system prompt and spending context window | Fernando |
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
- [user_stories.md](./user_stories.md) — 49 official user stories (US-001–US-049)
- [docs/thesisDocs/P202616_HU_y_Criterios_Aceptacion_V1.md](../../../docs/thesisDocs/P202616_HU_y_Criterios_Aceptacion_V1.md) — Source of truth: BDD acceptance criteria in Spanish
