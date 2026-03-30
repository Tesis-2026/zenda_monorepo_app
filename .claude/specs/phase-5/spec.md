# Phase 5: Financial Reports and Visualization

## Context

Before this phase, users could record transactions and manage categories (Phases 3–4), but had no way to visualize their spending patterns over time. The dashboard's `BudgetPieChart` and `SummaryCard` provided only static 50/30/20 breakdown and today/week totals. Phase 5 closes the gap by introducing a dedicated reporting layer: four new backend aggregation endpoints, a PDF export endpoint, and a full-screen reports UI with interactive charts.

User stories covered: US-0401 (monthly summary), US-0402 (weekly summary), US-0403 (daily summary), US-0404 (monthly comparison), US-0405 (charts by category), US-0406 (PDF export).

## Tasks Completed

1. `zenda_backend_app/src/modules/insights/domain/ports/insights.repository.ts` — Extended port: added `PeriodSummaryParams`, `PeriodSummaryData`, `MonthComparisonEntry`; added `getPeriodSummary` and `getMonthComparison` abstract methods
2. `zenda_backend_app/src/modules/insights/infrastructure/persistence/prisma-insights.repository.ts` — Refactored to share `fetchPeriodSummary` private method; implemented `getPeriodSummary` and `getMonthComparison`
3. `zenda_backend_app/src/modules/insights/application/use-cases/get-week-summary.use-case.ts` — New: ISO week bounds computation + delegates to `getPeriodSummary`
4. `zenda_backend_app/src/modules/insights/application/use-cases/get-day-summary.use-case.ts` — New: parses `YYYY-MM-DD`, builds day bounds, delegates to `getPeriodSummary`
5. `zenda_backend_app/src/modules/insights/application/use-cases/get-month-comparison.use-case.ts` — New: iterates N past months, parallel income/expense aggregation per month
6. `zenda_backend_app/src/modules/insights/application/use-cases/generate-pdf-report.use-case.ts` — New: builds PDF in memory via `pdfkit` (header, summary, category bars, goals progress, footer)
7. `zenda_backend_app/src/modules/insights/interface/dto/week-summary.dto.ts` — New: `year` + `week` (ISO 1–53) query params with `class-validator`
8. `zenda_backend_app/src/modules/insights/interface/dto/day-summary.dto.ts` — New: `date` query param with `YYYY-MM-DD` regex validation
9. `zenda_backend_app/src/modules/insights/interface/dto/comparison.dto.ts` — New: `months` (2–12) query param
10. `zenda_backend_app/src/modules/insights/interface/dto/comparison.response.dto.ts` — New: `MonthComparisonEntryDto` with year, month, totalIncome, totalExpense, netBalance
11. `zenda_backend_app/src/modules/insights/interface/summary.controller.ts` — Extended: added `/week`, `/day`, `/comparison` endpoints alongside existing `/month`
12. `zenda_backend_app/src/modules/insights/interface/reports.controller.ts` — New: `GET /reports/export/pdf` streams PDF buffer with `Content-Disposition: attachment`
13. `zenda_backend_app/src/modules/insights/insights.module.ts` — Registered four new use cases and `ReportsController`
14. `zenda_backend_app/src/health/health.controller.ts` — Bug fix: removed duplicate `version` property in object literal
15. `zenda_backend_app/package.json` — Added `pdfkit` and `@types/pdfkit`
16. `zenda_fronted_app/lib/core/models/summary_models.dart` — New: `TopCategoryItem`, `PeriodSummary`, `MonthComparisonEntry` with `fromJson` factories
17. `zenda_fronted_app/lib/core/services/insights_api_service.dart` — New: five methods wrapping all summary and PDF endpoints
18. `zenda_fronted_app/lib/core/services/api_client.dart` — Added `getBytes()` for binary PDF download
19. `zenda_fronted_app/lib/features/reports/reports_screen.dart` — New: full 3-tab screen (Month, Week, Compare) with charts and PDF export FAB
20. `zenda_fronted_app/lib/features/dashboard/dashboard_screen.dart` — Added Reports and Manage Categories navigation tiles to Profile tab
21. `zenda_fronted_app/lib/routing/app_router.dart` — Added `/reports` route
22. `zenda_fronted_app/lib/l10n/app_en.arb` — 20 new report keys
23. `zenda_fronted_app/lib/l10n/app_es.arb` — 20 new report keys (Spanish translations)
24. `zenda_fronted_app/pubspec.yaml` — Added `share_plus ^10.1.3` and `path_provider ^2.1.4`

## What Was Built

### Summary Endpoints (US-0401, US-0402, US-0403)

All three period endpoints share the same response shape via `PeriodSummaryData`:

| Field | Type | Description |
|---|---|---|
| `totalIncome` | `number` | Sum of INCOME transactions in period |
| `totalExpense` | `number` | Sum of EXPENSE transactions in period |
| `netBalance` | `number` | `totalIncome - totalExpense` |
| `topCategories` | `{ name, amount }[]` | Top 5 expense categories by amount |
| `goalsProgress` | `{ name, currentAmount, targetAmount, progressPercent }[]` | All active savings goals |

| Endpoint | Period Param | Example |
|---|---|---|
| `GET /api/summary/month` | `?year=2026&month=3` | March 2026 |
| `GET /api/summary/week` | `?year=2026&week=13` | ISO week 13 of 2026 |
| `GET /api/summary/day` | `?date=2026-03-30` | March 30, 2026 |

ISO week bounds are computed using the standard Jan-4 anchor rule (week 1 always contains the first Thursday of the year).

### Monthly Comparison Endpoint (US-0404)

`GET /api/summary/comparison?months=N` returns an array of N entries for the last N calendar months (oldest first), each with:

| Field | Type |
|---|---|
| `year` | `number` |
| `month` | `number` (1–12) |
| `totalIncome` | `number` |
| `totalExpense` | `number` |
| `netBalance` | `number` |

Valid range for `months`: 2–12.

### PDF Export Endpoint (US-0406)

`GET /api/reports/export/pdf?year=Y&month=M` streams a PDF buffer with:
- `Content-Type: application/pdf`
- `Content-Disposition: attachment; filename="zenda-report-YYYY-MM.pdf"`

PDF layout:
1. **Header** — indigo background, "Zenda" title, "Financial Report" subtitle, period label right-aligned
2. **Summary** — income (green), expense (red), divider, net balance (green/red by sign)
3. **Top Expense Categories** — proportional bar chart (pdfkit rectangles), category name left, amount right
4. **Savings Goals** — progress bar per goal, current/target amounts, percentage label
5. **Footer** — generation date centered

### ReportsScreen (US-0405)

Accessible via `/reports` route, linked from the Profile tab of `DashboardScreen`.

**Tab structure:**

| Tab | Content | Navigation |
|---|---|---|
| Month | Totals row + top-categories horizontal bar chart | ← / → month selector |
| Week | Totals row + top-categories horizontal bar chart | ← / → ISO week selector |
| Compare | Multi-line chart (income / expense / balance) | Segmented button: 2M / 3M / 6M |

**Totals row** — three stat cards: Income (green), Expense (red), Balance (blue/red by sign).

**Category bar chart** — custom widget using `LayoutBuilder` for proportional bars; top-5 categories with cycle of 5 brand colors; no fl_chart dependency.

**Comparison line chart** — `fl_chart` `LineChart` with three `LineChartBarData` series; month abbreviations on x-axis; currency labels on y-axis.

**PDF export FAB** — visible only on Month tab; downloads PDF bytes via `InsightsApiService.downloadPdfReport()`, saves to `getTemporaryDirectory()`, opens native share sheet via `share_plus`.
