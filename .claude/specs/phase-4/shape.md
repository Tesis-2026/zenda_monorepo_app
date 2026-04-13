# Shape: Phase 4 — Categorization System

## Decisions

- **`update()` repo method takes `id` and `name` directly (not a params object)** — two-argument flat signature is idiomatic for a single-field patch. Alternative: `update(id, userId, params: { name })` with userId in the signature. Rejected: ownership verification happens in the use case before the DB call, so the repository does not need userId; keeping the repo method minimal respects the separation of concerns.

- **Ownership check is done in `UpdateCategoryUseCase`, not in the repository** — `findById(id, userId)` returns the entity if accessible; the use case then calls `isOwnedBy(userId)` to distinguish "not found" from "found but system". Alternative: add an `updateCustom(id, userId, name)` repository method that embeds both checks. Rejected: business rules (who can rename what) belong in the use case, not in infrastructure.

- **Name-collision check uses `findByNameForUser` (case-insensitive)** — reuses the same lookup used by `CreateCategoryUseCase`. Alternative: add a DB unique constraint `@@unique([userId, name])`. Rejected: DB constraint would also prevent two users from having categories with the same name, which is allowed; also, handling `P2002` in the use case is less clear than an explicit pre-check.

- **`CategoryManagementScreen` uses `FutureProvider.autoDispose`** — same pattern as `TransactionListScreen` from Phase 3. Fresh data on every mount; `ref.invalidate()` for explicit refresh after mutations. Alternative: a persistent `AsyncNotifierProvider` with manual state mutation after each CRUD. Rejected: the list is short and fast to re-fetch; optimistic updates would require rollback logic.

- **Category management is navigated from `ProfileScreen` via `context.push`** — pushes onto the nav stack so back navigation works naturally. Alternative: add a 5th tab to the dashboard. Rejected: 5 tabs is too crowded; categories are a settings-like concern, not a primary navigation destination.

- **Delete failure re-invalidates the provider** — when `Dismissible.onDismissed` fires, the tile is already gone from the UI. If the API call fails, the provider is re-invalidated to restore the list. Alternative: wrap in a try/catch that prevents dismissal. Rejected: `Dismissible.onDismissed` fires after animation completes; preventing it requires `confirmDismiss` to return false, which is already used for the confirmation dialog — the guard is separate from the network call.

## Constraints

- SYSTEM categories cannot be renamed — enforced in `UpdateCategoryUseCase.execute()` via `isOwnedBy()` → `ForbiddenException`
- SYSTEM categories cannot be deleted — enforced in `DeleteCategoryUseCase.execute()` via `isOwnedBy()` → `ForbiddenException`
- Category names are max 40 characters — enforced in `CreateCategoryDto`, `UpdateCategoryDto` via `@MaxLength(40)`, and in Flutter text fields via `maxLength: 40`
- Name uniqueness is per-user (case-insensitive) — enforced at use-case level for both create and update
