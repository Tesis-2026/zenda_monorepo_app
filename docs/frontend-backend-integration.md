# Frontend ↔ Backend Integration Status

> Source of truth for wiring the Flutter app to the real NestJS backend.
> Last verified: **2026-06-07** (reconciliation after the 2026-06-04/06 batch).
> Method: read actual `lib/core/services/*.dart` `.fromJson` against `src/modules/*/interface/` controllers + response DTOs. `tsc --noEmit` clean, `flutter analyze` "No issues found", `test:e2e` 77/77 at time of audit.

---

## 1. Current state

**The app defaults to the REAL backend.** Demo mode is now opt-in at build time (the §6 recommendation below was implemented).

- `lib/main.dart:14` → `const bool _kDemoMode = bool.fromEnvironment('DEMO', defaultValue: false);`
- `lib/main.dart:42` → `if (_kDemoMode) ...buildDemoOverrides()` (mocks applied only when `DEMO=true`).
- Run demo: `flutter run --dart-define=DEMO=true`. Run real: just `flutter run` (point the base URL at a running backend, see §2).
- `buildDemoOverrides()` (`lib/core/mock/demo_overrides.dart`) replaces every `*ApiService` provider with a `Mock*` returning `DemoData`.

**Integrating = point at a running backend.** No code edit needed to leave demo mode.

---

## 2. Integration checklist (to go from demo → real backend)

1. **Demo mode is already off by default.** Nothing to edit — to force demo, build with `--dart-define=DEMO=true` (see §6).
2. **Base URL** is a `--dart-define` (`API_BASE_URL`), default `http://localhost:3000/api` (`api_client.dart:14-16`):
   - Windows desktop / web / iOS simulator: `http://localhost:3000/api` (default works)
   - Android emulator: `--dart-define=API_BASE_URL=http://10.0.2.2:3000/api`
   - Physical device: `http://<your-LAN-IP>:3000/api` (or an ngrok tunnel)
3. **Backend running + DB seeded:** `docker compose up -d` → `npm run prisma:migrate` → `npm run prisma:seed` → `npm run start:dev`.
4. **Category seed uses ENGLISH names** (`Food`, `Transportation`, `Housing`, `Utilities`, `Health`, `Entertainment`, `Shopping`, `Subscriptions`, `Cravings`, `Savings`, `Education`, `Other` + income types). This is **intentional and correct**: the frontend resolves `TransactionCategory` enum → English name via `categoryToApiName()` (`transaction_api_service.dart:5-18`), which matches the seed — so `categoryId` resolves and **no duplicates are created**. The UI translates names to Spanish via `CategoryUtils.labelEs()` for display. (Earlier drafts of this doc wrongly said the seed must be Spanish — that was incorrect.)
5. No data-mapping fixes required — the §4 issues are resolved (see updated §4).

---

## 3. Contract status — verified compatible

`ApiClient` handles: JWT Bearer, single-flight token refresh on 401, `Idempotency-Key` on retryable POSTs, NestJS validation-array error parsing, binary `getBytes` (PDF). Backend global prefix: `/api`.

**Compatible flows (no change needed):** auth (login/register/refresh/logout/forgot-password/send-otp/verify-otp/reset-password), transactions (CRUD + classify + list filters), categories (list/create/rename/delete), budgets (CRUD), goals (CRUD + contribute + complete + contributions), insights/summary (day/week/month/comparison/progress) + **PDF export**, recommendations (list/stats/feedback), predictions (expenses), education (topics/quiz/personalized quiz), **surveys (pre/post/SUS/comparison)**, feedback, AI chat (active/send/close), financial-progress, users (`/me` get/update/delete), notifications (`/notifications/preferences` GET + `PATCH /preferences/:type` — verified exists).

**No runtime crash risk:** every non-nullable `fromJson` read (`id`, `title`, `amount`, `order`, `difficulty`, etc.) maps to a field the backend response DTO actually sends. Reading *fewer* fields than the response contains is safe (extra JSON keys are ignored).

---

## 4. Data-mapping issues (✅ resolved by the 2026-06-04/06 batch)

### 4.1 Challenge rewards (✅ resolved)
- Backend `challenges/interface/dto/challenge.response.dto.ts:9-10` now sends `pointsReward: number` (`e.pointsReward`) and `badgeReward: string | null` (badge name parsed from `reward`), in addition to the raw `reward`.
- Frontend `Challenge.fromJson` reads exactly those fields → challenges show the correct points / badge.
- Pinned by the challenges e2e contract test (regression guard updated 2026-06-07). Tracked as ARCH-38 (FIXED).

### 4.2 Education topic metadata (✅ mostly resolved)
- Backend `education/interface/dto/topic.response.dto.ts:10-11` now sends `category` and `questionCount` from the entity → topics render the correct icon/color and real question count.
- **Only remaining gap:** `isLocked` is not in the DTO; `EducationTopic.fromJson` defaults it to `false`. Harmless — no topic-locking flow ships today. Tracked as ARCH-39 (PARTIAL).
- **Note:** backend `difficulty` is UPPERCASE (BEGINNER/INTERMEDIATE/ADVANCED); the FE stores it as-is and does not compare against lowercase. No issue.

### 4.3 Category icon key (✅ resolved 2026-06-01)
- Backend `Category` now stores a stable semantic `icon` key (e.g. `food`, `transport`); seeded for system categories, **null for custom** (`schema.prisma`, migration `20260601000000_add_category_icon`, `seed.ts` `ICON_BY_CATEGORY_NAME`).
- Exposed in `CategoryResponseDto.icon` and in the transaction's embedded category (`TransactionCategoryDto.icon`), so the client no longer guesses an icon from the category name.
- Frontend `CategoryUtils.iconForCategory(name, {iconKey, isCustom})` resolves the key first, then falls back to name matching, then to a single default icon (`Icons.label_rounded`) for custom/unknown categories — the name differentiates them. `CategoryModel.icon` parses the new field.
- Contract pinned by the `categories`/`transactions` e2e suites (system → `icon: 'food'`; custom → `icon: null`).

---

## 5. Known / accepted (tracked elsewhere — not blockers)

- **User model fields (ARCH-12):** backend `/users/me` returns `consentGiven`, `consentAt`, `failedLoginAttempts`, `lockedUntil`; the Flutter `User.fromJson` doesn't parse them. **Not a crash** (extra keys ignored) — just means lockout/consent state isn't read client-side. Tracked as ARCH-12 in `audit-issues.md`.
- `SavingsGoal.deletedAt` read as `String?` → null when absent; backend filters soft-deleted goals anyway. Inocuous.

---

## 6. Demo mode is runtime-configurable (✅ implemented)

`main.dart:14` reads `const bool _kDemoMode = bool.fromEnvironment('DEMO', defaultValue: false);` — the same build ships real (default) or demo (`--dart-define=DEMO=true`) without code edits. The base URL is likewise a `--dart-define` (`API_BASE_URL`, `api_client.dart:14`).

---

## 7. Debunked false positives (do not chase)

Two automated sweeps over-flagged these; verified against code:
- Dart `{'x': ?value}` null-aware map entries are **valid** (omit key when null) — the project compiles/builds.
- "Crash in Challenge/User/Goal `fromJson`" — all are null-safe `as X?` reads; **no crash**.
- "SUS response field mismatch" — `submitSus` returns a dedicated `SusResult` (`susScore`/`grade`) that matches the backend exactly.
- "Notifications endpoint missing" — exists (`@Controller('notifications')` + `@Get('preferences')` + `@Patch('preferences/:type')`).

---

## 8. TL;DR

Integration is **viable with no crashes and no remaining data-mapping fixes**. Required: (1) demo mode already off by default, (2) correct base URL via `--dart-define=API_BASE_URL`, (3) backend up + seeded (English category names are correct). §4.1 (challenge rewards) and §4.2 (topic metadata) are resolved; only `isLocked` (ARCH-39) and the client-side User lockout/consent fields (ARCH-12) remain as harmless gaps.
