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
| **B9** | Decouple `insights` repo from `goals` | Backend (ACL facade between insights and goals) | Medium | M (~4h) | ⚫ Superseded by B19 (2026-05-24) — ARCH-17 generalizes the same problem to 8+ module pairs |
| **B10** | Frontend `TransactionModel` AI tracking | Frontend (add `suggestedCategoryId`/`aiConfidence`/`categorySource` to model + API parser) | Low | S (~2h) | ⚪ Pending — see ARCH-11 |
| **B11** | Frontend `User` model security/consent fields | Frontend (add `failedLoginAttempts`/`lockedUntil`/`consentGiven`/`consentAt`/`notificationPrefs`) | Low | S (~2h) | ⚪ Pending — see ARCH-12. **Blocked by B14** (no wire format for lockout). |
| **B12** | Backend `RecommendationResponseDto` lifecycle fields | Backend (expose `viewedAt`/`dismissedAt`/`expiresAt`/`feedbackAt`/`modelVersion`/`source`/`inputContextJson` + matching frontend parser) | Low | S (~2h) | ⚪ Pending — see ARCH-09 |
| **B13** | Refactor `notifications.controller.ts` into DDD | Backend (introduce `NotificationPreferencesService` + use case wrapper; controller stops calling Prisma directly) | Low | M (~3h) | ⚪ Pending — see ARCH-03 (partial) |
| **B14** | Auth wire format for lockout state | Backend (add error body schema to 401 with `failedAttempts`/`lockedUntil`, OR add `/auth/me` exposing lockout) | Medium | M (~4h) | ⚪ Pending — see ARCH-10. Unblocks B11. |
| **B15** | Regenerate `docs/zenda-schema.sql` from Prisma | Docs (`npx prisma migrate diff --from-empty --to-schema-datamodel --script > docs/zenda-schema.sql`) | Minimal | XS (~30min) | ⚪ Pending — see ARCH-08 |
| **B16** | `CategoryResponseDto` add `transactionType` | Backend (DTO + mapper + frontend `CategoryModel` parser) | Low | XS (~30min) | ⚪ Pending — see ARCH-14 |
| **B17** | `PredictionEntity` + DTO add `confidenceInterval` | Backend (entity field, mapper from JSON column, DTO, frontend parser) — **also closes ARCH-04** if same refactor untangles the `modelVersion` packed columns | Medium | M (~4h) | ⚪ Pending — see ARCH-15. Promotes ARCH-04 from "out of scope" to "addressed together". |
| **B18** | `BudgetResponseDto` remove `deletedAt` (UX-06 regression fix) | Backend (DTO + mapper) | Minimal | XS (~15min) | ⚪ Pending — see ARCH-16 |
| **B19** | Cross-context ACL facades | Backend (introduce facade tokens for `BadgesModule`, `ChallengesModule`, `CategoriesModule`, `AuthModule`; stop direct module imports). **Supersedes B9** (insights→goals becomes one of N cases) | High | XL (~2d) | ⚪ Pending — see ARCH-17 |
| **B20** | `SubmitQuizDto` bounds + key validation | Backend (`@ArrayMaxSize`/custom validator constraining keys to known question IDs) | Minimal | XS (~30min) | ⚪ Pending — see ARCH-18 |
| **B21** | JWT payload + guard hardening | Backend (add `consentGiven` to payload; custom JWT strategy that re-checks `deletedAt` OR uses `tokenVersion` field on user) | Medium | M (~4h) | ⚪ Pending — see ARCH-19, ARCH-20 |
| **B22** | Prisma error mapping in `GlobalExceptionFilter` | Backend (translate P2002/P2025/P2003 to 409/404/400; remove per-use-case manual catches) | Low | S (~2h) | ⚪ Pending — see ARCH-21 |
| **B23** | Swagger `@ApiResponse` coverage | Backend (add success + error response schemas across all controllers; standardize error body) | Low | M (~6h) | ⚪ Pending — see ARCH-22 |
| **B24** | Env config validation at boot | Backend (Joi/zod schema or `class-validator` on `configuration.ts`; switch `process.env.X` to `configService.getOrThrow`) | Low | M (~3h) | ⚪ Pending — see ARCH-23. Compose with `.env.example` review. |
| **B25** | `User.tokenVersion` + JWT version claim | Backend (schema migration + auth use cases + guard) — closes ARCH-24, partially helps ARCH-20 | Medium | M (~4h) | ⚪ Pending — see ARCH-24 |
| **B26** | Request log redaction + response-side logging | Backend (extend `RequestLoggingInterceptor` to strip `password`, `Authorization`, `token` patterns from path/headers; log response status + size) | Low | S (~2h) | ⚪ Pending — see ARCH-25 |
| **B27** | Audit log writer (cross-cutting) | Backend (interceptor or decorator on mutation use cases; populate `AuditLog.before_json/after_json/request_id` for CRUD on Transaction/Budget/Goal/Category + auth events) | Medium-High | L (~1d) | ⚪ Pending — see ARCH-26. **Builds on B8** which created the `audit-events` module. |
| **B28** | Idempotency-Key support | Backend (DTO header + dedup table or Redis cache + middleware on POST routes); also frontend `api_client.dart` sends keys on retryable POSTs | Medium | M (~6h) | ⚪ Pending — see ARCH-27 |
| **B29** | Production Dockerfile + multi-stage build | Backend (`Dockerfile` with build stage + runtime stage; `.dockerignore`; document run/health/restart) | Low | S (~2h) | ⚪ Pending — see ARCH-28 |
| **B30** | `@Throttle` on remaining POST endpoints | Backend (Transactions/Budgets/Goals POST: standard limits; AI `/chat`: stricter — e.g., 10/min per user) | Minimal | XS (~30min) | ⚪ Pending — see ARCH-29 |
| **B31** | Health endpoint with DB ping + `/ready` | Backend (use `@nestjs/terminus` or simple `prisma.$queryRaw` ping in `/health`; add `/ready` checking deps; keep `/live` trivial) | Low | S (~2h) | ⚪ Pending — see ARCH-30 |
| **B32** | Update phase-2 spec path | Docs (replace `lib/features/auth/local_auth_service.dart` references with `lib/core/services/api_client.dart`; bundle with next phase spec refresh) | Minimal | XS (~15min) | ⚪ Pending — see ARCH-31 |

**Legend:** ⚪ Pending · 🟡 In Progress · 🟢 Done · 🔴 Blocked

**Note on B19 vs B9:** ARCH-17 generalizes the cross-context coupling problem to 8+ module pairs. B9 (originally just insights→goals) is **subsumed by B19**; the insights→goals case becomes one of the facades introduced by B19. Marking B9 as **superseded**; tracking shifts to B19.

**Note on B19 vs B9:** ARCH-17 generalizes the cross-context coupling problem to 8+ module pairs. B9 (originally just insights→goals) is **subsumed by B19**; the insights→goals case becomes one of the facades introduced by B19. Marking B9 as **superseded**; tracking shifts to B19.

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

### B10–B15 (added 2026-05-24 after ERD/contract deep-audit)

Each batch maps 1:1 to an entry in `docs/audit-issues.md` (ARCH-08 … ARCH-12). See the issues file for the file:line evidence.

**Suggested execution order** (low risk first, dependencies respected):

1. **B15** (regenerate SQL schema) — 30 min, no risk, unblocks documentation accuracy.
2. **B10** (TransactionModel AI fields) — 2h, isolated, unlocks the AI-accuracy KPI display.
3. **B12** (RecommendationResponseDto + parser) — 2h, isolated.
4. **B14** (auth wire format for lockout) — backend-first, 4h. Unblocks B11.
5. **B11** (User model security fields) — 2h, depends on B14.
6. **B13** (NotificationPreferences DDD) — 3h, isolated backend cleanup.

Original-plan pending (kept):
7. **B9** (insights → goals ACL) — 4h.
8. **B5** (setState → Riverpod) — 6h. Recommended after B11 so the new lockout fields flow through Riverpod.
9. **B7** (extract surveys/conversations modules) — 1.5d, highest risk; do last.

**Out of scope for this plan** (tracked in `audit-issues.md` only):
- ARCH-05 (`SavingsGoal.completedAt`)
- ARCH-06 (OCR stub)
- ARCH-07 (sync retry/backoff)
- GAP-01 (FCM)
- GAP-03 / GAP-04 (prediction accuracy + Predictor badge trigger)
- GAP-05 (test coverage)
- GAP-06 (demo readiness)

**Note:** ARCH-04 was originally out of scope, but B17 will need to refactor the packed `modelVersion` column to make room for `confidenceInterval`, so it's now bundled with B17.

### B10–B18 — recommended order (updated 2026-05-24, post fourth-tier audit)

Re-prioritized after finding ARCH-14, -15, -16 in the fourth-tier audit. The "quick wins" pool is bigger than first thought.

**Tier 1 — XS quick wins (under 1h each, zero risk):**
1. **B15** (regenerate SQL) — 30 min
2. **B18** (remove `deletedAt` from `BudgetResponseDto`) — 15 min, UX-06 regression
3. **B16** (`CategoryResponseDto.transactionType`) — 30 min

**Tier 2 — S/M model alignment (1h–4h):**
4. **B12** (`RecommendationResponseDto` + 8 missing fields + frontend parser) — 2h
5. **B10** (`TransactionModel` AI fields) — 2h
6. **B17** (prediction `confidenceInterval` + ARCH-04 untangling) — 4h
7. **B14** (auth wire format for lockout) — 4h (unblocks B11)
8. **B11** (`User` model security fields) — 2h, depends on B14
9. **B13** (notifications controller → DDD) — 3h

**Tier 3 — Security/ops quick wins (6th-pass additions, mostly XS-S):**
10. **B20** (`SubmitQuizDto` bounds) — 30 min, security quick win
11. **B30** (`@Throttle` remaining POST + AI chat) — 30 min, hardening quick win
12. **B22** (Prisma error mapping) — 2h
13. **B26** (request log redaction + status) — 2h
14. **B29** (production Dockerfile) — 2h
15. **B24** (env config validation at boot) — 3h
16. **B31** (health endpoint with DB ping + `/ready`) — 2h
17. **B21** (JWT hardening: `consentGiven` + soft-delete check) — 4h
18. **B25** (`User.tokenVersion` for session invalidation) — 4h
19. **B23** (Swagger `@ApiResponse` sweep) — 6h
20. **B28** (Idempotency-Key support) — 6h

**Tier 4 — Larger structural work (1d+):**
21. **B27** (audit log writer cross-cutting) — 1d
22. **B5** (setState → Riverpod) — 6h, do after B11
23. **B19** (cross-context ACL facades — supersedes B9) — 2d
24. **B7** (extract surveys + conversations modules) — 1.5d, highest risk; last

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
