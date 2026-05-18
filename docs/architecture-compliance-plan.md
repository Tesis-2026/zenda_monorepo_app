# Architecture Compliance Plan

Tracking doc for refactor batches that align the Zenda backend and frontend with the documented architecture (DDD + layered for backend; feature-based + Riverpod for frontend).

> Baseline audit date: **2026-05-17**
> Initial compliance: Backend ~65%, Frontend ~85% (mostly mechanical drift)
> Target compliance: **>=95%** after all batches.

---

## Authoritative rules

| Area | Source |
|------|--------|
| Backend DDD + layering | `skills/platform/platform-backend/domain-driven-design-nestjs/SKILL.md` |
| Backend Prisma patterns | `skills/_drafts/framework/tech-prisma/SKILL.md` |
| Backend general | `skills/platform/platform-backend/SKILL.md` |
| Frontend Flutter + Riverpod | `skills/platform/platform-mobile/flutter/SKILLS.md` |
| Project conventions | `CLAUDE.md` |

---

## Findings summary

### Backend critical violations
- 3 repositories query categories without `deletedAt: null` filter (data leak risk).
- 2 use cases import `PrismaService` directly (violates DDD layer rule).
- 1 module imports another module directly instead of using an ACL facade.
- `LoginUseCase` calls `AnalyticsService` (cross-cutting responsibility leak).

### Backend orphan entities (schema vs code)
- `UserFinancialProgress` — model exists, no module yet (just added 2026-05-17).
- `AiConversation` / `AiMessage` — live inside `recommendations`, should have own context.
- `Survey` / `SurveyResponse` — module folder exists but is empty.
- `AnalyticsEvent` / `AuditLog` / `Feedback` — no modules (orphan).
- `AuthChallenge` — lives inside auth, not formally separated.

### Frontend drift
- Multiple screens instantiate `ApiService()` directly inside widgets (should use Riverpod providers).
- `setState` used for business logic state (should be Riverpod) in ~6 screens.
- `Navigator.pop()` used in 12 files instead of `context.pop()` (GoRouter).
- 1 hardcoded UI string (`ai_chat_screen.dart`) not in ARB files.

### Already compliant
- Backend modules: auth, budgets, categories, transactions, goals, users.
- Frontend: feature-based folder structure, light-only theme, models in `core/models/`, no legacy `lib/services/`.

---

## Batches

Each batch ships as one commit on its own branch with PR to `develop`.

| # | Batch | Scope | Risk | Effort | Status |
|---|-------|-------|------|--------|--------|
| **B1** | Soft-delete filters on category queries | Backend repos (predictions, insights, recommendations) | Minimal | S (~1h) | 🟢 Done (2026-05-17) |
| **B2** | Consolidate service providers | Frontend (eliminate `ApiService()` in widgets) | Low | M (~4h) | 🟢 Done (2026-05-17) |
| **B3** | `Navigator.pop` → `context.pop` + i18n cleanup | Frontend (16 files + 1 ARB key) | Low | S (~2h) | 🟢 Done (2026-05-17) |
| **B4** | Remove `PrismaService` from use cases | Backend (`challenges`, `education` → new repo ports) | Medium | M (~1d) | 🟢 Done (2026-05-17) |
| **B5** | Migrate `setState` business logic to Riverpod | Frontend (`ai_chat`, login lockout, quiz) | Medium | L (~6h) | ⚪ Pending |
| **B6** | Create `financial-progress` module | Backend (wire `UserFinancialProgress` entity into DDD layers) | Medium | M (~4h) | 🟢 Done (2026-05-17) |
| **B7** | Extract `surveys` module + new `conversations` module | Backend (move `AiConversation/Message` out of recommendations; fill empty surveys module) | Medium-High | L (~1.5d) | ⚪ Pending |
| **B8** | Cross-cutting `audit-events` module + extract analytics from LoginUseCase | Backend (`AnalyticsEvent`, `AuditLog`, `Feedback`) | Medium | M (~6h) | 🟢 Done (2026-05-18) — scope narrowed (see notes) |
| **B9** | Decouple `insights` repo from `goals` | Backend (ACL facade between insights and goals) | Medium | M (~4h) | ⚪ Pending |

**Legend:** ⚪ Pending · 🟡 In Progress · 🟢 Done · 🔴 Blocked

---

## Detailed scope per batch

### B1 — Soft-delete filters on category queries

**Files affected:**
- `zenda_backend_app/src/modules/predictions/infrastructure/persistence/prisma-prediction.repository.ts:107`
- `zenda_backend_app/src/modules/insights/infrastructure/persistence/prisma-insights.repository.ts:115`
- `zenda_backend_app/src/modules/recommendations/infrastructure/persistence/prisma-recommendation.repository.ts:95`
- `zenda_backend_app/src/modules/badges/infrastructure/persistence/*badge.repository.ts` (verify all queries)

**Change:** add `deletedAt: null` to every `where` clause that queries the `Category` model (and `Badge` where applicable).

**Validation:** `npx prisma validate` + `npx tsc --noEmit` clean.

### B2 — Consolidate service providers (frontend)

**Files affected (screens to refactor):**
- `lib/features/auth/screens/verify_code_screen.dart`
- `lib/features/auth/screens/{login,register,forgot_password}_screen.dart`
- `lib/features/budget/screens/budget_screen.dart`
- `lib/features/goals/screens/goals_screen.dart`
- `lib/features/dashboard/providers/dashboard_providers.dart`
- `lib/features/education/screens/{education,personalized_quiz}_screen.dart`
- `lib/features/surveys/screens/survey_comparison_screen.dart`
- `lib/features/transactions/screens/{add,edit}_transaction_screen.dart`
- `lib/features/transactions/controllers/new_transaction_controller.dart`
- `lib/features/feedback/widgets/feedback_modal.dart`
- `lib/features/categories/screens/category_management_screen.dart`
- `lib/features/notifications/screens/notification_preferences_screen.dart`

**Change:** every `ApiService()` instantiation inside a widget or non-provider file must be replaced with a Riverpod `Provider<...>` declared in `lib/providers/services_providers.dart` (or per-feature `providers/` folder) and consumed via `ref.read(...)` / `ref.watch(...)`.

**Validation:** `flutter analyze` clean.

### B3 — Navigation + i18n cleanup

**Files affected:** see audit report (12 files using `Navigator.pop`); `ai_chat_screen.dart:29-33` (extract to ARB).

**Change:** swap `Navigator.pop(context)` → `context.pop()`; add `aiChatWelcomeDemo` ARB key to `app_en.arb` + `app_es.arb`; run `flutter gen-l10n`.

### B4–B9

See audit findings (above) for full scope. To be detailed when each batch is scheduled.

---

## Workflow per batch

1. Pre-audit (`tsc --noEmit` + `flutter analyze`) — confirm clean baseline.
2. Branch off `develop`: `refactor/<batch-id>-<short-desc>`.
3. Apply changes.
4. Post-audit — must equal pre-audit (no new errors).
5. Commit using conventional commit format.
6. Open PR to `develop`; merge after self-review.
7. Update this doc: status column, link to PR.

---

## PR log

| Batch | PR | Merged | Notes |
|-------|----|--------|-------|
| B1 + B2 | backend#14 · frontend#13 · root#15 | 2026-05-17 | Bundled — both low risk. `Badge` model has no `deletedAt`, so B1 ended up touching 3 repos (predictions, insights, recommendations) instead of 4. New `lib/providers/services_providers.dart` introduced for `authApiServiceProvider`, `feedbackApiServiceProvider`, `insightsApiServiceProvider`. 8 widget/handler call-sites refactored to consume providers via `ref.read`. |
| B3 | frontend#14 | 2026-05-17 | 16 files migrated to `context.pop()` / `ctx.pop()`. `lib/core/widgets/delete_confirm_sheet.dart` intentionally kept on `Navigator.pop` (low-level reusable widget should stay GoRouter-agnostic). 7 files gained the `go_router` import. `aiChatWelcomeDemo` extracted to ARB; `_ChatBubble` gained `isWelcome` flag to filter the welcome message from API history without string equality. |
| B6 | backend#15 | 2026-05-17 | Full DDD module under `src/modules/financial-progress/` with all 4 layers, plus `IFinancialProgressRepository` exported for the future aggregation job. Exposes `GET /api/financial-progress` and `GET /api/financial-progress/current`. The job that *populates* snapshots is intentionally out of scope and will be a follow-up. |
| B4 | backend#16 | 2026-05-17 | New `IChallengeVerificationPort` (challenges) + `IPersonalizedQuizContextPort` (education) replace direct `PrismaService` usage in `VerifyChallengesUseCase` and `GetPersonalizedQuizUseCase`. Drive-by fix: `deletedAt: null` filter added to the category hydration inside `PrismaPersonalizedQuizContextRepository` that the original use case was missing. Zero `PrismaService` references remain in any `application/` layer. |
| B8 | backend#17 | 2026-05-18 | Scope narrowed: `AnalyticsEvent` and `AuditLog` already live behind cross-cutting infra services (`AnalyticsService` + the request-logging interceptor), so they did not need new modules. Actions taken: (1) `Feedback` extracted from `education/` into its own `src/modules/feedback/` bounded context with full DDD layout — the old controller imported `PrismaService` directly which was a layer violation. (2) `AnalyticsService` removed from `LoginUseCase`, `RegisterUseCase`, and `GetPersonalizedQuizUseCase`; tracking now happens in their controllers. Public APIs unchanged. Zero `AnalyticsService` references remain in any `application/` layer. |
