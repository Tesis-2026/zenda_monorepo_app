# Changelog

All notable changes to the Zenda monorepo are recorded here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project's [Conventional Commits](CONTRIBUTING.md) convention.

The repo is pre-1.0 (thesis MVP), so versions track refactor batches rather than semantic versions. Each entry references the merged PR + the batch ID in [`docs/architecture-compliance-plan.md`](docs/architecture-compliance-plan.md).

---

## [Unreleased]

### Removed

- **Deployment Docker** (2026-05-31) — deleted `zenda_backend_app/Dockerfile` + `.dockerignore` (added by B29) by product decision. The backend is run locally (`npm run start:dev`) against the docker-composed PostgreSQL. The local-DB `docker-compose.yml` is **kept**. Reverts ARCH-28; B29 marked reverted.

### Pending (see [`docs/architecture-compliance-plan.md`](docs/architecture-compliance-plan.md))

- B5 — frontend `setState` → Riverpod (`ai_chat`, login lockout, quiz state machine)
- B7 — extract `surveys/` module + new `conversations/` module
- B10 / B11 / B12 / B14 — frontend model alignment with new backend fields
- B17 — `Prediction.confidenceInterval`
- B19 — cross-context ACL facades (supersedes B9)

---

## 2026-05-24 — Tier 3 (security / ops / observability + audit trail)

### Added
- **B27** (backend#27) — Cross-cutting `AuditLogService` + `RequestContextService` (AsyncLocalStorage). Records 14+ events: CREATE/UPDATE/DELETE on Transaction/Budget/Goal/Category + LOGIN_FAILED / LOGIN_LOCKED / RESET_PASSWORD. Closes ARCH-26.
- **B28** (backend#25) — RFC-draft `Idempotency-Key` header support. New `IdempotencyKey` table + `IdempotencyInterceptor` registered globally. Closes ARCH-27.
- **B29** (backend#21) — Production multi-stage `Dockerfile` + `.dockerignore`. Closes ARCH-28. _(Reverted 2026-05-31 — see Removed under [Unreleased].)_
- **B31** (backend#22) — `/api/live` (trivial), `/api/ready` (DB ping), upgraded `/api/health` to do the DB ping. Closes ARCH-30.
- **B23** (backend#24 + #28) — Reusable Swagger `@ApiResponse` decorators in `src/shared/swagger/` + applied across all 18 controllers. Closes ARCH-22.
- **B16** (backend#20) — `CategoryResponseDto.transactionType` exposed. Closes ARCH-14.

### Changed
- **B21 + B25** (backend#23) — JWT hardening. New `User.tokenVersion` column; JWT now carries `tokenVersion` + `consentGiven`. `JwtStrategy.validate()` re-loads the user, rejects soft-deleted + stale-version tokens. `ResetPasswordUseCase` bumps `tokenVersion` (implicit logout-everywhere). Closes ARCH-19, ARCH-20, ARCH-24. **Breaking deploy**: tokens issued before the migration get one 401 and must re-login.
- **B22** (backend#21) — `GlobalExceptionFilter` now maps `PrismaClientKnownRequestError` (P2002→409, P2003→400, P2025→404). Closes ARCH-21.
- **B24** (backend#22) — Env vars validated at boot via `class-validator` (`EnvSchema`). `DATABASE_URL` / `JWT_SECRET` required at any env; SMTP enforced in production. App crashes with a readable error when env is broken. Closes ARCH-23.
- **B26** (backend#21) — `RequestLoggingInterceptor` redacts sensitive query params (password / token / code / otp / secret / apikey) and captures response status + error details. Closes ARCH-25.
- **B30** (backend#20) — Per-endpoint `@Throttle` on Transactions/Budgets/Goals POST and AI `/chat`. Closes ARCH-29.
- **B20** (backend#20) — `SubmitQuizDto.answers` bounded with custom `@IsBoundedAnswersMap()` (≤50 entries, key ≤64 chars, value ≤500 chars). Closes ARCH-18.

### Fixed
- **B18** (backend#20) — `BudgetResponseDto` and `GoalResponseDto` no longer leak `deletedAt`. UX-06 regression — same fix was applied earlier to Transaction/Category but Goal also drifted. Closes ARCH-16.
- **B15** (root#21) — Regenerated `docs/zenda-schema.sql` from Prisma — was missing 3 tables (`user_financial_progress`, `ai_conversations`, `ai_messages`) and 3 enums. Closes ARCH-08.

### Docs
- root#22 — Reconciled `docs/audit-issues.md` + `docs/architecture-compliance-plan.md` after Tier-3 execution (status of 14 closed ARCH items).
- backend#26 — Documented idempotency race-condition trade-off inline in `IdempotencyInterceptor`.

---

## 2026-05-24 — Spanish-only locale + mocked-data refactor (frontend)

### Changed
- **i18n** (frontend#16, root#20) — App locale forced to `es` in `lib/app.dart`; removed `LocaleNotifier` and the EN/ES switcher from settings. `Intl.defaultLocale = 'es'` + `initializeDateFormatting('es')` in `main.dart`.
- **Mocked data** (frontend#16) — Translated every user-visible value in `lib/core/mock/demo_data.dart` and `mock_services.dart` to Spanish (accounts, 20 transaction notes, recommendations, education topics, 24 quiz questions, AI chat responses, challenges, badges, surveys, prediction). Weekday + month abbreviations in `summary_models.dart` also Spanish.
- **Hardcoded English** (frontend#16) — Swept 17 files for English strings that bypassed both i18n and the mock layer: error fallbacks, button labels, chip text, report month names, PDF subject, SUS fallback questions, financial-literacy fallback survey.

### Docs
- root#20 — Documented Spanish-only locale convention in `CLAUDE.md` and `.claude/specs/phase-2/`.

---

## 2026-05-18 — B8 (cross-cutting cleanup)

### Added
- **B8** (backend#17) — Extracted `Feedback` bounded context out of `education/` into its own `src/modules/feedback/` with full DDD layout.

### Removed
- **B8** (backend#17) — `AnalyticsService` calls removed from `LoginUseCase`, `RegisterUseCase`, `GetPersonalizedQuizUseCase`; tracking moved to the controllers. Zero `AnalyticsService` references remain in any `application/` layer.

---

## 2026-05-17 — Initial compliance plan execution (B1–B6)

### Added
- **B6** (backend#15) — `financial-progress` module with full DDD layout (entity, port, repository, use cases, controller). Exposes `GET /api/financial-progress` and `GET /api/financial-progress/current`.
- **B2** (frontend#13, root#15) — `lib/providers/services_providers.dart` introduced for `authApiServiceProvider`, `feedbackApiServiceProvider`, `insightsApiServiceProvider`. 8 widget call-sites refactored to consume providers via `ref.read`.

### Changed
- **B1** (backend#14) — Added `deletedAt: null` to category queries in `predictions`, `insights`, `recommendations` repositories.
- **B3** (frontend#14) — `Navigator.pop()` → `context.pop()` across 16 files. New `aiChatWelcomeDemo` ARB key extracted.
- **B4** (backend#16) — Removed `PrismaService` from `application/` use cases in `challenges` and `education`; introduced new repository ports (`IChallengeVerificationPort`, `IPersonalizedQuizContextPort`).

---

## Earlier — Pre-compliance-plan baseline (May 2026)

Foundational phases (1a, 1b, 2, 3, 4, 5, 6) are documented in `.claude/specs/phase-{phase}/spec.md`. Priority-1 / Security / Acceptance-Criteria / UX issues found in the original 2026-05-01 audit are tracked in [`docs/audit-issues.md`](docs/audit-issues.md) Fix Log — all 🟢 FIXED.
