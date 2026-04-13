# Standards Applied: Phase 3 — Transaction Recording

## Backend

- **Ownership guard in repository**: Every query that touches a specific record includes `userId` in the WHERE clause. Never trust the `:id` param alone.
- **Use case throws domain exceptions**: `GetTransactionUseCase` throws `NotFoundException` (NestJS built-in) when record not found or owned by another user. Controllers do not contain null-checks.
- **Optional-fields DTO**: `UpdateTransactionDto` marks all fields `@IsOptional()`. The use case accepts a partial command and only patches provided fields.
- **Category resolution indirection**: The controller never resolves categories directly. It delegates to `UpdateTransactionUseCase`, which delegates to `ResolveCategoryUseCase`.
- **Future-date guard in use case**: Business rule (no future dates) lives in the use case, not in the DTO validator. DTOs validate shape; use cases validate business rules.

## Frontend

- **Local-first, backend-async**: Local write is always the primary path. Backend sync is always fire-and-forget in a try/catch.
- **Service boundary for API name mapping**: `categoryToApiName()` is in `TransactionApiService`. Models and controllers do not know about backend naming conventions.
- **`FutureProvider.autoDispose` for remote data**: Used for screens that need fresh data on every mount and don't need to survive navigation.
- **`ref.invalidateSelf()` for pull-to-refresh**: Providers expose a method that calls `ref.invalidateSelf()`. Widgets call the method on `RefreshIndicator.onRefresh`. No direct provider manipulation in widgets.
- **All UI strings via `context.l10n`**: No string literals in `build()` methods. New ARB keys added in both `app_en.arb` and `app_es.arb` before use.

## API Client

- **`ApiClient.delete()` returns void**: Delete endpoints return 204; the client method returns `Future<void>`. Callers do not inspect the response body.
- **`ApiClient.getList()` returns `List<dynamic>`**: List endpoints return a JSON array. Caller is responsible for casting to the correct type.
