---
title: Schema Design — Types, Indexes, and Relations
impact: HIGH
tags: schema, prisma, postgresql, decimal, indexes
---

## Schema Design — Types, Indexes, and Relations

### Decimal for All Monetary Fields

**Never use `Float` for money.** Floating-point arithmetic loses precision.

```prisma
// Correct — exact decimal storage
amount         Decimal  @db.Decimal(12, 2)  // up to 9,999,999,999.99
targetAmount   Decimal  @db.Decimal(12, 2)
currentAmount  Decimal  @db.Decimal(12, 2)

// Anti-pattern — float loses precision
amount Float  // 150.30 may become 150.29999...
```

In TypeScript, always construct with string to avoid float imprecision:

```typescript
import { Decimal } from '@prisma/client/runtime/library';

new Decimal('150.50')  // exact
new Decimal(150.50)    // risky — float may introduce drift
```

Arithmetic uses Decimal methods: `.add()`, `.sub()`, `.mul()`, `.greaterThan()`.
Serialize for API responses with `.toNumber()` (display) or `.toString()` (full precision).

### UUID Primary Keys

```prisma
// Correct — native UUID type, collision-safe, no record count leakage
id String @id @default(uuid()) @db.Uuid

// Anti-pattern — auto-increment exposes record counts
id Int @id @default(autoincrement())
```

### Composite Indexes — Include deletedAt

For soft-deleted models, include `deletedAt` in composite indexes so the planner can use the index for `WHERE deletedAt IS NULL` queries.

```prisma
// Anti-pattern — planner can't use this index efficiently for soft-delete queries
@@index([userId, occurredAt])

// Correct — matches actual query pattern
@@index([userId, occurredAt, deletedAt])
@@index([userId, type, occurredAt, deletedAt])
```

The `Category` model in this project already applies this pattern correctly with `@@index([type, userId, deletedAt])`. Apply it consistently to `Transaction` and `SavingsGoal`.

### Unique Constraints on Business Keys

```prisma
// Enforce business invariants at the database level
model Budget {
  @@unique([userId, categoryId, month, year])  // one budget per period per category
}

model UserBadge {
  @@unique([userId, badgeId])  // a user earns each badge only once
}

model Prediction {
  @@unique([userId, period, type])  // one prediction per type per period
}
```

### Relation Strategies

| `onDelete` | When to use |
|------------|-------------|
| `Cascade` | Child has no meaning without parent (transactions → user, goals → user) |
| `SetNull` | Child should survive parent deletion, FK becomes null (transaction → category) |
| `Restrict` | Deletion must fail until child records are cleaned up first |

```prisma
// Cascade — transaction deleted when user deleted
transaction Transaction[] @relation("UserTransactions")
// On Transaction model:
user User @relation(fields: [userId], references: [id], onDelete: Cascade)

// SetNull — transaction survives if category is deleted
category Category? @relation(fields: [categoryId], references: [id], onDelete: SetNull)
```

### DateTime — UTC-Explicit Construction

```typescript
// Anti-pattern — uses server's local timezone (unpredictable in Docker)
const from = new Date(year, month - 1, 1);

// Correct — deterministic UTC
const from = new Date(Date.UTC(year, month - 1, 1));
const to   = new Date(Date.UTC(year, month, 0, 23, 59, 59, 999));
```

Serialize `DateTime` as ISO 8601 in API responses:

```typescript
occurredAt: transaction.occurredAt.toISOString()  // "2026-03-28T14:30:00.000Z"
```

Never return raw `Date` objects from response DTOs — JSON serialization is implicit and timezone-dependent.
