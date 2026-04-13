# Standards Applied: Phase 1A — Backend Scaffolding and Core Infrastructure

## Database / Schema

- **UUID primary keys:** All models use `@id @default(uuid()) @db.Uuid` — UUID v4 stored as PostgreSQL native UUID type, not varchar. This avoids sequential ID enumeration attacks and works across distributed inserts if the schema is ever sharded.
- **Soft deletes on mutable models:** Every model that represents user-owned mutable data has `deletedAt DateTime?`. Hard deletes are never used. Every `findMany` / `findFirst` query on a soft-deletable model must include `deletedAt: null` in the `where` clause.
- **`Decimal(12, 2)` for monetary amounts:** `amount` on `Transaction` and `targetAmount` / `currentAmount` on `SavingsGoal` use `@db.Decimal(12, 2)`. Floating-point types (`Float`, `Double`) are prohibited for financial data due to binary rounding errors.
- **Timestamps on every model:** `createdAt @default(now())` and `updatedAt @updatedAt` on all models. These are not optional.

## Service Layer

- **Services never receive raw `Request` objects:** Controllers extract the user ID from the JWT via `@UserId()` and pass it as a plain `string` parameter. Services are decoupled from HTTP concerns and testable without mocking NestJS request context.
- **Prisma errors handled at the service boundary:** `P2002` (unique constraint violation) is caught in `AuthService.register` and converted to `ConflictException`. Other Prisma errors are re-thrown and handled by `GlobalExceptionFilter`. Services do not leak Prisma internals to callers.
- **Soft-delete pattern for `remove()` operations:** All delete operations use `prisma.<model>.updateMany({ where: { id, userId, deletedAt: null }, data: { deletedAt: new Date() } })` and check `updated.count` to detect not-found cases. `updateMany` is used (not `update`) so a zero-count result can be detected without a separate `findFirst`.

## API / Controller

- **DTOs for all inputs:** Every controller method that accepts a body or query string uses a DTO class decorated with `class-validator` rules. Raw `@Body() body: any` is never used.
- **`@IsUUID('4')` for ID parameters:** UUID route params are validated to prevent injection of arbitrary strings into Prisma queries.
- **Response DTOs for Swagger documentation:** Every non-void endpoint has a corresponding response DTO class used in `@ApiOkResponse` / `@ApiCreatedResponse`. Response DTOs use `!` (definite assignment) on all required fields.
- **`@ApiBearerAuth()` on all protected controllers:** Every controller with `JwtAuthGuard` declares `@ApiBearerAuth()` so the Swagger UI renders the lock icon and the "Authorize" button populates the `Authorization` header automatically during testing.
- **HTTP status codes are explicit on non-default responses:** `@HttpCode(HttpStatus.NO_CONTENT)` is applied to DELETE endpoints that return no body. Endpoints that create resources use the default `201`; retrieval endpoints use `200`.

## Security

- **Helmet applied globally in `main.ts`:** Not configurable per-route. If a route needs to relax a header, it is an explicit architectural decision that must be documented.
- **CORS origin as a regex, not a wildcard:** `origin: [/^http:\/\/localhost(:\d+)?$/]` allows any localhost port without opening the API to all origins. The regex is defined once in `main.ts` and not duplicated.
- **Rate limits declared at the guard level, not middleware:** `ThrottlerGuard` is applied globally via `APP_GUARD`. Per-route overrides use `@Throttle({ default: { ttl, limit } })` at the route level. This keeps rate-limit logic inside the NestJS module system where it is visible and testable.
- **JWT secret and bcrypt rounds in config, not hard-coded:** Both are read from environment variables via `ConfigService`. A test environment can use a shorter `BCRYPT_ROUNDS` value (e.g., 4) to speed up hashing without changing application code.

## Module Structure

- **One NestJS module per feature domain:** `AuthModule`, `CategoriesModule`, `TransactionsModule`, `GoalsModule`, `InsightsModule`, `UsersModule`. Each module declares exactly what it provides and exports. Cross-module dependencies are explicit imports (`CategoriesModule` is imported by `TransactionsModule` to share `ResolveCategoryUseCase`).
- **Infrastructure in `src/infra/`, shared utilities in `src/common/`:** `infra/` contains persistence (`PrismaModule`) and external service adapters (`AiModule`). `common/` contains cross-cutting concerns with no business logic: logger, exception filter, validation DTO, config. Feature modules must not import from other feature modules' internal files — only from their exported providers.
