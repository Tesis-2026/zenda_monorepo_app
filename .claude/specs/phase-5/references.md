# References: Phase 5 — Financial Reports and Visualization

## Key Files

### Backend — New Files

| File | Change |
|---|---|
| `zenda_backend_app/src/modules/insights/application/use-cases/get-week-summary.use-case.ts` | New: `GetWeekSummaryUseCase` — computes ISO week bounds via `isoWeekBounds()`, delegates to `getPeriodSummary` |
| `zenda_backend_app/src/modules/insights/application/use-cases/get-day-summary.use-case.ts` | New: `GetDaySummaryUseCase` — parses `YYYY-MM-DD` string, builds day bounds, delegates to `getPeriodSummary` |
| `zenda_backend_app/src/modules/insights/application/use-cases/get-month-comparison.use-case.ts` | New: `GetMonthComparisonUseCase` — delegates to `getMonthComparison(userId, months)` |
| `zenda_backend_app/src/modules/insights/application/use-cases/generate-pdf-report.use-case.ts` | New: `GeneratePdfReportUseCase` — builds PDF buffer using `pdfkit`; includes header, summary, category bars, goals progress, footer |
| `zenda_backend_app/src/modules/insights/interface/dto/week-summary.dto.ts` | New: `WeekSummaryDto` — `year` (2000–3000) + `week` (1–53) with `@IsInt`, `@Min`, `@Max` |
| `zenda_backend_app/src/modules/insights/interface/dto/day-summary.dto.ts` | New: `DaySummaryDto` — `date` with `@Matches(YYYY-MM-DD regex)` |
| `zenda_backend_app/src/modules/insights/interface/dto/comparison.dto.ts` | New: `ComparisonDto` — `months` (2–12) |
| `zenda_backend_app/src/modules/insights/interface/dto/comparison.response.dto.ts` | New: `MonthComparisonEntryDto` — year, month, totalIncome, totalExpense, netBalance |
| `zenda_backend_app/src/modules/insights/interface/reports.controller.ts` | New: `ReportsController` at `/reports` — `GET /reports/export/pdf` streams `Buffer` with `Content-Disposition: attachment` |

### Backend — Modified Files

| File | Change |
|---|---|
| `zenda_backend_app/src/modules/insights/domain/ports/insights.repository.ts` | Added `PeriodSummaryParams`, `PeriodSummaryData`, `MonthComparisonEntry`; added `getPeriodSummary` and `getMonthComparison` abstract methods; renamed existing params interface to extend `PeriodSummaryParams` |
| `zenda_backend_app/src/modules/insights/infrastructure/persistence/prisma-insights.repository.ts` | Refactored: extracted shared `fetchPeriodSummary()` private method; implemented `getPeriodSummary` and `getMonthComparison`; `getMonthSummary` now delegates to `fetchPeriodSummary` |
| `zenda_backend_app/src/modules/insights/interface/summary.controller.ts` | Added `GET /summary/week`, `GET /summary/day`, `GET /summary/comparison` endpoints; injected three new use cases via constructor |
| `zenda_backend_app/src/modules/insights/insights.module.ts` | Registered `GetWeekSummaryUseCase`, `GetDaySummaryUseCase`, `GetMonthComparisonUseCase`, `GeneratePdfReportUseCase`; added `ReportsController` |
| `zenda_backend_app/src/health/health.controller.ts` | Bug fix: removed duplicate `version` property from the `check()` return object literal (TypeScript error TS1117) |
| `zenda_backend_app/package.json` | Added `pdfkit` (runtime) and `@types/pdfkit` (dev) |
| `zenda_backend_app/package-lock.json` | Updated lockfile with pdfkit dependency tree |

### Frontend — New Files

| File | Change |
|---|---|
| `zenda_fronted_app/lib/core/models/summary_models.dart` | New: `TopCategoryItem`, `PeriodSummary`, `MonthComparisonEntry` — all with `fromJson` factories; `MonthComparisonEntry` has `label` getter for 3-letter month abbreviation |
| `zenda_fronted_app/lib/core/services/insights_api_service.dart` | New: `InsightsApiService` — five methods: `getMonthSummary`, `getWeekSummary`, `getDaySummary`, `getComparison`, `downloadPdfReport` |
| `zenda_fronted_app/lib/features/reports/reports_screen.dart` | New: `ReportsScreen` — 3-tab layout (Month, Week, Compare); `_MonthTabState` with PDF export FAB; `_WeekTabState`; `_CompareTabState` with segmented button; `_CategoryBarChart` custom proportional bar widget; `_ComparisonChart` fl_chart `LineChart` with 3 series |

### Frontend — Modified Files

| File | Change |
|---|---|
| `zenda_fronted_app/lib/core/services/api_client.dart` | Added `getBytes(path)` static method returning `List<int>` for binary downloads |
| `zenda_fronted_app/lib/features/dashboard/dashboard_screen.dart` | Added Reports tile (`/reports`) and Manage Categories tile (`/categories`) to `_PerfilSection` using `context.push` |
| `zenda_fronted_app/lib/routing/app_router.dart` | Added `GoRoute(path: '/reports', builder: ReportsScreen)` |
| `zenda_fronted_app/lib/l10n/app_en.arb` | Added 20 keys: `reportsTitle`, `reportsTabMonth`, `reportsTabWeek`, `reportsTabCompare`, `reportsTopCategories`, `reportsNoCategoryData`, `reportsIncome`, `reportsExpense`, `reportsBalance`, `reportsCompareMonths`, `reportsNoComparisonData`, `reportsErrorLoad`, `reportsTotalIncome`, `reportsTotalExpense`, `reportsNetBalance`, `reportsWeekLabel`, `reportsMonthLabel`, `reportsExportPdf`, `reportsExportPdfError` |
| `zenda_fronted_app/lib/l10n/app_es.arb` | Same 20 keys in Spanish |
| `zenda_fronted_app/lib/l10n/app_localizations.dart` | Auto-generated: abstract getters for all 20 new keys |
| `zenda_fronted_app/lib/l10n/app_localizations_en.dart` | Auto-generated: English implementations |
| `zenda_fronted_app/lib/l10n/app_localizations_es.dart` | Auto-generated: Spanish implementations |
| `zenda_fronted_app/pubspec.yaml` | Added `share_plus: ^10.1.3` and `path_provider: ^2.1.4` |
| `zenda_fronted_app/pubspec.lock` | Updated lockfile with share_plus and path_provider dependency trees |
| `zenda_fronted_app/linux/flutter/generated_plugin_registrant.cc` | Auto-generated: platform plugin registration updated for new packages |
| `zenda_fronted_app/linux/flutter/generated_plugins.cmake` | Auto-generated |
| `zenda_fronted_app/macos/Flutter/GeneratedPluginRegistrant.swift` | Auto-generated |
| `zenda_fronted_app/windows/flutter/generated_plugin_registrant.cc` | Auto-generated |
| `zenda_fronted_app/windows/flutter/generated_plugins.cmake` | Auto-generated |

### Root Monorepo — Modified Files

| File | Change |
|---|---|
| `.claude/agent-os/product/roadmap.md` | Marked Phase 5 tasks as `[x]` complete; updated timeline row to `✅ Done (PDF export deferred to P2)` → `✅ Done` |

## Test Files

No test files were created in this phase.

## Standards Applied

- `skills/platform/platform-backend/domain-driven-design-nestjs/SKILL.md` — domain port extended before implementation; all new use cases follow single-responsibility; no NestJS decorators in domain layer
- `skills/_drafts/framework/tech-prisma/SKILL.md` — `deletedAt: null` on all queries; `Decimal` converted at repository boundary; no `PrismaService` in application layer
- `skills/platform/platform-mobile/flutter/SKILLS.md` — state in `ConsumerStatefulWidget`; all strings via `context.l10n`; `.when(data, loading, error)` fully handled
- `skills/universal/lang-typescript/SKILL.md` — strict types throughout; no `any`; discriminated union `PeriodSummaryData | MonthSummaryData` via type alias
- `skills/assistant/pre-work-audit/SKILL.md` — pre-audit ran before implementation (found and fixed `health.controller.ts` bug); post-audit confirmed zero new errors in both backend and frontend
