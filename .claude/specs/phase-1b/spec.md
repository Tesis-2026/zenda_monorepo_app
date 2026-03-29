# Phase 1B: Database Design and Data Model

## Context

Before this phase, the Prisma schema covered only four models (User, Category, Transaction, SavingsGoal) with no enums, no profile fields on User, and `Transaction.type` stored as a plain string. There was no schema support for budgets, notifications, education, gamification, predictions, recommendations, surveys, analytics, audit, or user feedback. This phase expands the schema to its full production shape — 19 models and 9 enums — so that every feature from Phase 2 through Phase 15 can be built without schema migrations that touch tables already holding user data. References: US-0101, US-0201, US-0301, US-0501, US-0901, US-1201.

## Tasks Completed

1. `prisma/schema.prisma` — 9 enums and 15 new models added; `User` expanded with profile and consent fields; `Category` gained `transactionType`; `Transaction.type` changed from `String` to `TransactionType` enum; Transaction indexes updated to composite form
2. `prisma/seed.ts` — expanded from category-only to full seed: 14 categories, 4 challenges, 7 badges, 8 educational topics, 3 survey records; all operations idempotent
3. `src/modules/transactions/dto/create-transaction.dto.ts` — `@IsIn` string validation replaced with `@IsEnum(TransactionType)`
4. `src/modules/transactions/dto/list-transactions.dto.ts` — same enum migration as above
5. `src/modules/insights/summary.service.ts` — string literals `'income'`, `'expense'`, `'SYSTEM'`, `'CUSTOM'` replaced with `TransactionType` and `CategoryType` enum values

## What Was Built

### Enums

| Enum | Values | Used by |
|------|--------|---------|
| `TransactionType` | `INCOME`, `EXPENSE` | Transaction, Category, Prediction |
| `IncomeType` | `SCHOLARSHIP`, `PART_TIME`, `FAMILY`, `MIXED` | User |
| `FinancialLiteracyLevel` | `LOW`, `MEDIUM`, `HIGH` | User |
| `TopicDifficulty` | `BEGINNER`, `INTERMEDIATE`, `ADVANCED` | EducationalTopic |
| `UserChallengeStatus` | `AVAILABLE`, `ACTIVE`, `COMPLETED` | UserChallenge |
| `RecommendationType` | `SAVINGS`, `BUDGET`, `GOAL` | Recommendation |
| `SurveyType` | `PRE`, `POST`, `SUS` | Survey |
| `NotificationType` | `BUDGET_ALERT`, `ANOMALY_ALERT`, `PREDICTION_READY`, `CHALLENGE_REMINDER`, `DAILY_REMINDER`, `BADGE_EARNED` | NotificationPreference |
| `FeedbackType` | `BUG`, `SUGGESTION`, `GENERAL` | Feedback |

### Models — Expanded

#### `User` (US-0101, US-0105)

Added fields:

| Field | Type | Purpose |
|-------|------|---------|
| `age` | `Int?` | Onboarding profile |
| `university` | `String?` | Onboarding profile |
| `incomeType` | `IncomeType?` | Onboarding profile |
| `averageMonthlyIncome` | `Decimal?` | Onboarding profile; feeds ML feature extraction |
| `financialLiteracyLevel` | `FinancialLiteracyLevel?` | Set from survey score; drives content difficulty |
| `profileCompleted` | `Boolean` | `false` until onboarding finished |
| `currency` | `String` | Default `"PEN"`; US-0106 allows `"USD"` |
| `consentGiven` | `Boolean` | Law 29733 compliance (US-1303) |
| `consentAt` | `DateTime?` | Timestamp of consent; stored for audit |

#### `Category`

Added `transactionType: TransactionType?` — null means the category is usable for both income and expense transactions. System categories have this set; custom categories may leave it null.

#### `Transaction`

`type` changed from `String` to `TransactionType` enum. Indexes replaced:

| Old index | New index |
|-----------|-----------|
| `[userId]` | `[userId, occurredAt]` |
| `[categoryId]` | `[userId, categoryId]` |
| `[occurredAt]` | `[userId, type, occurredAt]` |

### Models — Created

#### `Budget` (US-0501)

Monthly spending limit per user per category (or global when `categoryId` is null).

| Key field | Detail |
|-----------|--------|
| `amountLimit` | `Decimal(12,2)` — the cap for the period |
| `month` / `year` | Integer month/year pair for the budget period |
| `categoryId` | Nullable — null represents a global budget |

Unique constraint: `@@unique([userId, categoryId, month, year])`.

#### `NotificationPreference` (US-1104)

Per-user toggle for each `NotificationType`. Unique per `(userId, type)`. Default `enabled: true`.

#### `EducationalTopic` (US-1001)

Financial education content with `difficulty`, `order`, and full `content` text. Eight topics seeded.

#### `UserTopicProgress` (US-1001)

Junction record tracking whether a user has completed a topic. `completedAt` nullable — null means started but not completed. Unique per `(userId, topicId)`.

#### `Challenge` + `UserChallenge` (US-1002)

Challenge stores `criteriaJson` — a JSON object the verification engine evaluates. `UserChallenge` tracks the user's relationship to each challenge.

State machine:

```
AVAILABLE → ACTIVE      (user accepts — sets acceptedAt)
ACTIVE    → COMPLETED   (criteria met — sets completedAt)
```

#### `Badge` + `UserBadge` (US-1003)

Badge name is globally unique. `UserBadge` is the earned-badge record. Unique per `(userId, badgeId)` — a badge can only be earned once per user.

Seven badges seeded: First Transaction, Consistency, Goal Achieved, Challenger, Financial Sage, Predictor, Budgeter.

#### `Prediction` (US-0801, US-0802)

ML model output per user per period per type. `period` stored as `"YYYY-MM"` string. `actualTotal` and `accuracy` written back after the period ends for retrospective accuracy tracking.

Unique: `@@unique([userId, period, type])` — one prediction per direction per month.

#### `Recommendation` + `RecommendationFeedback` (US-0901, US-0902)

`Recommendation` is generated by the engine with a type (`SAVINGS`, `BUDGET`, `GOAL`), a message, and an optional `suggestedAction`. `isActive` flags whether it is currently shown. `RecommendationFeedback` is a one-to-one record storing whether the user accepted it.

#### `Survey` + `SurveyQuestion` + `SurveyResponse` (US-1201, US-1202, US-1203)

Three survey records seeded (PRE, POST, SUS). Questions are added in Phase 12 when validated instruments are finalised. `SurveyResponse` stores answers as JSON and the calculated score. Unique per `(userId, surveyId)` — one response per survey per user.

#### `AnalyticsEvent` (US-1502)

Append-only event log. No `updatedAt`. Events: `record_transaction`, `view_report`, `view_prediction`, `accept_challenge`, `complete_educational_topic`, `check_recommendation`.

#### `AuditLog` (US-1305)

Sensitive action log. `userId` uses `onDelete: SetNull` — records survive account deletion for compliance.

#### `Feedback` (US-1501)

In-app feedback: type (`BUG`, `SUGGESTION`, `GENERAL`), message, optional screen name, optional 1–5 rating.

### Seed Data

| Category | Items |
|----------|-------|
| Expense system categories | Food, Transportation, Education, Entertainment, Health, Housing, Utilities, Clothing, Other |
| Income system categories | Scholarship, Part-time work, Family, Freelance, Other |
| Challenges | No delivery 3 days, Record 7 days, Save S/20, Reduce entertainment 10% |
| Badges | First Transaction, Consistency, Goal Achieved, Challenger, Financial Sage, Predictor, Budgeter |
| Educational topics | Personal Budget, Savings, Credit and Debt, Inflation, Interest Rates, Basic Investing, Responsible Consumption, Digital Wallets in Peru |
| Survey records | PRE, POST, SUS (questions added Phase 12) |
