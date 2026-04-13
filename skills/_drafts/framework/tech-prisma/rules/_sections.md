# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. DDD Integration (ddd)

**Impact:** CRITICAL
**Description:** Use cases must depend on repository ports (abstract classes), not on PrismaService directly. Violating this couples the application layer to the infrastructure and breaks testability.

## 2. Schema Design (schema)

**Impact:** HIGH
**Description:** Correct field types, indexes, and relation strategies prevent data corruption, missing records in queries, and slow lookups. Decimal for money and composite indexes with deletedAt are non-negotiable.

## 3. Soft Deletes (softdelete)

**Impact:** CRITICAL
**Description:** All soft-delete filters must be applied manually — Prisma middleware does not cover aggregate/groupBy queries. A missing `deletedAt: null` silently returns deleted records.

## 4. Query Patterns (query)

**Impact:** HIGH
**Description:** Prefer select over include to avoid leaking sensitive fields. Never query inside loops. Use batch queries and Promise.all for independent reads.

## 5. Transactions (transaction)

**Impact:** HIGH
**Description:** Multi-write operations that must be atomic require $transaction. Interactive transactions for conditional read-then-write; array transactions for unconditional multi-write.

## 6. Error Handling (error)

**Impact:** HIGH
**Description:** PrismaClientKnownRequestError must be caught and mapped to HTTP exceptions. P2002, P2003, P2025, and P2034 each require distinct handling strategies.

## 7. Migrations (migration)

**Impact:** HIGH
**Description:** Migrations are forward-only, irreversible artifacts. Schema and data changes must be in separate migrations. Never edit an applied migration file.

## 8. Seeding (seed)

**Impact:** MEDIUM
**Description:** Seeds must be idempotent. Use upsert or createMany+skipDuplicates for reference data with unique natural keys. Never INSERT in a migration file.
