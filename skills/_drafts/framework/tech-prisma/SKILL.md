---
name: tech-prisma
description: Prisma 5 ORM patterns for NestJS DDD — schema design, soft deletes,
  transactions, migrations, error handling, and query optimization. Extends platform-database.
  Use when writing or reviewing any Prisma schema, repository, query, or migration.
metadata:
  category: framework
  extends: platform-database
  tags:
  - prisma
  - orm
  - postgresql
  - nestjs
  - database
  status: ready
  version: 1
---

# Principles

- The application layer (use cases) must never import `PrismaService` directly — depend on repository ports (abstract classes)
- Every query on a soft-deletable model must include `deletedAt: null` — there is no transparent middleware
- Financial amounts are always `Decimal`, never `Float` — precision is non-negotiable
- Multi-write operations that must be atomic use `$transaction` — never assume sequential calls are safe

# Rules

See [rules index](rules/_sections.md) for detailed patterns.

## Examples

### Positive Trigger

User: "Add a monthly budget feature with a unique constraint per user per period."

Expected behavior: Use `tech-prisma` guidance — define `@@unique([userId, categoryId, month, year])` in schema, handle P2002 in the use case, use interactive `$transaction` if multiple writes are needed, include `deletedAt: null` in all queries.

### Non-Trigger

User: "Design the REST endpoint contract for the budget API."

Expected behavior: Do not prioritize `tech-prisma`; this is an API design task. Use `platform-backend` instead.

## Troubleshooting

### Skill Does Not Trigger

- Error: skill not selected when writing Prisma repositories or schema.
- Cause: Request doesn't mention Prisma, schema, or repository explicitly.
- Solution: Rephrase with "Prisma", "repository", "migration", "schema", or "query".

### Guidance Conflicts With platform-database

- Error: `platform-database` and `tech-prisma` give different advice.
- Cause: `platform-database` is generic SQL; `tech-prisma` is Prisma-specific.
- Solution: `tech-prisma` takes precedence for all Prisma-specific patterns (error codes, query builder, migrations).

## Workflow

1. Identify the layer: schema (`.prisma`), repository (`infrastructure/`), use case, or migration.
2. Apply section rules for that layer.
3. Validate: no `PrismaService` in use cases, `deletedAt: null` in every query, `Decimal` for all money fields.
