---
title: Migrations — Forward-Only, Schema vs Data
impact: HIGH
tags: migration, schema, prisma
---

## Migrations — Forward-Only, Schema vs Data

### Never Edit an Applied Migration

Once a migration file has been applied to any shared environment (staging, production, team member's local DB), it must never be edited. Create a new migration instead.

```bash
# Wrong — editing applied migration directly
vim prisma/migrations/20260304_init/migration.sql

# Correct — new migration for any fix
npx prisma migrate dev --name fix_transaction_deleted_at_index
```

If the migration is only on your local dev machine and hasn't been applied anywhere else:
```bash
npx prisma migrate reset  # drops DB, re-runs all migrations + seed (dev only)
```

For production:
```bash
npx prisma migrate deploy  # applies pending migrations, no interactive prompts
```

### Migration Naming Convention

```bash
# Format: descriptive snake_case describing the change
npx prisma migrate dev --name add_budget_table
npx prisma migrate dev --name add_transaction_notes_column
npx prisma migrate dev --name index_transaction_deleted_at
npx prisma migrate dev --name add_unique_badge_name

# Anti-patterns
npx prisma migrate dev --name migration         # too vague
npx prisma migrate dev --name update            # useless
npx prisma migrate dev --name fix               # tells nothing
```

### Separate Schema and Data Migrations

Never mix DDL (schema changes) and DML (data changes) in the same migration file.

```sql
-- Anti-pattern — DDL + DML in one migration (risks locking + partial failures)
ALTER TABLE "Category" ADD COLUMN "slug" TEXT;
UPDATE "Category" SET "slug" = LOWER(REPLACE(name, ' ', '-'));
ALTER TABLE "Category" ALTER COLUMN "slug" SET NOT NULL;

-- Correct — three separate migrations:
-- Migration 1: add nullable column
ALTER TABLE "Category" ADD COLUMN "slug" TEXT;

-- Migration 2 (data migration — run between deployments)
-- Execute as a separate script, not in migration.sql

-- Migration 3: add NOT NULL constraint after data is backfilled
ALTER TABLE "Category" ALTER COLUMN "slug" SET NOT NULL;
```

For large table backfills (e.g., `Transaction` with many rows), run the data update in batches to avoid table locks:

```typescript
// data-migration/backfill-transaction-slugs.ts
const batchSize = 1000;
let cursor: string | undefined;
do {
  const rows = await prisma.transaction.findMany({
    take: batchSize,
    ...(cursor ? { skip: 1, cursor: { id: cursor } } : {}),
    where: { slug: null },
    orderBy: { id: 'asc' },
    select: { id: true, description: true },
  });
  if (rows.length === 0) break;
  await Promise.all(rows.map(r =>
    prisma.transaction.update({ where: { id: r.id }, data: { slug: slugify(r.description) } })
  ));
  cursor = rows[rows.length - 1].id;
} while (true);
```

### Pre-Deployment Checklist

Before running any migration in staging or production:

1. `npx prisma migrate diff` — preview the SQL that will be generated.
2. Review the SQL for `DROP TABLE`, `DROP COLUMN`, `ALTER COLUMN TYPE` — these are destructive and irreversible.
3. Never remove a column from the Prisma schema until all code that writes/reads it is fully deployed.
4. Test on a staging DB first with `npx prisma migrate deploy`.
5. For columns used in indexes, the `CREATE INDEX CONCURRENTLY` pattern prevents table locks — Prisma doesn't generate this automatically; add it manually via raw SQL in the migration file.

### Never INSERT Data in a Migration File

Migration SQL files are schema-only. Seeding belongs in `prisma/seed.ts`.

```sql
-- Anti-pattern in migration.sql
CREATE TABLE "Badge" (...);
INSERT INTO "Badge" (name) VALUES ('First Transaction');  -- don't do this

-- Correct: schema in migration, data in seed.ts
```
