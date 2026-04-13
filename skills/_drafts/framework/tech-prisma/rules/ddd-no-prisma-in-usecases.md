---
title: Use Cases Must Not Import PrismaService
impact: CRITICAL
tags: ddd, architecture, dependency-inversion
---

## Use Cases Must Not Import PrismaService

Application-layer use cases must depend on repository ports (abstract classes), never on `PrismaService` directly. This keeps the application layer infrastructure-free and independently testable.

**Anti-pattern — PrismaService in a use case:**

```typescript
// WRONG — application layer coupled to infrastructure
@Injectable()
export class GetMonthSummaryUseCase {
  constructor(private readonly prisma: PrismaService) {} // leaks Prisma into app layer

  async execute(cmd: GetMonthSummaryCommand) {
    const income = await this.prisma.transaction.aggregate({ ... }); // should be in repo
  }
}
```

**Correct — use case depends on repository port:**

```typescript
// CORRECT — application layer depends only on abstractions
@Injectable()
export class GetMonthSummaryUseCase {
  constructor(
    private readonly transactionRepo: ITransactionRepository,
    private readonly goalRepo: ISavingsGoalRepository,
  ) {}

  async execute(cmd: GetMonthSummaryCommand) {
    const [income, expenses, goals] = await Promise.all([
      this.transactionRepo.sumByTypeAndPeriod(cmd.userId, TransactionType.INCOME, cmd.from, cmd.to),
      this.transactionRepo.groupByCategoryAndPeriod(cmd.userId, cmd.from, cmd.to),
      this.goalRepo.findAllByUser(cmd.userId),
    ]);
  }
}
```

**Repository port — abstract class (not interface):**

```typescript
// domain/ports/transaction.repository.ts
// Abstract class, not interface — required for NestJS DI token resolution at runtime
export abstract class ITransactionRepository {
  abstract create(params: CreateTransactionParams): Promise<TransactionEntity>;
  abstract findAll(userId: string, filters: TransactionFilters): Promise<TransactionEntity[]>;
  abstract findById(id: string, userId: string): Promise<TransactionEntity | null>;
  abstract softDelete(id: string): Promise<void>;
  abstract sumByTypeAndPeriod(userId: string, type: TransactionType, from: Date, to: Date): Promise<Decimal>;
  abstract groupByCategoryAndPeriod(userId: string, from: Date, to: Date): Promise<CategorySumRow[]>;
}
```

**Why abstract class, not interface:** TypeScript interfaces are erased at compile time. NestJS DI needs a runtime value as the injection token. Abstract classes survive transpilation.

**Module binding:**

```typescript
@Module({
  providers: [
    { provide: ITransactionRepository, useClass: PrismaTransactionRepository },
    GetMonthSummaryUseCase,
  ],
})
export class TransactionsModule {}
```

**Repository implementation — only place PrismaService is allowed:**

```typescript
// infrastructure/prisma-transaction.repository.ts
@Injectable()
export class PrismaTransactionRepository extends ITransactionRepository {
  constructor(private readonly prisma: PrismaService) { super(); }

  async sumByTypeAndPeriod(userId: string, type: TransactionType, from: Date, to: Date): Promise<Decimal> {
    const result = await this.prisma.transaction.aggregate({
      where: { userId, type, occurredAt: { gte: from, lte: to }, deletedAt: null },
      _sum: { amount: true },
    });
    return result._sum.amount ?? new Decimal(0);
  }
}
```
