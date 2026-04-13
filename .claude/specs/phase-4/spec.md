# Phase 4: Categorization System

## Context

Phase 3 delivered backend transaction CRUD and the Flutter transaction list. The categorization system had its backend seeds, list/create/delete endpoints, and the Flutter category selector in `AddTransactionScreen` all done. Phase 4 closes the remaining gaps: the backend was missing `PUT /api/categories/:id` (rename), and the Flutter app had no management screen for custom categories.

User stories covered: US-0301 (already done), US-0302 (edit endpoint + management screen).

## Tasks Completed

1. `zenda_backend_app/src/modules/categories/domain/ports/category.repository.ts` — added abstract `update(id, name)` method to `ICategoryRepository`
2. `zenda_backend_app/src/modules/categories/infrastructure/persistence/prisma-category.repository.ts` — implemented `update()` using Prisma `category.update`
3. `zenda_backend_app/src/modules/categories/application/use-cases/update-category.use-case.ts` — created with ownership guard, name-collision check, then repo delegation
4. `zenda_backend_app/src/modules/categories/interface/dto/update-category.dto.ts` — `name` field with `@IsString`, `@IsNotEmpty`, `@MaxLength(40)`
5. `zenda_backend_app/src/modules/categories/interface/categories.controller.ts` — added `PUT /api/categories/:id` endpoint
6. `zenda_backend_app/src/modules/categories/categories.module.ts` — registered `UpdateCategoryUseCase`
7. `zenda_fronted_app/lib/core/models/category.dart` — created `CategoryModel` with `id`, `name`, `type` (system/custom)
8. `zenda_fronted_app/lib/core/services/category_api_service.dart` — created with `getAll()`, `create()`, `rename()`, `delete()`
9. `zenda_fronted_app/lib/providers/repositories_providers.dart` — added `categoryApiServiceProvider`
10. `zenda_fronted_app/lib/features/categories/category_management_screen.dart` — created full screen
11. `zenda_fronted_app/lib/routing/app_router.dart` — added `/categories` route
12. `zenda_fronted_app/lib/features/profile/profile_screen.dart` — added "Manage categories" button navigating to `/categories`
13. `zenda_fronted_app/lib/l10n/app_en.arb` — added 12 new keys (`catMgmt*`, `profileManageCategories`)
14. `zenda_fronted_app/lib/l10n/app_es.arb` — mirrored all 12 new keys in Spanish

## What Was Built

### `PUT /api/categories/:id` (US-0302)

`UpdateCategoryUseCase` performs three checks before writing:
1. Fetch by `id` + `userId` — throws `NotFoundException` if not found
2. Check `isOwnedBy(userId)` — throws `ForbiddenException` for SYSTEM categories
3. Check name collision via `findByNameForUser` (case-insensitive) — throws `ConflictException` if another category with that name exists for the user

The repository `update()` patches only the `name` field.

### `CategoryManagementScreen` (US-0302)

Navigation: `ProfileScreen` → button → `context.push('/categories')` → `CategoryManagementScreen`

| Section | Content | Actions |
|---|---|---|
| Default categories | System categories (seeded) | Read-only, lock icon |
| Custom categories | User-created categories | Edit (rename dialog), Swipe-to-delete |

- **Create**: FAB opens a dialog with text field (max 40 chars) → `POST /api/categories`
- **Rename**: Edit icon opens a pre-filled dialog → `PUT /api/categories/:id`
- **Delete**: Swipe left with confirmation dialog → `DELETE /api/categories/:id`
- **Refresh**: Pull-to-refresh via `ref.invalidate(_categoriesProvider)`
- Errors shown via `SnackBar`; provider re-invalidated on delete failure to restore dismissed tile
