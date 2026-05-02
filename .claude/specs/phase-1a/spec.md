# Phase 1A: Backend Scaffolding and Core Infrastructure

## Context

This is the foundation phase. No application code existed before it. The goal was to produce a running NestJS API with authentication, the five core feature modules, shared infrastructure, and a minimal Prisma schema — everything Phase 1B needs in place before expanding the data model. References: US-027, US-028, (infrastructure: JWT guard), US-001, US-005, (infrastructure: insights).

## Tasks Completed

1. `zenda_backend_app/` — NestJS 11 project initialised with TypeScript strict mode
2. `package.json` — dependencies installed: `@nestjs/jwt`, `@nestjs/passport`, `passport-jwt`, `bcrypt`, `prisma`, `@prisma/client`, `class-validator`, `class-transformer`, `@nestjs/swagger`, `helmet`, `@nestjs/throttler`, `@nestjs/config`
3. `prisma/schema.prisma` — initial schema with 4 models: `User`, `Category`, `Transaction`, `SavingsGoal`
4. `prisma/seed.ts` — initial seed with 14 system categories (expense + income)
5. `docker-compose.yml` — PostgreSQL 15 container with named volume; ports driven by env vars
6. `.env.example` — all required env vars documented with safe defaults
7. `src/common/config/configuration.ts` — typed config factory reading `DATABASE_URL`, `JWT_SECRET`, `JWT_EXPIRES_IN`, `BCRYPT_ROUNDS`, `PORT`, `APP_NAME`, `AZURE_OPENAI_ENDPOINT/KEY`
8. `src/common/logger/app-logger.service.ts` — custom `ConsoleLogger` wrapper (`AppLogger`)
9. `src/common/logger/request-logging.interceptor.ts` — global interceptor logging method, path, status, and duration for every request
10. `src/common/exceptions/global-exception.filter.ts` — global filter normalising all exceptions to `{ statusCode, message, path, timestamp }` JSON
11. `src/common/dto/success-response.dto.ts` — shared `{ success: boolean }` response shape
12. `src/health/health.controller.ts` — `GET /api/health` returning status, timestamp, and version
13. `src/infra/prisma/prisma.module.ts` + `prisma.service.ts` — global `PrismaModule` wrapping `PrismaClient` with `onModuleInit` connect and `onModuleDestroy` disconnect
14. `src/infra/ai/ai.module.ts` — placeholder `AiModule` with `AiProvider` and `LocalRulesProvider` stubs for Phase 8
15. `src/modules/auth/` — register + login endpoints with bcrypt password hashing and JWT signing; `JwtStrategy` + `JwtAuthGuard`; `@UserId()` decorator
16. `src/modules/users/users.module.ts` — empty placeholder module registered in `AppModule`
17. `src/modules/categories/` — CRUD for system + custom categories with soft delete; `resolveCategoryForTransaction` helper
18. `src/modules/transactions/` — create/list/soft-delete transactions with category resolution and date filtering
19. `src/modules/goals/` — create/list/contribute/soft-delete savings goals
20. `src/modules/insights/` — `GET /api/summary/month` aggregating income, expense, top-5 categories, goals progress
21. `src/main.ts` — bootstrap with Helmet, CORS (localhost-only regex), global `ValidationPipe` (whitelist + transform), Swagger at `/api/docs`, global prefix `/api`
22. `src/app.module.ts` — root module wiring `ConfigModule`, `ThrottlerModule` (120 req/min), `PrismaModule`, `AiModule`, and all six feature modules; global `AppLogger`, `GlobalExceptionFilter`, `RequestLoggingInterceptor`

## What Was Built

### Initial Prisma Schema (4 models)

| Model | Key fields | Notes |
|-------|-----------|-------|
| `User` | `id` (UUID), `email` (unique), `passwordHash`, `fullName`, `deletedAt?` | Core auth identity |
| `Category` | `id`, `name`, `type` (`CategoryType`), `userId?`, `deletedAt?` | SYSTEM = built-in, CUSTOM = user-created |
| `Transaction` | `id`, `userId`, `categoryId?`, `type` (String at this stage), `amount` (Decimal), `currency`, `description`, `occurredAt`, `deletedAt?` | `type` was a plain string — changed to enum in Phase 1B |
| `SavingsGoal` | `id`, `userId`, `name`, `targetAmount`, `currentAmount`, `dueDate?`, `deletedAt?` | Accumulation tracked via `currentAmount` |

### Auth Module (US-027, US-028)

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/api/auth/register` | POST | None | Hash password (bcrypt), create user, return JWT |
| `/api/auth/login` | POST | None | Verify password, return JWT |

- Rate limited: 10 req/min on register, 20 req/min on login
- JWT payload: `{ sub: userId, email }`

### Categories Module (US-001)

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/api/categories` | POST | JWT | Create a custom category |
| `/api/categories` | GET | JWT | List system + user's custom categories |
| `/api/categories/:id` | DELETE | JWT | Soft-delete a custom category |

- System categories cannot be deleted
- `resolveCategoryForTransaction`: accepts `categoryId` or `newCategoryName`; auto-creates if name not found

### Transactions Module (US-005)

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/api/transactions` | POST | JWT | Create transaction with optional category resolution |
| `/api/transactions` | GET | JWT | List with filters: `from`, `to`, `type`, `categoryId` |
| `/api/transactions/:id` | DELETE | JWT | Soft-delete |

### Goals Module (US-019)

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/api/goals` | POST | JWT | Create a savings goal |
| `/api/goals` | GET | JWT | List goals |
| `/api/goals/:id/contribute` | POST | JWT | Add amount to `currentAmount` |
| `/api/goals/:id` | DELETE | JWT | Soft-delete |

### Insights Module (infrastructure: insights)

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/api/summary/month` | GET | JWT | Income, expense, net balance, top-5 categories, goals progress for a given month/year |

### Cross-cutting Infrastructure

| Component | Purpose |
|-----------|---------|
| `AppLogger` | Structured console logging with context labels |
| `RequestLoggingInterceptor` | Logs every HTTP request with method, path, status, duration |
| `GlobalExceptionFilter` | Normalises all errors to consistent JSON shape |
| `ValidationPipe` | Strips unknown fields (`whitelist`), rejects extra fields (`forbidNonWhitelisted`), auto-transforms query params (`transform`) |
| `ThrottlerModule` | Global rate limit: 120 requests per 60 seconds |
| Helmet | Sets standard security headers on every response |
| CORS | Allows only `localhost` and `127.0.0.1` origins (any port) |
| Swagger | Auto-generated docs at `/api/docs` with Bearer auth support |
