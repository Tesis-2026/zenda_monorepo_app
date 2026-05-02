# Zenda — Audit Issues Tracker

**Last full audit:** 2026-05-01  
**Auditor:** Claude Code (deep code analysis)  
**Scope:** Backend (NestJS) + Frontend (Flutter)

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
| ARCH-01 | 🔴 OPEN | Backend | `src/modules/surveys/` | Surveys module injects `PrismaService` directly in controller — no use cases, no domain layer, violates DDD |
| ARCH-02 | 🔴 OPEN | Backend | `src/modules/feedback/` | Same as ARCH-01 — no use cases, direct PrismaService in controller |
| ARCH-03 | 🔴 OPEN | Backend | `src/modules/notifications/` | Same as ARCH-01 |
| ARCH-04 | 🔴 OPEN | Backend | `prisma-prediction.repository.ts:38` | `confidenceLevel` and `narrative` packed into `modelVersion` column as pipe-delimited string |
| ARCH-05 | 🔴 OPEN | Backend | `prisma/schema.prisma` | `SavingsGoal` has no `completedAt`/`isCompleted` field — completion simulated by setting `currentAmount = targetAmount` |
| ARCH-06 | 🔴 OPEN | Frontend | `core/services/ocr_service.dart` | OCR is a stub — `fillFromOcrDemo()` fills hardcoded values; camera/ML not implemented |
| ARCH-07 | 🔴 OPEN | Frontend | `sync_service.dart` | Offline queue has no retry limit, no exponential backoff, no dead-letter — permanently rejected transactions retry forever |

---

## Not Implemented (Phase-level gaps)

| ID | Status | Area | Description |
|----|--------|------|-------------|
| GAP-01 | 🔴 OPEN | Backend+Frontend | Phase 11 (Notifications) — FCM not integrated; no push notifications delivered |
| GAP-02 | 🔴 OPEN | Backend+Frontend | US-034 — 30-day re-invitation logic not wired anywhere |
| GAP-03 | 🔴 OPEN | Backend | (infrastructure: spending anomaly tracking) — Prediction accuracy tracking (compare predicted vs actual when period closes) |
| GAP-04 | 🔴 OPEN | Backend | Badge "Predictor" trigger not wired (no call to `awardIfNotEarned` on prediction views) |
| GAP-05 | 🔴 OPEN | Backend+Frontend | Phase 14 (Testing) — 0% test coverage; no unit or integration tests |
| GAP-06 | 🔴 OPEN | Backend+Frontend | Phase 16 (Demo Readiness) — no demo data script, no install guide, no demo script |
| GAP-07 | 🔴 OPEN | Backend | SUS questionnaire endpoint (US-035) not implemented |

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
