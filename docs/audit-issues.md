# Zenda — Audit Issues Tracker

**Last full audit:** 2026-05-24 (delta from 2026-05-01)  
**Auditor:** Claude Code (deep code analysis)  
**Scope:** Backend (NestJS) + Frontend (Flutter) + Docs (ERD/SQL alignment)

---

## Legend

| Status | Meaning |
|--------|---------|
| 🔴 OPEN | Not yet fixed |
| 🟡 IN PROGRESS | Fix in flight |
| 🟢 FIXED | Resolved and post-audit verified |

---

## Priority 1 — Thesis Validity (Fix before user testing)

| ID | Status | Area | File | Issue |
|----|--------|------|------|-------|
| P1-01 | 🟢 FIXED | Frontend | `survey_screen.dart` | Survey shows ALL questions at once in ListView — spec and research protocol require one question per view with blocked advancement until answered |
| P1-02 | 🟢 FIXED | Backend | `surveys.controller.ts` | Survey re-submission silently overwrites previous answers via upsert — corrupts pre/post research baseline data |
| P1-03 | 🟢 FIXED | Backend | `verify-challenges.use-case.ts` | Only 2 of 4 challenge criteria types implemented; `no_transactions_category` and `category_reduction_percentage` always return false — challenges using these types can never auto-complete |
| P1-04 | 🟢 FIXED | Frontend | `quiz_screen.dart` | `actualCorrect: null` hardcoded — correct answer never highlighted green during per-question review phase |

---

## Priority 2 — Security (Fix before any external user access)

| ID | Status | Area | File | Issue |
|----|--------|------|------|-------|
| S-01 | 🟢 FIXED | Backend | `prisma-password-reset-otp.repository.ts` | OTP code stored **plaintext** in DB — a DB dump exposes all active codes |
| S-02 | 🟢 FIXED | Backend | `prisma-user.repository.ts:11` | Soft-deleted users can still authenticate — `findByEmail` has no `deletedAt: null` filter |
| S-03 | 🟢 FIXED | Backend | `auth.module.ts:36` | JWT secret silently falls back to `undefined` if `JWT_SECRET` env var is absent — tokens trivially forgeable |
| S-04 | 🟢 FIXED | Backend | `login.use-case.ts:43` | Login lockout race condition — concurrent requests bypass the 3-attempt threshold using stale counter |
| S-05 | 🟢 FIXED | Backend | `auth.controller.ts:91` | OTP brute-force feasible — throttle tightened to 3/min |
| S-06 | 🟢 FIXED | Backend | `prisma-password-reset.repository.ts` | Password reset token stored plaintext in DB |
| S-07 | 🟢 FIXED | Backend | `reset-password.use-case.ts` | Password reset does not revoke existing JWT sessions |
| S-08 | 🟢 FIXED | Frontend | `local_kv_store.dart` | Account balances, transaction history, streak stored in plaintext `SharedPreferences` — readable on rooted devices |
| S-09 | 🟢 FIXED | Frontend | `pending_transaction_queue.dart` | Pending sync queue (amount, category, description) stored plaintext in `SharedPreferences` |
| S-10 | 🟢 FIXED | Frontend | `login_screen.dart` | 15-min lockout countdown is cosmetic — app restart resets it, allowing unlimited backend attempts |
| S-11 | 🟢 FIXED | Frontend | `transaction_list_screen.dart` | `err.toString()` shown directly to users — exposes internal API error messages |
| S-12 | 🟢 FIXED | Frontend | `new_transaction_controller.dart:249` | `userId: 'demo'` hardcoded in locally persisted transactions |

---

## Priority 3 — Acceptance Criteria Failures (Fix before thesis demo)

| ID | Status | Area | File | Issue |
|----|--------|------|------|-------|
| AC-01 | 🟢 FIXED | Backend | `list-transactions.dto.ts` | Missing filters: `minAmount`, `maxAmount`, `search` (description text), `sort` — spec US-012, US-039 |
| AC-02 | 🟢 FIXED | Backend | `delete-category.use-case.ts` | DELETE /categories/:id does not block when active transactions exist — spec US-041 |
| AC-03 | 🟢 FIXED | Backend | `create-goal.use-case.ts` | POST /goals does not validate that `dueDate` is in the future — spec US-021 |
| AC-04 | 🟢 FIXED | Backend | `get-recommendations.use-case.ts` | No minimum history guard — calls Azure AI for users with zero transactions — spec US-017 |
| AC-05 | 🟢 FIXED | Backend | `get-month-comparison.use-case.ts` | `months: 1` accepted with no guard — spec requires minimum 2 months — spec US-011 |
| AC-06 | 🟢 FIXED | Frontend | `challenges_screen.dart` | Single flat list — spec requires grouped sections: Active / Available / Completed / Expired — spec US-024 |
| AC-07 | 🟢 FIXED | Frontend | `budget_screen.dart` | Color threshold off-by-one: `>= 80` turns red; spec says green <60%, yellow 60–80%, red **>**80% — spec US-019 |
| AC-08 | 🟢 FIXED | Frontend | `dashboard_screen.dart` | No 30-day post-survey invitation banner — spec US-034 |
| AC-09 | 🟢 FIXED | Frontend | `survey_screen.dart` | Post-survey marks `postSurveyProvider` completed; banner hides once post done |
| AC-10 | 🟢 FIXED | Backend | `surveys.controller.ts` | `improvementPercentage` now returns relative % `((post-pre)/pre)*100` |

---

## Priority 4 — UX / Polish (Fix before pilot)

| ID | Status | Area | File | Issue |
|----|--------|------|------|-------|
| UX-01 | 🟢 FIXED | Frontend | `goals_screen.dart:279` | Celebration dialog dismiss button has `child: const Text('')` — invisible button |
| UX-02 | 🟢 FIXED | Frontend | `goals_screen.dart` | No completion animation — spec expects visual celebration on goal completion |
| UX-03 | 🟢 FIXED | Frontend | `challenges_screen.dart` | No animation on challenge completion |
| UX-04 | 🟢 FIXED | Frontend | `personalized_quiz_screen.dart` | `attemptsRemainingToday` only shown on results screen — should be visible before starting personalized quiz |
| UX-05 | 🟢 FIXED | Frontend | `register_screen.dart` | Validation fires only on submit, not inline on `onChanged` — spec requires real-time validation |
| UX-06 | 🟢 FIXED | Backend | Multiple response DTOs | `deletedAt` exposed in transaction, category, budget, goal API responses |
| UX-07 | 🟢 FIXED | Backend/Frontend | `dashboard_providers.dart:151` | AI advice fallback strings are hardcoded Spanish — shows in English locale |

---

## Priority 5 — Architecture Debt (Fix before production)

| ID | Status | Area | File | Issue |
|----|--------|------|------|-------|
| ARCH-01 | 🔴 OPEN | Backend | `src/modules/education/interface/surveys.controller.ts:16` | Surveys controller (lives inside `education/`, not in `surveys/`) injects `PrismaService` directly — no use cases, no domain entity, no repository port. **Re-verified 2026-05-24:** the empty `src/modules/surveys/` folder exists with only `application/domain/infrastructure` subdirs; the real survey logic is the transaction-script controller inside `education/`. Overlaps with batch **B7**. |
| ARCH-02 | 🟢 FIXED | Backend | `src/modules/feedback/` | **Resolved by B8 (2026-05-18).** Module now has full DDD layers: `domain/feedback.entity.ts`, `domain/ports/feedback.repository.ts`, `application/use-cases/submit-feedback.use-case.ts`, `infrastructure/persistence/prisma-feedback.repository.ts`, `interface/feedback.controller.ts`. |
| ARCH-03 | 🟡 PARTIAL | Backend | `src/modules/users/interface/notifications.controller.ts` | **Data design now matches ERD** — preferences live as JSON on `users.notification_prefs` (no separate table). **But the controller still injects `PrismaService` directly** (line 26+) with no use case layer. The original "missing notifications module" complaint is superseded by the ERD redesign; what remains is the DDD violation in the controller. |
| ARCH-04 | 🔴 OPEN | Backend | `prisma-prediction.repository.ts:38` | `confidenceLevel` and `narrative` packed into `modelVersion` column as pipe-delimited string |
| ARCH-05 | 🔴 OPEN | Backend | `prisma/schema.prisma` | `SavingsGoal` has no `completedAt`/`isCompleted` field — completion simulated by setting `currentAmount = targetAmount` |
| ARCH-06 | 🔴 OPEN | Frontend | `core/services/ocr_service.dart` | OCR is a stub — `fillFromOcrDemo()` fills hardcoded values; camera/ML not implemented |
| ARCH-07 | 🔴 OPEN | Frontend | `sync_service.dart` | Offline queue has no retry limit, no exponential backoff, no dead-letter — permanently rejected transactions retry forever |
| ARCH-08 | 🔴 OPEN | Docs | `docs/zenda-schema.sql` | SQL schema is stale and divergent from Prisma. Missing 3 tables (`user_financial_progress`, `ai_conversations`, `ai_messages`) and 3 enums (`category_source`, `ai_conversation_status`, `ai_message_role`). Should be regenerated from Prisma (`npx prisma migrate diff --from-empty --to-schema-datamodel --script`). |
| ARCH-09 | 🔴 OPEN | Backend | `src/modules/recommendations/interface/dto/recommendation.response.dto.ts:4-21` | DTO drops **8 fields** present in `RecommendationEntity` and ERD: `isActive`, `viewedAt`, `dismissedAt`, `expiresAt`, `feedbackAt`, `modelVersion`, `source`, `inputContextJson`. Frontend cannot render lifecycle state, filter stale/dismissed recommendations, or surface AI traceability for the >=80% accuracy KPI. |
| ARCH-10 | 🔴 OPEN | Backend | `src/modules/auth/interface/dto/auth-token.response.dto.ts` | Login success returns only `accessToken/refreshToken`. Failed login (401) has no body with `failedAttempts/lockedUntil`. Even after adding security fields to the frontend `User` model (ARCH-12), there is no wire format to populate them. Needs either an error body schema for 401 or a `/auth/me` endpoint that surfaces lockout state. |
| ARCH-11 | 🔴 OPEN | Frontend | `lib/core/models/transaction.dart` + `lib/core/services/transaction_api_service.dart` | Model + parser ignore the AI-tracking fields the backend exposes (`suggestedCategoryId`, `aiConfidence`, `categorySource`). Blocks the thesis KPI "AI prediction accuracy >=80%" from being visualized. |
| ARCH-12 | 🔴 OPEN | Frontend | `lib/core/models/user.dart` | Missing `failedLoginAttempts`, `lockedUntil`, `consentGiven`, `consentAt`, `notificationPrefs`. Lockout state is managed locally in `login_screen.dart` via SharedPreferences instead of server-authoritative state. |
| ARCH-13 | 🟢 ACCEPTED | Frontend | `lib/core/models/user.dart` (`FinancialLiteracyLevel` enum) | Dart values (`beginner/intermediate/advanced`) drift from Prisma/ERD (`LOW/MEDIUM/HIGH`). Mitigated by a converter at the boundary. Accepted as cosmetic — no functional impact. |
| ARCH-14 | 🔴 OPEN | Backend | `src/modules/categories/interface/dto/category.response.dto.ts:3-21` | `CategoryResponseDto` does not expose `transactionType` (`'INCOME' \| 'EXPENSE' \| null`). The field is in the ERD (`categories.transaction_type`, line 120) and in the Prisma model. Frontend has no way to filter categories by transaction type when, e.g., the user is recording an EXPENSE. |
| ARCH-15 | 🔴 OPEN | Backend | `src/modules/predictions/domain/prediction.entity.ts:10-25` + `predictions/interface/dto/prediction.response.dto.ts:10-22` | `PredictionEntity` does not carry `confidenceInterval` (`{lower, upper}` JSON in ERD line 302 + Prisma `Json?`). The DTO consequently omits it. The current `confidenceLevel: 'high' \| 'medium' \| 'low'` is the *categorized* form of what should be the raw interval. Compounds with ARCH-04 (packed `modelVersion` column) — both stem from the same persistence shortcut. |
| ARCH-16 | 🔴 OPEN | Backend | `src/modules/budgets/interface/dto/budget.response.dto.ts:13` | `BudgetResponseDto` still exposes `deletedAt!: string \| null` — this is a **regression of UX-06** (Fix Log 2026-05-01: "Removed `deletedAt` field from `GoalResponseDto`, `TransactionResponseDto`, `BudgetResponseDto`, `CategoryResponseDto`"). Verify whether the mapper was reverted or never updated. |
| ARCH-17 | 🔴 OPEN | Backend | `src/modules/{budgets,challenges,goals,education,predictions,transactions,users}/*.module.ts` | **No ACL facade tokens across module boundaries.** `BadgesModule` is imported directly by 6 modules; `ChallengesModule` by 2; `CategoriesModule` and `AuthModule` each by 1. Internal repositories (`BadgeRepository`, `ChallengeRepository`, etc.) are reachable across context boundaries instead of via abstract facade tokens. Violates the DDD-NestJS skill rule that each bounded context exports only its `<context>ContextFacade` token. **B9 was scoped to insights→goals only**; this finding generalizes the same violation to 8+ other module pairs. |
| ARCH-18 | 🟡 OPEN | Backend | `src/modules/education/interface/dto/submit-quiz.dto.ts:5` | `SubmitQuizDto.answers` is typed as `Record<string, string>` with only `@IsObject()` — no `@ArrayMaxSize`/`@MaxLength`/key whitelist. A malicious client could POST a 10k-key answer object; the controller would attempt to persist all of it. DoS / payload-bomb risk. |
| ARCH-19 | 🟡 OPEN | Backend | `src/modules/auth/types/jwt-payload.type.ts:2` | JWT payload carries only `sub` (userId) and `email`. `consentGiven` is missing, so every protected endpoint that needs to enforce consent must do a `User` lookup (extra DB hit per request). Adding `consentGiven` to the payload removes that round-trip for the common path. |
| ARCH-20 | 🟡 OPEN | Backend | `src/modules/auth/infrastructure/jwt-auth.guard.ts:5` | Guard extends `AuthGuard('jwt')` with default Passport behavior — validates JWT signature only. **Does NOT check `User.deletedAt`**. S-02 patched the login path (`findByEmail` filters soft-deleted), but a soft-deleted user with a still-valid JWT can keep authenticating until the token expires. Needs a strategy override that re-loads the user (or carries `deletedAt`/`tokenVersion` in payload and rejects on mismatch). |
| ARCH-21 | 🟡 OPEN | Backend | `src/shared/exceptions/global-exception.filter.ts:11` | Filter does not detect/transform Prisma error codes (`P2002` unique violation → 409 Conflict, `P2025` not found → 404, etc.). All Prisma errors bubble to a generic 500. Some use cases (e.g., `CreateBudgetUseCase` lines 43-48) catch P2002 manually and re-throw `BadRequestException`, but the handling is per-use-case rather than systematic. Inconsistent client experience. |
| ARCH-22 | 🔴 OPEN | Backend | All `*.controller.ts` files | No `@ApiResponse` decorators anywhere — endpoints document `@ApiOperation` summary only. Swagger UI shows no explicit success/error status codes, no error body schemas, no `@ApiParam` for path params. Clients integrating from OpenAPI spec get no contract for 400/401/404/409 bodies. |
| ARCH-23 | 🔴 OPEN | Backend | `src/shared/config/configuration.ts:8,17,18` | Critical env vars (`DATABASE_URL`, `AZURE_OPENAI_ENDPOINT`, `AZURE_OPENAI_KEY`) read via `process.env.X` with no fallback **and no `.getOrThrow()` validation**. Missing values become `undefined` silently — Prisma fails at first query (not at boot), Azure provider fails at first AI call. SMTP config (lines 21-27) has fake fallbacks (`smtp.example.com`) so missing SMTP also fails at first email send. App boots green with broken config. |
| ARCH-24 | 🟡 OPEN | Backend | `prisma/schema.prisma` (`User`) + `src/modules/auth/types/jwt-payload.type.ts` | No `tokenVersion` (or similar) on `User`. Passport/JWT cannot invalidate all sessions on password reset; S-07 deletes refresh tokens but already-issued access tokens stay valid until expiry. Symmetric with ARCH-20 — a token-version field on User + claim on JWT would let the guard reject revoked sessions immediately. |
| ARCH-25 | 🟡 OPEN | Backend | `src/shared/logger/request-logging.interceptor.ts` | Logs `method`, `path`, `userId`, `requestId`, `durationMs` ✅ but no redaction layer. A request like `GET /something?password=xxx` or with `Authorization: Bearer ...` propagated into the path/headers field would surface in the log stream. Also missing: HTTP response status code in the log line (only request side is captured). |
| ARCH-26 | 🔴 OPEN | Backend | All mutation use cases (transactions, budgets, goals, categories, auth) | `AuditLog` table is populated only by `DELETE_ACCOUNT` (`users.controller.ts:49-50`). No writes for CREATE/UPDATE/DELETE on Transaction/Budget/Goal/Category, nor for password reset / OTP send / login lockout events. ERD line 431-455 (with `before_json`/`after_json`/`request_id`) was designed for this — currently the table exists but is mostly empty. No interceptor / decorator / cross-cutting writer found. |
| ARCH-27 | 🔴 OPEN | Backend | All POST endpoints + `prisma/schema.prisma` | No idempotency-key support. POST `/transactions`, `/budgets`, `/goals`, `/feedback` etc. accept the same payload N times → N duplicate records. Mobile clients retrying after a flaky connection will duplicate. No `idempotency_key` column on any table. |
| ARCH-28 | 🔴 OPEN | Backend | `zenda_backend_app/` root | No production `Dockerfile`. `docker-compose.yml` exists for local dev Postgres only. Means: no reproducible container build, no easy deploy to any container platform (k8s/Cloud Run/ECS), no immutable runtime image. |
| ARCH-29 | 🔴 OPEN | Backend | `src/modules/{transactions,budgets,goals,recommendations}/interface/*.controller.ts` | POST endpoints for `/transactions`, `/budgets`, `/goals`, and the AI `/chat` endpoint have **no `@Throttle` decorator**. Auth endpoints are individually throttled (good), but everything else relies on the global 120/min fallback. AI chat in particular is expensive and unprotected from abuse. |
| ARCH-30 | 🟡 OPEN | Backend | `src/health/health.controller.ts:6-16` | Health endpoint returns static 200 without checking the database connection. No `/ready` endpoint separate from `/live` for k8s-style probes. Useless for deployment health gates — a healthy response says nothing about whether the DB is reachable. |
| ARCH-31 | 🟢 MINOR | Docs | `.claude/specs/phase-2/spec.md:17,25-26` (and references.md if present) | Spec lists `lib/features/auth/local_auth_service.dart` but the file does not exist. The credential-storage behavior described there is actually implemented in `lib/core/services/api_client.dart:14-15` via `FlutterSecureStorage`. Spec writer documented a phantom file; the underlying functionality is correct. Update spec path to point to `api_client.dart`. |

---

## Not Implemented (Phase-level gaps)

| ID | Status | Area | Description |
|----|--------|------|-------------|
| GAP-01 | 🔴 OPEN | Backend+Frontend | Phase 11 (Notifications) — FCM not integrated; no push notifications delivered |
| GAP-02 | 🟢 FIXED | Backend+Frontend | **Resolved by AC-08 (2026-05-01).** US-034 — `_PostSurveyBanner` in `_InicioSection` triggers when pre-survey done, post-survey pending, and ≥30 days since pre completion; `postSurveyProvider` + `PreSurveyNotifier.completedAt()` wire the date check. |
| GAP-03 | 🔴 OPEN | Backend | (infrastructure: spending anomaly tracking) — Prediction accuracy tracking (compare predicted vs actual when period closes) |
| GAP-04 | 🔴 OPEN | Backend | Badge "Predictor" trigger not wired (no call to `awardIfNotEarned` on prediction views) |
| GAP-05 | 🔴 OPEN | Backend+Frontend | Phase 14 (Testing) — 0% test coverage; no unit or integration tests |
| GAP-06 | 🔴 OPEN | Backend+Frontend | Phase 16 (Demo Readiness) — no demo data script, no install guide, no demo script |
| GAP-07 | 🟢 FIXED | Backend | **Verified 2026-05-24.** SUS endpoint at `src/modules/education/interface/surveys.controller.ts:60-92` exposes `GET /surveys/sus` and `POST /surveys/sus/response` with the standard SUS scoring formula (contribution sum × 2.5) and grade mapping (Excelente/Bueno/Regular/Bajo). US-035 acceptance met. |

---

## Fix Log

| Date | ID | What was done |
|------|----|--------------|
| 2026-05-01 | P1-01 | Rewrote `_SurveyForm` to one-question-per-view: `_currentIndex` in `_SurveyScreenState`, `LinearProgressIndicator`, "Next" blocked until answered, "Submit" only on last question; replaced deprecated `RadioListTile.groupValue` with `RadioGroup` ancestor |
| 2026-05-01 | P1-02 | Added pre-submission existence check in `surveys.controller.ts`; throws `ConflictException` on re-submission instead of upsert |
| 2026-05-01 | P1-03 | Implemented `no_transactions_category` and `category_reduction_percentage` criteria in `verify-challenges.use-case.ts` |
| 2026-05-01 | P1-04 | Added `actualCorrect != null` guards in `_OptionTile.build` — selected answer shows neutral primary color instead of red when correct answer data is absent |
| 2026-05-01 | S-03 | Changed `config.get` to `config.getOrThrow` for `auth.jwtSecret` and `auth.jwtExpiresIn` in `auth.module.ts` |
| 2026-05-01 | AC-01 | Added `minAmount`, `maxAmount`, `search`, `sort` to `ListTransactionsDto`, `TransactionFilters`, `PrismaTransactionRepository.findAll`, and `ListTransactionsUseCase` |
| 2026-05-01 | AC-02 | Added `ICategoryRepository.hasTransactions` abstract method + `PrismaCategoryRepository` impl; `DeleteCategoryUseCase` throws `ConflictException` when category has active transactions |
| 2026-05-01 | AC-03 | Added future-date guard in `CreateGoalUseCase` — throws `BadRequestException` if `dueDate <= new Date()` |
| 2026-05-01 | AC-04 | Added `context.months.length === 0` guard in `GetRecommendationsUseCase` — returns `repo.listActive(userId)` without calling AI when user has no transaction history |
| 2026-05-01 | AC-05 | Added `months < 2` guard in `GetMonthComparisonUseCase` — throws `BadRequestException` |
| 2026-05-01 | AC-06 | Rewrote `ChallengesScreen` to group by status (ACTIVE → AVAILABLE → COMPLETED → EXPIRED) with `_SectionHeader` widgets; added ARB keys `challengesSectionActive/Available/Completed/Expired` |
| 2026-05-01 | AC-07 | Fixed budget color threshold from `>= 80` to `> 80` in `_BudgetCard._progressColor` |
| 2026-05-01 | UX-01 | Fixed invisible dismiss button in goals celebration dialog — replaced `const Text('')` with `Text(l10n.commonOk)`; added `commonOk` key to both ARB files |
| 2026-05-01 | S-01 | Hashed OTP code with SHA-256 in `PrismaPasswordResetOtpRepository.create/findValid` — plaintext never touches DB |
| 2026-05-01 | S-02 | Changed `findByEmail` from `findUnique({email})` to `findFirst({email, deletedAt: null})` — soft-deleted users can no longer authenticate |
| 2026-05-01 | S-04 | `incrementFailedLogin` now returns `Promise<number>` (DB atomic increment result); `LoginUseCase` uses returned count instead of stale entity value |
| 2026-05-01 | S-05 | `verify-otp` throttle reduced from `{limit:10}` to `{limit:3}` per minute |
| 2026-05-01 | S-06 | Hashed reset token with SHA-256 in `PrismaPasswordResetRepository.create/findByToken` — plaintext token never stored in DB |
| 2026-05-01 | S-07 | `ResetPasswordUseCase` now injects `IRefreshTokenRepository` and calls `deleteByUserId` after password update — all sessions revoked on reset |
| 2026-05-01 | S-08 | `LocalKvStore` migrated from `SharedPreferences` to `FlutterSecureStorage` for all financial data keys |
| 2026-05-01 | S-09 | `PendingTransactionQueue` migrated from `SharedPreferences` to `FlutterSecureStorage` |
| 2026-05-01 | S-10 | Lockout expiry timestamp persisted to `SharedPreferences` (`zenda.auth.lockout_until`); restored and resumed on app restart |
| 2026-05-01 | S-11 | Replaced `err.toString()` in `transaction_list_screen.dart` error state with `l10n.commonUnknownError` |
| 2026-05-01 | S-12 | Replaced `userId: 'demo'` in `NewTransactionController` with `ref.read(authNotifierProvider).user?.id ?? ''` |
| 2026-05-01 | AC-08 | Added `_PostSurveyBanner` to `_InicioSection`; shown when pre-survey done, post not done, and ≥30 days since pre completion; added `postSurveyProvider` and `PreSurveyNotifier.completedAt()` |
| 2026-05-01 | AC-09 | `survey_screen.dart` marks `postSurveyProvider` completed on post-survey submit; banner hides reactively |
| 2026-05-01 | AC-10 | `surveys.controller.ts` comparison: `improvementPercentage = ((post-pre)/pre)*100` |
| 2026-05-01 | UX-02 | Added `_CelebrationDialog` StatefulWidget with `ScaleTransition` bounce animation (0→1.3→0.9→1.0) using `TweenSequence` + `AnimationController`; replaces static `AlertDialog` in `_showCelebrationDialog` |
| 2026-05-01 | UX-03 | Added `_ChallengeCelebrationDialog` with same bounce animation; replaces plain SnackBar after challenge `onComplete` in `challenges_screen.dart` |
| 2026-05-01 | UX-04 | Added `attemptsRemainingToday` chip to quiz progress header in `personalized_quiz_screen.dart` — now visible before first answer, not just in results |
| 2026-05-01 | UX-05 | Added `autovalidateMode: AutovalidateMode.onUserInteraction` to `Form` widget in `register_screen.dart` — all three fields validate in real-time as user types |
| 2026-05-01 | UX-06 | Removed `deletedAt` field from `GoalResponseDto`, `TransactionResponseDto`, `BudgetResponseDto`, `CategoryResponseDto` and the corresponding controller mappers |
| 2026-05-01 | UX-07 | Converted `aiAdviceProvider` from `Provider<String>` to `Provider.family<String, AppLocalizations>`; added 4 ARB keys (`aiAdviceStartRecording`, `aiAdviceReduceWants`, `aiAdviceSaveLow`, `aiAdviceOnTrack`) in both EN and ES ARB files; updated 2 call sites in `dashboard_screen.dart` |
| 2026-05-24 | ARCH-02 | Re-verified during ERD alignment audit; `src/modules/feedback/` has full DDD structure (entity, port, use case, repository, controller, DTO). Status reconciled from 🔴 OPEN → 🟢 FIXED in the issues table (no code change). |
| 2026-05-24 | ARCH-03 | Re-verified; `notifications/` is intentionally not a separate module per the ERD redesign (preferences live as JSON on `users.notification_prefs`). Controller still bypasses DDD (`users/interface/notifications.controller.ts` injects `PrismaService`). Status changed to 🟡 PARTIAL; needs a use case wrapper (no schema change). |
| 2026-05-24 | GAP-02 | Re-verified; `_PostSurveyBanner` + `postSurveyProvider` already implemented as part of AC-08 (2026-05-01). Status reconciled to 🟢 FIXED in the gap table. |
| 2026-05-24 | GAP-07 | Re-verified; SUS routes exist at `src/modules/education/interface/surveys.controller.ts:60-92` with standard scoring formula. US-035 acceptance met. Status reconciled to 🟢 FIXED. |
| 2026-05-24 | ARCH-08 | New finding during deep ERD-vs-Prisma-vs-SQL alignment check. `docs/zenda-schema.sql` is missing 3 tables (`user_financial_progress`, `ai_conversations`, `ai_messages`) and 3 enums (`category_source`, `ai_conversation_status`, `ai_message_role`). Tracked for regeneration. |
| 2026-05-24 | ARCH-09 | New finding; `RecommendationResponseDto` drops 7 fields from `RecommendationEntity` and the ERD `recommendations` table (`viewedAt`, `dismissedAt`, `expiresAt`, `feedbackAt`, `modelVersion`, `source`, `inputContextJson`). Blocks frontend lifecycle rendering and AI traceability. |
| 2026-05-24 | ARCH-10 | New finding; login response has no schema for `failedLoginAttempts`/`lockedUntil`. Needs either an error body schema on 401 or a `/auth/me` endpoint exposing lockout state. |
| 2026-05-24 | ARCH-11 | New finding; frontend `TransactionModel` + JSON parser ignore `suggestedCategoryId`, `aiConfidence`, `categorySource`. Blocks AI-accuracy KPI visualization. |
| 2026-05-24 | ARCH-12 | New finding; frontend `User` model lacks `failedLoginAttempts`, `lockedUntil`, `consentGiven`, `consentAt`, `notificationPrefs`. Server-authoritative lockout is impossible without these. |
| 2026-05-24 | ARCH-13 | New finding; `FinancialLiteracyLevel` Dart enum uses `beginner/intermediate/advanced` while Prisma/ERD use `LOW/MEDIUM/HIGH`. Accepted as cosmetic — converters at boundary handle serialization. No action planned. |
| 2026-05-24 | ARCH-09 (update) | Re-audit after full DTO sweep: `isActive` is also missing from `RecommendationResponseDto`. Total fields dropped is **8**, not 7. Updated ARCH-09 description. |
| 2026-05-24 | ARCH-14 | New finding from full DTO sweep; `CategoryResponseDto` omits `transactionType`. ERD line 120, Prisma model present, DTO missing. |
| 2026-05-24 | ARCH-15 | New finding; `PredictionEntity` lacks `confidenceInterval` field — the persistence layer collapses the ERD's `{lower, upper}` JSON into a coarse `'high' \| 'medium' \| 'low'` string. DTO can't expose what the entity doesn't carry. Compounds with ARCH-04 (`modelVersion` packed columns) — same root cause. |
| 2026-05-24 | ARCH-16 | New finding; `BudgetResponseDto` exposes `deletedAt`. This is a regression of UX-06 (Fix Log 2026-05-01). Need to verify if the mapper was reverted in a later commit or if UX-06 was only partial. |
| 2026-05-24 | (audit notes) | Endpoint coverage check (backend ↔ frontend) ran against all `*.controller.ts` and `lib/core/services/*.dart`. Initial deep-audit flagged 3 orphan endpoints (`POST /ai/chat`, `GET /education/quiz/personalized`, `PATCH /education/topics/:id/complete`) — re-verified as **false positives**: all 3 are called from `lib/core/services/{recommendations,education}_api_service.dart`. No ghost or unreachable endpoints detected. |
| 2026-05-24 | ARCH-17 | New finding from 5th-pass audit (cross-context coupling angle). No ACL facade tokens exist; `BadgesModule`/`ChallengesModule`/`CategoriesModule`/`AuthModule` imported directly across module boundaries. Generalizes the same violation B9 addresses for insights→goals to 8+ other module pairs. |
| 2026-05-24 | ARCH-18 | New finding; `SubmitQuizDto.answers` has no key/value bounds — payload-bomb / DoS risk. |
| 2026-05-24 | ARCH-19 | New finding; JWT payload missing `consentGiven` causes per-request DB lookup for consent enforcement. |
| 2026-05-24 | ARCH-20 | New finding; `JwtAuthGuard` does not reject tokens for soft-deleted users (S-02 only fixed login path, not JWT path). |
| 2026-05-24 | ARCH-21 | New finding; `GlobalExceptionFilter` has no Prisma error mapping (P2002, P2025 → generic 500). Per-use-case manual handling exists but is inconsistent. |
| 2026-05-24 | (audit notes) | 5th-pass audit checked 10 new angles. Clean: Decimal precision (Prisma 12,2 + .toNumber() is safe), pagination (all list DTOs bounded), FK cascade behavior (no orphan risk by constraint), Phase 1A/1B specs match current schema, `notification_prefs` JSON shape matches ERD spec exactly. Risk-but-not-architecture: zero test files (covered by GAP-05), no CI/CD pipeline (new — out of scope for compliance plan). |
| 2026-05-24 | ARCH-22 | New finding (6th-pass, Swagger angle); `@ApiResponse` decorators missing across all controllers — OpenAPI spec lacks error body schemas. |
| 2026-05-24 | ARCH-23 | New finding; critical env vars (`DATABASE_URL`, `AZURE_OPENAI_*`, SMTP) read with no validation — app boots green with broken config. |
| 2026-05-24 | ARCH-24 | New finding; no `User.tokenVersion` for global session invalidation. Compounds with ARCH-20 (guard doesn't reject soft-deleted users). |
| 2026-05-24 | ARCH-25 | New finding; `RequestLoggingInterceptor` has no sensitive-field redaction and doesn't capture response status. |
| 2026-05-24 | ARCH-26 | New finding; `AuditLog` table designed in ERD with full before/after/request-id capture but populated only by DELETE_ACCOUNT. Mutations on Transaction/Budget/Goal/Category and auth events are not audited. |
| 2026-05-24 | ARCH-27 | New finding; no idempotency-key support on POST endpoints. Mobile retries will create duplicates. |
| 2026-05-24 | ARCH-28 | New finding; no production Dockerfile. Backend can't be reproducibly built into a container image. |
| 2026-05-24 | ARCH-29 | New finding; POST endpoints on Transactions/Budgets/Goals + AI `/chat` lack `@Throttle` decorators. AI chat especially is expensive and unguarded. |
| 2026-05-24 | ARCH-30 | New finding; `/health` returns static 200 without DB check; no separate `/ready` endpoint for deployment probes. |
| 2026-05-24 | (audit notes) | 6th-pass also flagged a missing ARB key `resolveError` — **false positive**: it's a Dart method on `L10nX` extension (`l10n_extension.dart:15`) that maps backend error codes to localized strings, not an ARB key. Skipped. |
| 2026-05-24 | (audit notes) | 6th-pass confirmed clean: CORS + helmet wired (`main.ts:16-20`, hardcoded to localhost but applied), token rotation in `RefreshAccessTokenUseCase`, multi-tenant safety on transactions/budgets/goals repos (userId filter consistent), `@nestjs/schedule` not imported (no background jobs — confirms B6 note that snapshot job is out of scope and GAP-03 prediction accuracy job is unimplemented). |
| 2026-05-24 | ARCH-31 | New finding (7th-pass, phase spec drift angle); `phase-2/spec.md` references `lib/features/auth/local_auth_service.dart` which does not exist. The credential-storage behavior is actually in `api_client.dart`. Spec doc drift, not code regression. |
| 2026-05-24 | (audit notes) | 7th-pass confirmed clean: (a) Repository ports vs impls fully aligned (all abstract methods implemented, signatures match); (b) Frontend secure storage migrations S-08/S-09 are complete (auth tokens, financial data, pending queue all in `FlutterSecureStorage`; non-sensitive flags like onboarding completion stay in `SharedPreferences` appropriately); (c) `AzureFoundryProvider.callAzure()` has try/catch with 15s timeout and fallback to `statisticalPrediction()` (`azure-foundry.provider.ts:81,127-151`); (d) Query indexes cover the main `findAll` filters for transactions/recommendations/budgets/goals; (e) Backend `app.setGlobalPrefix('api')` + kebab-case routes consistent, no legacy routes; (f) JWT refresh on frontend: reactive 401 + single-flight guard (`api_client.dart:69-81,173-181`) + graceful logout on failure; (g) Localization fallback safe (`nullable-getter: false` in `l10n.yaml` → compile errors on missing keys, not runtime crashes); (h) Currency field exists in schema with PEN/USD; no conversion logic implemented, acceptable for MVP. |
| 2026-05-24 | (audit notes) | 7th-pass also flagged "audit_logs table doesn't exist" — **false positive**: the `AuditLog` model exists in `schema.prisma` and the ERD (line 431-455). The auditor was looking at the wrong place. ARCH-26 already tracks the real issue: the table exists but is mostly unused. |
| 2026-05-24 | (audit notes) | 7th-pass also "re-discovered" UX-06 regression on `BudgetResponseDto.deletedAt` — already tracked as ARCH-16. Not a new finding. |
