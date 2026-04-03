# Shape: Phase 3 — Transaction Recording

## Decisions

- **Fire-and-forget backend sync** — `NewTransactionController.save()` writes to SharedPreferences first, then calls the API in a try/catch that swallows all errors. Local storage is the source of truth. Alternative considered: fail the save if backend is unreachable. Rejected because: the app targets students on mobile networks with intermittent connectivity; blocking UX on a network call would degrade the core recording flow.

- **Category name mapping at the service layer** — `categoryToApiName()` lives in `TransactionApiService`, not in the model or controller. The Flutter `TransactionCategory` enum retains Spanish names for serialization compatibility (existing local data). Alternative: rename enum values to English. Rejected because: renaming would break all existing SharedPreferences data stored with Spanish enum values.

- **TransactionListScreen loads from backend, not local** — The list screen calls `GET /api/transactions` rather than reading from `TransactionsRepository`. Reason: the backend is the authoritative record for all synced transactions; local storage may be stale or partial. The `AddTransactionScreen` fire-and-forget sync ensures backend receives new entries.

- **`FutureProvider.autoDispose` for transaction list** — The list provider is autoDispose so it re-fetches each time the screen is opened. Alternative: a persistent `AsyncNotifierProvider` with manual invalidation. Chosen autoDispose because: list accuracy (after creates/deletes) matters more than avoiding re-fetches; screen-mount refetch is the simplest correct behavior.

- **Dismissible swipe-to-delete with confirmation dialog** — DELETE requires a confirmation dialog before API call. Alternative: undo toast (Slack-style). Rejected: undo requires a delay window + cancellation state; harder to implement correctly and backend uses soft deletes anyway, but the UI doesn't expose recovery.

- **Date range filter computed client-side** — "This week" and "This month" are computed to `from`/`to` ISO timestamps in the widget and passed as query params. Alternative: enum param (`period=week`). Chosen ISO timestamps because: the backend `GET /api/transactions` already accepts `from`/`to`; no backend change needed.

- **`UpdateTransactionUseCase` rejects future `occurredAt`** — Validated in the use case before the database write. Alternative: allow future dates for scheduled transactions. Rejected: Phase 3 scope is recording past/present transactions; scheduled transactions are out of scope.

- **`newCategoryName` for category re-resolution on update** — `PUT /api/transactions/:id` accepts `newCategoryName` (string) rather than `categoryId` (UUID). `ResolveCategoryUseCase` looks up or creates the category. Alternative: require `categoryId` from the client. Rejected: the Flutter client only knows display names, not UUIDs; requiring UUID lookups on the client would add an extra round-trip.

## Constraints

- `update()` repository method verifies ownership before patching — enforced at service layer, not just DB query
- Transfers (`TransactionKind.transfer`) are never sent to the backend — enforced in `TransactionApiService.create()` with an early return
- `occurredAt` cannot be in the future — enforced in `UpdateTransactionUseCase` before the DB write
- Category mapping must cover all 11 `TransactionCategory` enum cases — enforced by exhaustive Dart switch (compile-time error on missing cases)
