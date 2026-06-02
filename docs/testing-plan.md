# Backend Testing Plan — Contract Tests with Mocked Data (no DB)

> Status: **complete** — all 18 contract suites **implemented & green** (2026-05-31).
> `npm run test:e2e` runs **77 passing** tests across **18 suites** with **no DB**. Decided 2026-05-31.
>
> **Built:** `test/jest-e2e.json`, `test/support/prisma.mock.ts` (flexible Proxy mock), `test/support/create-test-app.ts`
> (boots AppModule, overrides `PrismaService` + optional guard + provider overrides, mirrors `main.ts` global setup),
> `test/fixtures.ts` (schema-shaped factories), and one `test/modules/<context>.e2e-spec.ts` per bounded context:
> health, auth, transactions, categories, budgets, goals, insights, recommendations, predictions,
> financial-progress, education, challenges, badges, surveys, feedback, conversations, users, notifications.
> Dev deps added: `jest`, `ts-jest`, `@types/jest`, `supertest`, `@types/supertest`, `@nestjs/testing`.
>
> **Gotchas learned (apply to every new suite):**
> - No `esModuleInterop` in tsconfig → import supertest as **`import request = require('supertest')`**.
> - Prisma mock write methods (`create/update/upsert/delete`) **must return resolved promises** — fire-and-forget
>   writers (`AnalyticsService.track`, `AuditLogService.record`) call `.create(...).catch(...)` and crash on `undefined`.
> - Validators are strict — e.g. `LoginDto.password` is `@MinLength(12)`; payloads must satisfy the real DTO.
> - Mock domain **repository ports** via `createTestApp({ overrides: [...] })` for success paths; rely on the default
>   Prisma mock (nulls) for not-found/validation paths.
>
> Goal: validate every backend function the way the **Android frontend** would read it, and how the
> **backend interprets** each request — **without a real database**, by mocking persistence with
> schema-shaped fixtures. Closes the testing gap (GAP-05) at the contract level.

---

## 1. Decision & trade-off

**Decision:** tests run against the **real HTTP pipeline** (controllers + validation pipes + DTO mapping +
guards) but with **mocked persistence** — no PostgreSQL, no Docker. Fixtures mimic the Prisma schema row
shapes; assertions check the response matches what the Flutter `fromJson` expects.

**Why (per product decision):** no DB/Docker dependency, fast, runs anywhere (CI included), and it targets
exactly where bugs live for integration — **DTO/response shapes, field names, enums, status codes**
(e.g. ARCH-38/39).

**Trade-off (explicit):** the project skill `skills/platform/platform-testing` prescribes a *real database,
no mocks*. This plan deliberately diverges for practicality. **Limitation:** these tests will NOT catch
real Prisma query bugs, SQL constraints, migrations, FK cascades, transaction atomicity, or `Decimal`
rounding. Those require a later integration-test layer against a test DB. This plan covers the
**request→interpretation→response contract**, not the persistence layer.

---

## 2. What each test proves

For every endpoint, a test asserts:
1. **Request interpretation** — the backend accepts the body/query the frontend sends (field names, types),
   and rejects invalid input (validation → 400).
2. **Response contract** — the JSON shape matches what the Flutter model `fromJson` reads: exact field
   names, types, enum casing (`INCOME`/`EXPENSE`, `LOW`/`MEDIUM`/`HIGH`, etc.), nested objects, nullability.
3. **Status & errors** — 200/201 on success; 401 (unauth), 403, 404, 409 (conflict) where expected.
4. **Auth flow** — protected routes require a Bearer token; the mocked guard injects a fake user.

This is the same contract captured in `docs/frontend-backend-integration.md` — the tests make it executable.

---

## 3. Architecture

- **Runner:** Jest + `ts-jest`. **HTTP:** `supertest`. **Nest:** `@nestjs/testing` `Test.createTestingModule`.
- **No DB:** build the app/module, then **override the persistence providers**:
  - Override `PrismaService` with a mock object (only the methods a use case touches).
  - Prefer overriding the **domain repository ports** (abstract-class tokens in `domain/ports/`) with
    in-memory fakes returning **fixtures** — cleaner than mocking raw Prisma, and matches the DDD layering.
  - Override `JwtAuthGuard` with a stub that sets `req.user = fixtureUser` (no real JWT needed), except in
    the auth suite which exercises the real token pipeline with a mocked `IUserRepository`.
- **Fixtures (schema-shaped):** a `test/fixtures/` folder with factory functions that return objects matching
  the Prisma model shape (e.g. `makeTransactionRow()`, `makeUserRow()`, `makeCategoryRow()`), so the mocked
  repos hand the use cases realistic data. One source of truth per entity, overridable per test.
- **Test data direction:** input fixtures mirror **Flutter request bodies**; expected outputs mirror
  **Flutter model fields**. Where they differ today (ARCH-38/39), the test encodes the *correct* contract
  and will fail until fixed — acting as a regression guard.

---

## 4. Folder structure & naming

```
zenda_backend_app/
├── test/
│   ├── jest-e2e.json              # ts-jest config, rootDir, moduleNameMapper
│   ├── support/
│   │   ├── create-test-app.ts     # builds Nest app with mocked providers + guard
│   │   ├── auth.stub.ts           # JwtAuthGuard override → injects fixture user
│   │   └── repo-mocks.ts          # in-memory fakes for the domain repository ports
│   ├── fixtures/
│   │   ├── user.fixture.ts
│   │   ├── transaction.fixture.ts
│   │   ├── category.fixture.ts
│   │   └── ...                     # one per entity, schema-shaped
│   └── modules/
│       ├── auth.e2e-spec.ts
│       ├── transactions.e2e-spec.ts
│       ├── budgets.e2e-spec.ts
│       └── ...                     # one suite per bounded context
```

- Suites: `<module>.e2e-spec.ts`. Test names describe behavior:
  `it('returns 201 with {accessToken, refreshToken} on valid register')`.
- Arrange-Act-Assert in every test. One behavior per test. No shared mutable state between tests.

---

## 5. Scripts to add (package.json)

```jsonc
"scripts": {
  "test": "jest",
  "test:e2e": "jest --config ./test/jest-e2e.json",
  "test:watch": "jest --watch --config ./test/jest-e2e.json",
  "test:cov": "jest --coverage --config ./test/jest-e2e.json"
}
```
Dev deps to install: `@nestjs/testing`, `jest`, `ts-jest`, `@types/jest`, `supertest`, `@types/supertest`.

---

## 6. Example (pattern to replicate) — transactions create

```ts
// test/modules/transactions.e2e-spec.ts (illustrative)
describe('POST /api/transactions', () => {
  let app: INestApplication;
  beforeAll(async () => { app = await createTestApp({ user: fixtureUser }); });
  afterAll(async () => { await app.close(); });

  it('accepts the Flutter create body and returns the response shape the app parses', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/transactions')
      .set('Authorization', 'Bearer test')
      .send({ type: 'EXPENSE', amount: 25.5, categoryId: fixtureCategory.id,
              description: 'Café', occurredAt: '2026-05-31T12:00:00.000Z' });

    expect(res.status).toBe(201);
    // Contract the Flutter TransactionModel.fromApiJson relies on:
    expect(res.body).toMatchObject({
      id: expect.any(String),
      type: 'expense',                 // backend normalizes to lowercase on read
      amount: 25.5,
      description: 'Café',
      category: { name: expect.any(String) },
    });
    expect(res.body).not.toHaveProperty('deletedAt'); // UX-06
  });

  it('rejects amount <= 0 with 400', async () => { /* ... */ });
});
```

The mocked transaction repository returns a `makeTransactionRow(...)` fixture so no DB is needed; the
controller's DTO mapper runs for real, which is what we're verifying.

---

## 7. Coverage map (one suite per bounded context, ~function-by-function)

| Module | Key functions to cover (request → response contract) |
|--------|------------------------------------------------------|
| auth | register, login, refresh, logout, forgot-password, send-otp, verify-otp, reset-password, lockout 401 body |
| users | GET/PUT `/me`, DELETE `/me` |
| transactions | create (idempotent), list (filters), get, update, delete, classify |
| categories | list, create, rename, delete (blocked when in use) |
| budgets | create, list (month/year), update, delete |
| goals | create, list, contribute, complete, contributions, delete |
| insights | day/week/month/comparison/progress summaries, PDF export (content-type) |
| recommendations | list (+lifecycle fields), stats, feedback |
| predictions | expenses (predictedTotal/confidenceInterval/byCategory), accuracy-check |
| education | topics list/detail, complete, quiz get/submit, personalized quiz — **assert `category`/`questionCount` (ARCH-39)** |
| challenges | list (+EXPIRED), accept, complete — **assert reward field (ARCH-38)** |
| badges | list (earned/locked) |
| surveys | pre/post/sus get + submit (score/level, susScore/grade), comparison |
| feedback | submit |
| financial-progress | list, current |
| conversations | chat send, active, close |
| health | live / ready / health (DB ping mocked) |

Each suite also asserts the **enum casing** and **field names** the Flutter models read, so the suite
fails if the backend drifts from the frontend contract.

---

## 8. Rollout order

1. ✅ **Foundation:** deps installed; `jest-e2e.json`, `prisma.mock.ts`, `create-test-app.ts`; `health.e2e-spec.ts` smoke. *(done 2026-05-31)*
2. ✅ **Pilot:** `auth.e2e-spec.ts` (register/login validation + 401 + 201 + lockout body) → pattern proven, green. *(done 2026-05-31)*
3. ✅ **Core financial:** transactions, categories, budgets, goals. *(done 2026-05-31)*
4. ✅ **Read/AI:** insights, recommendations, predictions, financial-progress. *(done 2026-05-31)*
5. ✅ **Education/gamification:** education (pins ARCH-39), challenges (pins ARCH-38), badges, surveys. *(done 2026-05-31)*
6. ✅ **Rest:** feedback, conversations (AI chat), users, notifications. *(done 2026-05-31)*

Each step: `npx tsc --noEmit` clean + `npm run test:e2e` green before moving on.

**All six tandas complete (2026-05-31).** `npm run test:e2e` runs **18 suites green, no DB**: health, auth,
transactions, categories, budgets, goals, insights, recommendations, predictions, financial-progress,
education, challenges, badges, surveys, feedback, conversations, users, notifications.

---

## 9. How to run (once implemented)

```bash
cd zenda_backend_app
npm install            # first time, pulls the test deps
npm run test:e2e       # no Docker / no DB needed
```

---

## 10. Relationship to other docs

- `docs/frontend-backend-integration.md` — the contract these tests enforce (incl. ARCH-38/39, enum maps).
- `docs/audit-issues.md` — GAP-05 (testing) is addressed at the contract level by this plan; a future
  **integration-test layer with a real DB** would be needed to fully close GAP-05 (persistence correctness).
- `skills/platform/platform-testing` — superseded for this layer by the mocked-data decision in §1.
