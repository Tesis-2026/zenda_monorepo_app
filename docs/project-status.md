# Zenda — Project Status Report
**Last updated:** 2026-04-26  
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

---

## 1. Mockup Screens vs Frontend Implementation

The mockup (`ZendaApp.pen`) has **49 frames**. Current coverage:

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
| 11 – Profile | `features/profile/profile_screen.dart` — standalone screen at `/profile` |
| 12 – Categories | `features/categories/category_management_screen.dart` |
| 13 – Forgot Password | `features/auth/forgot_password_screen.dart` |
| 14 – Reset Password | `features/auth/reset_password_screen.dart` |
| 15 – Edit Transaction | `features/transactions/edit_transaction_screen.dart` |
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

All previously orphaned screens are now linked from `ProfileScreen` (`/profile`):

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

The Dashboard's Profile tab now navigates to the full `ProfileScreen` (`/profile`) instead of an inline tab.

---

## 2. Auth & Onboarding Flow

The complete first-run user journey is now implemented:

```
Splash → Onboarding (3 product slides)
       → Consent Screen (/consent)     ← Law 29733 gate
       → Register (/auth/register)
       → Email Sent (/auth/email-sent) ← Registration confirmation
       → Profile Setup (/profile-setup) ← 4-step wizard (age, university, income type, income)
       → Dashboard (/dashboard)
```

**Login flow:**
```
Login → if profileCompleted → /dashboard
      → if !profileCompleted → /profile-setup
```

The router also enforces the redirect: any authenticated user with `profileCompleted == false` going to a protected route is redirected to `/profile-setup`.

---

## 3. User Stories — What Is Left

### ❌ Not implemented

| US | Title | Phase | Points | What's needed |
|----|-------|-------|--------|---------------|
| **US-0102** | Login lockout after 3 failed attempts | 2 | 5 | Backend rate-limit counter per user; not wired |
| **US-0702** | AI Auto-Categorization | 7 | 5 | `classifyTransaction()` exists in AI provider but is never called during `POST /transactions` |
| **US-0803** | Spending Anomaly Detection | 8 | 5 | No trigger on transaction creation in backend |
| **US-1004** | Financial Knowledge Quizzes | 10 | 8 | ❓ Quiz questions/answers needed (see §5); backend quiz endpoints not yet built; frontend is a stub |
| **US-1101** | Push Notification Infrastructure | 11 | 5 | ❓ Firebase project needed (see §5); preferences UI done; no actual FCM push delivery |
| **US-1102** | Budget Alert at 80% | 11 | 5 | No scheduled job in backend |
| **US-1103** | Anomalous Spending Alert | 11 | 3 | Linked to US-0803 — no trigger |
| **US-1301** | Data Encryption (TLS + at-rest) | 13 | 5 | Deferred to cloud production deployment |
| **US-1302** | ProGuard R8 for release builds | 13 | — | `flutter_secure_storage` used for JWT ✅; R8 not configured for release |
| **US-1305** | Access Auditing to AuditLog | 13 | — | Schema exists, `DELETE /users/me` logs it, nothing else does |
| **US-1306** | Right to deletion (30-day grace) | 13 | — | `DELETE /users/me` exists; no grace-period logic |
| **US-1401** | Service Unit Tests | 14 | 8 | Zero test files in codebase |
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
| **US-0102** | Login | JWT + 401 on bad credentials | Lockout after 3 consecutive failed attempts (15 min) |
| **US-0106** | Profile Editing | `PUT /api/users/me` + edit UI (name, age, university) | Currency selector and number format selector not in profile edit view |
| **US-0201** | Record Income | Endpoint + screen done | Balance on main dashboard does not update immediately after recording |
| **US-0204** | Main Dashboard | All widgets shown | `ZendaAiCard` is static/stubbed — not wired to real recommendations API |
| **US-0302** | Custom Categories | Full CRUD backend + frontend | Quick-creation modal from inside `AddTransactionScreen` not implemented |
| **US-0401** | Monthly Summary | Endpoint + Reports screen | Response time not benchmarked (<2 sec target) |
| **US-0501** | Budget Management | Full backend + frontend CRUD | `currentSpent` and `percentageUsed` need verification that they are sourced from backend, not calculated locally |
| **US-0502** | Financial Goals | Full CRUD + contribute | Completion animation when `currentAmount >= targetAmount` not implemented |
| **US-1002** | Financial Challenge System | List + accept endpoints + frontend | Challenge **completion auto-verification** not wired — no logic marks a challenge COMPLETED based on criteria |
| **US-1003** | Badge System | List endpoint + award method + frontend grid | `awardIfNotEarned()` is never triggered — no event hooks for first transaction, streak, goal completion, etc. |
| **US-1201** | Pre-Usage Survey | Backend endpoint + Flutter survey screen | ❓ Survey scoring is a **placeholder** (`answers / total × 100`). Real questions + correct answers needed (see §5) |
| **US-1202** | Post-Usage Survey | Backend endpoint + Flutter survey screen | Same placeholder scoring issue |
| **US-1601** | Demo Data Script | Some demo users seeded in backend | Need 200+ transactions/user, active budgets, goals, completed surveys |

---

### ✅ Done — meets acceptance criteria

| US | Title |
|----|-------|
| US-1801 | Repository and Project Structure |
| US-0101 | User Registration |
| US-0103 | Authentication Middleware (JWT guard) |
| US-0104 | Password Recovery (forgot-password + reset-password) |
| US-0105 | Initial Profile Setup — onboarding flow with 4-step wizard *(newly implemented)* |
| US-0203 | Transaction History with Filters |
| US-0205 | Edit Transaction |
| US-0206 | Delete Transaction |
| US-0301 | Default Categories (seed) |
| US-0302 | Custom Categories (CRUD backend + frontend) |
| US-0402 | Weekly Summary (backend endpoint) |
| US-0403 | Daily Summary (backend endpoint) |
| US-0404 | Monthly Comparison (backend endpoint) |
| US-0405 | Charts by Category (frontend) |
| US-0406 | PDF Export |
| US-0407 | Financial Progress Indicator |
| US-0503 | Detailed Goal Tracking (chart + projection) |
| US-0701 | Azure AI API Integration |
| US-0801 | Expense Prediction |
| US-0901 | Recommendation Engine |
| US-0902 | Feedback Tracking (recommendations) |
| US-1001 | Educational Content Module |
| US-1203 | Educational Improvement Calculation |
| US-1303 | Data Consent — standalone screen + Law 29733 gate *(newly implemented)* |
| US-1501 | In-App Feedback System — accessible via Profile → Send feedback *(newly implemented)* |

---

## 4. Backend Completeness

| Module | Status | Note |
|--------|--------|------|
| Auth | ✅ Solid | Register, login, refresh, logout, forgot/reset password |
| Predictions | ✅ Solid | Expense prediction with AI + statistical fallback |
| Recommendations | ✅ Solid | AI-driven + rule-based fallback, feedback tracking |
| Education | ✅ Solid | Topics CRUD, progress tracking, completion |
| Chat | ✅ Solid | `POST /ai/chat` — Azure AI with system prompt + graceful fallback *(newly implemented)* |
| Challenges | 🔄 Stub | CRUD works; no completion auto-verification logic |
| Badges | 🔄 Stub | List works; `awardIfNotEarned()` never triggered by events |
| Surveys | 🔄 Stub | Endpoints work; scoring is placeholder (no correct answers in DB) |
| Notifications | 🔄 Stub | Preferences stored; no actual FCM push delivery |
| Feedback | 🔄 Stub | `POST /feedback` works; no domain layer (direct Prisma access) |

---

## 5. Open Questions — Needed From You

These items are blocked until you provide content or make a decision.

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
| 1 | Survey real questions + correct-answer scoring | Medium — **[content needed]** | Critical — thesis metric |
| 2 | Quiz backend endpoints + real questions | Medium — **[content needed]** | High — US-1004 |
| 3 | Challenge completion auto-verification | Medium | High — gamification |
| 4 | Badge award triggers (first transaction, streak, goal) | Medium | High — gamification |
| 5 | ZendaAiCard wired to real recommendations API | Low | High — dashboard differentiator |
| 6 | Expand demo data seed script | Low | High — Phase 16 |
| 7 | AI auto-categorization wired to POST /transactions | Low | Medium — method already exists |
| 8 | FCM push delivery | Medium — **[content needed]** | Medium — US-1101 |
| 9 | Goal completion animation | Low | Low — cosmetic |
| 10 | Budget `currentSpent` verification (backend vs local) | Low | Medium |
| 11 | Demo script (15–20 min walkthrough) | Low | High — Phase 16 |
| 12 | Technical documentation | Medium | High — Phase 16 |
| 13 | Unit + integration tests | High | High — Phase 14 / ISO 25010 |

---

## 7. Changes Log

| Date | Change |
|------|--------|
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
