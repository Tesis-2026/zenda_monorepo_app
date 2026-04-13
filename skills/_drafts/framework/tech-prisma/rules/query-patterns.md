---
title: Query Patterns — select, N+1 Prevention, Raw SQL
impact: HIGH
tags: query, performance, n-plus-one, select, include
---

## Query Patterns — select, N+1 Prevention, Raw SQL

### Prefer select Over include for Read-Only Queries

`include` returns all columns, which can leak sensitive fields (`passwordHash`, `deletedAt`, internal flags). Use `select` to project only what the response DTO needs.

```typescript
// Anti-pattern — leaks passwordHash and all internal fields
const user = await this.prisma.user.findUnique({ where: { id } });

// Correct — explicit projection
const user = await this.prisma.user.findUnique({
  where: { id },
  select: { id: true, email: true, fullName: true, profileCompleted: true },
});

// Correct — nested select on includes
const txs = await this.prisma.transaction.findMany({
  where: { userId, deletedAt: null },
  include: {
    category: { select: { id: true, name: true } }, // only the fields you need
  },
});
```

### Never Query Inside a Loop — N+1 Prevention

```typescript
// Anti-pattern — N+1: one query per transaction
const transactions = await this.prisma.transaction.findMany({ where: { userId } });
for (const tx of transactions) {
  tx.category = await this.prisma.category.findUnique({ where: { id: tx.categoryId } }); // N queries!
}

// Correct — batch lookup with IN, then map in memory
const transactions = await this.prisma.transaction.findMany({
  where: { userId, deletedAt: null },
  include: { category: { select: { id: true, name: true } } }, // single JOIN
});

// Correct — when groupBy result needs category names
const grouped = await this.prisma.transaction.groupBy({
  by: ['categoryId'],
  where: { userId, deletedAt: null },
  _sum: { amount: true },
});

const ids = grouped.map(r => r.categoryId).filter((id): id is string => id !== null);
const categories = await this.prisma.category.findMany({
  where: { id: { in: ids } },
  select: { id: true, name: true },
});
const nameMap = new Map(categories.map(c => [c.id, c.name]));

const result = grouped.map(r => ({
  categoryName: nameMap.get(r.categoryId ?? '') ?? 'Unknown',
  total: (r._sum.amount ?? new Decimal(0)).toNumber(),
}));
```

### Parallel Independent Queries

Use `Promise.all` for queries with no data dependency between them:

```typescript
// Anti-pattern — sequential, wastes time
const income  = await this.prisma.transaction.aggregate({ ... });
const expense = await this.prisma.transaction.aggregate({ ... });
const goals   = await this.prisma.savingsGoal.findMany({ ... });

// Correct — parallel execution
const [income, expense, goals] = await Promise.all([
  this.prisma.transaction.aggregate({ where: { ...notDeleted, type: INCOME, ... }, _sum: { amount: true } }),
  this.prisma.transaction.aggregate({ where: { ...notDeleted, type: EXPENSE, ... }, _sum: { amount: true } }),
  this.prisma.savingsGoal.findMany({ where: { userId, ...notDeleted } }),
]);
```

### Aggregate and groupBy

```typescript
// aggregate — single numeric result
const result = await this.prisma.transaction.aggregate({
  where: { userId, type: TransactionType.EXPENSE, deletedAt: null },
  _sum: { amount: true },
  _count: { id: true },
});
// Always handle null sum
const total = result._sum.amount ?? new Decimal(0);

// groupBy — SQL GROUP BY equivalent
const byCategory = await this.prisma.transaction.groupBy({
  by: ['categoryId'],                        // all non-aggregate fields in by
  where: { userId, type: EXPENSE, deletedAt: null },
  _sum: { amount: true },
  orderBy: { _sum: { amount: 'desc' } },
  take: 5,
});
```

### Raw SQL — Only When the Query Builder Cannot

Use `$queryRaw` for window functions, CTEs, or CASE WHEN logic that Prisma can't express.

```typescript
// Legitimate — window function for 6-month trend
const trend = await this.prisma.$queryRaw<{ month: string; total: number }[]>`
  SELECT
    TO_CHAR("occurredAt", 'YYYY-MM') AS month,
    SUM(amount)::float AS total
  FROM "Transaction"
  WHERE "userId" = ${userId}::uuid
    AND "deletedAt" IS NULL
    AND "type" = ${TransactionType.EXPENSE}::"TransactionType"
  GROUP BY month
  ORDER BY month DESC
  LIMIT 6
`;

// Always use tagged template literals — Prisma parameterizes them safely
// NEVER use $queryRawUnsafe with user input — SQL injection risk
```

### Cursor-Based Pagination (for Transaction Lists)

```typescript
// Anti-pattern — offset scan is O(page * size) for large tables
findMany({ skip: page * size, take: size, orderBy: { occurredAt: 'desc' } })

// Correct — cursor is O(1) regardless of page depth
findMany({
  take: pageSize,
  skip: 1,              // skip the cursor itself
  cursor: { id: lastSeenId },
  orderBy: { occurredAt: 'desc' },
  where: { userId, deletedAt: null },
})
```
