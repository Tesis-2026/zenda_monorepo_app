# Zenda — Project Status Report
**Last updated:** 2026-06-13 (session 7 — Phase 11 notifications, anomaly detection, audit logging, accounts removal, predictions accuracy)
**Branch:** develop
**Scope:** User stories, mockup coverage, backend completeness, technical debt, open questions

> **What changed since the 2026-04-30 update (read first):** Phase 11 (Notifications) is now implemented end-to-end — a full-DDD `NotificationsModule`, `FcmService`, 3 `@Cron` jobs, an inbox screen, a bell with an unread badge, and FCM token registration. Anomaly detection (US-016) is live via `src/infra/spending-alert/`, firing an `ANOMALY_ALERT` on transaction create. `AuditLog` is now written across 29+ call sites (was account-deletion only). `Prediction.actualTotal`/`accuracy` are now populated (were dead fields), making the AI-accuracy KPI computable. The Flutter **accounts** concept was fully removed and replaced by budgets; a new "Gestión" (Management) tab hosts Progreso/Presupuestos/Metas. AI chat is now persistent (`conversations` module). Most l10n violations are fixed. **Still open:** zero automated tests (Phase 14), US-034 30-day invitation, budget `findAll()` N+1, account-deletion grace period, ProGuard R8, demo data + demo script (Phase 16).

---

## How to read this document

| Symbol | Meaning |
|--------|---------|
| ✅ | Fully implemented and meets acceptance criteria |
| 🔄 | Partially implemented — something specific is missing |
| ❌ | Not implemented |
| ⚠️ | Implemented differently than the mockup (dialog vs full screen) — intentional design choice |
| ❓ | Needs a decision or content from you before it can be completed |
| 🎨 | Design gap — screen exists but is missing a widget required by a user story |

---

## 1. Mockup Screens vs Frontend Implementation

The mockup (`ZendaApp.pen`) has **50 frames** (46 app screens + 4 user-flow diagrams).

> **⚠️ Naming conflict (created 2026-04-29):** Two screens are numbered "15":
> - `GSPIQ` (x=2700) → 15 – Reset Password (renamed today from "14")
> - `eonMK` (x=2250, y=1848) → 15 – Edit Transaction (pre-existing)
>
> The Edit Transaction screen should be renumbered **16** and all subsequent screens shifted up by 1 (16–45 → 17–46). Low cosmetic priority but must be fixed before next design handoff.

### ✅ Fully implemented

| Mockup Screen | Flutter Location |
|---------------|-----------------|
| 14 – Verify Code *(new 2026-04-29)* | `features/auth/verify_code_screen.dart` — 6 OTP boxes, 60s cooldown, auto-submit |
| 01 – Login | `features/auth/login_screen.dart` |
| 02 – Register | `features/auth/register_screen.dart` |
| 03 – Onboarding (product intro) | `features/onboarding/onboarding_screen.dart` |
| 04 – Dashboard | `features/dashboard/dashboard_screen.dart` |
| 05 – Transactions | `features/transactions/transaction_list_screen.dart` |
| 06 – Add Transaction | `features/transactions/add_transaction_screen.dart` |
| 07 – Budget | `features/budget/budget_screen.dart` |
| 08 – Goals | `features/goals/goals_screen.dart` |
| 09 – Goal Detail | `features/goals/goal_detail_screen.dart` |
| 10 – Reports | `features/reports/reports_screen.dart` |
| 11 – Profile | `features/profile/profile_screen.dart` |
| 12 – Categories | `features/categories/category_management_screen.dart` |
| 13 – Forgot Password | `features/auth/forgot_password_screen.dart` *(design updated 2026-04-29: now code-based flow)* |
| 15 – Reset Password *(was 14)* | `features/auth/reset_password_screen.dart` |
| 15 – Edit Transaction *(should be 16)* | `features/transactions/edit_transaction_screen.dart` |
| 19 – AI Predictions | `features/predictions/predictions_screen.dart` |
| 20 – Recommendations | `features/recommendations/recommendations_screen.dart` |
| 21 – Financial Progress | `features/progress/progress_screen.dart` |
| 22 – Education List | `features/education/education_screen.dart` |
| 23 – Education Detail | `features/education/topic_detail_screen.dart` |
| 24 – Quiz | `features/education/quiz_screen.dart` — **fully implemented** (session 5) |
| 25 – Challenges | `features/challenges/challenges_screen.dart` |
| 26 – Badges | `features/badges/badges_screen.dart` |
| 27 – Notification Prefs | `features/notifications/notification_preferences_screen.dart` |
| 28–29 – Survey Question + Result | `features/surveys/survey_screen.dart` |
| 30 – Feedback Modal | `features/feedback/feedback_modal.dart` — accessible from Profile → Send feedback |
| 31 – Email Verification | `features/auth/email_sent_screen.dart` — shown after registration |
| 37 – AI Chat | `features/ai_chat/ai_chat_screen.dart` — backed by `POST /ai/chat` |
| 38–42 – Onboarding: Profile Setup | `features/onboarding/profile_setup_screen.dart` — 4-step wizard post-registration |
| 43 – Splash | `features/onboarding/splash_decider.dart` |
| 44 – Data Consent | `features/consent/consent_screen.dart` — shown before registration |

---

### ❌ Design exists — Flutter code not yet built

*(None — all designed screens have Flutter implementations as of 2026-04-29.)*

> **24 – Quiz** is fully implemented as of session 5. The screen fetches a 5-question pool from `GET /education/topics/:id/quiz?language=en|es`, shows per-question feedback, and posts answers to `POST /education/topics/:id/quiz/submit`. Language is selected automatically from the device locale.

---

### ⚠️ Screens implemented as dialogs instead of full screens

The mockup shows these as full-screen flows; the app uses modals/dialogs. Both are valid UX patterns. Not a blocker.

| Mockup Screen | Flutter Implementation |
|---------------|----------------------|
| 16 – Create Goal | Bottom sheet inside `GoalsScreen` |
| 17 – Contribute to Goal | Bottom sheet inside `GoalsScreen` |
| 18 – Create Budget | Dialog inside `BudgetScreen` |
| 32 – Reset Password Success | Snackbar, not a separate screen |
| 33 – Transaction Saved | Snackbar, not a separate screen |
| 34 – Delete Confirmation | `showDialog()` popup |
| 35 – Create Category | Dialog inside `CategoryManagementScreen` |
| 36 – Edit Category | Dialog inside `CategoryManagementScreen` |
| 45 – Edit Budget | Dialog inside `BudgetScreen` |

---

### ✅ Navigation — all screens are reachable

All screens are linked from `ProfileScreen` (`/profile`):

| Screen | Route | Entry point |
|--------|-------|-------------|
| PredictionsScreen | `/predictions` | Profile → Finance section |
| RecommendationsScreen | `/recommendations` | Profile → Finance section |
| ProgressScreen | `/progress` | Profile → Finance section |
| EducationScreen | `/education` | Profile → Learn & Grow section |
| ChallengesScreen | `/challenges` | Profile → Learn & Grow section |
| BadgesScreen | `/badges` | Profile → Learn & Grow section |
| SurveyScreen (pre) | `/surveys/pre` | Profile → Surveys section |
| SurveyScreen (post) | `/surveys/post` | Profile → Surveys section |
| NotificationPreferencesScreen | `/notifications` | Profile → Support section |
| AiChatScreen | `/ai-chat` | Profile → Learn & Grow section |
| FeedbackModal | — | Profile → Support → Send feedback |
| QuizScreen | `/education/:id/quiz` | Topic detail → Quiz button |

> **⚠️ Design vs code mismatch:** The Flutter `ProfileScreen` has full navigation sections. Screen 11 in `ZendaApp.pen` shows only a minimal info card + sign-out button. The design must be updated to match the implementation (see §2.1 Design Gaps).

---

## 2. Auth & Onboarding Flow

### 2.1 Password Reset — ✅ Fully implemented 2026-04-29

```
13 – Forgot Password  →  14 – Verify Code  →  15 – Reset Password
   Enter email              Enter 6-digit code     Enter new password
   "Send Code" CTA          6 OTP boxes            Pre-filled token
                            60s resend cooldown     "Reset Password" CTA
                            Auto-submit on fill
```

- `forgot_password_screen.dart` — ✅ calls `POST /auth/send-otp`, navigates to `/auth/verify-code`
- `verify_code_screen.dart` — ✅ 6 boxes, 60s timer, auto-submit, passes `resetToken` to reset screen
- `reset_password_screen.dart` — ✅ accepts `prefillToken` from `VerifyCodeScreen` via `state.extra`
- Backend `POST /api/auth/send-otp` and `POST /api/auth/verify-otp` — ✅ implemented 2026-04-29

### 2.2 Full First-Run Journey

```
Splash → Onboarding (3 product slides)
       → Consent Screen (/consent)       ← Law 29733 gate
       → Register (/auth/register)
       → Email Sent (/auth/email-sent)   ← Registration confirmation
       → Profile Setup (/profile-setup)  ← 4-step wizard (age, university, income type, income)
       → Dashboard (/dashboard)
```

**Login flow:**
```
Login → if profileCompleted → /dashboard
      → if !profileCompleted → /profile-setup
```

---

## 2.1 Design Gaps — Screens with Missing Widgets

| # | Screen | Missing Widget / Logic | User Story | Status |
|---|--------|----------------------|------------|--------|
| ~~🎨1~~ | ~~06 – Add Transaction~~ | ~~No AI categorization suggestion~~ | US-018 | ✅ Done — "Zenda suggests: [Category]" chip below note field, debounced 800ms |
| ~~🎨2~~ | ~~07 – Budget~~ | ~~No "Add Budget" button~~ | US-019 | ✅ Done — FAB with `Icons.add` present, calls `_showCreateDialog()` wired to `POST /budgets` |
| ~~🎨3~~ | ~~07 – Budget~~ | ~~No per-row edit/delete trigger~~ | US-043 | ✅ Done — edit (`Icons.edit_outlined`) + delete (`Icons.delete_outline`) icon buttons in `_BudgetCard` header; one hardcoded `'Delete'` string remaining (l10n) |
| ~~🎨4~~ | ~~08 – Goals~~ | ~~No deadline display on goal cards~~ | US-021 | ✅ Done |
| ~~🎨5~~ | ~~08 – Goals~~ | ~~No goal complete/delete action~~ | US-045 | ✅ Done |
| ~~🎨6~~ | ~~09 – Goal Detail~~ | ~~No deadline or days remaining~~ | US-022 | ✅ Done |
| ~~🎨7~~ | ~~09 – Goal Detail~~ | ~~No "Mark Complete" / "Delete Goal" buttons~~ | US-045 | ✅ Done |
| 🎨8 | 11 – Profile | **Design doesn't match implementation.** Flutter profile has nav sections; design shows only info card + sign-out. | Multiple | ❌ Open (design update needed in `.pen`) |
| ~~🎨9~~ | ~~22 – Education List~~ | ~~No AI personalization indicator~~ | US-048 | ✅ Done |
| 🎨10 | 22 – Education List | **No AI-generated contextual questions entry point.** | US-049 | ❌ Open |

---

## 3. User Stories — What Is Left

> **Audit methodology (2026-04-29):** Each story was verified against the live codebase via subagent deep-read of all backend `.ts` and Flutter `.dart` files. A story is ✅ only when all acceptance criteria are satisfied in the code.

### ❌ Not implemented

| US | Title | Phase | Points | What's needed |
|----|-------|-------|--------|---------------|
| **US-034** | 30-day post-survey invitation | 12 | — | No active-days counter; no `pilot-status` endpoint; post-survey works but is never auto-invited |
| **US-029** | Data Encryption (TLS + at-rest) | 13 | 5 | Deferred to cloud deployment; `flutter_secure_storage` used for JWT ✅ |
| (infrastructure: ProGuard R8) | ProGuard R8 for release builds | 13 | — | Not configured in `android/app/build.gradle` |
| (infrastructure: right to deletion) | Right to deletion (30-day grace) | 13 | — | `DELETE /users/me` still performs an immediate hard delete with no grace period |
| (infrastructure: unit tests) | Service Unit Tests | 14 | 8 | Zero `.spec.ts` files in backend; only 1 stub `widget_test.dart` in Flutter |
| (infrastructure: integration tests) | Integration Tests | 14 | — | Zero test files (contract-testing plan written — `docs/testing-plan.md` — but not executed) |
| (infrastructure: AI validation tests) | AI API Integration Validation | 14 | 8 | Zero test files |
| **US-035** | Usability Tests (30 students) | 14 | 13 | Requires human participants (SUS instrument is built — see below) |
| (infrastructure: security tests) | Security Tests | 14 | — | Zero test files |
| (infrastructure: performance tests) | Performance Tests | 14 | — | Zero test files |
| (infrastructure: demo script) | Demo Script (15–20 min) | 16 | — | Not written |
| (infrastructure: technical documentation) | Technical Documentation | 16 | — | Architecture/ERD/compliance docs now exist; demo/install guide still pending |

> **Resolved since 2026-04-30** (moved out of this table): **US-016** Spending Anomaly Detection (`src/infra/spending-alert/spending-alert.service.ts`, fires `ANOMALY_ALERT` on transaction create), **US-016 (alert)** Anomalous Spending Alert (persisted notification), **US-020** Budget Alert at 80% (inline SnackBar + persisted `BUDGET_ALERT` notification on expense save), **US-048** AI-Personalized Learning Path ("Recomendado" chip on first incomplete topic), **US-049** AI-Generated Contextual Questions (`GET /education/quiz/personalized` + `PersonalizedQuizScreen`), **FCM push infrastructure** (`src/infra/fcm/fcm.service.ts` + `NotificationsModule` + 3 `@Cron` jobs + Flutter `fcm_service.dart`), and **audit logging** (`AuditLogService` now written across 29+ call sites). The **SUS usability instrument** (US-035 backend) is built: `GET /surveys/sus` + `POST /surveys/sus/response` with the standard 10-item scoring formula — only the human study with 30 students remains.

---

### 🔄 Partially implemented — specific gaps remaining

| US | Title | What's Done | What's Missing |
|----|-------|------------|----------------|
| **US-040 / US-041** | Custom Categories | Full CRUD + quick-create "+" chip; category icon key on model | Quick-create captures name only — no icon/color picker in the modal |
| **US-009** | Monthly Summary | Endpoint + Reports screen | Response time not benchmarked (<2 sec target) |
| **US-007** | Daily Summary | `GET /api/summary/day` + calendar grid in `_DayTab` | No per-day spending indicator dots (requires batch API not yet built) |
| **US-010** | Charts by Category | Bar + pie charts done | Tap-to-drill-down and period selector not implemented |
| **US-019** | Budget Management | Full backend CRUD + Flutter; FAB + per-card edit/delete icons ✅ | Color thresholds differ from spec: code green<70%/yellow 70–90%/red>90% vs spec green<60%/yellow 60–80%/red>80% |
| **US-021** | Financial Goals | Backend + Flutter + deadline display + mark-complete + detail screen | Goal completion confetti animation not implemented |
| (infrastructure: recommendation feedback) | Feedback Tracking | `POST /api/recommendations/:id/feedback` done | Internal metrics dashboard not implemented |
| **US-033** | Pre-Usage Survey | `POST /api/surveys/pre/response` + Flutter screen; real `correctAnswer` scoring (8 questions) | Module still controller-only (no DDD layer) — see §4.2 |
| **US-034** | 30-day post-survey invitation | Post-survey endpoint + screen work | No active-days counter / `pilot-status` endpoint / persistent dashboard banner |
| (infrastructure: demo data) | Demo Data Script | Some demo users in `prisma/seed.ts` | Need 200+ transactions/user, active budgets, goals, completed surveys |

> **Resolved since 2026-04-30** (moved to §3 Done): **US-001 / main dashboard** — dashboard home now reads the backend via `InsightsApiService` (the local SharedPreferences duality is gone; accounts removed entirely). **US-015** — `Prediction.actualTotal`/`accuracy` are now written by `recordActuals()` and surfaced via the accuracy-check endpoint. **US-024 / US-046** — challenge auto-verification is wired (`VerifyChallengesUseCase`, 4 criteria types, triggered from `CreateTransactionUseCase`). **US-025** — 7/7 badge triggers wired, including Predictor.

---

### ✅ Done — meets acceptance criteria

| US | Title | Verified via |
|----|-------|-------------|
| (infrastructure: repository setup) | Repository and Project Structure | Monorepo layout, branch strategy |
| VERIF-01 | OTP-based password reset (backend) | `POST /api/auth/send-otp` + `POST /api/auth/verify-otp`; `PasswordResetOtp` schema; styled OTP email |
| VERIF-02 | Verify Code screen (Flutter) | `verify_code_screen.dart` — 6 OTP boxes, 60s cooldown, auto-submit |
| US-028 | Login lockout after 3 failed attempts | `failedLoginAttempts`/`lockedUntil` on User; `LoginUseCase` locks 15 min after 3 failures |
| US-031 | Profile number format preference | `SegmentedButton` in `ProfileScreen` persists `dot`/`comma` to `SharedPreferences` |
| US-045 | Mark Goal as Completed or Delete | Active/completed sections; confirmation + celebration dialogs; detail screen buttons |
| US-018 | AI Auto-Categorization | `POST /api/transactions/classify` + debounced chip in `AddTransactionScreen` |
| US-027 | User Registration | `register.use-case.ts`, `register.dto.ts`, `register_screen.dart` |
| (infrastructure: JWT guard) | Authentication Middleware | `jwt-auth.guard.ts`, `@UserId()` decorator, 401 on invalid token |
| (infrastructure: password recovery) | Password Recovery | `POST /api/auth/forgot-password` + OTP flow + `reset-password`; email via nodemailer |
| US-030 / US-032 | Initial Profile Setup | `profile_setup_screen.dart` 4-step wizard, `profileCompleted` flag wired |
| US-012 / US-039 | Transaction History with Filters | `ListTransactionsUseCase` with all query params, `TransactionListScreen` |
| US-003 | Edit Transaction | `PUT /api/transactions/:id` (ownership validated), `EditTransactionScreen` |
| US-004 | Delete Transaction | `DeleteTransactionUseCase` (soft delete, ownership), Flutter confirmation dialog |
| US-005 | Default Categories (seed) | `prisma/seed.ts` — 9 expense + 5 income categories |
| US-040 / US-041 | Custom Categories (CRUD) | Full `categories` module + `CategoryManagementScreen` |
| US-008 | Weekly Summary | `GET /api/summary/week` + Flutter `_WeekTab` with ISO week selector |
| US-011 | Monthly Comparison | `GET /api/summary/comparison` + Flutter `_CompareTab` with 2M/3M/6M selector |
| US-010 | Charts by Category | `_CategoryBarChart` + `BudgetPieChart` |
| US-013 | PDF Export | `GeneratePdfReportUseCase` + Flutter `_exportPdf()` with `share_plus` |
| US-014 | Financial Progress Indicator | `GET /api/summary/progress` + Flutter `ProgressScreen` |
| US-022 | Detailed Goal Tracking | `GoalDetailScreen` with contribution history, line chart, projection message |
| US-043 | Edit or Delete Monthly Budget | `UpdateBudgetUseCase` + `DeleteBudgetUseCase`; Flutter edit dialog + delete confirmation |
| (infrastructure: Azure AI integration) | Azure AI API Integration | `AzureFoundryProvider` — 4 AI methods; env-var config; graceful fallback |
| US-017 | Recommendation Engine | `GetRecommendationsUseCase` + rule-based fallback; `RecommendationsScreen`; `ZendaAiCard` wired |
| US-023 | Educational Content Module | `GET /education/topics`, detail, `PATCH .../complete`; `EducationScreen` + `TopicDetailScreen` |
| US-026 | Financial Knowledge Quizzes | `QuizQuestion` model + migration; 44 bilingual question groups (EN + ES) seeded across all 8 topics; `GET /education/topics/:id/quiz?language=` pool-selects 5 questions (2B+2I+1A); `POST /education/topics/:id/quiz/submit` scores and returns per-question feedback; `QuizScreen` fully implemented with state machine, per-question reveal, result screen |
| US-033 / US-047 | Educational Improvement Calculation | `GET /api/surveys/comparison` (per-user pre/post diff) |
| (infrastructure: data consent) | Data Consent | `consent_screen.dart` gates registration; `consentGiven`/`consentAt` on User |
| US-036 | In-App Feedback System | `POST /api/feedback`; Flutter `FeedbackModal` from `ProfileScreen` |
| US-001 / (main dashboard) | Record Income + Dashboard | Dashboard home now reads `GET /api/summary/*` via `InsightsApiService`; accounts concept removed (budgets are the source of available money) |
| US-015 | Expense Prediction Accuracy | `recordActuals()` writes `actualTotal`/`accuracy`; accuracy-check endpoint populates the AI-accuracy KPI |
| US-016 | Spending Anomaly Detection + Alert | `src/infra/spending-alert/spending-alert.service.ts` compares current vs 3-month avg, fires `ANOMALY_ALERT` (>20%) on transaction create |
| US-020 | Budget Alert at 80% | `percentageUsed` in `GET /budgets`; inline amber SnackBar + persisted `BUDGET_ALERT` notification on expense save |
| US-024 / US-046 | Challenge Auto-Verification | `VerifyChallengesUseCase` (4 criteria types) triggered from `CreateTransactionUseCase`; celebration dialog on completion |
| US-025 | Badge System | 7/7 award triggers wired (incl. Predictor) |
| US-035 | SUS Usability Instrument (backend) | `GET /surveys/sus` + `POST /surveys/sus/response`, standard 10-item scoring (0–100 + grade) — human study still pending |
| US-048 | AI-Personalized Learning Path | "Recomendado" chip on first incomplete topic in `education_screen.dart` |
| US-049 | AI-Generated Contextual Questions | `GET /education/quiz/personalized` + `PersonalizedQuizScreen` (limit 5/day) |
| (infrastructure: FCM push service) | Notifications + FCM (Phase 11) | Full-DDD `NotificationsModule`, `FcmService`, 3 `@Cron` jobs, inbox screen, bell + unread badge, FCM token registration |
| (infrastructure: audit log) | Access Auditing to AuditLog | `AuditLogService` written across 29+ call sites (auth, budgets, categories, goals, surveys, transactions) |
| US-037 | Analytics Coverage | `AnalyticsService` events extended to predictions (`view_prediction`) and education (`view_topic`) |

---

## 4. Backend Completeness

### 4.1 Module Status

> **Module count:** 17 bounded contexts in `src/modules/` (CLAUDE.md's "16" predates `notifications` being promoted to a full module). Cross-cutting infra in `src/infra/`: ai, analytics, email, **fcm**, prisma, **spending-alert**, telemetry.

| Module | Endpoints | DDD Layer | Status | Notes |
|--------|-----------|-----------|--------|-------|
| Auth | 8 | ✅ Full use-cases + ports | ✅ Solid | Register, login, refresh, logout, OTP, reset-password; lockout logic; audit-logged |
| Users | 2 (GET/PUT) + 1 (DELETE) | 🔄 Partial — DELETE bypasses DDD | 🔄 Partial | `DELETE /users/me` runs raw Prisma `$transaction` (intentional — audit row must be transactional with deletion); still immediate hard delete, no grace period |
| Transactions | 6 | ✅ Full use-cases + ports | ✅ Solid | CRUD + classify; analytics + audit; anomaly + budget alerts fired on create; challenge auto-verify |
| Categories | 4 | ✅ Full use-cases + ports | ✅ Solid | System + custom; soft delete; audit-logged; icon key on model |
| Budgets | 4 | ✅ Full use-cases + ports | 🔄 Partial | N+1 query still present in `findAll()` — 2 `aggregate` calls per row |
| Goals | 6 | ✅ Full use-cases + ports | ✅ Solid | CRUD + contribute + complete; audit-logged |
| Insights | 5 + 1 PDF | 🔄 Partial — progress bypasses DDD | 🔄 Partial | `GET /summary/progress` runs raw Prisma aggregates in controller |
| Predictions | 1 + accuracy-check | ✅ Full use-case + port | ✅ Solid | `actualTotal`/`accuracy` now written via `recordActuals()`; `modelVersion` still encodes confidence+narrative as pipe-delimited string (minor debt) |
| Recommendations | 2 | ✅ Full use-cases + port | ✅ Solid | AI + rule-based fallback; feedback endpoint |
| Conversations | 3 | ✅ Full use-cases + ports | ✅ Solid | `GET /ai/chat/active`, `POST /ai/chat`, `POST /ai/chat/close`; persistent AI chat (extracted from recommendations, B7) |
| Education | 7 | ✅ Full use-cases + port | ✅ Solid | List, detail, complete, quiz GET/submit, personalized quiz GET/submit; badge trigger on completion |
| Challenges | 3 | 🔄 Partial — VerifyChallengesUseCase added | 🔄 Partial | Auto-verification wired (4 criteria); derived `EXPIRED` status; controller still calls repo directly for read paths; `PrismaChallengeRepository` injects `IBadgeRepository` (cross-context infra dep) |
| Badges | 1 | ❌ No use-case — controller calls repo directly | 🔄 Partial | List works; 7/7 award triggers in use-cases of other modules ✅ |
| Feedback | 1 | ❌ No domain/application layer | 🔄 Stub | Direct Prisma in controller; analytics delegated to `AnalyticsService` ✅ |
| Surveys | 8 (PRE/POST/comparison + SUS) | ❌ No domain/application layer | 🔄 Stub | Inline scoring + direct Prisma; real `correctAnswer` scoring; SUS instrument added; audit-logged |
| Notifications | 6 | ✅ Full use-cases + ports | ✅ Solid | Inbox list + unread count, mark-read, mark-all, FCM token register/clear, daily-reminder-time; `FcmService` (`src/infra/fcm/`); 3 `@Cron` jobs (daily reminder, challenge reminder, prediction-ready) |
| Analytics (infra) | — | N/A | ✅ Solid | `AnalyticsService` global; 14 event types wired |
| Audit (shared) | — | N/A | ✅ Solid | `AuditLogService` written across 29+ call sites (fire-and-forget) |

### 4.2 Architecture Debt

| Issue | Location | Severity |
|-------|----------|----------|
| N+1 query in `PrismaBudgetsRepository` — 2 `aggregate` calls per row in `toEntity()`, hit by `findAll`/`findById`/`update`/`findGlobalForPeriod`/`findForCategoryAndPeriod` | `prisma-budgets.repository.ts` | Medium |
| `DELETE /users/me` — raw Prisma `$transaction` in controller (intentional per B27, but still bypasses domain layer); no 30-day grace | `users.controller.ts:44-66` | Medium |
| `GET /summary/progress` — raw Prisma aggregates in controller | `summary.controller.ts` | Medium |
| `FeedbackModule`, `SurveysModule` — zero DDD; all logic in controller | 2 modules | Low (scope is limited) |
| `ChallengesController`, `BadgesController` — controller calls repository port directly for read paths, no use-case | 2 controllers | Low |
| `PrismaChallengeRepository` injects `IBadgeRepository` — infra layer cross-context dependency | `prisma-challenge.repository.ts` | Medium |
| `Prediction.modelVersion` encodes confidence + narrative as pipe-delimited string | Predictions infra | Low |
| `AiModule` exports `AzureFoundryProvider` concrete class alongside `AI_PROVIDER` token — redundant | `ai.module.ts` | Low |

> **Resolved since 2026-04-30:** `NotificationsModule` now has full DDD layers; `Prediction.actualTotal`/`accuracy` are now written (no longer dead fields); `AuditLog` write coverage extended from 1 site to 29+.

---

## 5. Frontend — Known Gaps and Technical Debt

### 5.1 Dashboard Data Architecture — FIXED ✅ + Accounts removed ✅

`todayExpenseProvider`, `weekExpenseProvider`, and `budgetBreakdownProvider` call the backend API via `InsightsApiService` instead of reading from local SharedPreferences. `daySummaryProvider`, `weekSummaryProvider`, and `monthSummaryProvider` are `FutureProvider.autoDispose` providers backed by `GET /api/summary/day`, `/week`, `/month`. The `RefreshIndicator` on the dashboard invalidates all three on pull-to-refresh.

The **accounts concept was removed entirely** (commit `feat: wire real backend, replace accounts with budgets`): `account.dart`, `account_card.dart`, and `accounts_repository.dart` no longer exist. Total available money = sum of per-category budgets. A residual `TransactionModel.accountId` defaults to `''`.

**Remaining local-only stores** (by design):
- `TransactionsRepository` — SharedPreferences, legacy local cache (still used for streak tracking)
- `StreakRepository` — SharedPreferences

**Demo mode:** `main.dart` defines `const bool _kDemoMode = bool.fromEnvironment('DEMO', defaultValue: false)` — the app targets the **real backend by default**; run with `--dart-define=DEMO=true` to use demo overrides.

### 5.2 Hardcoded Strings (l10n Violations) — mostly FIXED ✅

Given the locale is forced to `es` (no language switcher), hardcoded **Spanish** copy is tolerated; only **English** strings in `build()` are violations. The `account_card.dart` / `account.dart` violations are gone (files deleted); `dashboard_providers.dart` AI fallbacks and `budget_screen.dart` now use `context.l10n`.

| File | Hardcoded String(s) | Impact |
|------|--------------------|----|
| `reports/reports_screen.dart` | `_monthNames` array (now Spanish: `'Enero'…'Diciembre'`) | Low — Spanish-only locale, but should still move to l10n for consistency |

### 5.3 Dead Code

The account-related dead code is gone with the accounts removal. Remaining minor items:

| File | What it is |
|------|-----------|
| `features/transactions/transaction_create_screen.dart` | Stub file; not registered in the router (verify before deleting) |
| `features/streak/streak_notifier.dart` | `ChangeNotifier`-based `StreakNotifier`; superseded by `StreakRepository` approach (verify before deleting) |

### 5.4 Stub / Unimplemented Features

| Feature | Status |
|---------|--------|
| OCR receipt scan | `OcrService` abstract class with no concrete implementation. `AddTransactionScreen` calls `fillFromOcrDemo()` which hardcodes `amount=12.50`, `category=comida`, `note='Cafetería'`. |
| Google Sign-In | `OutlinedButton` for "Continue with Google" has `onPressed: null` (disabled). No OAuth integration. |

> **Push notifications — now implemented ✅** (Phase 11): `core/services/fcm_service.dart` initializes Firebase, registers/refreshes the FCM token with the backend, and handles foreground/background messages. `features/notifications/notifications_inbox_screen.dart` is the inbox; `notification_bell_icon.dart` shows the unread badge. `pubspec.yaml` adds `firebase_core ^3.6.0`, `firebase_messaging ^15.1.3`, `flutter_local_notifications ^18.0.1`. (Real device delivery still requires Firebase credentials — see §6.)

### 5.5 API Service Coverage — Complete Map

45 `GoRoute` entries declared in `app_router.dart`. All API calls go through `ApiClient`. Token refresh (401 retry) is handled automatically in `ApiClient`.

| Service file | Endpoints |
|---|---|
| `auth_api_service.dart` | POST /auth/register, /auth/login, /auth/logout, /auth/forgot-password, /auth/send-otp, /auth/verify-otp, /auth/reset-password; GET /users/me |
| `user_api_service.dart` | GET /users/me, PUT /users/me |
| `transaction_api_service.dart` | POST /transactions (+ /classify), GET /transactions, PUT /transactions/:id, DELETE /transactions/:id |
| `budget_api_service.dart` | GET/POST /budgets, PUT/DELETE /budgets/:id |
| `goals_api_service.dart` | GET/POST /goals, POST /goals/:id/contribute, GET /goals/:id/contributions, POST /goals/:id/complete, DELETE /goals/:id |
| `insights_api_service.dart` | GET /summary/month, /week, /day, /comparison, /progress; GET /reports/export/pdf |
| `category_api_service.dart` | GET/POST /categories, PUT/DELETE /categories/:id |
| `recommendations_api_service.dart` | GET /recommendations, POST /recommendations/:id/feedback |
| `predictions_api_service.dart` | GET /predictions/expenses |
| `education_api_service.dart` | GET /education/topics, GET /education/topics/:id, PATCH /education/topics/:id/complete, GET /education/topics/:id/quiz?language=, POST /education/topics/:id/quiz/submit |
| `challenges_api_service.dart` | GET /challenges, POST /challenges/:id/accept, POST /challenges/:id/complete |
| `badges_api_service.dart` | GET /badges |
| `surveys_api_service.dart` | GET /surveys/pre, /surveys/post; POST /surveys/pre/response, /surveys/post/response |
| `notifications_api_service.dart` | GET /notifications/inbox, PATCH /notifications/:id/read, PATCH /notifications/read-all, POST/DELETE /notifications/fcm-token, PATCH /notifications/daily-reminder-time |
| `recommendations_api_service.dart` (chat) | GET /ai/chat/active, POST /ai/chat, POST /ai/chat/close (persistent conversations) |
| `progress_api_service.dart` | GET /summary/progress |
| `feedback_api_service.dart` | POST /feedback |
| `transactions_repository.dart` | **LOCAL ONLY** — SharedPreferences (legacy cache, used for streak) |
| `streak_repository.dart` | **LOCAL ONLY** — SharedPreferences (`zenda.streak.v1`) |

---

## 6. Open Questions — Needed From You

### ✅ Quiz questions — resolved (US-026)
`QuizQuestion` pool seeded with 44 bilingual question groups (88 DB rows) across all 8 educational topics and all 3 difficulty levels, based on Peru-specific financial data (BCRP, SBS, AFP, IGV, Yape/Plin, RMV). Endpoints built. `QuizScreen` fully implemented. No further action needed.

### ✅ Survey questions — resolved (US-033 / US-034 / US-047)
8 PRE questions and 8 POST questions with `correctAnswer` set in seed. Scoring compares user answers to `correctAnswer` (strict equality). The ≥20% improvement metric is now measurable.

### ❓ Firebase for push notifications (infrastructure: FCM push service)
Notification preferences are stored but not delivered. To implement:
- `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) from your Firebase project

### ❓ Demo data readiness (Phase 16 / infrastructure: demo data)
- Shall I expand the seed script to 200+ transactions/user with realistic PEN amounts, budgets, and goals?
- What is the target demo date?

---

## 7. What Remains — Priority Order

| # | Item | Effort | Impact |
|---|------|--------|--------|
| 1 | **Automated tests** — execute the contract-testing plan (`docs/testing-plan.md`); zero `.spec.ts` / real `_test.dart` today | High | High — Phase 14 / ISO 25010 |
| 2 | **Expand demo data seed** (200+ transactions/user, active budgets, goals, completed surveys) | Low | High — Phase 16 |
| 3 | **Demo script** (15–20 min walkthrough) + installation guide | Low | High — Phase 16 |
| 4 | **US-034** — `pilot-status` endpoint + persistent 30-day post-survey invitation banner | Medium | Medium — last open thesis HU |
| 5 | Fix N+1 query in `PrismaBudgetsRepository` (`toEntity` aggregates) | Low | Medium — performance |
| 6 | Provide Firebase credentials (`google-services.json` / `GoogleService-Info.plist`) for real FCM delivery | Low — **[content needed]** | Medium |
| 7 | Account-deletion 30-day grace period (currently immediate hard delete) | Medium | Medium — Law 29733 / Phase 13 |
| 8 | ProGuard R8 for release builds (`android/app/build.gradle`) | Low | Low — Phase 13 |
| 9 | Move `reports_screen.dart` month names to l10n | Low | Low — consistency |
| 10 | Goal completion confetti animation | Low | Low — cosmetic |
| 11 | **Redesign screen 11 (Profile)** in `ZendaApp.pen` to match Flutter implementation | Low | Medium |
| 12 | **Fix screen naming conflict** in `ZendaApp.pen` (two screens numbered "15") | Low | Low — cosmetic |

---

## 8. Roadmap Phase Audit

| Phase | Title | Status | Gap summary |
|-------|-------|--------|-------------|
| 1 | Infrastructure and Setup | ✅ Done | Repo, Docker/Postgres, NestJS base, Flutter base, CI/CD config all present |
| 2 | Authentication and Users | ✅ Done | Register/login/JWT/refresh/logout/forgot-reset-password; OTP flow; lockout after 3 failures |
| 3 | Transaction Recording | ✅ Done | Full CRUD + Flutter; dashboard home now reads `GET /api/summary/*` via `InsightsApiService` (local-data duality removed; accounts removed) |
| 4 | Categorization | ✅ Done | Full CRUD backend + Flutter; quick-create "+" chip in `AddTransactionScreen` |
| 5 | Reports and Visualization | 🔄 Partial | Monthly/weekly/comparison + Flutter + PDF export + progress; Day tab calendar grid; month names hardcoded (Spanish) in `ReportsScreen`; chart tap-drill-down not done |
| 6 | Budgets and Goals | 🔄 Partial | Budget + Goals full CRUD + Flutter; goal deadline, complete, detail screen; **completion confetti missing**; **N+1 in BudgetsRepository** |
| 7 | AI Integration | ✅ Done | `AzureFoundryProvider`; `POST /transactions/classify`; debounced AI chip; persistent AI chat (`conversations` module) |
| 8 | Predictions | ✅ Done | Prediction endpoint + `PredictionsScreen`; **anomaly detection wired** (`spending-alert`, fires on transaction create); **`actualTotal`/`accuracy` now written** |
| 9 | Recommendations | ✅ Done | `GetRecommendationsUseCase` + rule-based fallback; `RecommendationsScreen`; `ZendaAiCard` wired to real API |
| 10 | Education and Gamification | ✅ Done | Education + personalized quiz + learning-path chip; challenges + badges + **7/7 award triggers** (incl. Predictor); `VerifyChallengesUseCase` (4 criteria) auto-verifies; `EXPIRED` status derived; remaining: `PrismaChallengeRepository` cross-context infra dep |
| 11 | Notifications | ✅ Done | Full-DDD `NotificationsModule`; `FcmService`; 3 `@Cron` jobs (daily reminder, challenge reminder, prediction-ready); `BUDGET_ALERT` + `ANOMALY_ALERT` on transaction create; Flutter inbox + bell + unread badge + FCM token registration. Real device delivery needs Firebase credentials (§6) |
| 12 | Pre/Post Evaluation | 🔄 Partial | Survey GET/POST + improvement comparison + real correct-answer scoring (8 Q each) + **SUS instrument** (`GET/POST /surveys/sus`); **US-034 30-day invitation not wired** |
| 13 | Security and Compliance | 🔄 Partial | Consent + rate limiting + `minSdk=28` + `flutter_secure_storage`; **`AuditLog` now written across 29+ sites** ✅; **TLS/DB encryption deferred**; **ProGuard R8 not configured**; `DELETE /users/me` still immediate hard delete (**no 30-day grace**) |
| 14 | Testing and Quality | ❌ Not started | Zero `.spec.ts` in backend; 1 stub `widget_test.dart` in Flutter; contract-testing plan written (`docs/testing-plan.md`) but not executed |
| 15 | Feedback and Analytics | ✅ Done | `POST /feedback` + Flutter modal; `AnalyticsService` (`@Global()`) wires 14 event types (incl. `view_prediction`, `view_topic`) |
| 16 | Demo Readiness | 🔄 Partial | Architecture/ERD/compliance docs exist; **minimal seed data**, **no demo script**, **no installation guide** |

---

## 9. Changes Log

| Date | Change |
|------|--------|
| 2026-06-13 | **Status reconciliation (session 7):** Re-audited backend + frontend against live code. **Phase 11 Notifications done** — full-DDD `NotificationsModule`, `FcmService` (`src/infra/fcm/`), 3 `@Cron` jobs, 6 inbox/token endpoints; Flutter inbox screen + bell + unread badge + FCM registration (`firebase_core`/`firebase_messaging`/`flutter_local_notifications` added). **US-016 anomaly detection** live via `src/infra/spending-alert/` (fires `ANOMALY_ALERT` on transaction create); **US-020 budget alert** persists `BUDGET_ALERT`. **`AuditLog`** now written across 29+ call sites (was account-deletion only). **`Prediction.actualTotal`/`accuracy`** now populated (`recordActuals()`) — AI-accuracy KPI computable. **Accounts removed** in Flutter (replaced by budgets); new **"Gestión" Management tab** (Progreso/Presupuestos/Metas). **Persistent AI chat** via `conversations` module. **SUS instrument** (`GET/POST /surveys/sus`). **US-048/US-049** done (learning-path chip, personalized quiz). 7/7 badge triggers; challenge auto-verify (4 criteria) + derived `EXPIRED`. Most l10n violations fixed. Still open: zero automated tests, US-034 invitation, budget N+1, deletion grace period, ProGuard R8, demo data/script. |
| 2026-04-29 | **Dashboard data source fix + challenge auto-verification (session 6):** Fixed dashboard data source — `daySummaryProvider`, `weekSummaryProvider`, `monthSummaryProvider` now call `InsightsApiService`; `todayExpenseProvider`, `weekExpenseProvider`, `budgetBreakdownProvider` derive from API data. `RefreshIndicator` invalidates all three providers. Added `VerifyChallengesUseCase` in ChallengesModule — verifies `daily_recording_streak` and `savings_goal_contribution` challenge criteria using `PrismaService` directly (avoids circular deps); triggered fire-and-forget from `CreateTransactionUseCase` and `ContributeToGoalUseCase`. Updated `user_stories.md`: US-028 → Done, US-018 → Done, US-024/US-046 auto-verification → [x], US-025 badge triggers → 6/7 [x], US-037 → In Progress. Updated `roadmap.md`: Phase 7 → ✅ Done, Phase 10/12/13/15 items updated. |
| 2026-04-29 | **Quiz system — US-026 (session 5):** Added `QuizQuestion` Prisma model + migration `20260429200000_add_quiz_question_pool`. Seeded 44 bilingual question groups (88 rows, EN+ES) across all 8 educational topics and 3 difficulty levels using real Peru financial data (BCRP, AFP, SBS, IGV, Yape/Plin, RMV, FSD). Backend: `GetQuizUseCase` (pool selection: 2B+2I+1A, randomized per request), `SubmitQuizUseCase` (per-question feedback + score), 2 new endpoints in `EducationController`. Flutter: `QuizScreen` fully implemented — state machine (answering → reviewing → results), animated option tiles with correct/incorrect reveal, score circle + review list, automatic EN/ES from device locale. Fixed pre-existing `AnalyticsService` type error. US-026 moved to ✅ Done. Survey scoring confirmed real (not placeholder). |
| 2026-04-29 | **Full codebase audit (session 4):** Subagent deep-read of all 17 backend modules (all `.ts` files) and all 31 Flutter routes (all `.dart` files). Added §4.2 Architecture Debt, §5 Frontend Known Gaps and Technical Debt (5 subsections). Identified dashboard data-source duality as #1 priority issue. Found 14 hardcoded l10n violations (6 files). Catalogued 3 dead-code items. Updated §7 priority list to 16 items. Updated all module statuses in §4.1. |
| 2026-04-29 | **Analytics + deprecation cleanup:** Created `AnalyticsService` (`src/infra/analytics/`) as a `@Global()` NestJS service; wired 12 `AnalyticsEvent` types. Migrated 67 deprecated `.withOpacity()` → `.withValues(alpha:)` and 14 `Key? key` → `super.key` across Flutter codebase. |
| 2026-04-29 | **Full feature completion (session 3):** VERIF-01/02 (OTP flow), US-028 (login lockout), US-018 (AI classify chip), US-045 (goal complete/delete), 🎨4/🎨6/🎨7 (goal deadline + detail buttons), US-007 (calendar grid in Day tab), 🎨9 (education personalization header), US-031 (number format preference). |
| 2026-04-29 | **Badge wiring + backend completeness audit:** 5/6 badge award triggers wired. `hasConsecutiveDays()`, `countAll()`/`countCompleted()`, `countByUser()` added to repository ports + Prisma impls. `isCompleted: boolean` added to `GoalResponseDto`. `minSdk=28` set. |
| 2026-04-29 | **Production-readiness + partial US implementation:** deleted 7 dead/fake service files; implemented US-007, US-021, US-045, US-024/US-046, (infrastructure: main dashboard), US-031 currency selector, US-040/US-041 quick-create chip. |
| 2026-04-29 | **Doc sync:** updated roadmap.md checkboxes (phases 5, 7–10, 12, 15); updated user_stories.md statuses for 25 stories |
| 2026-04-29 | **Full codebase audit (session 2):** verified every user story against backend + Flutter source; added Roadmap Phase Audit §7 |
| 2026-04-29 | **Design audit:** 50 `.pen` frames vs 49 thesis user stories; 10 design gaps (🎨1–🎨10), 1 naming conflict |
| 2026-04-29 | **Design:** Password reset redesigned link-based → OTP; Screen 14 created; Screen 15 renamed |
| 2026-04-26 | Initial status report generated |
| 2026-04-26 | Removed income prediction (REMOVED: was US-0802) and all ML references — Azure OpenAI only |
| 2026-04-26 | **Implemented:** ConsentScreen, EmailSentScreen, ProfileSetupScreen, AiChatScreen, QuizScreen stub |
| 2026-04-26 | **Fixed:** All navigation gaps; Profile tab push to `/profile`; Feedback Modal; Registration → profile-setup flow |

---

*Update this document after each implementation sprint. Source of truth: live codebase + ZendaApp.pen mockup.*
