# Zenda — Project Status Report
**Last updated:** 2026-04-29  
**Branch:** develop  
**Scope:** User stories, mockup coverage, backend completeness, open questions

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
| 24 – Quiz | `features/education/quiz_screen.dart` — stub, reachable from topic detail |
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

| Mockup Screen | What's needed |
|---------------|--------------|
| **14 – Verify Code** | `features/auth/verify_code_screen.dart` — 6-digit OTP input, timer countdown, resend link. Screen designed 2026-04-29. Requires backend OTP endpoint (see §3). |

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

### ✅ Navigation — all screens are now reachable

All previously orphaned screens are linked from `ProfileScreen` (`/profile`):

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

> **⚠️ Design vs code mismatch:** The Flutter `ProfileScreen` has these full navigation sections. Screen 11 in the design (`ZendaApp.pen`) shows only a minimal info card + sign-out button. The design must be updated to match the fuller implementation (see §2.1 Design Gaps).

---

## 2. Auth & Onboarding Flow

### 2.1 Password Reset — **Updated 2026-04-29: Link-based → Code-based**

The password reset flow was redesigned from a link-based approach to a 6-digit OTP code approach. Three screens now cover this flow:

```
13 – Forgot Password  →  14 – Verify Code (NEW)  →  15 – Reset Password
   Enter email              Enter 6-digit code         Enter new password
   "Send Code" CTA          Timer: 14:32               Strength indicator
                            Boxes 1–3 filled (●)       "Reset Password" CTA
                            Box 4 active (green)
                            Boxes 5–6 empty
                            "Resend" link
```

**Flutter code status:**
- `forgot_password_screen.dart` — exists, but still sends a link (old flow). Needs update to call OTP endpoint.
- `verify_code_screen.dart` — **does not exist yet**. Must be created.
- `reset_password_screen.dart` — exists and is reusable; just needs to receive the OTP token.
- Backend `POST /api/auth/send-otp` and `POST /api/auth/verify-otp` — **do not exist yet**.

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

These screens exist in `ZendaApp.pen` and have Flutter implementations, but are missing specific widgets that are required by user stories. Each gap is a targeted design + code fix.

| # | Screen | Missing Widget / Logic | User Story | Fix |
|---|--------|----------------------|------------|-----|
| 🎨1 | 06 – Add Transaction | **No AI categorization suggestion.** When user fills the note field, no "Zenda suggests: [Category]" chip appears above the category grid. | US-018 / US-0702 | Add a conditionally visible chip row below the note field. Wire to `classifyTransaction()` on note blur. |
| 🎨2 | 07 – Budget | **No "Add Budget" button.** The header shows only title + month selector. There is no visible way to create a new budget from this screen. Goals screen has a comparable "+ New" button. | US-019 / US-0501 | Add "+ New" button to the Budget screen header (same pattern as Goals). |
| 🎨3 | 07 – Budget | **No per-row edit/delete trigger.** Budget rows show category + progress bar but have no "⋯" kebab or swipe action. Screen 45 (Edit Budget modal) exists but is unreachable from the design. | US-043 / US-0504 | Add a "⋯" icon to the right of each budget row. Long-press or tap opens Edit/Delete options. |
| 🎨4 | 08 – Goals | **No deadline display on goal cards.** Cards show progress % and amounts but no target date. | US-021 / US-0502 | Add "Due: [date]" below the progress bar on each goal card. |
| 🎨5 | 08 – Goals | **No goal complete/delete action.** Goal cards have no swipe-to-reveal or action menu. | US-045 / US-0505 | Add "⋯" kebab or long-press to reveal "Mark Complete" and "Delete" options. |
| 🎨6 | 09 – Goal Detail | **No deadline or days remaining.** The progress card shows amount/% but no target date or countdown. | US-022 / US-0503 | Add "Target: [date] · [N] days left" row to the progress card. |
| 🎨7 | 09 – Goal Detail | **No "Mark Complete" / "Delete Goal" buttons.** The only action visible is "+ Add" for contributions. | US-045 / US-0505 | Add two secondary action buttons below the contribution section. |
| 🎨8 | 11 – Profile | **Design doesn't match implementation.** Flutter profile has sections for Finance Tools, Education, Gamification, Research, Settings/Support. Design shows only info card + sign-out. | Multiple | Redesign screen 11 to include nav section rows matching the Flutter implementation. |
| 🎨9 | 22 – Education List | **No AI personalization indicator.** Topic ordering is static. No "Recommended for you" label or explanation. | US-048 / US-1006 | Add a "Personalized for you ✨" section header above the AI-ordered topics. Explain briefly why topics are prioritized. |
| 🎨10 | 22 – Education List | **No AI-generated contextual questions entry point.** US-049 requires AI-generated questions based on the user's spending patterns. No dedicated screen or entry point exists. | US-049 / US-1007 | Add a card "Practice with Zenda AI" on the Education screen. Create a new screen (or extend Quiz screen) for AI-generated questions. |

---

## 3. User Stories — What Is Left

> **Audit methodology (2026-04-29):** Each story was verified against the live codebase — backend TypeScript source files, Flutter Dart files, and route declarations. A story is ✅ only when all acceptance criteria in `user_stories.md` are satisfied in the code.

### ❌ Not implemented

| US | Title | Phase | Points | What's needed |
|----|-------|-------|--------|---------------|
| **VERIF-01** | OTP-based password reset (backend) | Auth | — | `POST /api/auth/send-otp` and `POST /api/auth/verify-otp` endpoints; replace link-based flow |
| **VERIF-02** | Verify Code screen (Flutter) | Auth | — | `verify_code_screen.dart` — 6-digit OTP input, countdown timer, resend, route between ForgotPassword and ResetPassword |
| **US-0102** | Login lockout after 3 failed attempts | 2 | 5 | `LoginUseCase` has no failed-attempt counter; `ThrottlerModule` only rate-limits by IP, not per-user after failed auth |
| **US-0702** | AI Auto-Categorization | 7 | 5 | `classifyTransaction()` exists in `AzureFoundryProvider` but is never called from `CreateTransactionUseCase`; also missing UI chip in `AddTransactionScreen` (🎨1) |
| **US-0803** | Spending Anomaly Detection | 8 | 5 | No trigger in `CreateTransactionUseCase`; `AiProvider.classifyTransaction` not used for anomaly detection |
| **US-1004** | Financial Knowledge Quizzes | 10 | 8 | ❓ Quiz questions/answers needed (see §5); no quiz backend endpoints (`GET /api/education/quizzes`, `POST /api/education/quizzes/:id/answer`); `QuizScreen` is a stub |
| **US-1006** | AI-Personalized Learning Path | 10 | — | No `GET /api/education/learning-path` endpoint; `EducationController` has no AI ordering; design missing personalization label (🎨9) |
| **US-1007** | AI-Generated Contextual Questions | 10 | — | No `GET /api/education/quizzes/contextual` endpoint; no Flutter screen; design missing entry point (🎨10) |
| **US-1101** | Push Notification Infrastructure | 11 | 5 | ❓ Firebase project needed (see §5); `NotificationPreference` stored but no FCM integration in `NotificationsModule` |
| **US-1102** | Budget Alert at 80% | 11 | 5 | No scheduled job or `@Cron()` decorator anywhere in codebase |
| **US-1103** | Anomalous Spending Alert | 11 | 3 | Depends on US-0803 — no trigger on transaction creation |
| **US-1301** | Data Encryption (TLS + at-rest) | 13 | 5 | Deferred to cloud production deployment; `flutter_secure_storage` is used for JWT ✅ but TLS and DB encryption at-rest not implemented locally |
| **US-1302** | ProGuard R8 for release builds | 13 | — | `flutter_secure_storage` used ✅; ProGuard/R8 not configured in `android/app/build.gradle` |
| **US-1305** | Access Auditing to AuditLog | 13 | — | `AuditLog` schema exists; no write calls found outside account deletion |
| **US-1306** | Right to deletion (30-day grace) | 13 | — | No `DELETE /api/account` endpoint with grace-period logic |
| **US-1401** | Service Unit Tests | 14 | 8 | Zero `.spec.ts` or `_test.dart` files in codebase |
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
| **US-0102** | Login | JWT + 401 on bad credentials | Lockout after 3 consecutive failed attempts (15 min) — `LoginUseCase` has no counter |
| **US-0106** | Profile Editing | `PUT /api/users/me` + edit UI + currency selector (PEN/USD) added | Number format (thousands separator) not yet selectable |
| **US-0201** | Record Income | Endpoint + screen done | Balance on main dashboard does not update immediately after recording |
| **US-0204** | Main Dashboard | All widgets shown; `ZendaAiCard` now wired to real `GET /api/recommendations` | Full load time not benchmarked (<2 sec target) |
| **US-0302** | Custom Categories | Full CRUD backend + frontend + quick-create "+" chip in `AddTransactionScreen` | Quick-create dialog captures name only (no icon/color picker in the modal) |
| **US-0401** | Monthly Summary | Endpoint + Reports screen | Response time not benchmarked (<2 sec target) |
| **US-0403** | Daily Summary | Backend `GET /api/summary/day` fully implemented; Flutter Day tab with date navigation added to `ReportsScreen` | "Visual calendar with spending indicator per day" not implemented |
| **US-0405** | Charts by Category | Horizontal bar chart + pie chart (`BudgetPieChart`) done | Tap-to-drill-down and period selector (week/month/quarter) not implemented |
| **US-0501** | Budget Management | Full backend + Flutter CRUD — `currentSpent`/`percentageUsed` come from backend ✅; FAB creates budget ✅; per-card edit/delete icons ✅ | Progress bar color thresholds differ from spec: code uses green <70% / yellow 70–90% / red >90% vs specified green <60% / yellow 60–80% / red >80% |
| **US-0502** | Financial Goals | Backend POST/GET/contribute + Flutter goals list + contribute dialog + deadline date picker in create dialog ✅ | Completion animation when `currentAmount >= targetAmount` not implemented |
| **US-0505** | Mark Goal as Completed or Delete | Goal delete ✅; "Mark complete" `FilledButton.icon` added to `GoalsScreen` (calls `PUT /goals/:id/complete`) | Completed goals section not shown separately; no confirmation dialog before mark-complete |
| **US-0801** | Expense Prediction | `GetExpensePredictionUseCase` + statistical fallback + Flutter `PredictionsScreen` done | Retrospective accuracy tracking (`actualTotal` / `accuracy` fields on `Prediction`) not implemented |
| **US-0902** | Feedback Tracking | `POST /api/recommendations/:id/feedback` done | Internal metrics dashboard not implemented |
| **US-1002** | Financial Challenge System | List + accept endpoints + frontend + "Mark completed" button added | Challenge **auto-verification** not wired (no cron job or event hook calling `repo.complete()`) |
| **US-1003** | Badge System | `GET /api/badges` + award method + Flutter grid screen | `awardIfNotEarned()` is never called — no event hooks on transaction creation, goal completion, or challenge completion |
| **US-1201** | Pre-Usage Survey | Backend `POST /api/surveys/pre/response` + Flutter survey screen | ❓ Scoring is placeholder: `answeredQuestions / total * 100` — no correct-answer comparison; real questions + correct answers needed (see §5) |
| **US-1202** | Post-Usage Survey | Backend `POST /api/surveys/post/response` + improvement calculation | Same placeholder scoring; "invitation after 30 days" notification not implemented |
| **US-1601** | Demo Data Script | Some demo users seeded in backend `prisma/seed.ts` | Need 200+ transactions/user, active budgets, goals, completed surveys |

---

### ✅ Done — meets acceptance criteria

| US | Title | Verified via |
|----|-------|-------------|
| US-1801 | Repository and Project Structure | Monorepo layout, branch strategy |
| US-0101 | User Registration | `register.use-case.ts`, `register.dto.ts`, `register_screen.dart` |
| US-0103 | Authentication Middleware | `jwt-auth.guard.ts`, `@UserId()` decorator, 401 on invalid token |
| US-0104 | Password Recovery (link-based) | `forgot-password.use-case.ts`, `reset-password.use-case.ts`, Flutter screens exist |
| US-0105 | Initial Profile Setup | `profile_setup_screen.dart` 4-step wizard, `profileCompleted` flag wired |
| US-0203 | Transaction History with Filters | `list-transactions.use-case.ts` with all query params, `transaction_list_screen.dart` |
| US-0205 | Edit Transaction | `update-transaction.use-case.ts` (ownership validated), `edit_transaction_screen.dart` |
| US-0206 | Delete Transaction | `delete-transaction.use-case.ts` (soft delete, ownership), Flutter confirmation dialog |
| US-0301 | Default Categories (seed) | `prisma/seed.ts` — 9 expense + 5 income categories |
| US-0302 | Custom Categories (CRUD) | Full `categories` module + `category_management_screen.dart` |
| US-0402 | Weekly Summary | `GET /api/summary/week` + Flutter `_WeekTab` with ISO week selector |
| US-0404 | Monthly Comparison | `GET /api/summary/comparison` + Flutter `_CompareTab` with 2M/3M/6M selector |
| US-0405 | Charts by Category | `_CategoryBarChart` + pie chart in `BudgetPieChart` (dashboard), fl_chart library |
| US-0406 | PDF Export | `generate-pdf-report.use-case.ts` + Flutter `_exportPdf()` with `share_plus` |
| US-0407 | Financial Progress Indicator | `GET /api/summary/progress` + Flutter `ProgressScreen` wired to `ProgressApiService` |
| US-0503 | Detailed Goal Tracking | `GoalDetailScreen` with contribution history, `fl_chart` line chart, projection message |
| US-0504 | Edit or Delete Monthly Budget | `update-budget.use-case.ts` + `delete-budget.use-case.ts`; Flutter `_showEditDialog()` (calls `PUT /budgets/:id`) + `_deleteBudget()` (calls `DELETE /budgets/:id`) with confirmation |
| US-0104 | Password Recovery | `POST /api/auth/forgot-password` + `POST /api/auth/reset-password`; email via nodemailer; Flutter `ForgotPasswordScreen` + `ResetPasswordScreen` |
| US-0205 | Edit Transaction | `PUT /api/transactions/:id` (ownership validated); Flutter `EditTransactionScreen` pre-filled |
| US-0302 | Custom Categories (CRUD) | Full `categories` module + `CategoryManagementScreen` + quick-create "+" chip in `AddTransactionScreen` |
| US-0402 | Weekly Summary | `GET /api/summary/week` + Flutter `_WeekTab` with ISO week selector |
| US-0404 | Monthly Comparison | `GET /api/summary/comparison` + Flutter `_CompareTab` with 2M/3M/6M selector |
| US-0406 | PDF Export | `generate-pdf-report.use-case.ts` + Flutter `_exportPdf()` with `share_plus` |
| US-0407 | Financial Progress Indicator | `GET /api/summary/progress` + Flutter `ProgressScreen` wired to `ProgressApiService` |
| US-0503 | Detailed Goal Tracking | `GoalDetailScreen` with contribution history, `fl_chart` line chart, projection message |
| US-0504 | Edit or Delete Monthly Budget | `update-budget.use-case.ts` + `delete-budget.use-case.ts`; Flutter `_showEditDialog()` + `_deleteBudget()` |
| US-0701 | Azure AI API Integration | `AzureFoundryProvider` — `predictExpenses`, `generateRecommendations`, `classifyTransaction`, `chat`; env-var config; graceful fallback |
| US-0901 | Recommendation Engine | `GetRecommendationsUseCase` with Azure AI + rule-based fallback; Flutter `RecommendationsScreen`; `ZendaAiCard` wired to real API |
| US-1001 | Educational Content Module | `GET /api/education/topics`, `GET /api/education/topics/:id`, `PATCH .../complete`; Flutter `EducationScreen` + `TopicDetailScreen` |
| US-1203 | Educational Improvement Calculation | `GET /api/surveys/comparison` (per-user pre/post diff); placeholder scoring noted but endpoint exists |
| US-1303 | Data Consent | `consent_screen.dart` gates registration; `consentGiven`/`consentAt` fields on User |
| US-1501 | In-App Feedback System | `POST /api/feedback` (`feedback.controller.ts`); Flutter `FeedbackModal` accessible from `ProfileScreen` |

---

## 4. Backend Completeness

| Module | Status | Note |
|--------|--------|------|
| Auth | 🔄 Gap | Register, login, refresh, logout, forgot/reset password (link-based); OTP endpoints not yet built |
| Predictions | ✅ Solid | Expense prediction with AI + statistical fallback |
| Recommendations | ✅ Solid | AI-driven + rule-based fallback, feedback tracking |
| Education | ✅ Solid | Topics CRUD, progress tracking, completion |
| Chat | ✅ Solid | `POST /ai/chat` — Azure AI with system prompt + graceful fallback |
| Challenges | 🔄 Stub | CRUD works; no completion auto-verification logic |
| Badges | 🔄 Stub | List works; `awardIfNotEarned()` never triggered by events |
| Surveys | 🔄 Stub | Endpoints work; scoring is placeholder (no correct answers in DB) |
| Notifications | 🔄 Stub | Preferences stored; no actual FCM push delivery |
| Feedback | 🔄 Stub | `POST /feedback` works; no domain layer (direct Prisma access) |

---

## 5. Open Questions — Needed From You

### ❓ Quiz questions (US-1004 — screen 24)
The quiz screen exists as a stub. Backend quiz endpoints have not been built yet.
To implement fully I need:
- The quiz questions for each educational topic (minimum 5 multiple-choice questions per topic)
- The correct answer for each question
- Confirmation: is the quiz per topic, or a standalone section?

### ❓ Survey questions + correct answers (US-1201/US-1202)
Survey scoring is currently `answeredQuestions / total × 100` — a placeholder.
The ≥20% knowledge improvement thesis metric depends on real questions with correct answers.
To implement I need:
- 15–20 financial literacy multiple-choice questions (based on Cordova-Buiza et al., 2022 or SBS, 2022)
- The correct answer for each question so the backend can calculate an accurate score

### ❓ Firebase for push notifications (US-1101)
Notification preferences are stored. Actual FCM push delivery is not implemented.
To implement I need:
- `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) from your Firebase project
- If no Firebase project exists yet, this can be deferred to Phase 16

### ❓ Demo data readiness (Phase 16 / US-1601)
The backend has some seeded demo users. For the thesis demo to look realistic:
- Do you want me to expand the seed script to 200+ transactions/user with realistic PEN amounts, budgets, and goals?
- What is the target demo date? (Helps prioritize remaining work)

---

## 6. What Remains — Priority Order

Items listed by impact on thesis completeness. Items marked **[content needed]** are blocked on §5.

| # | Item | Effort | Impact |
|---|------|--------|--------|
| 1 | **Implement OTP forgot-password flow** (backend + Flutter `verify_code_screen.dart`) | Medium | Critical — auth flow is broken for new users |
| 2 | **Fix screen naming conflict** in `ZendaApp.pen`: rename "15 – Edit Transaction" to "16 –" and shift all subsequent numbers | Low | Medium — prevents confusion in design handoff |
| 3 | **Redesign screen 11 (Profile)** in `ZendaApp.pen` to add navigation sections matching Flutter implementation | Low | High — design and code are out of sync |
| 4 | **Design gaps 🎨1–🎨9** — targeted widget additions to existing screens | Low | High — several user stories not represented in design |
| 5 | Survey real questions + correct-answer scoring | Medium — **[content needed]** | Critical — thesis metric |
| 6 | Quiz backend endpoints + real questions | Medium — **[content needed]** | High — US-1004 |
| 7 | Challenge completion auto-verification | Medium | High — gamification |
| 8 | Badge award triggers (first transaction, streak, goal) | Medium | High — gamification |
| 9 | ~~ZendaAiCard wired to real recommendations API~~ **Done** | — | — |
| 10 | AI auto-categorization wired to `POST /transactions` + UI chip in Add Transaction | Low | Medium |
| 11 | Goal completion animation + completed section + mark-complete confirmation dialog (🎨7) | Low | Medium |
| 12 | Add Budget button in Budget screen header (🎨2) + edit/delete trigger (🎨3) | Low | Medium |
| 13 | Goal deadline display on detail screen (🎨6); date picker in create dialog now done (🎨4 ✅) | Low | Low |
| 14 | Expand demo data seed script | Low | High — Phase 16 |
| 15 | FCM push delivery | Medium — **[content needed]** | Medium — US-1101 |
| 16 | Goal completion animation | Low | Low — cosmetic |
| 17 | Budget `currentSpent` verification (backend vs local) | Low | Medium |
| 18 | Demo script (15–20 min walkthrough) | Low | High — Phase 16 |
| 19 | Technical documentation | Medium | High — Phase 16 |
| 20 | Unit + integration tests | High | High — Phase 14 / ISO 25010 |

---

## 7. Roadmap Phase Audit

Audited against `.claude/agent-os/product/roadmap.md` checkboxes and actual codebase. Status reflects code reality, not roadmap checkbox state (roadmap checkboxes are outdated).

| Phase | Title | Status | Gap summary |
|-------|-------|--------|-------------|
| 1 | Infrastructure and Setup | ✅ Done | Repo, Docker/Postgres, NestJS base, Flutter base, CI/CD config all present |
| 2 | Authentication and Users | 🔄 Partial | Register/login/JWT/refresh/logout/forgot-password/reset-password done; **lockout after 3 failures not implemented**; **OTP flow not implemented**; `financialLiteracyLevel` assignment in profile setup not wired |
| 3 | Transaction Recording | 🔄 Partial | Full CRUD + Flutter screens + edit + delete done; **dashboard balance does not refresh immediately after recording** |
| 4 | Categorization | 🔄 Partial | Full CRUD backend + Flutter `CategoryManagementScreen`; **quick-create from `AddTransactionScreen` not implemented** |
| 5 | Reports and Visualization | 🔄 Partial | Monthly/weekly/comparison summaries + Flutter tabs + category bar chart + PDF export + progress indicator all done; **Day tab added to ReportsScreen**; **"visual calendar" missing**; chart tap-drill-down and period selector not done |
| 6 | Budgets and Goals | 🔄 Partial | Budget full CRUD + Flutter done; goals full CRUD + Flutter done; **deadline date picker added**; **"Mark complete" button added**; completion animation + completed section + mark-complete confirmation dialog still missing |
| 7 | AI Integration | 🔄 Partial | `AzureFoundryProvider` fully implemented with fallback; **`classifyTransaction()` not wired to `POST /transactions`** |
| 8 | Predictions | 🔄 Partial | Expense prediction endpoint + Flutter `PredictionsScreen` done; **anomaly detection not triggered on transaction save**; retrospective accuracy tracking not implemented |
| 9 | Recommendations | ✅ Done | `GET /api/recommendations` + feedback done; Flutter `RecommendationsScreen` done; `ZendaAiCard` wired to real API |
| 10 | Education and Gamification | 🔄 Partial | Education topics CRUD + Flutter done; challenges list + accept + manual complete + Flutter done; badges list + Flutter done; **quiz endpoints missing**; **challenge auto-verification not wired**; **badges never awarded automatically**; **AI learning path missing** |
| 11 | Notifications | 🔄 Partial | Notification preferences stored; **no FCM integration**; **no budget 80% job**; **no anomaly alert trigger** |
| 12 | Pre/Post Evaluation | 🔄 Partial | Survey GET/POST + Flutter screen + improvement comparison done; **scoring is placeholder** (no correct-answer logic); **30-day invitation notification not wired** |
| 13 | Security and Compliance | 🔄 Partial | Consent screen + rate limiting done; **TLS/DB encryption deferred to cloud**; **ProGuard R8 not configured**; **AuditLog writes missing** |
| 14 | Testing and Quality | ❌ Not started | Zero test files in backend or frontend |
| 15 | Feedback and Analytics | 🔄 Partial | `POST /api/feedback` + Flutter modal done; `AnalyticsEvent` fire-and-forget in FeedbackController; **full event logging not wired** to other actions (transactions, challenges, etc.) |
| 16 | Demo Readiness | ❌ Not started | Minimal seed data; no demo script; no installation guide; no technical documentation |

---

## 8. Changes Log

| Date | Change |
|------|--------|
| 2026-04-29 | **Production-readiness + partial US implementation:** deleted 7 dead/fake service files (`lib/services/`, `local_auth_service.dart`, `ai_advice_service.dart`); implemented US-0403 Day tab in ReportsScreen; US-0502 deadline date picker in goal creation; US-0505 Mark-Complete button on goal cards; US-1002 Mark-Completed button on challenge cards; US-0204 ZendaAiCard wired to real recommendations API; US-0106 currency selector (PEN/USD) in profile edit; US-0302 quick-create "+" chip in AddTransactionScreen |
| 2026-04-29 | **Doc sync:** updated roadmap.md checkboxes (phases 5, 7–10, 12, 15); updated user_stories.md statuses and acceptance criteria for 25 stories; updated project-status.md §3, §7, §8 |
| 2026-04-29 | **Full codebase audit (Section 3 + Roadmap):** verified every user story's acceptance criteria against backend TypeScript and Flutter Dart source files; updated ❌/🔄/✅ statuses; added Roadmap Phase Audit section (§7) |
| 2026-04-29 | **Status corrections:** US-0504 promoted ❌→✅ (backend PUT/DELETE + Flutter edit dialog/delete confirmed); US-0505 reclassified ❌→🔄 (delete works, mark-complete absent); US-0403 reclassified ✅→🔄 (Flutter daily tab missing); US-0501 gap updated (FAB + per-card edit/delete confirmed, color threshold mismatch noted) |
| 2026-04-29 | **Design audit:** deep cross-reference of all 50 `.pen` frames vs 49 thesis user stories; identified 10 design gaps (🎨1–🎨10), 1 screen naming conflict, 1 auth flow design/code divergence |
| 2026-04-29 | **Design:** Password reset flow redesigned — link-based → OTP code-based. Screen 13 updated; Screen 14 (Verify Code) created; Screen 15 (Reset Password) renamed and moved |
| 2026-04-29 | **Design:** Naming conflict introduced — two screens named "15"; Edit Transaction must be renumbered 16 |
| 2026-04-26 | Initial status report generated |
| 2026-04-26 | Removed income prediction (US-0802) from entire project |
| 2026-04-26 | Removed all ML/machine-learning references — project uses Azure OpenAI API only |
| 2026-04-26 | **Implemented:** ConsentScreen (`/consent`), EmailSentScreen (`/auth/email-sent`), ProfileSetupScreen (`/profile-setup`), AiChatScreen (`/ai-chat`), QuizScreen stub (`/education/:id/quiz`) |
| 2026-04-26 | **Implemented:** Backend `POST /ai/chat` endpoint with Azure AI + fallback |
| 2026-04-26 | **Fixed:** All navigation gaps — 10 orphaned screens now reachable from ProfileScreen |
| 2026-04-26 | **Fixed:** Profile tab in Dashboard now pushes to standalone `/profile` screen |
| 2026-04-26 | **Fixed:** Feedback Modal now accessible via Profile → Send feedback |
| 2026-04-26 | **Fixed:** Registration flow: register → email-sent → profile-setup → dashboard |
| 2026-04-26 | **Fixed:** Login now redirects to `/profile-setup` if `profileCompleted == false` |
| 2026-04-26 | **Fixed:** Router enforces profile setup for unauthenticated incomplete profiles |

---

*Update this document after each implementation sprint. Source of truth: live codebase + ZendaApp.pen mockup.*
