---
title: Prisma Error Codes — Mapping to HTTP Exceptions
impact: HIGH
tags: error, prisma, exceptions, http
---

## Prisma Error Codes — Mapping to HTTP Exceptions

`PrismaClientKnownRequestError` must be caught and mapped to HTTP exceptions. Letting them bubble to `GlobalExceptionFilter` uncaught returns a generic 500.

### Error Code Reference for Zenda

| Code | Trigger | HTTP | When it occurs |
|------|---------|------|----------------|
| P2002 | Unique constraint violated | 409 | Duplicate email on register; duplicate budget per period |
| P2003 | Foreign key violation | 400 | Transaction with non-existent `categoryId` |
| P2025 | Record not found (update/delete) | 404 | `update`/`delete` where row doesn't exist |
| P2014 | Required relation missing | 400 | Create child without valid parent |
| P2034 | Transaction conflict / deadlock | 503 | Concurrent goal contributions |

### Add to GlobalExceptionFilter

```typescript
// common/exceptions/global-exception.filter.ts
import { PrismaClientKnownRequestError } from '@prisma/client/runtime/library';

// Inside catch(exception):
if (exception instanceof PrismaClientKnownRequestError) {
  return this.handlePrismaError(exception, response, request);
}

private handlePrismaError(
  e: PrismaClientKnownRequestError,
  response: Response,
  request: Request,
) {
  const path = request.url;
  const timestamp = new Date().toISOString();

  switch (e.code) {
    case 'P2002': {
      const fields = (e.meta?.target as string[])?.join(', ') ?? 'field';
      return response.status(409).json({
        statusCode: 409, message: `A record with this ${fields} already exists.`, path, timestamp,
      });
    }
    case 'P2003': {
      const field = (e.meta?.field_name as string) ?? 'relation';
      return response.status(400).json({
        statusCode: 400, message: `Invalid reference: ${field} does not exist.`, path, timestamp,
      });
    }
    case 'P2025': {
      return response.status(404).json({
        statusCode: 404, message: (e.meta?.cause as string) ?? 'Record not found.', path, timestamp,
      });
    }
    case 'P2034': {
      return response.status(503).json({
        statusCode: 503, message: 'Service temporarily unavailable. Please retry.', path, timestamp,
      });
    }
    default:
      return response.status(500).json({
        statusCode: 500, message: 'Database error.', path, timestamp,
      });
  }
}
```

### P2002 — Where to Handle

Handle P2002 close to the operation that can trigger it, not only in the global filter. For expected conflicts (e.g., duplicate email), throw `ConflictException` proactively after a `findFirst` check:

```typescript
// In RegisterUseCase — pre-check for clearer error
const existing = await this.userRepo.findByEmail(dto.email);
if (existing) throw new ConflictException('This email is already registered.');
```

For less-frequent conflicts (e.g., duplicate budget), catch P2002 at the repository level:

```typescript
async create(params: CreateBudgetParams): Promise<BudgetEntity> {
  try {
    return await this.prisma.budget.create({ data: { ...params } });
  } catch (e) {
    if (e instanceof PrismaClientKnownRequestError && e.code === 'P2002') {
      throw new ConflictException('A budget for this category and period already exists.');
    }
    throw e;
  }
}
```

### P2025 — Where to Handle

Handle P2025 via `findFirst` before `update`/`delete` to respect soft-delete filters:

```typescript
// findFirst checks deletedAt — update({ where: { id } }) does not
const record = await this.prisma.transaction.findFirst({
  where: { id, userId, deletedAt: null },
});
if (!record) throw new NotFoundException('Transaction not found');

await this.prisma.transaction.update({ where: { id }, data: { deletedAt: new Date() } });
```
