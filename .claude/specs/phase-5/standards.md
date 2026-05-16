# Standards Applied: Phase 5 — Financial Reports and Visualization

## Database

- **`deletedAt: null` on every query:** All `where` clauses in `prisma-insights.repository.ts` include `deletedAt: null` for transactions and savings goals. There is no transparent soft-delete middleware — the filter must be explicit at every query site.
- **`Decimal` conversion at repository boundary:** Every `_sum.amount` result from Prisma aggregations is converted with `.toNumber()` inside the repository. The domain and application layers never handle Prisma `Decimal` objects.
- **`Promise.all` for parallel aggregation:** Income and expense aggregations within a single period are always issued in parallel via `Promise.all`. The month comparison loop uses `Promise.all([incomeAgg, expenseAgg])` per month to halve per-iteration latency.

## Backend (Service / Application Layer)

- **Domain port extended with new abstract methods:** `getPeriodSummary` and `getMonthComparison` are declared as `abstract` methods on `IInsightsRepository` before any implementation. No application layer code imports `PrismaService` directly — all queries go through the port.
- **Use case per query, single responsibility:** Each query has its own `@Injectable()` use case class (`GetWeekSummaryUseCase`, `GetDaySummaryUseCase`, `GetMonthComparisonUseCase`, `GeneratePdfReportUseCase`). No use case performs more than one logical operation.
- **Date logic lives in the use case:** ISO week bounds (`isoWeekBounds`) and day bounds are computed inside the use case, not in the controller or repository. This keeps the repository agnostic to time granularity concepts.
- **PDF generation as a pure async operation:** `GeneratePdfReportUseCase.execute()` returns `Promise<Buffer>`. It has no side effects (no file writes, no HTTP calls). The controller is responsible for setting response headers and streaming the buffer.

## API

- **Consistent `@Query()` + `class-validator` DTOs:** All new endpoints use `@Query()` with a typed DTO class decorated with `@IsInt`, `@Min`, `@Max`, and `@Matches` as appropriate. The global `ValidationPipe` (configured in `main.ts`) rejects invalid inputs automatically.
- **`@Res()` used only for binary streaming:** `ReportsController.exportPdf` is the only endpoint that injects `@Res()`. All other endpoints return typed promises and let NestJS serialize the response. This is the correct pattern — avoid `@Res()` except when streaming or setting custom headers.
- **Swagger annotations on all endpoints:** Every new endpoint has `@ApiOperation`, `@ApiTags('Insights')`. The PDF endpoint adds `@ApiProduces('application/pdf')` so Swagger reflects the binary response type.
- **All endpoints under `JwtAuthGuard`:** Applied at the controller class level, not per-method. No endpoint in the insights module is publicly accessible.

## Frontend (State / Data Layer)

- **`FutureProvider.family` per query type:** Each summary type has its own scoped provider (`_monthSummaryProvider`, `_weekSummaryProvider`, `_comparisonProvider`) keyed by a typed record argument. This prevents stale data when the user changes the period selector.
- **`Provider<InsightsApiService>` as a module-private service provider:** The service provider is declared at file scope inside `reports_screen.dart` rather than in a global providers file, keeping it co-located with its only consumer.
- **State in `ConsumerStatefulWidget`, not providers:** Period selection state (`_year`, `_month`, `_week`) is managed with `setState` inside `_MonthTabState` and `_WeekTabState`. This is appropriate because it is pure UI navigation state with no cross-screen sharing requirement.
- **Loading, error, and data states always handled:** Every `ref.watch(provider).when(data:, loading:, error:)` call is complete — no `orElse` fallback that silently swallows error states.
- **PDF download does not block UI:** The export FAB sets `_exporting = true` and shows a spinner in place of the icon while the download is in progress. `mounted` is checked before calling `setState` after the async operation.

## Frontend (UI / i18n)

- **No hardcoded strings:** All visible text in `reports_screen.dart` uses `context.l10n.*`. Month name abbreviations used in `MonthComparisonEntry.label` and the `_monthNames` constant are English-only internal identifiers, not displayed user-facing strings.
- **ARB keys prefixed `reports`:** All 20 new keys follow the `reports` prefix convention established in prior phases (`auth`, `tx`, `catMgmt`, etc.).
- **Light theme tokens only:** All color decisions use `Theme.of(context).colorScheme` tokens or the `AppColors` palette. The app is locked to light mode (`themeMode: ThemeMode.light`), so no brightness branching is needed.
- **`withValues(alpha:)` used for transparency:** New code uses `.withValues(alpha: x)` instead of the deprecated `.withOpacity(x)` for all semi-transparent color values.
