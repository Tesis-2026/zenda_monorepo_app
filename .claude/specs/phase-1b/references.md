# References: Phase 1B — Database Design and Data Model

## Key Files

| File | Change |
|------|--------|
| `zenda_backend_app/prisma/schema.prisma` | Modified — added 9 enums (`TransactionType`, `IncomeType`, `FinancialLiteracyLevel`, `TopicDifficulty`, `UserChallengeStatus`, `RecommendationType`, `SurveyType`, `NotificationType`, `FeedbackType`); expanded `User` with 8 profile fields + 2 consent fields + 16 new relations; added `transactionType: TransactionType?` to `Category`; changed `Transaction.type` from `String` to `TransactionType` enum and updated indexes to composite form; added 15 new models: `Budget`, `NotificationPreference`, `EducationalTopic`, `UserTopicProgress`, `Challenge`, `UserChallenge`, `Badge`, `UserBadge`, `Prediction`, `Recommendation`, `RecommendationFeedback`, `Survey`, `SurveyQuestion`, `SurveyResponse`, `AnalyticsEvent`, `AuditLog`, `Feedback` |
| `zenda_backend_app/prisma/seed.ts` | Modified — replaced single-type category seed with full idempotent seed: 9 expense + 5 income system categories with `transactionType` set, 4 challenges with `criteriaJson`, 7 badges, 8 educational topics with content and difficulty, 3 survey records |
| `zenda_backend_app/src/modules/transactions/dto/create-transaction.dto.ts` | Modified — removed `TRANSACTION_TYPES` string constant and `@IsIn`; replaced with `TransactionType` Prisma enum import and `@IsEnum(TransactionType)` |
| `zenda_backend_app/src/modules/transactions/dto/list-transactions.dto.ts` | Modified — removed `TRANSACTION_TYPES` import and `@IsIn`; replaced with `TransactionType` enum and `@IsEnum(TransactionType)` |
| `zenda_backend_app/src/modules/insights/summary.service.ts` | Modified — replaced string literals `'income'`, `'expense'`, `'SYSTEM'`, `'CUSTOM'` with `TransactionType.INCOME`, `TransactionType.EXPENSE`, `CategoryType.SYSTEM`, `CategoryType.CUSTOM` imported from `@prisma/client` |

## Test Files

No test files were created in this phase.

## Standards Applied

- `skills/platform/platform-database/` — UUID PKs, soft deletes on all mutable models, composite indexes on filter columns, `@@unique` for business-key constraints, `Decimal(12,2)` for monetary amounts, JSON columns for variable-structure data consumed as a unit
- `skills/universal/lang-typescript/` — Prisma enum imports used directly; no string literals for enum values; `@IsEnum` over `@IsIn`; no `any`
