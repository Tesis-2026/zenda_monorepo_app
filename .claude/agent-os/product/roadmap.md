# Zenda MVP Roadmap — Execution Plan by Phases

**Goal:** A functional mobile application where university students record transactions, view reports, receive AI-powered spending predictions (>= 80% accuracy), complete gamified educational challenges, and demonstrate a >= 20% increase in financial knowledge measured by pre/post usage survey. The app meets usability (SUS >= 4.0/5.0), security (Law 29733), and quality (ISO 25010) standards.

**Duration:** 10.5 months (February 2026 — December 2026)
**Team:** 2 part-time developers (20 hrs/week each)
**Budget:** S/ 14,241 (general expenses + goods and subcontracting)

**Critical Path:** Infrastructure → Auth → Transaction Recording → Categorization → Reports → Budgets → ML Pipeline → Predictions → Recommendations → Education/Gamification → Notifications → Pre/Post Evaluation → User Validation → Demo

---

## Technical Foundation

**Stack:**
- Mobile Frontend: Android native (Kotlin) — Android 9+ (API 28)
- Backend: Node.js/Express or Spring Boot + PostgreSQL
- AI/ML: Python (Scikit-learn, TensorFlow Lite) — models exported for mobile inference
- Cloud: Azure (cloud services, storage, AI APIs)
- Authentication: Firebase Auth (email/password)
- Notifications: Firebase Cloud Messaging (FCM)
- CI/CD: GitHub Actions + Google Play Internal Testing

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

- [ ] `P0` `infra` `backend` -- **Git repository setup** -- Create monorepo on GitHub with structure: `/android` (mobile app), `/backend` (REST API), `/ml` (AI models), `/docs` (documentation). Include `.gitignore`, `README.md`, `CONTRIBUTING.md`, `LICENSE`. Configure branch protection: `main` (protected), `develop` (integration), `feature/*` (development). Refs: [US-1801](./user_stories.md#US-1801)

- [ ] `P0` `infra` `backend` -- **PostgreSQL database setup** -- Provision PostgreSQL instance on Azure. Create initial schema with tables: `users`, `transactions`, `categories`, `budgets`, `goals`, `educational_content`, `challenges`, `badges`, `user_badges`, `predictions`, `recommendations`, `surveys`, `survey_responses`, `notification_preferences`, `analytics_events`, `audit_logs`, `feedback`. Include indexes, foreign keys, check constraints, enums. Script: `database/schema.sql`. Refs: [US-1802](./user_stories.md#US-1802)

- [ ] `P0` `infra` `android` -- **Base Android project** -- Create Android Studio project with Kotlin, minSdkVersion 28 (Android 9). Configure: MVVM architecture, Room (local SQLite), Retrofit (HTTP client), Hilt (dependency injection), Navigation Component, Material Design 3. Package structure: `ui/`, `data/`, `domain/`, `di/`, `utils/`. Refs: [US-1803](./user_stories.md#US-1803)

- [ ] `P0` `infra` `backend` -- **Base REST API** -- Configure backend server with health-check endpoints: `GET /api/v1/health` returns `{ status: "ok", version: "1.0.0" }`. Configure CORS, global rate limiting, logging, centralized error handling. Document with OpenAPI/Swagger. Refs: [US-1804](./user_stories.md#US-1804)

- [ ] `P1` `infra` -- **CI/CD setup** -- GitHub Actions workflow: lint → test → build on each PR. Automatic deployment to Azure (backend) and Google Play Internal Testing (APK) on merge to `main`. Refs: Best practices

- [ ] `P1` `infra` -- **Environment variables and secrets** -- Create `.env.example` with all required variables. Configure GitHub Secrets for CI/CD. Document in `SETUP.md`. Refs: Security best practices

---

### 1B. Database Design and Data Model

> **Impact: Critical** — The schema defines the structure of the entire application.

- [ ] `P0` `backend` `database` -- **Users schema** -- Table `users`: `id` (UUID PK), `email` (UNIQUE NOT NULL), `password_hash` (TEXT NOT NULL), `name` (VARCHAR 100), `age` (INT), `university` (VARCHAR 200), `income_type` (ENUM: SCHOLARSHIP, PART_TIME, FAMILY, MIXED), `average_monthly_income` (DECIMAL), `financial_literacy_level` (ENUM: LOW, MEDIUM, HIGH), `profile_completed` (BOOLEAN DEFAULT false), `currency` (VARCHAR 3 DEFAULT 'PEN'), `consent_given` (BOOLEAN DEFAULT false), `consent_at` (TIMESTAMP), `created_at` (TIMESTAMP), `updated_at` (TIMESTAMP). Refs: [US-0101](./user_stories.md#US-0101)

- [ ] `P0` `backend` `database` -- **Transactions schema** -- Table `transactions`: `id` (UUID PK), `user_id` (FK → users), `type` (ENUM: INCOME, EXPENSE), `amount` (DECIMAL NOT NULL CHECK > 0), `category_id` (FK → categories), `description` (TEXT), `date` (DATE NOT NULL), `deleted_at` (TIMESTAMP nullable), `created_at` (TIMESTAMP), `updated_at` (TIMESTAMP). Indexes: `(user_id, date)`, `(user_id, category_id)`, `(user_id, type, date)`. Refs: [US-0201](./user_stories.md#US-0201)

- [ ] `P0` `backend` `database` -- **Categories, budgets, goals schema** -- Tables `categories`, `budgets`, `goals` per specification in Phase 4 and 6. Foreign keys with ON DELETE CASCADE where appropriate. Check constraints for enums. Refs: [US-0301](./user_stories.md#US-0301)

- [ ] `P1` `backend` `database` -- **Gamification, AI, and evaluation schema** -- Tables: `educational_content`, `challenges`, `badges`, `user_badges`, `predictions`, `recommendations`, `surveys`, `survey_responses`, `analytics_events`, `audit_logs`, `feedback`. Refs: [US-0901](./user_stories.md#US-0901)

---

## Phase 2: Authentication and User Management

> **Impact: Critical** — Without authentication there is no access to the app. Blocks all user functions.

- [ ] `P0` `backend` `security` -- **Registration endpoint** -- `POST /api/v1/auth/register` accepts `email`, `password`, `name`. Validates correct email format, password >= 8 characters with uppercase, lowercase, and number. Creates user with active status. Returns JWT token. Hashing with bcrypt (cost factor 12). Refs: [US-0101](./user_stories.md#US-0101)

- [ ] `P0` `backend` `security` -- **Login endpoint** -- `POST /api/v1/auth/login` accepts `email`, `password`. Validates credentials. Returns JWT (expires in 30 days). Temporary lockout after 3 failed attempts (15 min lockout). Refs: [US-0102](./user_stories.md#US-0102)

- [ ] `P0` `backend` `security` -- **JWT authentication middleware** -- Intercepts routes `/api/v1/*` (except `/auth/*`). Validates signature, expiration. Loads `user_id` into request context. Returns 401 if invalid. Refs: [US-0103](./user_stories.md#US-0103)

- [ ] `P0` `android` `ui` -- **Registration and login screens** -- Forms with real-time validation. Loading states. Error handling. JWT stored in EncryptedSharedPreferences. Refs: [US-0101](./user_stories.md#US-0101), [US-0102](./user_stories.md#US-0102)

- [ ] `P1` `backend` -- **Password recovery** -- `POST /api/v1/auth/forgot-password` sends email with reset token (1h expiry). `POST /api/v1/auth/reset-password` accepts token + new password. Refs: [US-0104](./user_stories.md#US-0104)

- [ ] `P1` `android` `ui` -- **Initial profile onboarding** -- After first login: age, university, income type, average income, currency. Saves `profile_completed = true`. Optional skip with importance message. Refs: [US-0105](./user_stories.md#US-0105)

- [ ] `P1` `android` `ui` -- **Profile editing** -- Allows editing personal data, currency, number format. Refs: [US-0106](./user_stories.md#US-0106)

---

## Phase 3: Transaction Recording (Core Feature)

> **Impact: Critical** — This is the app's primary action. Without transactions there is no data for anything else.

- [ ] `P0` `backend` `api` -- **Transaction CRUD** -- `POST /api/v1/transactions` (create), `GET /api/v1/transactions` (list with filters and pagination), `GET /api/v1/transactions/{id}` (detail), `PUT /api/v1/transactions/{id}` (edit), `DELETE /api/v1/transactions/{id}` (soft delete). Ownership validation. Balance updated on each operation. Refs: [US-0201](./user_stories.md#US-0201) to [US-0206](./user_stories.md#US-0206)

- [ ] `P0` `android` `ui` -- **Transaction recording screen** -- Type selector (Income/Expense), numeric amount input, category selector (grid), date picker (default today), optional description. "Save" button. Confirmation message. Refs: [US-0201](./user_stories.md#US-0201)

- [ ] `P0` `android` `ui` -- **Main dashboard** -- Current month balance, last 5 transactions, FAB "+" to add. Pull-to-refresh. Loads in < 2 sec. Refs: [US-0204](./user_stories.md#US-0204)

- [ ] `P1` `android` `ui` -- **History with filters** -- Complete transaction list. Filters: dates, category, type, amount. Search by description. Infinite scroll pagination. Refs: [US-0203](./user_stories.md#US-0203)

- [ ] `P2` `android` `ui` -- **Edit and delete** -- Tap on transaction opens editable detail. Delete button with confirmation. Immediate update of balance and reports. Refs: [US-0205](./user_stories.md#US-0205), [US-0206](./user_stories.md#US-0206)

---

## Phase 4: Categorization System

> **Impact: High** — Foundation for reports, predictions, and budgets.

- [ ] `P0` `backend` -- **Default categories (seed)** -- Expenses: Food, Transportation, Education, Entertainment, Health, Housing, Utilities, Clothing, Other. Income: Scholarship, Part-time work, Family, Freelance, Other. With assigned icons and colors. Refs: [US-0301](./user_stories.md#US-0301)

- [ ] `P0` `backend` `api` -- **Custom categories CRUD** -- Create, list, edit, delete custom categories. Validate that categories with transactions cannot be deleted. Refs: [US-0302](./user_stories.md#US-0302)

- [ ] `P0` `android` `ui` -- **Category selector** -- Grid with icons/colors. "Create new" option. Quick creation modal. Refs: [US-0301](./user_stories.md#US-0301)

- [ ] `P1` `android` `ui` -- **Category management** -- Custom category administration screen. Refs: [US-0302](./user_stories.md#US-0302)

---

## Phase 5: Financial Reports and Visualization

> **Impact: High** — Visibility into financial habits. Prerequisite for predictions to have context.

- [ ] `P0` `backend` `api` -- **Report endpoints** -- Monthly, weekly, daily summary. Multi-month comparison. Each returns totals, breakdown by category with percentages. Response < 2 sec. Refs: [US-0401](./user_stories.md#US-0401) to [US-0404](./user_stories.md#US-0404)

- [ ] `P0` `android` `ui` -- **Monthly summary screen** -- Total income/expenses/balance, pie chart by category, top 3 categories. Month selector. Refs: [US-0401](./user_stories.md#US-0401)

- [ ] `P1` `android` `ui` -- **Interactive charts** -- Bar charts by category, comparative line charts by month. MPAndroidChart library. Tap for detail. Refs: [US-0405](./user_stories.md#US-0405)

- [ ] `P2` `backend` `api` -- **PDF export** -- Generates PDF with complete summary. Temporary download URL (24h). Refs: [US-0406](./user_stories.md#US-0406)

---

## Phase 6: Budget and Financial Goal Management

> **Impact: High** — Prerequisite for intelligent alerts. Goals give purpose to savings.

- [ ] `P0` `backend` `api` -- **Budget CRUD** -- Create budget by category or global. List with `current_spent` and `percentage_used`. Edit and delete. Refs: [US-0501](./user_stories.md#US-0501)

- [ ] `P0` `android` `ui` -- **Budget screen** -- List with progress bars (green/yellow/red). Creation modal. Refs: [US-0501](./user_stories.md#US-0501)

- [ ] `P1` `backend` `api` -- **Financial goals CRUD** -- Create goal with name, target amount, deadline. List with progress. Contribute to goal. Refs: [US-0502](./user_stories.md#US-0502)

- [ ] `P1` `android` `ui` -- **Goals screen** -- Cards with progress, contribute button, completion animation. Refs: [US-0502](./user_stories.md#US-0502)

- [ ] `P2` `android` `ui` -- **Goal detail** -- Contribution history, progress chart, completion projection. Refs: [US-0503](./user_stories.md#US-0503)

---

## Phase 7: AI Pipeline — Data Collection and Preparation

> **Impact: Critical** — Without prepared data there is no model. Bridge between transactional app and intelligent app.

- [ ] `P0` `ml` `backend` -- **Feature extraction pipeline** -- Python script that extracts features per user: spending by category per month, expense/income ratio, frequency, variability. Output CSV. Refs: [US-0701](./user_stories.md#US-0701)

- [ ] `P0` `ml` -- **Training dataset** -- Synthetic dataset based on Peruvian student profiles. Minimum 1000 records with realistic distributions. Document variables and assumptions. Refs: [US-0702](./user_stories.md#US-0702)

- [ ] `P0` `ml` -- **Model selection and training** -- Evaluate: Linear Regression, Random Forest, XGBoost, LSTM. Metrics: MAE, RMSE, R². 5-fold cross-validation. Target: predict next month's spending >= 80% accuracy. Refs: [US-0703](./user_stories.md#US-0703)

- [ ] `P1` `ml` -- **Export for inference** -- TFLite for on-device or API endpoint. Document model input/output. Refs: [US-0704](./user_stories.md#US-0704)

- [ ] `P1` `ml` -- **Re-training pipeline** -- Monthly script that re-trains with new data. Only deploys if accuracy improves. Refs: [US-0705](./user_stories.md#US-0705)

---

## Phase 8: AI Predictions

> **Impact: Critical** — Main differentiator. Turns the app from reactive to proactive.

- [ ] `P0` `backend` `ml` `api` -- **Expense prediction** -- `GET /api/v1/predictions/expenses?period=next_month` invokes ML model. Returns: predicted_total, predicted_by_category (array), confidence_interval, model_version. Requires >= 2 months of history. Accuracy >= 80%. Refs: [US-0801](./user_stories.md#US-0801)

- [ ] `P0` `backend` `ml` `api` -- **Income prediction** -- `GET /api/v1/predictions/income?period=next_month` projects income considering source variability. Refs: [US-0802](./user_stories.md#US-0802)

- [ ] `P0` `android` `ui` -- **Predictions screen** -- Monthly prediction, breakdown by category, projected balance, confidence indicator. Refs: [US-0801](./user_stories.md#US-0801)

- [ ] `P1` `backend` `ml` -- **Anomaly detection** -- If spending in category exceeds >20% historical average, generates alert. Refs: [US-0803](./user_stories.md#US-0803)

- [ ] `P1` `backend` -- **Real accuracy tracking** -- When period completes, compare predicted vs actual. Calculate retrospective accuracy. Refs: [US-0804](./user_stories.md#US-0804)

---

## Phase 9: Personalized Recommendations

> **Impact: High** — Closes the loop: data → analysis → concrete action.

- [ ] `P0` `backend` `ml` `api` -- **Recommendation engine** -- `GET /api/v1/recommendations` generates 1-5 recommendations based on patterns, predictions, budgets, and goals. Types: SAVINGS, BUDGET, GOAL. Refs: [US-0901](./user_stories.md#US-0901)

- [ ] `P0` `android` `ui` -- **Recommendations section** -- Cards with message, suggested action, feedback button ("Helpful"/"Not relevant"). Integrated into Dashboard. Refs: [US-0901](./user_stories.md#US-0901)

- [ ] `P1` `backend` -- **Acceptance tracking** -- Feedback endpoint. Metric: acceptance rate target >= 60%. Refs: [US-0902](./user_stories.md#US-0902)

- [ ] `P2` `backend` `ml` -- **Feedback-driven improvement** -- Engine adjusts priority based on user's historical feedback. Refs: [US-0903](./user_stories.md#US-0903)

---

## Phase 10: Educational Module and Gamification

> **Impact: High** — Key differentiator. Required to demonstrate >= 20% knowledge improvement.

- [ ] `P0` `backend` `api` -- **Educational content** -- CRUD of topics with user progress. Seed: Personal budget, Savings, Credit/debt, Inflation, Interest rates, Basic investing, Responsible consumption, Digital wallets in Peru. Refs: [US-1001](./user_stories.md#US-1001)

- [ ] `P0` `android` `ui` -- **Educational module** -- Topic list with difficulty and status. Content in readable mobile format. Mark as completed. Refs: [US-1001](./user_stories.md#US-1001)

- [ ] `P0` `backend` `api` -- **Challenge system** -- CRUD of challenges with automatic verification. Seed: "No delivery for 3 days", "Record expenses for 7 consecutive days", "Save S/20 this week". Refs: [US-1002](./user_stories.md#US-1002)

- [ ] `P0` `android` `ui` -- **Challenges screen** -- Active challenges with progress, available with accept button, completed with date. Refs: [US-1002](./user_stories.md#US-1002)

- [ ] `P1` `backend` `api` -- **Badge system** -- Automatic assignment by criteria: "First transaction", "7 consecutive days", "Goal achieved", "5 challenges completed", "Module 100%". Refs: [US-1003](./user_stories.md#US-1003)

- [ ] `P1` `android` `ui` -- **Badges screen** -- Grid with badges (color if earned, gray if not). Detail with criteria. Refs: [US-1003](./user_stories.md#US-1003)

---

## Phase 11: Notifications and Alerts

> **Impact: Medium-High** — Maintain engagement and prevent financial problems.

- [ ] `P0` `backend` `notifications` -- **Push notification service** -- Integration with FCM. Methods for: budget alert, anomalous spending, prediction, challenge reminder. Refs: [US-1101](./user_stories.md#US-1101)

- [ ] `P0` `backend` -- **Budget alert at 80%** -- Hourly job that checks budgets. Notifies once per budget per period. Refs: [US-1102](./user_stories.md#US-1102)

- [ ] `P0` `backend` -- **Excessive spending alert** -- Trigger when recording transaction. If category exceeds >20% average of last 3 months, notify. Refs: [US-1103](./user_stories.md#US-1103)

- [ ] `P1` `android` `ui` -- **Notification preferences** -- Toggles for each type. Configurable daily reminder time. Refs: [US-1104](./user_stories.md#US-1104)

- [ ] `P2` `backend` -- **Daily recording reminder** -- If no transaction recorded today, send reminder at configured time. Refs: [US-1105](./user_stories.md#US-1105)

---

## Phase 12: Pre/Post Usage Evaluation (Impact Measurement)

> **Impact: Critical** — Without evaluation, OE4 cannot be demonstrated. Validates educational objective.

- [ ] `P0` `backend` `api` -- **Pre-usage survey** -- Questionnaire of 15-20 financial knowledge questions (validated instruments). Score calculation 0-100. Present during onboarding. Refs: [US-1201](./user_stories.md#US-1201)

- [ ] `P0` `backend` `api` -- **Post-usage survey** -- Same questionnaire (variant) + SUS. Present after 4-8 weeks. Refs: [US-1202](./user_stories.md#US-1202)

- [ ] `P0` `backend` `api` -- **Improvement calculation** -- Individual and aggregate pre/post comparison. Target: improvement >= 20%. Refs: [US-1203](./user_stories.md#US-1203)

- [ ] `P0` `android` `ui` -- **Survey screens** -- Multiple choice questions, one per screen, progress bar. Score upon completion with interpretation. Refs: [US-1201](./user_stories.md#US-1201)

- [ ] `P1` `backend` -- **Integrated SUS questionnaire** -- 10 standard questions. Automatic calculation 0-100. Refs: [US-1204](./user_stories.md#US-1204)

---

## Phase 13: Security, Privacy, and Compliance

> **Impact: Critical** — Without security, handling financial data violates the law.

- [ ] `P0` `backend` `security` -- **Encryption in transit and at rest** -- Mandatory TLS. Azure encryption at rest. Encrypted backup. Refs: [US-1301](./user_stories.md#US-1301)

- [ ] `P0` `android` `security` -- **Secure storage** -- EncryptedSharedPreferences, SQLCipher for Room, ProGuard enabled. Refs: [US-1302](./user_stories.md#US-1302)

- [ ] `P0` `backend` `security` -- **Law 29733 consent** -- Explicit consent screen. Record in DB with timestamp. Refs: [US-1303](./user_stories.md#US-1303)

- [ ] `P1` `backend` -- **Rate limiting** -- 100 req/min per user, 10 req/min for auth. Refs: [US-1304](./user_stories.md#US-1304)

- [ ] `P1` `backend` -- **Access auditing** -- Log sensitive actions in `audit_logs`. Refs: [US-1305](./user_stories.md#US-1305)

- [ ] `P2` `backend` -- **Right to deletion** -- `DELETE /api/v1/account` complete deletion with 30-day grace period. Refs: [US-1306](./user_stories.md#US-1306)

---

## Phase 14: Testing and Quality

> **Impact: Critical** — Without tests there is no confidence. Required by ISO 25010.

- [ ] `P0` `backend` `testing` -- **Unit tests** -- Core services. Coverage >= 80%. Refs: [US-1401](./user_stories.md#US-1401)

- [ ] `P0` `backend` `testing` -- **Integration tests** -- Complete pipeline: registration → login → transaction → report → prediction. Refs: [US-1402](./user_stories.md#US-1402)

- [ ] `P0` `ml` `testing` -- **Model validation** -- Accuracy >= 80%, no overfitting, coherent predictions. Refs: [US-1403](./user_stories.md#US-1403)

- [ ] `P0` `android` `testing` -- **Usability tests** -- 30 students, 4-8 weeks, SUS >= 4.0/5.0. Refs: [US-1404](./user_stories.md#US-1404)

- [ ] `P1` `backend` `testing` -- **Security tests** -- JWT, ownership, SQL injection, XSS, rate limiting. Refs: [US-1405](./user_stories.md#US-1405)

- [ ] `P1` `android` `testing` -- **Performance tests** -- Dashboard < 2s, transaction < 3s, predictions < 5s. Refs: [US-1406](./user_stories.md#US-1406)

- [ ] `P2` `android` `testing` -- **Compatibility tests** -- Android 9, 11, 13, 14. Resolutions 720p-1440p. Refs: [US-1407](./user_stories.md#US-1407)

---

## Phase 15: Feedback and Continuous Improvement

> **Impact: Medium** — Enables iteration before final release.

- [ ] `P0` `backend` `api` -- **Feedback endpoint** -- Type (BUG/SUGGESTION/GENERAL), message, screen, rating. Refs: [US-1501](./user_stories.md#US-1501)

- [ ] `P0` `android` `ui` -- **Feedback button** -- Accessible from any screen. Modal with form. Refs: [US-1501](./user_stories.md#US-1501)

- [ ] `P1` `backend` -- **Event analytics** -- Log key actions without affecting performance. Refs: [US-1502](./user_stories.md#US-1502)

- [ ] `P1` `backend` -- **Internal metrics dashboard** -- Active users, transactions/day, pre/post scores, acceptance rate. Refs: [US-1503](./user_stories.md#US-1503)

---

## Phase 16: Demo Readiness and Documentation

> **Impact: Critical** — Validation requires realistic data and reproducible scenarios.

- [ ] `P0` `database` -- **Test data script** -- 5 varied users, 200+ transactions per user (3 months), budgets, goals, pre-usage surveys. Refs: [US-1601](./user_stories.md#US-1601)

- [ ] `P0` `docs` -- **Installation guide** -- Step by step: clone, DB, variables, backend, APK. Refs: [US-1602](./user_stories.md#US-1602)

- [ ] `P0` `docs` -- **Demo script** -- 15-20 min: registration → onboarding → survey → transactions → report → budget → prediction → recommendation → challenge → badges. Refs: [US-1603](./user_stories.md#US-1603)

- [ ] `P1` `docs` -- **Technical documentation** -- Context diagram, components, DB, AI flow, technical decisions. Refs: [US-1604](./user_stories.md#US-1604)

---

## Global Timeline

| Phase | Name | Sprint(s) | Duration | Status |
|-------|------|-----------|----------|--------|
| 1 | Infrastructure and Setup | Sprint 1 | 3 weeks | -- |
| 2 | Authentication and Users | Sprint 1-2 | 3 weeks | -- |
| 3 | Transaction Recording | Sprint 2-3 | 4 weeks | -- |
| 4 | Categorization | Sprint 3 | 2 weeks | -- |
| 5 | Reports and Visualization | Sprint 4-5 | 4 weeks | -- |
| 6 | Budgets and Goals | Sprint 5-6 | 3 weeks | -- |
| 7 | ML Pipeline (Data) | Sprint 6-7 | 4 weeks | -- |
| 8 | AI Predictions | Sprint 7-8 | 4 weeks | -- |
| 9 | Recommendations | Sprint 8-9 | 3 weeks | -- |
| 10 | Education and Gamification | Sprint 9-10 | 4 weeks | -- |
| 11 | Notifications | Sprint 10 | 2 weeks | -- |
| 12 | Pre/Post Evaluation | Sprint 11 | 3 weeks | -- |
| 13 | Security and Compliance | Sprint 11-12 | 3 weeks | -- |
| 14 | Testing and Quality | Sprint 12-13 | 3 weeks | -- |
| 15 | Feedback and Analytics | Sprint 13 | 2 weeks | -- |
| 16 | Demo Readiness | Sprint 14 | 2 weeks | -- |

---

## Risk Mitigation

| Risk | Prob. | Impact | Mitigation | Owner |
|------|-------|--------|------------|-------|
| **Cloud AI integration failures** | Medium | High | Local TFLite models as fallback | Fernando |
| **ML complexity delays** | High | High | Short sprints, rapid prototyping, MVP prioritization | Fernando |
| **Team availability** | Medium | Medium | Fixed schedules, backup plan, workload monitoring | Both |
| **Data vulnerabilities** | Medium | High | E2E encryption, security audits, LGPD compliance | Paolo |
| **Low model accuracy** | Medium | High | Cross-validation, data augmentation | Fernando |
| **Requirement changes** | High | Medium | Formal change process | Both |
| **Insufficient data** | Low | High | Synthetic data, university collaboration | Fernando |
| **Low adoption** | Medium | Medium | Early pilot tests, gamification | Paolo |
| **Cloud costs** | Low | Medium | Usage alerts, Azure optimization | Paolo |
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
