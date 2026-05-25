# Shape: Phase 1B — Database Design and Data Model

## Decisions

- **Full schema defined in one phase rather than incrementally** — all 15 new models were added in a single migration rather than introduced phase by phase. Incremental schema additions on tables with live user data carry risk: adding a non-nullable column requires a default, renaming a column requires a multi-step migration, and adding a foreign key to an existing table locks it briefly. Defining the full shape now means every future phase adds application logic, not structure.

- **`Transaction.type` changed from `String` to `TransactionType` enum** — the original string column allowed any value including `"transfer"`, `"INCOME "` (with a space), or an empty string. Changing to a PostgreSQL-native enum enforces validity at the database level. The existing string values `"INCOME"` and `"EXPENSE"` match the enum names exactly, making this a non-destructive migration on any existing data.

- **`Category.transactionType` is nullable rather than required** — a category with `transactionType = null` is universal: valid for both income and expense transactions. This covers user-created categories like "Misc" that the user may want on either side. A non-null value restricts the category to one direction. The alternative — requiring every category to declare a type — would force users to create duplicate categories when they want the same label on both sides.

- **`Budget.categoryId` nullable with `@@unique([userId, categoryId, month, year])`** — a null `categoryId` represents a global monthly budget. PostgreSQL's unique index treats each null as distinct, so the database cannot enforce the one-global-budget-per-period rule by itself. The service layer must query for existing `(userId, null, month, year)` before creating a second global budget.

- **`Prediction` writes `actualTotal` and `accuracy` back to the same row** — rather than a separate retroactive accuracy table, the actual outcome is written back to the prediction record after the period ends. This keeps the accuracy query simple (`SELECT * FROM predictions WHERE accuracy IS NOT NULL`) and avoids a join. The `@@unique([userId, period, type])` constraint ensures there is always at most one row to update per direction per period.

- **`AnalyticsEvent` has no `updatedAt`** — events are immutable once written. Including `updatedAt` would imply they can be edited, which violates the append-only contract. Omitting it makes that intent explicit in the schema.

- **`AuditLog.userId` uses `onDelete: SetNull` rather than `Cascade`** — if a user deletes their account (infrastructure: right to deletion), their audit logs must be preserved for compliance (Law 29733). `Cascade` would destroy them. `SetNull` preserves the log record with the user reference cleared.

- **`SurveyQuestion.options` stored as JSON array** — the answer options for each question vary in count and content. Normalising them into a separate table (`SurveyOption`) would add a join for every question fetch with no analytical benefit — questions are always consumed with their options. JSON is appropriate here because the options are read as a unit and never queried individually.

- **`Challenge.criteriaJson` stored as JSON** — each challenge has a different verification algorithm (streak, category spend, contribution amount). Storing criteria as a typed JSON object lets the verification engine inspect the structure at runtime without requiring a separate table per challenge type. The alternative — a `ChallengeType` enum with nullable typed columns — would create many null columns and make adding new challenge types a schema change.

- **Seed is idempotent** — each seed function checks for existence with `findFirst` before calling `create`. This means `npm run prisma:seed` is safe to re-run after any reset or in CI environments without producing duplicate data.

- **Survey question content deferred to Phase 12** — the three `Survey` records (PRE, POST, SUS) are seeded now, but `SurveyQuestion` rows are not. The actual questions must be derived from validated financial literacy instruments (Cordova-Buiza et al., 2022; SBS, 2022) which are defined in Phase 12 as part of the impact evaluation design. Seeding placeholder survey records now lets Phase 12 add questions without touching the seed script.

## Constraints

- `Transaction.type` must be `INCOME` or `EXPENSE` — enforced by PostgreSQL enum column; any other value is rejected at the database level.
- A category with `transactionType = INCOME` must not be used on `EXPENSE` transactions — enforced at the service layer in `TransactionsService`, not in the schema.
- A user can have at most one budget per category per month/year — enforced by `@@unique([userId, categoryId, month, year])` on `Budget`. The one-global-budget rule must be enforced by the service layer.
- A badge can only be earned once per user — enforced by `@@unique([userId, badgeId])` on `UserBadge`.
- A `UserChallenge` can only be in one status at a time; state transitions are one-way (`AVAILABLE → ACTIVE → COMPLETED`) — enforced at the service layer; the schema stores only the current status.
- A user can submit only one response per survey — enforced by `@@unique([userId, surveyId])` on `SurveyResponse`.
- Topic progress records are unique per user per topic — enforced by `@@unique([userId, topicId])` on `UserTopicProgress`.
- There is at most one prediction per user per period per type — enforced by `@@unique([userId, period, type])` on `Prediction`.
- A recommendation has at most one feedback record — enforced by `@unique` on `RecommendationFeedback.recommendationId`.
- Notification preferences are unique per user per notification type — enforced by `@@unique([userId, type])` on `NotificationPreference`.
- `AuditLog` records survive user deletion — enforced by `onDelete: SetNull` on `AuditLog.user`.
- System categories cannot be deleted — enforced in `CategoriesService`; only `CategoryType.CUSTOM` categories scoped to the requesting user may be soft-deleted.
