# Shape: Phase 2 — Flutter Frontend Foundation

## Decisions

- **Feature-based directory over layer-based** — `lib/features/<feature>/` groups all files for a screen together (widget, controller, service). Alternative was a layer-based structure (`lib/screens/`, `lib/controllers/`, `lib/services/`) which was rejected because it scatters related files and slows navigation. Feature folders make the codebase navigable without knowing the full architecture.

- **Riverpod 3 over BLoC or Provider** — Riverpod was chosen for type-safe, compile-time provider access, no `BuildContext` dependency in logic, and Notifier pattern that maps cleanly to use-case boundaries. BLoC adds event/state boilerplate not justified at this scale. Provider is simpler but lacks Riverpod's static safety and ref-scoping.

- **GoRouter 17 over Navigator 2.0** — Declarative routing with URL-based navigation is required for deep linking and auth redirects. GoRouter's `AuthGate` pattern (wrapping screens, not using redirect callbacks) was chosen for simplicity at this scale. A full `redirect` callback was considered but deferred — it requires listenable auth state which adds complexity not needed for MVP.

- **Local-first data with API auth** — Auth (login, register, password recovery) goes to the NestJS backend. Everything else (transactions, accounts, streaks) is stored locally in SharedPreferences via `TransactionsRepository`, `AccountsRepository`. Alternative was full API integration from day one, but local-first reduces risk during backend-frontend co-development: the UI is testable without a running server.

- **`flutter_secure_storage` for JWT** — JWT stored in platform secure storage (Android Keystore / iOS Keychain), not SharedPreferences. Alternative (SharedPreferences) was rejected because tokens are sensitive credentials and SharedPreferences is unencrypted on Android.

- **`LocalKvStore` wrapper over raw SharedPreferences** — Thin wrapper that centralizes the SharedPreferences instance, making it mockable in tests and swappable without touching callers. Alternative was to inject SharedPreferences directly, but that would spread the platform API throughout the codebase.

- **`L10nX` extension for localization access** — `context.l10n` extension removes the verbose `AppLocalizations.of(context)` call from every widget. Alternative was using a global accessor, but that breaks when context changes locale at runtime.

- **ARB-based i18n over package:easy_localization** — `flutter gen-l10n` is the Flutter team's official solution: compile-time key safety, no extra dependency, works with ICU plurals. `easy_localization` was considered but adds a runtime dependency and loses compile-time safety.

- **`nullable-getter: false` in l10n.yaml** — Forces `AppLocalizations.of(context)` to be non-nullable, removing unnecessary null checks at every call site. Only valid because all routes are children of `MaterialApp.router` which guarantees the delegate is present.

- **Spanish-only locale, forced at app root** — `lib/app.dart` hardcodes `locale: const Locale('es')` and declares `supportedLocales: [Locale('es')]`. The previous `LocaleNotifier` / `localeProvider` (SharedPreferences-backed runtime switcher) and the language entry in `SettingsScreen` were removed. Alternative was to keep the EN/ES switcher and rely on device locale; rejected because the product audience is exclusively Spanish-speaking (Peruvian university students), the English copy was incomplete in mock data, and an unused switcher confuses users and inflates QA scope.

- **Spanish-only mocked data** — Demo seed data in `lib/core/mock/demo_data.dart` and `lib/core/mock/mock_services.dart` (transaction notes, account names, education topics, quizzes, AI chat responses, challenges, badges, surveys, prediction narrative, goal names) is written directly in Spanish. Alternative was routing every demo string through ARB keys; rejected because mocks simulate API payloads, and the real backend will also return Spanish content in production.

- **Mocked category names are stored in Spanish, not translated at display** — `TopCategoryItem.name`, `Recommendation`-like seed fields, and `DemoData._categoryApiName()` all return Spanish display strings (`'Comida'`, `'Salud'`, `'Transporte'`). Widgets render `item.name` directly with no translator helper. Alternative was keeping English keys in the data and translating at the display boundary via a `labelEs()` helper; rejected because it contradicts the "data is Spanish by default" criterion and adds a leak point. `CategoryUtils.iconForCategory` and `bgColorForCategory` already match on lowercase EN-or-ES keys (`'food' || 'comida' => ...`), so passing Spanish names to icon/color lookups still works. The drill-down sheet filter compares case-insensitively, so Spanish names match between the top-categories list and the transactions stream.

- **`bucketForCategory()` in Transaction model** — Category-to-50/30/20 bucket mapping lives in the domain model, not in UI widgets. Alternative was a switch in the dashboard widget, but that logic belongs with the transaction data, not the presentation layer.

## Constraints

- No emoji in ARB locale strings — enforced by convention; emojis cause encoding issues across tools and are not screen-reader friendly.
- No hardcoded **English** strings in `build()` methods — enforced by code review. UI chrome (buttons, labels, dialogs) must come from `AppLocalizations`. One-off Spanish copy in demo/mock files is acceptable when it represents simulated API content rather than UI chrome.
- Locale forced to `es`: any new code that reads device locale or attempts to set a locale at runtime must be rejected in review.
- `flutter gen-l10n` must be run after any ARB change — the generated files (`app_localizations*.dart`) are committed to avoid build-time generation requirements in CI.
- All routes declared in `lib/routing/app_router.dart` — no ad-hoc `GoRouter` instances in tests or widgets.
