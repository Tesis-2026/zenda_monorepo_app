# Standards Applied: Phase 4 — Categorization System

## Backend

- **Single-field patch keeps repo method minimal**: `update(id, name)` patches only what changes. The use case owns the validation logic; the repository owns the DB operation.
- **Use case pre-checks before write**: ownership verified → name collision checked → then `repo.update()`. Order matters: `NotFoundException` before `ForbiddenException` avoids leaking whether a resource exists.
- **Reuse existing `findByNameForUser` for collision detection**: no new repository method for a check that `CreateCategoryUseCase` already uses. Three duplicates rule — not there yet; reuse instead.

## Frontend

- **`CategoryModel` is a plain Dart class with `fromJson`**: no framework imports, no Riverpod. Pure data layer. Matches the same pattern as `TransactionModel`, `User`, `Account`.
- **Service layer for all API calls**: `CategoryApiService` wraps all four HTTP verbs. The screen never calls `ApiClient` directly.
- **Provider per screen, autoDispose**: `_categoriesProvider` is file-private (underscore prefix) and autoDispose. Not exported — no other screen needs this state.
- **Mutations invalidate the provider**: all create/rename/delete operations call `ref.invalidate(_categoriesProvider)` after success, triggering a fresh fetch. No manual list mutation.
- **`Dismissible.confirmDismiss` for delete confirmation**: the confirmation dialog is the gate for the dismissal animation. If the user cancels, the tile snaps back. Network call happens in `onDismissed` after confirmation.
- **All UI strings via `context.l10n`**: no string literals in `build()` methods. All 12 new ARB keys added in both `app_en.arb` and `app_es.arb` before use.

## Navigation

- **`context.push` for sub-screen navigation**: pushes onto the GoRouter stack so the back button works without router configuration. `context.go` would replace the current route.
