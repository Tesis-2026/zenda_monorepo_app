# Frontend ↔ Backend Integration Status

> Source of truth for wiring the Flutter app to the real NestJS backend.
> Last verified: **2026-05-31** (code-level contract + response-parsing audit).
> Method: read actual `lib/core/services/*.dart` `.fromJson` against `src/modules/*/interface/` controllers + response DTOs. `tsc --noEmit` and `flutter analyze` clean at time of audit.

---

## 1. Current state

**The app runs 100% in DEMO/MOCK mode.** No call reaches the backend today.

- `lib/main.dart:9` → `const bool _kDemoMode = true;`
- `lib/main.dart:26` → `overrides: _kDemoMode ? buildDemoOverrides() : const []`
- `buildDemoOverrides()` (`lib/core/mock/demo_overrides.dart`) replaces every `*ApiService` provider with a `Mock*` returning `DemoData`.

**Integrating = flip the switch + point at a running backend.** It is not a big rewrite — the contract is largely aligned.

---

## 2. Integration checklist (to go from demo → real backend)

1. **`lib/main.dart`** → set `_kDemoMode = false` (or make it a `--dart-define`, see §6).
2. **`lib/core/services/api_client.dart:12`** → set `_kBaseUrl`:
   - Android emulator: `http://10.0.2.2:3000/api`
   - Physical device: `http://<your-LAN-IP>:3000/api` (or an ngrok tunnel)
   - `localhost` only works on iOS simulator / same host.
3. **Backend running + DB seeded:** `docker compose up -d` → `npm run prisma:migrate` → `npm run prisma:seed` → `npm run start:dev`.
4. **Category seed must use the Spanish names the frontend expects** (Comida, Transporte, Vivienda, Servicios, Salud, Entretenimiento, Compras, Suscripciones, Ahorro, Otros). The transaction flow resolves its `TransactionCategory` enum → name → `categoryId` via `GET /categories`. If the seed names differ, category resolution falls back to `newCategoryName` (creates duplicates).
5. Apply the two data-mapping fixes in §4 (otherwise challenge rewards and education topic categories show wrong data — no crash).

---

## 3. Contract status — verified compatible

`ApiClient` handles: JWT Bearer, single-flight token refresh on 401, `Idempotency-Key` on retryable POSTs, NestJS validation-array error parsing, binary `getBytes` (PDF). Backend global prefix: `/api`.

**Compatible flows (no change needed):** auth (login/register/refresh/logout/forgot-password/send-otp/verify-otp/reset-password), transactions (CRUD + classify + list filters), categories (list/create/rename/delete), budgets (CRUD), goals (CRUD + contribute + complete + contributions), insights/summary (day/week/month/comparison/progress) + **PDF export**, recommendations (list/stats/feedback), predictions (expenses), education (topics/quiz/personalized quiz), **surveys (pre/post/SUS/comparison)**, feedback, AI chat (active/send/close), financial-progress, users (`/me` get/update/delete), notifications (`/notifications/preferences` GET + `PATCH /preferences/:type` — verified exists).

**No runtime crash risk:** every non-nullable `fromJson` read (`id`, `title`, `amount`, `order`, `difficulty`, etc.) maps to a field the backend response DTO actually sends. Reading *fewer* fields than the response contains is safe (extra JSON keys are ignored).

---

## 4. Open data-mapping issues (🟡 wrong/missing data — NOT crashes)

These parse without error but display wrong/empty data until fixed.

### 4.1 Challenge rewards
- Backend `challenges/interface/dto/challenge.response.dto.ts:8` sends a single `reward: string | null`.
- Frontend `core/services/education_api_service.dart:294,299` reads `pointsReward` (`as int? ?? 0`) and `badgeReward` (`as String?`) — **neither field exists** in the response.
- **Effect:** challenges always show **0 points / no badge**; the real `reward` is dropped.
- **Fix (pick one):** map FE to the backend field — `pointsReward: int.tryParse(json['reward'] ?? '') ?? 0` (or split reward semantics), OR change the backend DTO to expose `pointsReward`/`badgeReward` explicitly.

### 4.2 Education topic metadata
- Backend `education/interface/dto/topic.response.dto.ts` sends: id, title, content, difficulty, order, isCompleted, completedAt. It does **NOT** send `category`, `questionCount`, `isLocked`.
- Frontend `core/services/education_api_service.dart:37,43` reads `category ?? 'budgeting'`, `questionCount ?? 0`, `isLocked ?? false`.
- **Effect:** **every** topic renders as category "budgeting" (wrong icon/color/label for saving/investing topics) and shows **0 questions**.
- **Fix (preferred):** add `category`, `questionCount`, `isLocked` to `TopicResponseDto` + its mapper (the data exists on the entity/DB). Alternatively accept the FE defaults.
- **Minor related:** backend sends `difficulty` UPPERCASE (BEGINNER/INTERMEDIATE/ADVANCED). Confirm the FE doesn't compare against lowercase.

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

## 6. Recommendation: make demo mode runtime-configurable

Today `_kDemoMode` is a compile-time `const` → switching requires editing source + rebuilding. Consider:

```dart
const bool _kDemoMode = bool.fromEnvironment('DEMO', defaultValue: true);
```
Then build real: `flutter build apk --dart-define=DEMO=false`. Lets the same codebase ship demo or real without code edits.

---

## 7. Debunked false positives (do not chase)

Two automated sweeps over-flagged these; verified against code:
- Dart `{'x': ?value}` null-aware map entries are **valid** (omit key when null) — the project compiles/builds.
- "Crash in Challenge/User/Goal `fromJson`" — all are null-safe `as X?` reads; **no crash**.
- "SUS response field mismatch" — `submitSus` returns a dedicated `SusResult` (`susScore`/`grade`) that matches the backend exactly.
- "Notifications endpoint missing" — exists (`@Controller('notifications')` + `@Get('preferences')` + `@Patch('preferences/:type')`).

---

## 8. TL;DR

Integration is **viable with no crashes**. Required: (1) `_kDemoMode=false`, (2) correct base URL, (3) backend up + seeded with matching category names. Recommended before demo with real data: fix §4.1 (challenge rewards) and §4.2 (topic metadata). Everything else is wired correctly.
