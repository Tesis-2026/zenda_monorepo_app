# Standards Applied: Phase 2 — Flutter Frontend Foundation

## Architecture

- **Feature isolation:** Each feature folder (`lib/features/<feature>/`) is self-contained. Screens, controllers, and feature-specific widgets live together. Cross-feature dependencies go through `lib/core/` or providers.
- **State in providers, not widgets:** Business logic and async state live in Riverpod `Notifier` / `AsyncNotifier` classes. Widgets only read state via `ref.watch` and dispatch via `ref.read(...notifier)`.
- **No `ref.watch` in callbacks:** `ref.watch` is only called in `build()`; all callbacks and event handlers use `ref.read`.

## Routing

- **Single router file:** All routes live in `lib/routing/app_router.dart`. No `GoRouter` instance created outside this file.
- **Route strings are not hardcoded in widgets:** `context.go('/dashboard')` strings match the definitions in `app_router.dart`. No magic strings scattered across screens.
- **AuthGate wraps screens, not redirects:** Auth screens are wrapped with `AuthGate` which checks state and skips to `/dashboard` if already authenticated. This is simpler than `GoRouter.redirect` callbacks for the current auth complexity.

## Localization

- **No string literals in `build()` methods:** Every user-facing string is accessed via `context.l10n.keyName`.
- **Capture l10n once per build:** `final l10n = context.l10n;` at the top of `build()`, then used in validators and child closures — avoids calling `AppLocalizations.of(context)` repeatedly.
- **Key naming:** `featureNoun` camelCase prefix — `authLoginTitle`, `dashboardGreeting`, `txSaveButton`, `profileEditButton`, `commonCancel`.
- **Placeholder syntax:** `{name}` in ARB, declared in `@key.placeholders`. Type is always explicit (`"type": "String"` or `"type": "int"`).
- **Plural syntax:** ICU `{count, plural, =1{singular} other{plural}}` — no manual if/else for plurals.
- **No emoji in locale strings:** Emoji belong in the UI layer (Icon widgets), not in translated text.

## API Integration

- **Single `ApiClient`:** All HTTP calls go through `lib/core/services/api_client.dart`. Direct `http.get/post` calls in feature code are not allowed.
- **Auth token injection:** `ApiClient` reads the JWT from `flutter_secure_storage` and injects it into request headers automatically.
- **Error normalization:** `ApiClient` maps HTTP error responses to typed Dart exceptions before they reach callers.

## Widgets

- **`const` constructors everywhere possible:** Widgets that do not hold mutable state use `const` constructors to enable Flutter's widget diffing optimization.
- **Widget extraction over nesting:** When a `build()` method exceeds ~80 lines, extract sub-widgets. Named private widgets (`_SomeSection`) over anonymous builders for reuse and readability.
- **No business logic in `build()`:** Only rendering decisions (ternaries for empty states, theme lookups) are allowed in `build()`. Data fetching, storage writes, and navigation are in controllers or event handlers.

## Theme

- **No hardcoded colors in widgets:** All colors come from `Theme.of(context).colorScheme` or the project-defined palette constants in `AppTheme`. Exception: Zenda's brand green `Color(0xFF34D399)` is used directly where semantic tokens are not yet defined.
- **Light theme only:** The app is locked to light mode via `themeMode: ThemeMode.light` in `lib/app.dart`. Dark mode is not supported — no dark color tokens, no brightness checks, no `values-night/` resources.
