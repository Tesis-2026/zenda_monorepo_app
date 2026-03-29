# Shape: Phase 1A — Backend Scaffolding and Core Infrastructure

## Decisions

- **NestJS over Express directly** — NestJS provides a module system, dependency injection, decorators for validation and Swagger, and built-in support for guards and interceptors. The alternative (bare Express) would require manually wiring each of these. For a project with 15+ phases and multiple contributors over time, the opinionated structure of NestJS reduces coordination overhead.

- **Prisma over TypeORM or raw SQL** — Prisma generates a fully-typed client from the schema, making query results type-safe without manual interface definitions. TypeORM uses decorators on entity classes, which couples the domain model to the ORM. Raw SQL provides flexibility but loses compile-time safety. Prisma keeps the schema as the single source of truth and the generated client as the persistence layer.

- **`PrismaModule` as a global module** — all feature modules need database access. Making `PrismaModule` global avoids importing it in every module. The alternative — importing per module — adds boilerplate with no architectural benefit since there is only one database.

- **JWT with Passport over session-based auth** — the app is mobile-first and the Flutter frontend cannot use cookies reliably across platforms. Stateless JWT tokens are well-suited for REST APIs consumed by mobile clients. Session-based auth requires server-side session storage, which adds infrastructure complexity.

- **bcrypt for password hashing** — bcrypt is adaptive (rounds are configurable) and has been the standard for password hashing in Node.js for over a decade. `argon2` would be a stronger alternative but has native bindings that complicate Docker builds. bcrypt with 12 rounds provides adequate security for this use case.

- **`@UserId()` decorator over injecting the full `Request` object** — controllers only need the authenticated user's ID, not the full request. A custom decorator extracts `request.user.sub` at the call site, keeping controller methods clean and testable without mocking the full request object.

- **Global `ValidationPipe` with `whitelist: true` and `forbidNonWhitelisted: true`** — `whitelist` strips any properties not declared in the DTO before they reach the handler, preventing accidental mass-assignment. `forbidNonWhitelisted` rejects the request outright if unknown properties are present, giving the client an explicit error. The alternative — not validating at all — would allow garbage data to reach the service layer.

- **`ThrottlerModule` at the global level with per-route overrides** — a global 120 req/min ceiling blocks trivial DDoS without impacting normal usage. Auth endpoints get tighter per-route limits (10 reg/min, 20 login/min) because they are the highest-value targets for brute force. The alternative — no rate limiting — is not acceptable for a public API.

- **Helmet enabled globally** — sets `X-Content-Type-Options`, `X-Frame-Options`, `Strict-Transport-Security`, and other headers by default. No configuration is needed for standard behaviour. Disabling it (the alternative) would leave the API open to clickjacking and MIME-sniffing attacks.

- **CORS restricted to localhost regex** — the Flutter app communicates with the backend over localhost during development. Allowing all origins (`*`) would expose the API to cross-origin requests from any browser tab. A regex pattern matches `localhost` on any port without hard-coding a specific port number, which is useful since Flutter's embedded web server picks ports dynamically.

- **Separate `configuration.ts` factory over reading `process.env` directly in services** — a typed factory function lets `ConfigService` inject strongly-typed config objects anywhere. Reading `process.env` directly in services makes them harder to test (requires mutating the process environment) and makes the full config surface invisible.

- **`AiModule` as a placeholder in Phase 1A** — the AI/ML features (Phase 8) depend on the same NestJS module system. Registering a stub module now lets later phases inject AI providers without modifying `AppModule`. The alternative — adding the module only in Phase 8 — would require touching the root module mid-project.

- **`/api` global prefix** — all routes live under `/api`, making it unambiguous that the server is an API, not a web app. This also makes routing proxies (nginx, API Gateway) straightforward: one prefix rule routes all API traffic. The alternative — no prefix — risks route collisions if a static file server is ever served from the same host.

## Constraints

- All routes require JWT authentication except `POST /api/auth/register` and `POST /api/auth/login` — enforced by `JwtAuthGuard` applied per-controller.
- System categories (`CategoryType.SYSTEM`) cannot be deleted by any user — enforced in the categories service; `remove()` applies `updateMany` filtered to `type: CUSTOM, userId` so system rows are never matched.
- Transactions and goals are scoped to the authenticated user — all queries include `userId` from the JWT payload; no user can read or mutate another user's data.
- Category resolution on transaction create: `categoryId` and `newCategoryName` are mutually exclusive — enforced in `resolveCategoryForTransaction`; sending both throws `400 BadRequest`.
- `occurredAt` on a transaction must not be in the future — enforced in the transactions service before the Prisma call.
- Passwords are never stored in plain text — enforced by always passing through `bcrypt.hash` in `register` before writing to the database.
