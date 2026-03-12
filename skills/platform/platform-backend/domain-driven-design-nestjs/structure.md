# Directory Structure Template

## Bounded Context Layout

Every bounded context MUST follow this exact folder structure. No exceptions. Each context is a NestJS module.

```
src/<context-name>/
│
├── <context-name>.module.ts          # NestJS module — wires all layers together
├── tokens.ts                          # DI injection token constants (strings or Symbols)
│
├── domain/
│   ├── model/
│   │   ├── aggregates/
│   │   │   └── cart.aggregate.ts      # Aggregate root (plain TS class, NO decorators)
│   │   ├── entities/
│   │   │   └── cart-item.entity.ts    # Child entities (plain TS class, NO decorators)
│   │   ├── commands/
│   │   │   └── add-product-to-cart.command.ts   # Readonly command class
│   │   ├── queries/
│   │   │   └── get-cart-by-id.query.ts          # Readonly query class
│   │   └── value-objects/
│   │       └── cart-status.enum.ts    # Enums, typed wrappers, branded types
│   ├── ports/
│   │   ├── cart-command.service.ts     # Abstract class (service port)
│   │   ├── cart-query.service.ts       # Abstract class (service port)
│   │   └── cart.repository.ts          # Abstract class (repository port)
│   └── exceptions/
│       ├── cart-not-found.exception.ts
│       └── invalid-cart-operation.exception.ts
│
├── application/
│   ├── command-services/
│   │   └── cart-command.service-impl.ts   # @Injectable() implements port
│   ├── query-services/
│   │   └── cart-query.service-impl.ts     # @Injectable() implements port
│   ├── event-handlers/
│   │   └── cart-seeder.handler.ts         # OnModuleInit / OnApplicationBootstrap
│   ├── acl/
│   │   └── cart-context-facade.impl.ts    # @Injectable() ACL facade implementation
│   └── validators/
│       └── cart.validator.ts              # Complex cross-field validation
│
├── infrastructure/
│   ├── persistence/
│   │   ├── entities/
│   │   │   ├── cart.orm-entity.ts         # TypeORM @Entity() schema (NOT domain model)
│   │   │   └── cart-item.orm-entity.ts
│   │   ├── repositories/
│   │   │   └── typeorm-cart.repository.ts # @Injectable() implements repository port
│   │   └── mappers/
│   │       └── cart-persistence.mapper.ts # ORM entity <-> Domain aggregate mapping
│   ├── adapters/
│   │   ├── stripe-payment.adapter.ts      # External payment service
│   │   ├── cloudinary-image.adapter.ts    # External image service
│   │   └── sendgrid-email.adapter.ts      # External email service
│   ├── guards/
│   │   └── cart-owner.guard.ts            # Resource ownership guard
│   └── cache/
│       └── cart-cache.interceptor.ts      # Cache interceptor
│
└── interfaces/
    ├── rest/
    │   ├── carts.controller.ts            # @Controller() with guards + swagger
    │   ├── dto/
    │   │   ├── create-cart-item.dto.ts    # class-validator decorated request DTO
    │   │   ├── update-cart-item.dto.ts
    │   │   └── cart-response.dto.ts       # Response DTO (plain class or interface)
    │   └── mappers/
    │       └── cart-rest.mapper.ts        # DTO <-> Command/Domain mapping
    ├── graphql/
    │   ├── cart-query.resolver.ts          # @Resolver() for queries
    │   ├── cart-mutation.resolver.ts       # @Resolver() for mutations
    │   ├── dto/
    │   │   └── cart-graphql.types.ts       # @ObjectType(), @InputType() GraphQL types
    │   └── mappers/
    │       └── cart-graphql.mapper.ts
    └── acl/
        ├── dto/
        │   └── cart.dto.ts                # Minimal DTO exposed to OTHER contexts
        └── cart-context.facade.ts         # Abstract class — ACL facade contract
```

## File Naming Convention

NestJS uses kebab-case for all files. Follow this pattern:

| Component | File name pattern | Example |
|-----------|-------------------|---------|
| Module | `<context>.module.ts` | `carts.module.ts` |
| Aggregate | `<name>.aggregate.ts` | `cart.aggregate.ts` |
| Domain entity | `<name>.entity.ts` | `cart-item.entity.ts` |
| ORM entity | `<name>.orm-entity.ts` | `cart.orm-entity.ts` |
| Command | `<verb>-<noun>.command.ts` | `add-product-to-cart.command.ts` |
| Query | `<get>-<noun>-by-<criteria>.query.ts` | `get-cart-by-id.query.ts` |
| Value object | `<name>.enum.ts` or `<name>.vo.ts` | `cart-status.enum.ts` |
| Service port | `<name>-command.service.ts` | `cart-command.service.ts` |
| Service impl | `<name>-command.service-impl.ts` | `cart-command.service-impl.ts` |
| Repository port | `<name>.repository.ts` | `cart.repository.ts` |
| Repository impl | `typeorm-<name>.repository.ts` | `typeorm-cart.repository.ts` |
| Controller | `<plural-name>.controller.ts` | `carts.controller.ts` |
| Resolver | `<name>-query.resolver.ts` | `cart-query.resolver.ts` |
| DTO | `<name>.dto.ts` | `create-cart-item.dto.ts` |
| Mapper | `<name>-<layer>.mapper.ts` | `cart-rest.mapper.ts` |
| Guard | `<name>.guard.ts` | `cart-owner.guard.ts` |
| Exception | `<name>.exception.ts` | `cart-not-found.exception.ts` |
| Tokens | `tokens.ts` | `tokens.ts` |
| Test | `<source-file>.spec.ts` | `cart-command.service-impl.spec.ts` |

## Shared Module Layout

The `shared/` module contains cross-cutting concerns used by ALL bounded contexts. It is a NestJS `@Global()` module.

```
src/shared/
├── shared.module.ts                   # @Global() @Module — auto-available everywhere
├── domain/
│   ├── aggregates/
│   │   └── auditable-aggregate-root.ts    # Base class: id, createdAt, updatedAt
│   ├── entities/
│   │   └── auditable.entity.ts            # Base for non-aggregate domain entities
│   └── value-objects/
│       └── pagination.vo.ts               # Shared pagination value object
├── infrastructure/
│   ├── config/
│   │   └── app.config.ts                  # ConfigModule registration
│   ├── database/
│   │   └── database.module.ts             # TypeOrmModule.forRoot() config
│   ├── cache/
│   │   └── cache.module.ts                # CacheModule config (Redis)
│   ├── guards/
│   │   ├── jwt-auth.guard.ts              # Global JWT authentication guard
│   │   └── roles.guard.ts                 # Role-based authorization guard
│   ├── decorators/
│   │   ├── current-user.decorator.ts      # @CurrentUser() parameter decorator
│   │   └── roles.decorator.ts             # @Roles() method decorator
│   ├── interceptors/
│   │   └── logging.interceptor.ts
│   ├── filters/
│   │   └── all-exceptions.filter.ts       # Global exception filter (like GlobalExceptionHandler)
│   └── pipes/
│       └── validation.pipe.ts             # Global ValidationPipe config
├── exceptions/
│   ├── resource-not-found.exception.ts    # Base 404 (extends HttpException)
│   ├── invalid-operation.exception.ts     # Base 400
│   └── business-rule.exception.ts         # Base 409
└── interfaces/
    └── pagination.interface.ts            # Shared pagination response interface
```

## Test Structure

Tests are colocated next to their source files (NestJS convention):

```
src/<context-name>/
├── application/
│   ├── command-services/
│   │   ├── cart-command.service-impl.ts
│   │   └── cart-command.service-impl.spec.ts    # Unit test (mocked deps)
│   └── query-services/
│       ├── cart-query.service-impl.ts
│       └── cart-query.service-impl.spec.ts
├── domain/
│   └── model/
│       └── aggregates/
│           ├── cart.aggregate.ts
│           └── cart.aggregate.spec.ts           # Pure unit test (no mocks needed)
└── infrastructure/
    └── persistence/
        └── repositories/
            ├── typeorm-cart.repository.ts
            └── typeorm-cart.repository.spec.ts   # Integration test (test DB)
```

For e2e tests:
```
test/
├── <context-name>/
│   └── <context-name>.e2e-spec.ts    # End-to-end tests per context
└── jest-e2e.json
```

## Rules for Structure

### DO
- Keep one aggregate root per bounded context (two only if genuinely separate lifecycles)
- Place repository PORTS (abstract classes) in `domain/ports/` — implementations in `infrastructure/persistence/repositories/`
- Place service PORTS (abstract classes) in `domain/ports/` — implementations in `application/`
- Place ACL facade PORTS (abstract classes) in `interfaces/acl/` — implementations in `application/acl/`
- Separate ORM entities (`infrastructure/persistence/entities/`) from domain aggregates (`domain/model/aggregates/`) — they are NOT the same class
- Create a `tokens.ts` per context with all DI token constants
- Colocate `.spec.ts` test files next to their source

### DON'T
- Don't create a `utils/` or `helpers/` folder — find the right layer for the logic
- Don't create `common/` inside a bounded context — use the shared module
- Don't nest bounded contexts inside each other
- Don't put DTOs in the domain layer — request DTOs go in `interfaces/rest/dto/`, ACL DTOs in `interfaces/acl/dto/`
- Don't use barrel files (`index.ts`) that re-export across layers — they break the dependency rule
- Don't put TypeORM `@Entity()` decorators on domain aggregate classes — domain stays pure
