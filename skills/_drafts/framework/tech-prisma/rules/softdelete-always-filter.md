---
title: Soft Deletes — Always Filter Manually
impact: CRITICAL
tags: softdelete, query, security
---

## Soft Deletes — Always Filter Manually

Prisma middleware does not cover `aggregate`, `groupBy`, `count`, or `$queryRaw`. Relying on middleware gives false safety — use explicit manual filters everywhere.

**Every query on a soft-deletable model must include `deletedAt: null`.**

Soft-deletable models in this project: `User`, `Category`, `Transaction`, `SavingsGoal`, `Budget`.

### Shared Constant — Never Forget the Filter

```typescript
// shared in a utils file or within the repository
export const notDeleted = { deletedAt: null } as const;

// Usage — spread into every where clause
await this.prisma.transaction.findMany({
  where: { userId, ...notDeleted, type: filters.type },
});

await this.prisma.transaction.aggregate({
  where: { userId, ...notDeleted, occurredAt: { gte: from, lte: to } },
  _sum: { amount: true },
});
```

### Anti-pattern — Missing the Filter

```typescript
// DANGEROUS — returns deleted transactions too
const txs = await this.prisma.transaction.findMany({
  where: { userId },
});

// DANGEROUS — aggregate includes deleted amounts in sum
const result = await this.prisma.transaction.aggregate({
  where: { userId, type: TransactionType.EXPENSE },
  _sum: { amount: true },
});
```

### Soft Delete Implementation

```typescript
// Correct — update deletedAt, never call prisma.model.delete()
async softDelete(id: string, userId: string): Promise<void> {
  // Verify ownership before deleting
  const record = await this.prisma.transaction.findFirst({
    where: { id, userId, deletedAt: null },
  });
  if (!record) throw new NotFoundException('Transaction not found');

  await this.prisma.transaction.update({
    where: { id },
    data: { deletedAt: new Date() },
  });
}
```

Never expose `softDelete(id)` directly from a controller without ownership verification in the use case.

### Escape Hatch — Querying Deleted Records

When you legitimately need to include deleted records (e.g., audit logs, admin views), explicitly override the filter:

```typescript
// Intentional — audit log fetches all records including deleted
const all = await this.prisma.transaction.findMany({
  where: { userId },
  // No deletedAt filter — intentional for audit
});
```

Comment the intent so future developers don't add `...notDeleted` automatically.
