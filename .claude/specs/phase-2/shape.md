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

- **`bucketForCategory()` in Transaction model** — Category-to-50/30/20 bucket mapping lives in the domain model, not in UI widgets. Alternative was a switch in the dashboard widget, but that logic belongs with the transaction data, not the presentation layer.

## Constraints

- No emoji in ARB locale strings — enforced by convention; emojis cause encoding issues across tools and are not screen-reader friendly.
- No hardcoded strings in `build()` methods — enforced by code review; all user-facing strings must come from `AppLocalizations`.
- `flutter gen-l10n` must be run after any ARB change — the generated files (`app_localizations*.dart`) are committed to avoid build-time generation requirements in CI.
- All routes declared in `lib/routing/app_router.dart` — no ad-hoc `GoRouter` instances in tests or widgets.
