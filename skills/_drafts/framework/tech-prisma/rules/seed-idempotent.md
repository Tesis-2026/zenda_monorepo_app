---
title: Seeding — Idempotent with upsert and createMany
impact: MEDIUM
tags: seed, prisma, idempotent
---

## Seeding — Idempotent with upsert and createMany

Seeds must be safe to re-run at any time without creating duplicates or throwing errors.

### Preferred: createMany + skipDuplicates

For reference data with a `@@unique` constraint on a natural key, `createMany` with `skipDuplicates` is the most efficient pattern — one round-trip for all records.

```typescript
// Requires @@unique([name]) on Badge model
await prisma.badge.createMany({
  data: BADGES,
  skipDuplicates: true,
});

// Requires @@unique([title]) on Challenge model
await prisma.challenge.createMany({
  data: CHALLENGES,
  skipDuplicates: true,
});
```

Add `@@unique` to natural keys if not already present:

```prisma
model Badge {
  name String @unique  // natural key — already in schema
}

model EducationalTopic {
  title String @unique  // add this if not present
}
```

### When to Use upsert

Use `upsert` when you want to keep seed data fresh on re-runs (i.e., update existing records with new values):

```typescript
for (const topic of EDUCATIONAL_TOPICS) {
  await prisma.educationalTopic.upsert({
    where: { title: topic.title },
    update: { content: topic.content, difficulty: topic.difficulty },
    create: topic,
  });
}
```

### When to Use findFirst + create (Current Pattern)

Keep `findFirst + create` only for models without a unique natural key, where `createMany + skipDuplicates` cannot be used:

```typescript
// Category has no DB-level unique constraint on name — use findFirst + create
for (const name of EXPENSE_CATEGORIES) {
  const exists = await prisma.category.findFirst({
    where: { name: { equals: name, mode: 'insensitive' }, type: SYSTEM, deletedAt: null },
    select: { id: true },
  });
  if (!exists) {
    await prisma.category.create({ data: { name, type: SYSTEM, transactionType: EXPENSE } });
  }
}
```

### Wrap All Seed Functions in a Transaction

```typescript
// prisma/seed.ts
async function main(): Promise<void> {
  await prisma.$transaction(async (tx) => {
    await seedCategories(tx);
    await seedChallenges(tx);
    await seedBadges(tx);
    await seedEducationalTopics(tx);
    await seedSurveys(tx);
  });
  console.log('Seed completed');
}
```

Pass the `tx` transaction client into each function so all seed operations are atomic. If any seed function fails, none of the changes are committed.

### Never INSERT in a Migration File

Reference data (categories, badges, topics) belongs in `seed.ts`, not in `migration.sql`. Mixing schema and data makes it impossible to safely re-run migrations on a clean database.
