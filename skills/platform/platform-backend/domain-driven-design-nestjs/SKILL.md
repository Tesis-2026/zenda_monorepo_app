---
name: ddd-nestjs
description: Domain-Driven Design and Clean Architecture guide for NestJS projects. Auto-invokes when creating bounded contexts, aggregates, entities, services, controllers, modules, or any DDD layer component in a NestJS/TypeScript codebase.
argument-hint: [bounded-context-name]
---

# Domain-Driven Design & Clean Architecture — NestJS

This skill enforces DDD tactical patterns and Clean Architecture layering for NestJS (Node.js + TypeScript) projects. Follow these rules strictly when generating, modifying, or reviewing code.

For the full directory template and scaffolding rules, see [structure.md](structure.md).
For naming conventions and concrete code examples, see [conventions.md](conventions.md).
For anti-patterns and common mistakes, see [donts.md](donts.md).

---

## Core Principles

1. **Bounded Contexts are king** — every feature belongs to exactly one context, mapped 1:1 to a NestJS `@Module`. Never scatter domain logic across modules.
2. **Dependency rule** — dependencies point inward: `interfaces → application → domain`. Domain NEVER imports from application, infrastructure, or interfaces. Use NestJS DI with abstract tokens to invert infrastructure dependencies.
3. **Domain purity** — aggregates, entities, and value objects are plain TypeScript classes. ZERO NestJS decorators (`@Injectable`, `@Module`) in the domain layer. No framework imports whatsoever.
4. **CQRS-lite** — separate Command services (writes) from Query services (reads). Each has its own abstract class (port) in domain and an `@Injectable()` implementation in application. Optionally use `@nestjs/cqrs` for a full command/query bus.
5. **Anti-Corruption Layer (ACL)** — contexts communicate ONLY through facade interfaces injected via NestJS DI tokens. Never import a service or repository from another module directly.
6. **Commands and Queries are readonly classes** — immutable data carriers with validation in the constructor.
7. **Rich domain model** — push business rules INTO the aggregate. Services orchestrate; they don't contain business logic.
8. **NestJS Module = Bounded Context** — each bounded context is a self-contained module that exports ONLY its ACL facade token. Internal providers are NEVER exported.

---

## Quick Decision Tree

```
Need to add a feature?
├── Which bounded context does it belong to?
│   ├── Existing context → add to that context's module
│   └── New domain concept → create a new NestJS module (bounded context)
│
├── What layer?
│   ├── Business rule / invariant → Domain (aggregate method)
│   ├── Orchestration / cross-concern → Application (command/query service)
│   ├── Database / external API → Infrastructure (repository impl, adapter)
│   └── HTTP / GraphQL endpoint → Interfaces (controller/resolver)
│
└── Crosses context boundaries?
    └── YES → Use ACL facade via DI token, NEVER direct imports
```

---

## Layer Responsibilities (summary)

| Layer | Contains | Depends On | Never Contains |
|-------|----------|------------|----------------|
| **Domain** | Aggregates, entities, value objects, commands, queries, service ports (abstract classes), repository ports (abstract classes), domain exceptions | Nothing (only TypeScript stdlib) | NestJS decorators, HTTP concerns, ORM decorators, external API calls |
| **Application** | Command service impls, query service impls, event handlers, ACL facade impls | Domain (implements ports) | Controllers, HTTP DTOs, direct DB queries |
| **Infrastructure** | TypeORM/Prisma repositories, external service adapters, guards, strategies, email/payment providers, cache adapters | Domain (implements repository ports) | Business logic, orchestration |
| **Interfaces** | REST controllers, GraphQL resolvers, DTOs (request/response), mappers, Swagger decorators | Application, Domain (read-only for types) | Business logic, direct repository access |

---

## NestJS Module Wiring

Each bounded context module follows this pattern:

```typescript
@Module({
  imports: [
    TypeOrmModule.forFeature([CartEntity, CartItemEntity, CartStatusEntity]),
    IamModule, // Only if consuming IamContextFacade
  ],
  controllers: [CartsController],
  providers: [
    // Application services bound to domain port tokens
    { provide: CART_COMMAND_SERVICE, useClass: CartCommandServiceImpl },
    { provide: CART_QUERY_SERVICE, useClass: CartQueryServiceImpl },
    // Infrastructure repos bound to domain port tokens
    { provide: CART_REPOSITORY, useClass: TypeOrmCartRepository },
    // ACL facade (this is what gets exported)
    { provide: CART_CONTEXT_FACADE, useClass: CartContextFacadeImpl },
    // GraphQL resolvers
    CartQueryResolver,
    CartMutationResolver,
  ],
  exports: [CART_CONTEXT_FACADE], // ONLY export the ACL facade token
})
export class CartsModule {}
```

**Key rules:**
- Use `string` or `Symbol` injection tokens for all ports (defined in a `tokens.ts` file per context)
- Bind implementations via `{ provide: TOKEN, useClass: Impl }`
- ONLY export the ACL facade token — internal services stay private to the module
- Import other context modules only when you need their exported ACL facade

---

## Creating a New Bounded Context

When the user asks to create a new bounded context (or you determine one is needed), scaffold the full directory tree from [structure.md](structure.md) and follow these steps:

1. **Create the folder tree** under `src/<context-name>/`
2. **Start with the domain layer** — define the aggregate root, entities, value objects, commands, queries, exceptions, and service/repository port abstract classes
3. **Then application layer** — implement command and query services with `@Injectable()`
4. **Then infrastructure** — add TypeORM entities (schema decorators) and repository implementations
5. **Finally interfaces** — add controllers/resolvers, DTOs, and mappers
6. **Wire the module** — create the NestJS `@Module` binding all providers to their tokens
7. **Register in AppModule** — import the new module in `app.module.ts`
8. **Wire cross-context communication** through ACL facades if needed

Always generate **test files** as `*.spec.ts` colocated alongside source files (NestJS convention).

---

## When $ARGUMENTS is provided

If a bounded context name is passed (e.g., `/ddd-nestjs shipping`), scaffold the full directory tree and base classes for that context following the structure in [structure.md](structure.md). Generate:
- Aggregate root class extending `AuditableAggregateRoot`
- At least one command and query class (readonly with constructor validation)
- Command and query service port abstract classes
- Command and query service implementations (`@Injectable()`)
- Repository port (abstract class) + TypeORM implementation stub
- TypeORM entity (infrastructure schema) separate from domain aggregate
- NestJS module with proper DI token wiring
- Controller stub with `@UseGuards(JwtAuthGuard)` and Swagger decorators
- ACL facade abstract class + implementation stub (if cross-context communication is expected)
- Mapper class stub (static methods)
- Domain exception extending shared base exceptions
- `tokens.ts` file with all injection token constants
- `<context>.module.ts` with complete provider/export wiring
