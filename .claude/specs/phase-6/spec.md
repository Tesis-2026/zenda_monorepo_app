# Phase 6: Budget and Financial Goal Management

## Context

Before this phase, users could record transactions and view reports (Phases 3–5), but had no way to set spending limits or track savings targets. The Budget model and `@@unique` constraint had been defined in Phase 1B, and the Goals backend (create, list, contribute, delete) was implemented in Phase 3. Phase 6 closes the gap by adding the Budget CRUD backend, and building dedicated Flutter screens for both budgets and goals.

User stories covered: US-0501 (budget management), US-0502 (savings goals frontend), US-0503 (goal detail screen).

## Tasks Completed

1. `zenda_backend_app/src/modules/budgets/domain/budget.entity.ts` — New: `BudgetEntity` with `currentSpent` and computed `percentageUsed` getter
2. `zenda_backend_app/src/modules/budgets/domain/ports/budget.repository.ts` — New: `IBudgetRepository` abstract class with `create`, `findAll`, `findById`, `update`, `softDelete`
3. `zenda_backend_app/src/modules/budgets/application/use-cases/create-budget.use-case.ts` — New: creates budget, wraps Prisma P2002 as `ConflictException`
4. `zenda_backend_app/src/modules/budgets/application/use-cases/list-budgets.use-case.ts` — New: lists budgets with optional month/year filter
5. `zenda_backend_app/src/modules/budgets/application/use-cases/update-budget.use-case.ts` — New: updates `amountLimit`, checks ownership via `findById` first
6. `zenda_backend_app/src/modules/budgets/application/use-cases/delete-budget.use-case.ts` — New: ownership check then soft delete
7. `zenda_backend_app/src/modules/budgets/infrastructure/persistence/prisma-budgets.repository.ts` — New: `PrismaBudgetsRepository`; computes `currentSpent` per budget via separate `aggregate` query in `toEntity()`
8. `zenda_backend_app/src/modules/budgets/interface/dto/create-budget.dto.ts` — New: `categoryId?`, `amountLimit`, `month` (1–12), `year` (2000–3000)
9. `zenda_backend_app/src/modules/budgets/interface/dto/update-budget.dto.ts` — New: `amountLimit`
10. `zenda_backend_app/src/modules/budgets/interface/dto/budget.response.dto.ts` — New: all fields including `currentSpent`, `percentageUsed`, `categoryName`
11. `zenda_backend_app/src/modules/budgets/interface/dto/list-budgets.dto.ts` — New: optional `month` and `year` query params via `@Type(() => Number)` + `@IsInt`
12. `zenda_backend_app/src/modules/budgets/interface/budgets.controller.ts` — New: `BudgetsController` at `/budgets` — POST, GET, PUT /:id, DELETE /:id
13. `zenda_backend_app/src/modules/budgets/budgets.module.ts` — New: module wiring repository, 4 use cases, controller
14. `zenda_backend_app/src/app.module.ts` — Added `BudgetsModule` import
15. `zenda_fronted_app/lib/core/models/budget.dart` — New: `Budget` model with `fromJson` factory
16. `zenda_fronted_app/lib/core/models/savings_goal.dart` — New: `SavingsGoal` model with `fromJson` factory and computed `progressPercent`
17. `zenda_fronted_app/lib/core/services/budget_api_service.dart` — New: `BudgetApiService` — `getAll`, `create`, `update`, `delete`
18. `zenda_fronted_app/lib/core/services/goals_api_service.dart` — New: `GoalsApiService` — `getAll`, `create`, `contribute`, `delete`, `getContributions`; includes `GoalContribution` model
19. `zenda_fronted_app/lib/features/budget/budget_screen.dart` — New: `BudgetScreen` — month/year selector, progress bars (green/yellow/red), create modal, edit modal, delete confirm
20. `zenda_fronted_app/lib/features/goals/goals_screen.dart` — New: `GoalsScreen` — goal cards with progress bars, contribute modal, create modal, delete confirm; card tap navigates to goal detail
21. `zenda_fronted_app/lib/features/goals/goal_detail_screen.dart` — New: `GoalDetailScreen` — summary card, cumulative fl_chart, contribution history list, completion projection banner, alert banner for overdue goals
22. `zenda_fronted_app/lib/routing/app_router.dart` — Added `/budgets`, `/goals`, and `/goals/:id` (goal detail) routes; imports `GoalDetailScreen` and `SavingsGoal`
23. `zenda_fronted_app/lib/features/dashboard/dashboard_screen.dart` — Added Budgets and Goals navigation tiles to `_PerfilSection`
24. `zenda_fronted_app/lib/l10n/app_en.arb` — 29 new keys: `profileBudgets`, `profileGoals`, `budget*` (14), `goals*` (8), `goalsDetail*` (7)
25. `zenda_fronted_app/lib/l10n/app_es.arb` — Same 29 keys in Spanish

## What Was Built

### Budget CRUD (US-0501)

`GET /api/budgets?month=M&year=Y` returns all budgets for the authenticated user, enriched with current spending:

| Field | Type | Description |
|---|---|---|
| `id` | `string` | UUID |
| `categoryId` | `string \| null` | Null = global budget for all categories |
| `categoryName` | `string \| null` | Category name joined from Category table |
| `amountLimit` | `number` | Max spend in PEN |
| `month` | `number` | 1–12 |
| `year` | `number` | e.g. 2026 |
| `currentSpent` | `number` | Sum of EXPENSE transactions in period |
| `percentageUsed` | `number` | `currentSpent / amountLimit * 100`, capped at 100 |

| Endpoint | Description |
|---|---|
| `POST /api/budgets` | Create budget; 409 if duplicate (categoryId+month+year) |
| `GET /api/budgets?month=&year=` | List budgets with spending; month/year filters optional |
| `PUT /api/budgets/:id` | Update amountLimit |
| `DELETE /api/budgets/:id` | Soft delete |

### BudgetScreen (US-0501)

Accessible via `/budgets`, linked from the Profile tab.

- Month/year selector (← / → navigation)
- Cards showing category name, progress bar, S/ spent of S/ limit, percentage
- Progress bar color: green (< 70%), yellow (70–89%), red (≥ 90%)
- FAB opens creation modal: category dropdown (all system + custom categories), amount field, month/year dropdowns
- Edit icon on each card to update amountLimit
- Delete icon with confirm dialog

### GoalsScreen (US-0502)

Accessible via `/goals`, linked from the Profile tab.

- Cards showing goal name, indigo progress bar, S/ current of S/ target
- "Add contribution" button triggers a modal to enter the contribution amount
- Completed goals (100%) show a green checkmark and hide the contribute button
- FAB opens creation modal: name field, target amount field
- Delete icon with confirm dialog
- Tapping a card navigates to `/goals/:id` (GoalDetailScreen), passing the `SavingsGoal` object via GoRouter `extra`

### GoalDetailScreen (US-0503)

Accessible via `/goals/:id`, reached by tapping any goal card in GoalsScreen.

- Summary card: goal name, progress bar (indigo/green), S/ current of S/ target, percentage
- Cumulative progress chart (fl_chart LineChart): actual savings vs target line, shows growth over time; hidden when no contributions
- Projection banner: computes average daily contribution rate; shows projected completion date or an overdue alert when a `dueDate` is set
- Contribution history: reversed list of all `GoalContribution` records fetched from `GET /api/goals/:id/contributions`; shows amount and date
- Empty state text when no contributions yet
