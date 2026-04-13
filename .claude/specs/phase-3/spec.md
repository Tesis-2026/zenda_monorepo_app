# Phase 3: Transaction Recording (Core Feature)

## Context

Phase 2 delivered a complete auth + profile system with local-first transaction storage (SharedPreferences). Phase 3 closes the gap between local-only transactions and a fully synced backend, and adds the transaction history UI (list, filters, delete). It also adds the missing GET/:id and PUT/:id endpoints to the backend so individual transactions can be viewed and edited.

User stories covered: US-0201, US-0202, US-0203, US-0204, US-0205, US-0206.

## Tasks Completed

1. `zenda_backend_app/src/modules/transactions/domain/ports/transaction.repository.ts` — added `UpdateTransactionParams` interface and two new abstract methods: `findByIdWithCategory` and `update`
2. `zenda_backend_app/src/modules/transactions/infrastructure/persistence/prisma-transaction.repository.ts` — implemented `findByIdWithCategory` and `update` with ownership verification
3. `zenda_backend_app/src/modules/transactions/application/use-cases/get-transaction.use-case.ts` — created `GetTransactionUseCase` (finds by id+userId, throws 404 if not found)
4. `zenda_backend_app/src/modules/transactions/application/use-cases/update-transaction.use-case.ts` — created `UpdateTransactionUseCase` with `UpdateTransactionCommand`, optional category re-resolution, future-date guard
5. `zenda_backend_app/src/modules/transactions/interface/dto/update-transaction.dto.ts` — created with all optional fields + class-validator decorators
6. `zenda_backend_app/src/modules/transactions/interface/transactions.controller.ts` — added `@Get(':id')` and `@Put(':id')` endpoints
7. `zenda_backend_app/src/modules/transactions/transactions.module.ts` — registered `GetTransactionUseCase` and `UpdateTransactionUseCase`
8. `zenda_fronted_app/lib/services/transactions_service.dart` — fixed 3 pre-existing errors: missing `accountId`/`kind` args, non-exhaustive switch for all `TransactionCategory` cases
9. `zenda_fronted_app/lib/core/services/transaction_api_service.dart` — created `TransactionApiService` with `categoryToApiName()` mapper, `create()`, `getAll()`, `delete()` methods
10. `zenda_fronted_app/lib/core/services/api_client.dart` — added `getList()` and `delete()` methods
11. `zenda_fronted_app/lib/providers/repositories_providers.dart` — added `transactionApiServiceProvider`
12. `zenda_fronted_app/lib/features/transactions/controllers/new_transaction_controller.dart` — updated `save()` to fire-and-forget backend sync after local save
13. `zenda_fronted_app/lib/features/transactions/transaction_list_screen.dart` — full implementation (was stub): `FutureProvider.autoDispose`, type + date filters, Dismissible swipe-to-delete, pull-to-refresh, category icons, all strings via `context.l10n`
14. `zenda_fronted_app/lib/features/dashboard/dashboard_screen.dart` — Transactions tab now renders `TransactionListScreen`
15. `zenda_fronted_app/lib/l10n/app_en.arb` — added 13 new keys for the list screen
16. `zenda_fronted_app/lib/l10n/app_es.arb` — mirrored all 13 new keys in Spanish

## What Was Built

### Transaction API — GET/:id and PUT/:id (US-0205, US-0206)

| Endpoint | Method | Guard | Use Case |
|----------|--------|-------|----------|
| `/api/transactions/:id` | GET | JwtAuthGuard | GetTransactionUseCase |
| `/api/transactions/:id` | PUT | JwtAuthGuard | UpdateTransactionUseCase |

`GetTransactionUseCase` calls `repo.findByIdWithCategory(id, userId)`. Returns 404 if not found or belongs to another user.

`UpdateTransactionUseCase` accepts `UpdateTransactionCommand` (all fields optional). Category is re-resolved via `ResolveCategoryUseCase` if `newCategoryName` is provided. `occurredAt` rejects future dates.

### Backend Sync — Fire-and-Forget (US-0201)

`NewTransactionController.save()` saves locally first (SharedPreferences, always succeeds), then calls `TransactionApiService.create()` in a try/catch that swallows failures. Transfers are excluded (backend only supports INCOME/EXPENSE).

Category name mapping from Flutter enum (Spanish) to backend (English):

| Flutter enum | API name |
|---|---|
| `comida` | Food |
| `transporte` | Transportation |
| `vivienda` | Housing |
| `servicios` | Utilities |
| `salud` | Health |
| `ocio` | Entertainment |
| `compras` | Shopping |
| `suscripciones` | Subscriptions |
| `antojos` | Cravings |
| `ahorro` | Savings |
| `otros` | Other |

### TransactionListScreen (US-0203)

- Loads from `GET /api/transactions` with `type` (EXPENSE/INCOME) and date range (`from`/`to`) query params
- Type filter chips: All / Expenses / Income
- Date range chips: This week / This month / All time
- Swipe-to-delete with confirmation dialog → `DELETE /api/transactions/:id`
- Pull-to-refresh invalidates the provider
- Category icon mapped from backend category name string
- All user-facing strings via `context.l10n`
