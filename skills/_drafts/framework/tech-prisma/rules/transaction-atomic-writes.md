---
title: $transaction — Atomic Multi-Write Operations
impact: HIGH
tags: transaction, atomic, prisma
---

## $transaction — Atomic Multi-Write Operations

Any operation that spans multiple writes and must be atomic requires `$transaction`. Sequential `await` calls without a transaction are not atomic — a failure after the first write leaves data inconsistent.

### Array Transaction — Unconditional Multi-Write

Use when all writes are known upfront and require no conditional logic:

```typescript
// Atomic: goal contribution + analytics event
const [updatedGoal] = await this.prisma.$transaction([
  this.prisma.savingsGoal.update({
    where: { id: goalId },
    data: { currentAmount: newAmount },
  }),
  this.prisma.analyticsEvent.create({
    data: { userId, eventType: 'goal_contribution', metadata: { goalId, amount } },
  }),
]);
```

### Interactive Transaction — Conditional Read-Then-Write

Use when you need to read data before deciding what to write. The read and write share the same DB transaction, preventing race conditions.

```typescript
// Atomic: read goal → validate → update
await this.prisma.$transaction(async (tx) => {
  const goal = await tx.savingsGoal.findFirst({
    where: { id: goalId, userId, deletedAt: null },
  });
  if (!goal) throw new NotFoundException('Goal not found');

  const newAmount = goal.currentAmount.add(new Decimal(contribution));
  if (newAmount.greaterThan(goal.targetAmount)) {
    throw new BadRequestException('Contribution exceeds the goal target');
  }

  await tx.savingsGoal.update({
    where: { id: goalId },
    data: { currentAmount: newAmount },
  });
}, { timeout: 10_000 }); // default is 5s — increase for complex logic
```

**Use `tx` (the transaction client), not `this.prisma`, inside the callback.**

### Decision Guide

| Scenario | Pattern |
|----------|---------|
| Two independent writes that must both succeed | Array transaction |
| Read → validate → write (e.g., goal contribution) | Interactive transaction |
| Single write | Plain `prisma.model.create/update` |
| Reports / reads only | No transaction needed |

### Concurrent Write Conflict (P2034)

Interactive transactions can fail with P2034 when two requests modify the same row simultaneously. Retry with exponential backoff:

```typescript
async function withRetry<T>(fn: () => Promise<T>, retries = 3): Promise<T> {
  for (let attempt = 0; attempt < retries; attempt++) {
    try {
      return await fn();
    } catch (e) {
      if (
        e instanceof PrismaClientKnownRequestError &&
        e.code === 'P2034' &&
        attempt < retries - 1
      ) {
        await new Promise(r => setTimeout(r, 50 * Math.pow(2, attempt)));
        continue;
      }
      throw e;
    }
  }
  throw new Error('Max retries exceeded');
}

// Usage for goal contributions (concurrent updates plausible)
return withRetry(() => this.prisma.$transaction(async (tx) => { ... }));
```
