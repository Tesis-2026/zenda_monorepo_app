# Shape: Phase 5 — Financial Reports and Visualization

## Decisions

- **Shared `PeriodSummaryData` type for all three period endpoints** — Month, week, and day all return the same shape (`totalIncome`, `totalExpense`, `netBalance`, `topCategories`, `goalsProgress`). The alternative was a thinner response for week/day (no goals progress). Rejected because goals progress is always relevant context regardless of period length, and the uniform shape simplifies the Flutter service layer to a single model.

- **`getPeriodSummary` private method shared across month/week/day** — Rather than duplicating the four-query Prisma block in each use case, the repository exposes a single `getPeriodSummary(params: PeriodSummaryParams)` port that takes `from`/`to` bounds. Each use case computes its own bounds and delegates. The alternative was three separate repository methods (`getWeekSummary`, `getDaySummary`, etc.). Rejected because the query logic is identical — only the date bounds differ.

- **ISO week bounds computed in the use case, not the controller** — `GetWeekSummaryUseCase` contains the `isoWeekBounds()` helper. The alternative was computing bounds in the controller or in the repository. Rejected: controllers should not contain date logic; repositories should not know about ISO standards. The use case is the correct home for domain-level date interpretation.

- **ISO week anchor: Jan 4 rule** — Week 1 is defined as the week containing January 4th (equivalent to the first Thursday). This matches the ISO 8601 standard and ensures consistent behavior across year boundaries. The alternative (treating Jan 1 as the start of week 1) was rejected because it produces weeks that don't align with EU/Latin American academic and financial calendars.

- **Comparison endpoint iterates months sequentially, not via a single raw SQL query** — `getMonthComparison` loops N months and issues two `aggregate` calls per month (income + expense via `Promise.all`). The alternative was a single `groupBy` with a date-trunc expression. Rejected because Prisma's `groupBy` does not support arbitrary date truncation without raw SQL, and raw SQL breaks the ORM abstraction layer. For N ≤ 12, the sequential approach is well within acceptable latency.

- **PDF generated in memory as `Buffer`, streamed directly** — `GeneratePdfReportUseCase` resolves a `Promise<Buffer>` using pdfkit's `Readable` stream. The controller reads this buffer and writes it to the `Response` object. The alternative was writing to a temporary file and returning a URL (as the roadmap's "24h temporary URL" suggestion implies). Rejected for this phase because it requires a file storage layer (S3 or local disk with cleanup jobs). Direct streaming is functionally equivalent for the mobile share-sheet use case.

- **Category bar chart built with `LayoutBuilder` rectangles, not `fl_chart` `BarChart`** — The horizontal category chart in `ReportsScreen` is a custom widget using `Stack` + proportional `Container` widths, not `fl_chart`'s `BarChart`. The alternative was `fl_chart`'s horizontal bar chart. Rejected because fl_chart's `BarChart` requires numeric indices on both axes and doesn't support mixed label types (category names on Y, currency on X) without significant custom renderer work. The custom approach is simpler and renders identically.

- **`fl_chart` `LineChart` used for the comparison chart** — The multi-month trend chart uses `fl_chart` because it natively supports multiple series, curved lines, dot markers, and fill below the line. This is the one chart that benefits from fl_chart's full API.

- **PDF export FAB appears only on the Month tab** — Weekly and daily PDFs were not implemented. The PDF format (monthly summary + category chart + goals) is semantically tied to a month period. The alternative was a FAB on all three tabs. Rejected: a weekly PDF would lack goals progress context, and a daily PDF would be near-empty for most users.

- **`share_plus` used for PDF sharing, not a download URL** — On mobile, the OS share sheet is the idiomatic way to distribute files. The alternative (showing a copyable URL) would require a hosted storage backend. `share_plus` with `XFile` passes the local temp file path to the OS and works without network storage.

- **Navigation to ReportsScreen via Profile tab tiles, not a 5th bottom nav item** — Adding a 5th tab would require restructuring the `PageView` and all bottom nav logic. The alternative was adding Reports as a dedicated nav tab. Rejected for now because the 4-tab layout (Home, Transactions, Budget, Profile) is established. Reports is an occasional-use screen, appropriate as a profile-level navigation item.

## Constraints

- **`deletedAt: null` on all transaction queries** — enforced in `prisma-insights.repository.ts` on every `where` clause; soft-deleted transactions must never appear in summaries.
- **`Decimal` → `number` conversion at repository boundary** — all `_sum.amount` values call `.toNumber()` before leaving the repository; the application and domain layers never see Prisma `Decimal`.
- **`months` param range 2–12** — enforced by `@Min(2) @Max(12)` on `ComparisonDto`; requesting fewer than 2 months produces a meaningless comparison.
- **`week` param range 1–53** — enforced by `@Min(1) @Max(53)` on `WeekSummaryDto`; ISO year can have 52 or 53 weeks.
- **`date` param must match `YYYY-MM-DD`** — enforced by `@Matches(/^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$/)` on `DaySummaryDto`.
- **PDF export only available for month granularity** — `ReportsController` reuses `MonthSummaryDto` (year + month) and calls `getMonthSummary`; no separate PDF DTO needed.
- **Top categories capped at 5** — `take: 5` in the Prisma `groupBy` call; enforced at repository level.
