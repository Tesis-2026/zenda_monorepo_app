# References: Phase 6 — Budget and Financial Goal Management

## Key Files

### Backend — New Files

| File | Change |
|---|---|
| `zenda_backend_app/src/modules/budgets/domain/budget.entity.ts` | New: `BudgetEntity` — id, userId, categoryId, categoryName, amountLimit, month, year, currentSpent; computed `percentageUsed` getter |
| `zenda_backend_app/src/modules/budgets/domain/ports/budget.repository.ts` | New: `IBudgetRepository` abstract class — `create`, `findAll`, `findById`, `update`, `softDelete` |
| `zenda_backend_app/src/modules/budgets/application/use-cases/create-budget.use-case.ts` | New: `CreateBudgetUseCase` — creates budget; wraps P2002 as `ConflictException` |
| `zenda_backend_app/src/modules/budgets/application/use-cases/list-budgets.use-case.ts` | New: `ListBudgetsUseCase` — lists budgets with optional month/year filter |
| `zenda_backend_app/src/modules/budgets/application/use-cases/update-budget.use-case.ts` | New: `UpdateBudgetUseCase` — ownership check then updates amountLimit |
| `zenda_backend_app/src/modules/budgets/application/use-cases/delete-budget.use-case.ts` | New: `DeleteBudgetUseCase` — ownership check then soft delete |
| `zenda_backend_app/src/modules/budgets/infrastructure/persistence/prisma-budgets.repository.ts` | New: `PrismaBudgetsRepository` — `toEntity()` computes `currentSpent` via `aggregate` query on transactions |
| `zenda_backend_app/src/modules/budgets/interface/dto/create-budget.dto.ts` | New: `CreateBudgetDto` — `categoryId?` (UUID), `amountLimit` (positive number), `month` (1–12), `year` (2000–3000) |
| `zenda_backend_app/src/modules/budgets/interface/dto/update-budget.dto.ts` | New: `UpdateBudgetDto` — `amountLimit` (positive number) |
| `zenda_backend_app/src/modules/budgets/interface/dto/budget.response.dto.ts` | New: `BudgetResponseDto` — all entity fields + `currentSpent`, `percentageUsed`, `categoryName` |
| `zenda_backend_app/src/modules/budgets/interface/dto/list-budgets.dto.ts` | New: `ListBudgetsDto` — optional `month` and `year` with `@Type(() => Number)` for query string coercion |
| `zenda_backend_app/src/modules/budgets/interface/budgets.controller.ts` | New: `BudgetsController` at `/budgets` — POST, GET (with optional month/year), PUT /:id, DELETE /:id |
| `zenda_backend_app/src/modules/budgets/budgets.module.ts` | New: `BudgetsModule` — wires `IBudgetRepository`, 4 use cases, `BudgetsController` |

### Backend — Modified Files

| File | Change |
|---|---|
| `zenda_backend_app/src/app.module.ts` | Added `BudgetsModule` to imports |

### Frontend — New Files

| File | Change |
|---|---|
| `zenda_fronted_app/lib/core/models/budget.dart` | New: `Budget` model with `fromJson` factory |
| `zenda_fronted_app/lib/core/models/savings_goal.dart` | New: `SavingsGoal` model with `fromJson` factory and computed `progressPercent` getter |
| `zenda_fronted_app/lib/core/services/budget_api_service.dart` | New: `BudgetApiService` — `getAll`, `create`, `update`, `delete` |
| `zenda_fronted_app/lib/core/services/goals_api_service.dart` | New: `GoalsApiService` — `getAll`, `create`, `contribute`, `delete` |
| `zenda_fronted_app/lib/features/budget/budget_screen.dart` | New: `BudgetScreen` — month/year selector, progress bars (green/yellow/red), create/edit/delete modals, `_BudgetCard`, `_MonthSelector`, `_EmptyState` |
| `zenda_fronted_app/lib/features/goals/goals_screen.dart` | New: `GoalsScreen` — goal cards with progress bars, contribute modal, create/delete modals, `_GoalCard`, `_EmptyState` |

### Frontend — Modified Files

| File | Change |
|---|---|
| `zenda_fronted_app/lib/routing/app_router.dart` | Added `GoRoute(path: '/budgets')` and `GoRoute(path: '/goals')` |
| `zenda_fronted_app/lib/features/dashboard/dashboard_screen.dart` | Added Budgets and Goals `ListTile` entries to `_PerfilSection` |
| `zenda_fronted_app/lib/l10n/app_en.arb` | Added 22 keys: `profileBudgets`, `profileGoals`, 14 `budget*` keys, 6 `goals*` keys |
| `zenda_fronted_app/lib/l10n/app_es.arb` | Same 22 keys in Spanish |
| `zenda_fronted_app/lib/l10n/app_localizations.dart` | Auto-generated: abstract getters for all 22 new keys |
| `zenda_fronted_app/lib/l10n/app_localizations_en.dart` | Auto-generated: English implementations |
| `zenda_fronted_app/lib/l10n/app_localizations_es.dart` | Auto-generated: Spanish implementations |

### Root Monorepo — Modified Files

| File | Change |
|---|---|
| `.claude/agent-os/product/roadmap.md` | Marked Phase 6 P0 and P1 tasks as `[x]` complete; updated timeline row to `✅ Done (goal detail screen deferred to P2)` |

## Test Files

No test files were created in this phase.

## Standards Applied

- `skills/platform/platform-backend/domain-driven-design-nestjs/SKILL.md` — domain port defined before implementation; ownership verified at use-case layer; no NestJS decorators in domain layer
- `skills/_drafts/framework/tech-prisma/SKILL.md` — `deletedAt: null` on all queries; `Decimal` converted at repository boundary; no `PrismaService` in application layer
- `skills/platform/platform-mobile/flutter/SKILLS.md` — `ConsumerStatefulWidget` for budget screen (has local state); `ConsumerWidget` for goals screen (no local state); all strings via `context.l10n`; `.when(data, loading, error)` fully handled
- `skills/universal/lang-typescript/SKILL.md` — strict types throughout; no `any`; typed command interfaces per use case
- `skills/assistant/pre-work-audit/SKILL.md` — pre-audit confirmed backend and frontend were clean before implementation; post-audit confirmed zero new errors
