# Shape: Phase 6 — Budget and Financial Goal Management

## Decisions

- **`currentSpent` computed at repository boundary, not in the use case** — `PrismaBudgetsRepository.toEntity()` issues one `aggregate` query per budget to compute `currentSpent`. The entity always carries a complete snapshot (amountLimit + currentSpent + percentageUsed). The alternative was computing `currentSpent` in the use case by injecting both the budget repository and a transaction aggregation method. Rejected because it would introduce cross-module coupling (budgets use case importing from transactions domain), violating bounded context isolation.

- **`categoryId = null` means global budget (all categories)** — The schema allows `categoryId` to be null at the DB level (`@@unique([userId, categoryId, month, year])` with `categoryId?`). A null-categoryId budget aggregates ALL EXPENSE transactions for the period regardless of category. The alternative was requiring a category for every budget. Rejected because users may want a single total spending cap before they have enough data to budget per category.

- **`currentSpent` filter scope: EXPENSE transactions only, `deletedAt: null`** — The spending aggregate always filters `type: EXPENSE` and `deletedAt: null`. Income transactions are excluded. The alternative was counting all transaction types. Rejected: budgets track spending caps, not net balance.

- **Ownership checked via `findById` before `update` and `softDelete`** — `UpdateBudgetUseCase` and `DeleteBudgetUseCase` call `repo.findById(id, userId)` and throw `NotFoundException` if null. The `userId` parameter is propagated to the repository `where` clause so a user cannot find another user's budget. The alternative was relying on the DB FK constraint to reject invalid deletes. Rejected: FK constraints don't produce informative 404s; the use case is the correct guard site.

- **Prisma P2002 wrapped as `ConflictException` in the use case, not the repository** — `CreateBudgetUseCase.execute()` catches `{ code: 'P2002' }` and throws NestJS `ConflictException`. The alternative was catching P2002 in the repository and returning a domain error. Rejected: domain errors would require the controller to map them back to HTTP status codes, adding indirection. A `ConflictException` thrown from the application layer is directly understood by NestJS's exception filter.

- **`DropdownButtonFormField.value` used in the budget creation modal** — The category and period dropdowns in `_showCreateDialog` use controlled state via `StatefulBuilder` + `setDlgState`. This requires the `value` parameter (which triggers a deprecation info warning in Flutter 3.33+). The alternative was using `initialValue`. Rejected: `initialValue` is only used to set the initial value when a `FormField` is first inserted into the widget tree — it cannot update the dropdown when the user changes selection. The deprecation warning is a Flutter analyzer false positive for this controlled-dropdown pattern.

- **File-scoped providers in `budget_screen.dart` and `goals_screen.dart`** — Following the `reports_screen.dart` precedent, service providers are declared at file scope in the feature file rather than in `repositories_providers.dart`. The alternative was registering them in the global providers file. Rejected: budgets and goals services are only consumed by their respective screens; no cross-screen sharing is required.

- **Goals frontend uses `FutureProvider.autoDispose` (no family)** — The goals list has no filter state (all goals are always shown). A single unkeyed provider is sufficient. The alternative was using a family provider. Rejected: over-engineering for a filter that doesn't exist.

- **`GoalsScreen` uses `ConsumerWidget` (not `ConsumerStatefulWidget`)** — There is no local UI state needed for the goals list; the period selector used by budgets is absent. Dialogs are async methods on the widget class. The alternative was `ConsumerStatefulWidget`. Rejected: state is only needed when local variables must persist across builds. `ConsumerWidget` + async dialog methods is simpler.

## Constraints

- **`@@unique([userId, categoryId, month, year])`** — enforced by Prisma schema; duplicate creation returns P2002, wrapped as 409 `ConflictException` in the use case
- **`amountLimit` must be positive** — enforced by `@IsPositive()` on `CreateBudgetDto` and `UpdateBudgetDto`
- **`month` range 1–12** — enforced by `@Min(1) @Max(12)` on `CreateBudgetDto` and `ListBudgetsDto`
- **`year` range 2000–3000** — enforced by `@Min(2000) @Max(3000)` on `CreateBudgetDto` and `ListBudgetsDto`
- **`deletedAt: null` on all queries** — enforced in `PrismaBudgetsRepository` on every `findMany`, `findFirst`, and the `currentSpent` aggregate `where` clause; no transparent soft-delete middleware
- **`Decimal` → `number` conversion at repository boundary** — `amountLimit.toNumber()` and `_sum.amount?.toNumber()` called in `toEntity()`; application and domain layers never see Prisma `Decimal`
- **Goal detail screen deferred** — US-022 (contribution history, progress chart, completion projection) is P2 and was not implemented in this phase
