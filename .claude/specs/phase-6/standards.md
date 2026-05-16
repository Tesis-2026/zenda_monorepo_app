# Standards Applied: Phase 6 — Budget and Financial Goal Management

## Database

- **`deletedAt: null` on every query:** All `where` clauses in `prisma-budgets.repository.ts` include `deletedAt: null` for both budget rows and the spending aggregate (transaction query). There is no transparent soft-delete middleware — the filter must be explicit.
- **`Decimal` → `number` conversion at repository boundary:** `amountLimit.toNumber()` and `_sum.amount?.toNumber()` are called inside `toEntity()`. The domain and application layers never handle Prisma `Decimal` objects.
- **Parallel aggregation deferred:** Each budget's `currentSpent` is computed via one `aggregate` call in `toEntity()`. For N budgets this issues N sequential queries. For N ≤ ~20 (typical per-month budget count) this is within acceptable latency. A future optimization could use `Promise.all` across all budgets, but was not added prematurely.

## Backend (Service / Application Layer)

- **Domain port extended before implementation:** `IBudgetRepository` (abstract class) is defined in `domain/ports/` before `PrismaBudgetsRepository` is written. No use case imports `PrismaService` — all queries go through the port.
- **Use case per operation, single responsibility:** Four separate `@Injectable()` use cases (`CreateBudgetUseCase`, `ListBudgetsUseCase`, `UpdateBudgetUseCase`, `DeleteBudgetUseCase`). No use case performs more than one logical operation.
- **Ownership enforced at use-case layer:** `UpdateBudgetUseCase` and `DeleteBudgetUseCase` call `findById(id, userId)` and throw `NotFoundException` before mutating. The repository `findById` includes `userId` in the `where` clause, so it returns `null` for any budget belonging to another user.
- **P2002 wrapped in the use case:** `CreateBudgetUseCase` catches `{ code: 'P2002' }` and rethrows as `ConflictException`. This keeps HTTP semantics out of the repository and domain layers.

## API

- **`@Query()` + `class-validator` DTOs with `@Type(() => Number)`:** `ListBudgetsDto` uses `@Type(() => Number)` (class-transformer) to coerce string query params to integers before validation. This is required because HTTP query strings are always strings — without `@Type`, `@IsInt` would always fail.
- **All endpoints under `JwtAuthGuard`:** Applied at the `BudgetsController` class level. No budget endpoint is publicly accessible.
- **Swagger annotations on all endpoints:** `@ApiTags('Budgets')` at the controller level; `@ApiOperation({ summary })` on each method.
- **`toResponse()` private mapper in the controller:** The controller maps `BudgetEntity` → `BudgetResponseDto` in a private `toResponse()` method rather than in the use case or entity. This follows the existing `GoalsController` pattern.

## Frontend (State / Data Layer)

- **`FutureProvider.autoDispose.family` keyed by `_BudgetFilter` record:** The budget list provider is scoped to `(month, year)`. When the user navigates months, a new provider instance is created for the new period. `.autoDispose` ensures unused periods are garbage collected.
- **`FutureProvider.autoDispose` (no family) for goals:** The goals list has no filter state, so a single unkeyed provider is appropriate.
- **File-scoped service providers:** `_budgetServiceProvider`, `_categoryServiceProvider`, `_goalsServiceProvider` are declared at file scope inside their respective screen files, following the `reports_screen.dart` precedent. They are not registered globally because no other screen consumes them.
- **`ref.invalidate()` after mutations:** After create, update, delete, and contribute, the screen calls `ref.invalidate(provider)` to force a fresh fetch. No optimistic updates are used.

## Frontend (UI / i18n)

- **No hardcoded strings:** All visible text uses `context.l10n.*`. The `_monthNames` constant is an English-only internal identifier (month abbreviations in the period selector header) — not displayed as a user-facing string.
- **ARB keys prefixed `budget` and `goals`:** All 22 new keys follow the established prefix convention (`auth`, `tx`, `catMgmt`, `reports`, etc.).
- **Light theme tokens only:** Progress bar backgrounds use `.withValues(alpha:)` on neutral tokens from `AppColors`. The app is locked to light mode (`themeMode: ThemeMode.light`), so no brightness branching is needed.
- **`withValues(alpha:)` used for transparency:** All semi-transparent color values in `_BudgetCard` and `_GoalCard` use `.withValues(alpha: x)` instead of the deprecated `.withOpacity(x)`.
- **`mounted` checked before async `setState`:** Dialog callbacks check `!context.mounted` or `!mounted` before any call to `ref.invalidate()` or `ScaffoldMessenger.of(context)` after an `await`.
