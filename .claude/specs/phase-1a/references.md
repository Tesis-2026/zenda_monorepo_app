# References: Phase 1A — Backend Scaffolding and Core Infrastructure

## Key Files

| File | Change |
|------|--------|
| `zenda_backend_app/prisma/schema.prisma` | Created — initial schema with `CategoryType` enum and 4 models: `User`, `Category`, `Transaction` (type as String), `SavingsGoal` |
| `zenda_backend_app/prisma/seed.ts` | Created — initial idempotent seed with 14 system categories (9 expense, 5 income) |
| `zenda_backend_app/docker-compose.yml` | Created — PostgreSQL 15 service with named volume; all credentials and port driven by env vars |
| `zenda_backend_app/.env.example` | Created — all env vars documented with safe development defaults |
| `zenda_backend_app/src/main.ts` | Created — NestJS bootstrap: Helmet, CORS regex, global ValidationPipe, Swagger at `/api/docs`, global prefix `/api` |
| `zenda_backend_app/src/app.module.ts` | Created — root module: ConfigModule, ThrottlerModule, PrismaModule, AiModule, all feature modules; global AppLogger, GlobalExceptionFilter, RequestLoggingInterceptor |
| `zenda_backend_app/src/common/config/configuration.ts` | Created — typed config factory for app, database, auth, and Azure OpenAI settings |
| `zenda_backend_app/src/common/logger/app-logger.service.ts` | Created — `AppLogger` extends `ConsoleLogger`; used as the NestJS application logger |
| `zenda_backend_app/src/common/logger/request-logging.interceptor.ts` | Created — logs method, path, status code, and response time for every request |
| `zenda_backend_app/src/common/exceptions/global-exception.filter.ts` | Created — catches all exceptions; normalises to `{ statusCode, message, path, timestamp }` |
| `zenda_backend_app/src/common/dto/success-response.dto.ts` | Created — shared `{ success: boolean }` DTO used by delete endpoints |
| `zenda_backend_app/src/health/health.controller.ts` | Created — `GET /api/health` returns status, ISO timestamp, and app version |
| `zenda_backend_app/src/infra/prisma/prisma.module.ts` | Created — global module exporting `PrismaService` |
| `zenda_backend_app/src/infra/prisma/prisma.service.ts` | Created — extends `PrismaClient`; connects on `onModuleInit`, disconnects on `onModuleDestroy` |
| `zenda_backend_app/src/infra/ai/ai.module.ts` | Created — placeholder module with `AiProvider` and `LocalRulesProvider` stubs |
| `zenda_backend_app/src/modules/auth/auth.module.ts` | Created — wires `JwtModule`, `PassportModule`, `PrismaUserRepository`, `RegisterUseCase`, `LoginUseCase`, `JwtStrategy` |
| `zenda_backend_app/src/modules/auth/infrastructure/jwt.strategy.ts` | Created — Passport JWT strategy extracting Bearer token; validates against `JWT_SECRET` |
| `zenda_backend_app/src/modules/auth/infrastructure/jwt-auth.guard.ts` | Created — `AuthGuard('jwt')` wrapper applied to all protected controllers |
| `zenda_backend_app/src/modules/auth/infrastructure/persistence/prisma-user.repository.ts` | Created — Prisma implementation of `IUserRepository` |
| `zenda_backend_app/src/modules/auth/interface/decorators/user-id.decorator.ts` | Created — extracts `request.user.sub` from JWT payload; used in all protected controllers |
| `zenda_backend_app/src/modules/auth/interface/decorators/current-user.decorator.ts` | Created — extracts full JWT payload object |
| `zenda_backend_app/src/modules/auth/interface/dto/register.dto.ts` | Created — `email`, `password`, `fullName` with validation |
| `zenda_backend_app/src/modules/auth/interface/dto/login.dto.ts` | Created — `email`, `password` with validation |
| `zenda_backend_app/src/modules/auth/interface/dto/auth-token.response.dto.ts` | Created — `{ accessToken: string }` response shape |
| `zenda_backend_app/src/modules/auth/application/use-cases/register.use-case.ts` | Created — checks duplicate email, hashes password, creates user, returns JWT |
| `zenda_backend_app/src/modules/auth/application/use-cases/login.use-case.ts` | Created — finds user by email, verifies bcrypt hash, returns JWT |
| `zenda_backend_app/src/modules/auth/domain/user.entity.ts` | Created — `UserEntity` domain class |
| `zenda_backend_app/src/modules/auth/domain/ports/user.repository.ts` | Created — `IUserRepository` abstract class: `findByEmail`, `create` |
| `zenda_backend_app/src/modules/auth/types/jwt-payload.type.ts` | Created — `{ sub: string; email: string }` type used by `JwtStrategy` |
| `zenda_backend_app/src/modules/categories/categories.module.ts` | Created — wires `PrismaCategoryRepository`, all category use cases, `CategoriesController` |
| `zenda_backend_app/src/modules/categories/interface/categories.controller.ts` | Created — POST / GET / DELETE endpoints with JWT guard and `@UserId()` |
| `zenda_backend_app/src/modules/categories/interface/dto/create-category.dto.ts` | Created — `name` with max-length validation |
| `zenda_backend_app/src/modules/categories/interface/dto/category.response.dto.ts` | Created — full category response shape |
| `zenda_backend_app/src/modules/categories/application/use-cases/create-category.use-case.ts` | Created — checks for duplicate name, creates CUSTOM category |
| `zenda_backend_app/src/modules/categories/application/use-cases/list-categories.use-case.ts` | Created — returns SYSTEM + user's CUSTOM categories ordered by type then name |
| `zenda_backend_app/src/modules/categories/application/use-cases/delete-category.use-case.ts` | Created — soft-deletes CUSTOM categories owned by the user |
| `zenda_backend_app/src/modules/categories/application/use-cases/resolve-category.use-case.ts` | Created — resolves `categoryId` or `newCategoryName` to a `CategoryEntity`; auto-creates if name not found |
| `zenda_backend_app/src/modules/categories/domain/category.entity.ts` | Created — `CategoryEntity` with `isOwnedBy` and `isAccessibleBy` |
| `zenda_backend_app/src/modules/categories/domain/ports/category.repository.ts` | Created — `ICategoryRepository` abstract class |
| `zenda_backend_app/src/modules/categories/infrastructure/persistence/prisma-category.repository.ts` | Created — Prisma implementation |
| `zenda_backend_app/src/modules/transactions/transactions.module.ts` | Created — imports `CategoriesModule`; wires repository, use cases, controller |
| `zenda_backend_app/src/modules/transactions/interface/transactions.controller.ts` | Created — POST / GET / DELETE with DTO mappers |
| `zenda_backend_app/src/modules/transactions/interface/dto/create-transaction.dto.ts` | Created — full transaction input validation including `@IsEnum(TransactionType)` |
| `zenda_backend_app/src/modules/transactions/interface/dto/list-transactions.dto.ts` | Created — optional date range, type, categoryId filters |
| `zenda_backend_app/src/modules/transactions/interface/dto/transaction.response.dto.ts` | Created — full transaction response including nested category |
| `zenda_backend_app/src/modules/transactions/application/use-cases/create-transaction.use-case.ts` | Created — validates date, resolves category, persists transaction |
| `zenda_backend_app/src/modules/transactions/application/use-cases/list-transactions.use-case.ts` | Created — delegates to repository with filter object |
| `zenda_backend_app/src/modules/transactions/application/use-cases/delete-transaction.use-case.ts` | Created — finds by id + userId, soft-deletes |
| `zenda_backend_app/src/modules/transactions/domain/transaction.entity.ts` | Created — `TransactionEntity` with `isOwnedBy` |
| `zenda_backend_app/src/modules/transactions/domain/ports/transaction.repository.ts` | Created — `ITransactionRepository` + `TransactionWithCategory` interface |
| `zenda_backend_app/src/modules/transactions/infrastructure/persistence/prisma-transaction.repository.ts` | Created — Prisma implementation with category include |
| `zenda_backend_app/src/modules/goals/goals.module.ts` | Created — wires repository, use cases, controller |
| `zenda_backend_app/src/modules/goals/interface/goals.controller.ts` | Created — POST / GET / POST contribute / DELETE with DTO mappers |
| `zenda_backend_app/src/modules/goals/interface/dto/create-goal.dto.ts` | Created — `name`, `targetAmount`, optional `dueDate` |
| `zenda_backend_app/src/modules/goals/interface/dto/contribute-goal.dto.ts` | Created — `amount` with min validation |
| `zenda_backend_app/src/modules/goals/interface/dto/goal.response.dto.ts` | Created — full goal response shape |
| `zenda_backend_app/src/modules/goals/application/use-cases/create-goal.use-case.ts` | Created — creates savings goal for user |
| `zenda_backend_app/src/modules/goals/application/use-cases/list-goals.use-case.ts` | Created — returns all non-deleted goals ordered by createdAt desc |
| `zenda_backend_app/src/modules/goals/application/use-cases/contribute-to-goal.use-case.ts` | Created — adds amount to `currentAmount` via entity `contribute()` method |
| `zenda_backend_app/src/modules/goals/application/use-cases/delete-goal.use-case.ts` | Created — soft-deletes goal owned by user |
| `zenda_backend_app/src/modules/goals/domain/savings-goal.entity.ts` | Created — `SavingsGoalEntity` with `progressPercent` getter and `contribute()` method |
| `zenda_backend_app/src/modules/goals/domain/ports/savings-goal.repository.ts` | Created — `ISavingsGoalRepository` abstract class |
| `zenda_backend_app/src/modules/goals/infrastructure/persistence/prisma-goals.repository.ts` | Created — Prisma implementation |
| `zenda_backend_app/src/modules/insights/insights.module.ts` | Created — wires `GetMonthSummaryUseCase` and `SummaryController` |
| `zenda_backend_app/src/modules/insights/interface/summary.controller.ts` | Created — `GET /api/summary/month` with year/month query params |
| `zenda_backend_app/src/modules/insights/interface/dto/month-summary.dto.ts` | Created — year (2000–3000) and month (1–12) with integer validation |
| `zenda_backend_app/src/modules/insights/interface/dto/month-summary.response.dto.ts` | Created — totalIncome, totalExpense, netBalance, topCategories, goalsProgress |
| `zenda_backend_app/src/modules/insights/application/use-cases/get-month-summary.use-case.ts` | Created — parallel queries for income, expense, category breakdown, goals; returns `MonthSummaryResult` |
| `zenda_backend_app/src/modules/users/users.module.ts` | Created — empty placeholder registered in `AppModule` |

## Test Files

No test files were created in this phase.

## Standards Applied

- `skills/universal/lang-typescript/` — strict TypeScript, no `any`, `class-validator` on all inputs, `class-transformer` for query param coercion
- `skills/platform/platform-nestjs/` — one module per domain, global pipes/filters/interceptors in `AppModule`, `APP_FILTER` / `APP_INTERCEPTOR` tokens
- `skills/platform/platform-database/` — UUID PKs, soft deletes, `Decimal(12,2)` for money, `deletedAt: null` on all queries
