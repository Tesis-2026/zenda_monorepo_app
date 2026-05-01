# Zenda — Project Status Report
**Last updated:** 2026-04-29 (session 5 — quiz system implementation)
**Branch:** main (backend: `feat/badge-wiring-and-feature-completion-apr29`)
**Scope:** User stories, mockup coverage, backend completeness, technical debt, open questions

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
| ~~🎨1~~ | ~~06 – Add Transaction~~ | ~~No AI categorization suggestion~~ | US-0702 | ✅ Done — "Zenda suggests: [Category]" chip below note field, debounced 800ms |
| ~~🎨2~~ | ~~07 – Budget~~ | ~~No "Add Budget" button~~ | US-019 / US-0501 | ✅ Done — FAB with `Icons.add` present, calls `_showCreateDialog()` wired to `POST /budgets` |
| ~~🎨3~~ | ~~07 – Budget~~ | ~~No per-row edit/delete trigger~~ | US-043 / US-0504 | ✅ Done — edit (`Icons.edit_outlined`) + delete (`Icons.delete_outline`) icon buttons in `_BudgetCard` header; one hardcoded `'Delete'` string remaining (l10n) |
| ~~🎨4~~ | ~~08 – Goals~~ | ~~No deadline display on goal cards~~ | US-0502 | ✅ Done |
| ~~🎨5~~ | ~~08 – Goals~~ | ~~No goal complete/delete action~~ | US-0505 | ✅ Done |
| ~~🎨6~~ | ~~09 – Goal Detail~~ | ~~No deadline or days remaining~~ | US-0503 | ✅ Done |
| ~~🎨7~~ | ~~09 – Goal Detail~~ | ~~No "Mark Complete" / "Delete Goal" buttons~~ | US-0505 | ✅ Done |
| 🎨8 | 11 – Profile | **Design doesn't match implementation.** Flutter profile has nav sections; design shows only info card + sign-out. | Multiple | ❌ Open (design update needed in `.pen`) |
| ~~🎨9~~ | ~~22 – Education List~~ | ~~No AI personalization indicator~~ | US-1006 | ✅ Done |
| 🎨10 | 22 – Education List | **No AI-generated contextual questions entry point.** | US-1007 | ❌ Open |

---

## 3. User Stories — What Is Left

> **Audit methodology (2026-04-29):** Each story was verified against the live codebase via subagent deep-read of all backend `.ts` and Flutter `.dart` files. A story is ✅ only when all acceptance criteria are satisfied in the code.

### ❌ Not implemented

| US | Title | Phase | Points | What's needed |
|----|-------|-------|--------|---------------|
| **US-0803** | Spending Anomaly Detection | 8 | 5 | No trigger in `CreateTransactionUseCase`; AI classification not used for anomaly detection |
| **US-1006** | AI-Personalized Learning Path | 10 | — | No `GET /api/education/learning-path` endpoint; no AI ordering |
| **US-1007** | AI-Generated Contextual Questions | 10 | — | No `GET /api/education/quizzes/contextual` endpoint; no Flutter screen |
| **US-1101** | Push Notification Infrastructure | 11 | 5 | ❓ Firebase credentials needed (§6); no FCM integration |
| **US-1102** | Budget Alert at 80% | 11 | 5 | No `@Cron()` job or scheduled trigger in codebase |
| **US-1103** | Anomalous Spending Alert | 11 | 3 | Depends on US-0803 |
| **US-1301** | Data Encryption (TLS + at-rest) | 13 | 5 | Deferred to cloud deployment; `flutter_secure_storage` used for JWT ✅ |
| **US-1302** | ProGuard R8 for release builds | 13 | — | Not configured in `android/app/build.gradle` |
| **US-1305** | Access Auditing to AuditLog | 13 | — | `AuditLog` schema exists; no write calls except account deletion |
| **US-1306** | Right to deletion (30-day grace) | 13 | — | `DELETE /users/me` performs an immediate hard delete with no grace period |
| **US-1401** | Service Unit Tests | 14 | 8 | Zero `.spec.ts` or `_test.dart` files |
| **US-1402** | Integration Tests | 14 | — | Zero test files |
| **US-1403** | AI API Integration Validation | 14 | 8 | Zero test files |
| **US-1404** | Usability Tests (30 students) | 14 | 13 | Requires human participants |
| **US-1405** | Security Tests | 14 | — | Zero test files |
| **US-1406** | Performance Tests | 14 | — | Zero test files |
| **US-1603** | Demo Script (15–20 min) | 16 | — | Not written |
| **US-1604** | Technical Documentation | 16 | — | `docs/` files all marked "Pending (Phase 16)" |

---

### 🔄 Partially implemented — specific gaps remaining

| US | Title | What's Done | What's Missing |
|----|-------|------------|----------------|
| **US-0201** | Record Income | Endpoint + `AddTransactionScreen` done | **Dashboard home tab reads from local SharedPreferences, not the API.** Account balances and budget breakdown reflect only locally-seeded data. Recording a transaction via the API does not update the dashboard home. |
| **US-0204** | Main Dashboard | All widgets shown; `ZendaAiCard` wired to real `GET /api/recommendations` | Same data-duality problem as US-0201: home-page expense totals and budget pie use local `transactionsProvider` (SharedPreferences), not the backend. Full-load benchmarking not done. |
| **US-0302** | Custom Categories | Full CRUD + quick-create "+" chip | Quick-create captures name only — no icon/color picker in the modal |
| **US-0401** | Monthly Summary | Endpoint + Reports screen | Response time not benchmarked (<2 sec target) |
| **US-0403** | Daily Summary | `GET /api/summary/day` + calendar grid in `_DayTab` | No per-day spending indicator dots (requires batch API not yet built) |
| **US-0405** | Charts by Category | Bar + pie charts done | Tap-to-drill-down and period selector not implemented |
| **US-0501** | Budget Management | Full backend CRUD + Flutter; FAB + per-card edit/delete icons ✅ | Color thresholds differ from spec: code green<70%/yellow 70–90%/red>90% vs spec green<60%/yellow 60–80%/red>80% |
| **US-0502** | Financial Goals | Backend + Flutter + deadline display + mark-complete + detail screen | Goal completion confetti animation not implemented |
| **US-0801** | Expense Prediction | Prediction endpoint + Flutter `PredictionsScreen` done | Retrospective accuracy (`actualTotal`/`accuracy` fields on `Prediction`) never populated — dead DB fields |
| **US-0902** | Feedback Tracking | `POST /api/recommendations/:id/feedback` done | Internal metrics dashboard not implemented |
| **US-1002** | Financial Challenge System | List + accept + manual complete + Flutter done | Challenge **auto-verification** not wired (no cron or event hook) |
| **US-1003** | Badge System | 6/6 award triggers wired; Flutter badge grid done | Challenge-completion badge trigger not wired |
| **US-1201** | Pre-Usage Survey | `POST /api/surveys/pre/response` + Flutter screen | Scoring compares against `correctAnswer` (8 real EN questions seeded); "30-day invitation" notification not implemented |
| **US-1202** | Post-Usage Survey | `POST /api/surveys/post/response` + improvement calc | Same real scoring; "30-day invitation" notification not implemented |
| **US-1601** | Demo Data Script | Some demo users in `prisma/seed.ts` | Need 200+ transactions/user, active budgets, goals, completed surveys |

---

### ✅ Done — meets acceptance criteria

| US | Title | Verified via |
|----|-------|-------------|
| US-1801 | Repository and Project Structure | Monorepo layout, branch strategy |
| VERIF-01 | OTP-based password reset (backend) | `POST /api/auth/send-otp` + `POST /api/auth/verify-otp`; `PasswordResetOtp` schema; styled OTP email |
| VERIF-02 | Verify Code screen (Flutter) | `verify_code_screen.dart` — 6 OTP boxes, 60s cooldown, auto-submit |
| US-0102 | Login lockout after 3 failed attempts | `failedLoginAttempts`/`lockedUntil` on User; `LoginUseCase` locks 15 min after 3 failures |
| US-0106 | Profile number format preference | `SegmentedButton` in `ProfileScreen` persists `dot`/`comma` to `SharedPreferences` |
| US-0505 | Mark Goal as Completed or Delete | Active/completed sections; confirmation + celebration dialogs; detail screen buttons |
| US-0702 | AI Auto-Categorization | `POST /api/transactions/classify` + debounced chip in `AddTransactionScreen` |
| US-0101 | User Registration | `register.use-case.ts`, `register.dto.ts`, `register_screen.dart` |
| US-0103 | Authentication Middleware | `jwt-auth.guard.ts`, `@UserId()` decorator, 401 on invalid token |
| US-0104 | Password Recovery | `POST /api/auth/forgot-password` + OTP flow + `reset-password`; email via nodemailer |
| US-0105 | Initial Profile Setup | `profile_setup_screen.dart` 4-step wizard, `profileCompleted` flag wired |
| US-0203 | Transaction History with Filters | `ListTransactionsUseCase` with all query params, `TransactionListScreen` |
| US-0205 | Edit Transaction | `PUT /api/transactions/:id` (ownership validated), `EditTransactionScreen` |
| US-0206 | Delete Transaction | `DeleteTransactionUseCase` (soft delete, ownership), Flutter confirmation dialog |
| US-0301 | Default Categories (seed) | `prisma/seed.ts` — 9 expense + 5 income categories |
| US-0302 | Custom Categories (CRUD) | Full `categories` module + `CategoryManagementScreen` |
| US-0402 | Weekly Summary | `GET /api/summary/week` + Flutter `_WeekTab` with ISO week selector |
| US-0404 | Monthly Comparison | `GET /api/summary/comparison` + Flutter `_CompareTab` with 2M/3M/6M selector |
| US-0405 | Charts by Category | `_CategoryBarChart` + `BudgetPieChart` |
| US-0406 | PDF Export | `GeneratePdfReportUseCase` + Flutter `_exportPdf()` with `share_plus` |
| US-0407 | Financial Progress Indicator | `GET /api/summary/progress` + Flutter `ProgressScreen` |
| US-0503 | Detailed Goal Tracking | `GoalDetailScreen` with contribution history, line chart, projection message |
| US-0504 | Edit or Delete Monthly Budget | `UpdateBudgetUseCase` + `DeleteBudgetUseCase`; Flutter edit dialog + delete confirmation |
| US-0701 | Azure AI API Integration | `AzureFoundryProvider` — 4 AI methods; env-var config; graceful fallback |
| US-0901 | Recommendation Engine | `GetRecommendationsUseCase` + rule-based fallback; `RecommendationsScreen`; `ZendaAiCard` wired |
| US-1001 | Educational Content Module | `GET /education/topics`, detail, `PATCH .../complete`; `EducationScreen` + `TopicDetailScreen` |
| US-1004 | Financial Knowledge Quizzes | `QuizQuestion` model + migration; 44 bilingual question groups (EN + ES) seeded across all 8 topics; `GET /education/topics/:id/quiz?language=` pool-selects 5 questions (2B+2I+1A); `POST /education/topics/:id/quiz/submit` scores and returns per-question feedback; `QuizScreen` fully implemented with state machine, per-question reveal, result screen |
| US-1203 | Educational Improvement Calculation | `GET /api/surveys/comparison` (per-user pre/post diff) |
| US-1303 | Data Consent | `consent_screen.dart` gates registration; `consentGiven`/`consentAt` on User |
| US-1501 | In-App Feedback System | `POST /api/feedback`; Flutter `FeedbackModal` from `ProfileScreen` |

---

## 4. Backend Completeness

### 4.1 Module Status

| Module | Endpoints | DDD Layer | Status | Notes |
|--------|-----------|-----------|--------|-------|
| Auth | 8 | ✅ Full use-cases + ports | ✅ Solid | Register, login, refresh, logout, OTP, reset-password; lockout logic |
| Users | 2 (GET/PUT) + 1 (DELETE) | 🔄 Partial — DELETE bypasses DDD | 🔄 Partial | `DELETE /users/me` runs raw Prisma in controller |
| Transactions | 6 | ✅ Full use-cases + ports | ✅ Solid | CRUD + classify; analytics wired |
| Categories | 4 | ✅ Full use-cases + ports | ✅ Solid | System + custom; soft delete |
| Budgets | 4 | ✅ Full use-cases + ports | 🔄 Partial | N+1 query in `findAll()` — one `aggregate` per row |
| Goals | 6 | ✅ Full use-cases + ports | ✅ Solid | CRUD + contribute + complete |
| Insights | 5 + 1 PDF | 🔄 Partial — progress bypasses DDD | 🔄 Partial | `GET /summary/progress` runs raw Prisma aggregates in controller |
| Predictions | 1 | ✅ Full use-case + port | 🔄 Partial | `actualTotal`/`accuracy` fields are dead (never written); `modelVersion` column encodes confidence+narrative as pipe-delimited string |
| Recommendations | 2 | ✅ Full use-cases + port | ✅ Solid | AI + rule-based fallback; feedback endpoint |
| Education | 5 | ✅ Full use-cases + port | ✅ Solid | List, detail, complete, quiz GET, quiz submit; badge trigger on completion; `quiz_topic` analytics event |
| Challenges | 3 | ❌ No use-cases — controller calls repo directly | 🔄 Partial | No auto-verification; `PrismaChallengeRepository` injects `IBadgeRepository` directly (cross-context infra dep) |
| Badges | 1 | ❌ No use-case — controller calls repo directly | 🔄 Partial | List works; award triggers in use-cases of other modules ✅ |
| Feedback | 1 | ❌ No domain/application layer | 🔄 Stub | Direct Prisma in controller; analytics now delegated to `AnalyticsService` ✅ |
| Surveys | 5 | ❌ No domain/application layer | 🔄 Stub | All endpoints have inline scoring + direct Prisma; scoring is placeholder (no correct answers) |
| Notifications | 2 | ❌ No domain/application layer | 🔄 Stub | Preferences stored; no FCM delivery; no scheduled jobs |
| Chat | 1 | N/A (thin pass-through) | ✅ Solid | `POST /ai/chat` delegates to `AiProvider.chat()` |
| Analytics (infra) | — | N/A | ✅ Solid | `AnalyticsService` global; 12 event types wired |

### 4.2 Architecture Debt

| Issue | Location | Severity |
|-------|----------|----------|
| `DELETE /users/me` — raw Prisma `$transaction` in controller, bypasses domain layer | `users.controller.ts:41-53` | Medium |
| `GET /summary/progress` — raw Prisma aggregates in controller | `summary.controller.ts:68-102` | Medium |
| `FeedbackModule`, `SurveysModule`, `NotificationsModule` — zero DDD; all logic in controller | 3 modules | Low (scope is limited) |
| `ChallengesController`, `BadgesController` — controller calls repository port directly, no use-case | 2 controllers | Low |
| `PrismaChallengeRepository` injects `IBadgeRepository` — infra layer cross-context dependency | `prisma-challenge.repository.ts:57-61` | Medium |
| `Prediction.modelVersion` encodes confidence + narrative as pipe-delimited string | Predictions infra | Low |
| `Prediction.actualTotal` + `Prediction.accuracy` — dead DB fields, never written | Predictions model | Low |
| N+1 query in `PrismaBudgetsRepository.findAll()` — one `aggregate` per row | `prisma-budgets.repository.ts` | Medium |
| `AiModule` exports `AzureFoundryProvider` concrete class alongside `AI_PROVIDER` token — redundant | `ai.module.ts` | Low |

---

## 5. Frontend — Known Gaps and Technical Debt

### 5.1 Dashboard Data Architecture — FIXED ✅

`todayExpenseProvider`, `weekExpenseProvider`, and `budgetBreakdownProvider` now call the backend API via `InsightsApiService` instead of reading from local SharedPreferences. `daySummaryProvider`, `weekSummaryProvider`, and `monthSummaryProvider` are new `FutureProvider.autoDispose` providers backed by `GET /api/summary/day`, `/week`, `/month`. The `RefreshIndicator` on the dashboard invalidates all three on pull-to-refresh.

**Remaining local-only stores** (by design — accounts are not yet synced to backend):
- `AccountsRepository` — SharedPreferences, seeds 3 accounts on first run (`Efectivo`, `BCP Débito`, `Interbank Crédito`)
- `TransactionsRepository` — SharedPreferences, legacy local cache (still used for streak tracking)
- `StreakRepository` — SharedPreferences

### 5.2 Hardcoded Strings (l10n Violations)

The following strings bypass `context.l10n` and are hardcoded directly in widget build methods:

| File | Hardcoded String(s) | Impact |
|------|--------------------|----|
| `dashboard/widgets/account_card.dart` | `'Deuda:'`, `'Disp:'` — Spanish labels for credit accounts | Spanish-locked; invisible on English locale |
| `core/models/account.dart` | `typeLabel` getter returns `'Efectivo'`, `'Débito'`, `'Crédito'` — used in `AccountCard` | Spanish-locked display names |
| `dashboard/dashboard_providers.dart` | 4 hardcoded Spanish fallback strings for AI advice (`'Empieza a registrar...'`, `'Tus "deseos"...'`, `'Tu ahorro está bajo...'`, `'¡Vas muy bien!...'`) | High — user-visible fallbacks, Spanish-only |
| `reports/reports_screen.dart` | `_monthNames` English array; `['M','T','W','T','F','S','S']` day headers in calendar grid | English-locked; not translatable |
| `budget/budget_screen.dart` | `const Text('Delete')` in confirmation dialog | English-only |
| `onboarding/profile_setup_screen.dart` | `SnackBar(content: Text('Could not save profile. Continuing anyway.'))` | English-only error message |

### 5.3 Dead Code

| File | What it is |
|------|-----------|
| `features/transactions/transaction_create_screen.dart` | 1-line stub file; not registered in the router; never referenced |
| `features/streak/streak_notifier.dart` | `ChangeNotifier`-based `StreakNotifier`; not wired as a Riverpod provider anywhere; replaced by `StreakRepository`-based approach |
| `_PerfilSection` class in `dashboard_screen.dart` | Defined but never added to the PageView `children`; unreachable dead widget |

### 5.4 Stub / Unimplemented Features

| Feature | Status |
|---------|--------|
| OCR receipt scan | `OcrService` abstract class with no concrete implementation. `AddTransactionScreen` calls `fillFromOcrDemo()` which hardcodes `amount=12.50`, `category=comida`, `note='Cafetería'`. |
| Google Sign-In | `OutlinedButton` for "Continue with Google" has `onPressed: null` (disabled). No OAuth integration. |
| Push notifications | `NotificationPreferencesScreen` saves preferences to the API, but no FCM registration, no device token, no actual notification delivery. |

### 5.5 API Service Coverage — Complete Map

All 31 routes declared in `app_router.dart`. All API calls go through `ApiClient` (base URL: `http://10.0.2.2:3000/api` for Android emulator). Token refresh (401 retry) is handled automatically in `ApiClient`.

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
| `notifications_api_service.dart` | GET /notifications/preferences, PATCH /notifications/preferences/:type |
| `ai_chat_api_service.dart` | POST /ai/chat |
| `progress_api_service.dart` | GET /summary/progress |
| `feedback_api_service.dart` | POST /feedback |
| `accounts_repository.dart` | **LOCAL ONLY** — SharedPreferences (`zenda.accounts.v1`) |
| `transactions_repository.dart` | **LOCAL ONLY** — SharedPreferences (`zenda.transactions.v1`) |
| `streak_repository.dart` | **LOCAL ONLY** — SharedPreferences (`zenda.streak.v1`) |

---

## 6. Open Questions — Needed From You

### ✅ Quiz questions — resolved (US-1004)
`QuizQuestion` pool seeded with 44 bilingual question groups (88 DB rows) across all 8 educational topics and all 3 difficulty levels, based on Peru-specific financial data (BCRP, SBS, AFP, IGV, Yape/Plin, RMV). Endpoints built. `QuizScreen` fully implemented. No further action needed.

### ✅ Survey questions — resolved (US-1201/US-1202)
8 PRE questions and 8 POST questions with `correctAnswer` set in seed. Scoring compares user answers to `correctAnswer` (strict equality). The ≥20% improvement metric is now measurable.

### ❓ Firebase for push notifications (US-1101)
Notification preferences are stored but not delivered. To implement:
- `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) from your Firebase project

### ❓ Demo data readiness (Phase 16 / US-1601)
- Shall I expand the seed script to 200+ transactions/user with realistic PEN amounts, budgets, and goals?
- What is the target demo date?

---

## 7. What Remains — Priority Order

| # | Item | Effort | Impact |
|---|------|--------|--------|
| 1 | **Fix hardcoded Spanish strings** in `account_card.dart`, `dashboard_providers.dart`, `account.dart` (`typeLabel`) | Low | High — thesis SUS score |
| 2 | **Fix screen naming conflict** in `ZendaApp.pen`: rename "15 – Edit Transaction" to "16 –" | Low | Medium |
| 3 | **Redesign screen 11 (Profile)** in `ZendaApp.pen` to match Flutter implementation | Low | High |
| 4 | Fix budget screen l10n `'Delete'` string + month-name/day-header hardcodes in Reports | Low | Medium |
| 5 | Expand demo data seed script (200+ transactions/user) | Low | High — Phase 16 |
| 6 | FCM push delivery | Medium — **[content needed]** | Medium — US-1101 |
| 7 | Fix N+1 query in `PrismaBudgetsRepository.findAll()` | Low | Medium — performance |
| 8 | Goal completion confetti animation | Low | Low — cosmetic |
| 9 | Wire "Predictor" badge trigger (check predictions view count) | Low | Low — gamification |
| 10 | Demo script (15–20 min walkthrough) | Low | High — Phase 16 |
| 11 | Technical documentation | Medium | High — Phase 16 |
| 12 | Unit + integration tests | High | High — Phase 14 / ISO 25010 |

---

## 8. Roadmap Phase Audit

| Phase | Title | Status | Gap summary |
|-------|-------|--------|-------------|
| 1 | Infrastructure and Setup | ✅ Done | Repo, Docker/Postgres, NestJS base, Flutter base, CI/CD config all present |
| 2 | Authentication and Users | ✅ Done | Register/login/JWT/refresh/logout/forgot-reset-password; OTP flow; lockout after 3 failures |
| 3 | Transaction Recording | 🔄 Partial | Full CRUD + Flutter done; **home-page dashboard reads local SharedPreferences, not API** — balances and budget breakdown don't update after recording |
| 4 | Categorization | ✅ Done | Full CRUD backend + Flutter; quick-create "+" chip in `AddTransactionScreen` |
| 5 | Reports and Visualization | 🔄 Partial | Monthly/weekly/comparison + Flutter + PDF export + progress; Day tab has calendar grid; **hardcoded month names and day headers in `ReportsScreen`**; chart tap-drill-down not done |
| 6 | Budgets and Goals | 🔄 Partial | Budget + Goals full CRUD + Flutter; goal deadline, complete, detail screen; **completion confetti missing**; **N+1 in BudgetsRepository** |
| 7 | AI Integration | ✅ Done | `AzureFoundryProvider`; `POST /transactions/classify`; debounced AI chip in `AddTransactionScreen` |
| 8 | Predictions | 🔄 Partial | Prediction endpoint + `PredictionsScreen`; **anomaly detection not triggered on transaction save**; **`actualTotal`/`accuracy` dead fields** |
| 9 | Recommendations | ✅ Done | `GetRecommendationsUseCase` + rule-based fallback; `RecommendationsScreen`; `ZendaAiCard` wired to real API |
| 10 | Education and Gamification | 🔄 Partial | Education topics + Flutter + personalization header + quiz fully implemented done; challenges + badges + 6/7 award triggers wired (Predictor missing); **`VerifyChallengesUseCase` wired** for `daily_recording_streak` + `savings_goal_contribution`; `PrismaChallengeRepository` cross-context infra dep |
| 11 | Notifications | 🔄 Partial | Preferences stored; **no FCM**; **no budget-80% cron job**; **no anomaly alert** |
| 12 | Pre/Post Evaluation | 🔄 Partial | Survey GET/POST + Flutter + improvement comparison + **real correct-answer scoring seeded (8 Q each)**; **30-day invitation not wired** |
| 13 | Security and Compliance | 🔄 Partial | Consent + rate limiting + `minSdk=28` + `flutter_secure_storage` + `DELETE /users/me` (immediate hard delete); **TLS/DB encryption deferred**; **ProGuard R8 not configured**; **AuditLog writes missing**; **no 30-day grace on deletion** |
| 14 | Testing and Quality | ❌ Not started | Zero test files in backend or frontend |
| 15 | Feedback and Analytics | ✅ Done | `POST /feedback` + Flutter modal; `AnalyticsService` (`@Global()`) wires 12 event types: `login`, `register`, `record_transaction`, `delete_transaction`, `create_goal`, `contribute_goal`, `complete_goal`, `accept_challenge`, `complete_challenge`, `complete_topic`, `create_budget`, `submit_feedback` |
| 16 | Demo Readiness | ❌ Not started | Minimal seed data; no demo script; no installation guide; no technical documentation |

---

## 9. Changes Log

| Date | Change |
|------|--------|
| 2026-04-29 | **Dashboard data source fix + challenge auto-verification (session 6):** Fixed dashboard data source — `daySummaryProvider`, `weekSummaryProvider`, `monthSummaryProvider` now call `InsightsApiService`; `todayExpenseProvider`, `weekExpenseProvider`, `budgetBreakdownProvider` derive from API data. `RefreshIndicator` invalidates all three providers. Added `VerifyChallengesUseCase` in ChallengesModule — verifies `daily_recording_streak` and `savings_goal_contribution` challenge criteria using `PrismaService` directly (avoids circular deps); triggered fire-and-forget from `CreateTransactionUseCase` and `ContributeToGoalUseCase`. Updated `user_stories.md`: US-0102 → Done, US-0702 → Done, US-1002 auto-verification → [x], US-1003 badge triggers → 6/7 [x], US-1502 → In Progress. Updated `roadmap.md`: Phase 7 → ✅ Done, Phase 10/12/13/15 items updated. |
| 2026-04-29 | **Quiz system — US-1004 (session 5):** Added `QuizQuestion` Prisma model + migration `20260429200000_add_quiz_question_pool`. Seeded 44 bilingual question groups (88 rows, EN+ES) across all 8 educational topics and 3 difficulty levels using real Peru financial data (BCRP, AFP, SBS, IGV, Yape/Plin, RMV, FSD). Backend: `GetQuizUseCase` (pool selection: 2B+2I+1A, randomized per request), `SubmitQuizUseCase` (per-question feedback + score), 2 new endpoints in `EducationController`. Flutter: `QuizScreen` fully implemented — state machine (answering → reviewing → results), animated option tiles with correct/incorrect reveal, score circle + review list, automatic EN/ES from device locale. Fixed pre-existing `AnalyticsService` type error. US-1004 moved to ✅ Done. Survey scoring confirmed real (not placeholder). |
| 2026-04-29 | **Full codebase audit (session 4):** Subagent deep-read of all 17 backend modules (all `.ts` files) and all 31 Flutter routes (all `.dart` files). Added §4.2 Architecture Debt, §5 Frontend Known Gaps and Technical Debt (5 subsections). Identified dashboard data-source duality as #1 priority issue. Found 14 hardcoded l10n violations (6 files). Catalogued 3 dead-code items. Updated §7 priority list to 16 items. Updated all module statuses in §4.1. |
| 2026-04-29 | **Analytics + deprecation cleanup:** Created `AnalyticsService` (`src/infra/analytics/`) as a `@Global()` NestJS service; wired 12 `AnalyticsEvent` types. Migrated 67 deprecated `.withOpacity()` → `.withValues(alpha:)` and 14 `Key? key` → `super.key` across Flutter codebase. |
| 2026-04-29 | **Full feature completion (session 3):** VERIF-01/02 (OTP flow), US-0102 (login lockout), US-0702 (AI classify chip), US-0505 (goal complete/delete), 🎨4/🎨6/🎨7 (goal deadline + detail buttons), US-0403 (calendar grid in Day tab), 🎨9 (education personalization header), US-0106 (number format preference). |
| 2026-04-29 | **Badge wiring + backend completeness audit:** 5/6 badge award triggers wired. `hasConsecutiveDays()`, `countAll()`/`countCompleted()`, `countByUser()` added to repository ports + Prisma impls. `isCompleted: boolean` added to `GoalResponseDto`. `minSdk=28` set. |
| 2026-04-29 | **Production-readiness + partial US implementation:** deleted 7 dead/fake service files; implemented US-0403, US-0502, US-0505, US-1002, US-0204, US-0106 currency selector, US-0302 quick-create chip. |
| 2026-04-29 | **Doc sync:** updated roadmap.md checkboxes (phases 5, 7–10, 12, 15); updated user_stories.md statuses for 25 stories |
| 2026-04-29 | **Full codebase audit (session 2):** verified every user story against backend + Flutter source; added Roadmap Phase Audit §7 |
| 2026-04-29 | **Design audit:** 50 `.pen` frames vs 49 thesis user stories; 10 design gaps (🎨1–🎨10), 1 naming conflict |
| 2026-04-29 | **Design:** Password reset redesigned link-based → OTP; Screen 14 created; Screen 15 renamed |
| 2026-04-26 | Initial status report generated |
| 2026-04-26 | Removed income prediction (US-0802) and all ML references — Azure OpenAI only |
| 2026-04-26 | **Implemented:** ConsentScreen, EmailSentScreen, ProfileSetupScreen, AiChatScreen, QuizScreen stub |
| 2026-04-26 | **Fixed:** All navigation gaps; Profile tab push to `/profile`; Feedback Modal; Registration → profile-setup flow |

---

*Update this document after each implementation sprint. Source of truth: live codebase + ZendaApp.pen mockup.*
