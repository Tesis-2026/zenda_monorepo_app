# Standards Applied: Phase 1B — Database Design and Data Model

## Database / Schema

- **Primary keys:** All 15 new models use `@id @default(uuid()) @db.Uuid` — UUID v4 stored as PostgreSQL native UUID, not varchar. Consistent with existing models.
- **Soft deletes:** All mutable models have `deletedAt DateTime?`. Append-only models (`AnalyticsEvent`, `AuditLog`, `RecommendationFeedback`, `UserBadge`) have no `deletedAt` — events and earned badges are permanent records. Every query against mutable models must include `deletedAt: null`.
- **Timestamps:** Every mutable model has `createdAt @default(now())` and `updatedAt @updatedAt`. Append-only models have only `createdAt`.
- **Enum storage:** All enums are defined as PostgreSQL native enum types via Prisma. Values are stored as the enum name (e.g. `INCOME`, not `0` or `"income"`). This makes data readable in raw SQL queries and prevents invalid values at the database level.
- **Composite indexes:** Every model that will be filtered in `WHERE` clauses has composite indexes on the most-common filter combinations: `[userId, occurredAt]`, `[userId, type, occurredAt]`, `[userId, month, year]`, `[userId, isActive]`, `[userId, status]`, `[surveyId, order]`, `[userId, eventType]`. Single-column indexes added only where the column has high selectivity (`email`, `badge.name`).
- **Business-key uniqueness via `@@unique`:** Invariants that are business rules — not just technical constraints — are encoded in the schema: one prediction per period per type, one badge earned per user, one challenge record per user, one survey response per user, one notification preference per type per user. This prevents invalid state without relying on application-layer checks alone.
- **Decimal precision:** Monetary amounts use `@db.Decimal(12, 2)`. Percentage scores use `@db.Decimal(5, 2)`. No floating-point types are used for financial data.
- **JSON columns justified per use:** `criteriaJson`, `predictedByCategory`, `confidenceInterval`, `answersJson`, `options`, `metadata` all store data that is consumed as a unit and not queried field-by-field. Normalising these into relational tables would add joins with no analytical benefit at this stage.
- **Cascade rules explicit on every relation:** Every foreign key declares its `onDelete` behaviour explicitly: `Cascade` for user-owned data, `SetNull` for audit/reference data that must survive deletion, `SetNull` for nullable foreign keys on transactions/budgets.

## Service Layer

- **Enum imports replace string literals throughout:** `TransactionType` and `CategoryType` are imported from `@prisma/client` and used directly in all service queries. The previous string literals (`'income'`, `'SYSTEM'`) were a source of silent runtime bugs — a typo would pass TypeScript but produce wrong query results.
- **Idempotent seed functions:** Each seed helper (`seedCategories`, `seedChallenges`, `seedBadges`, `seedEducationalTopics`, `seedSurveys`) calls `findFirst` before `create`. The seed script can be re-run safely on any environment. Functions are separated by data type so individual sections can be re-run or extended independently.

## API / Controller

- **`@IsEnum` over `@IsIn` for enum validation:** `@IsIn(['INCOME', 'EXPENSE'])` would accept any correctly spelled string but offers no compile-time type checking. `@IsEnum(TransactionType)` validates against the Prisma-generated enum type — the DTO field type and the validation rule stay in sync automatically when the enum is extended.
