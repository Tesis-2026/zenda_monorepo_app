# Phase 2: Flutter Frontend Foundation

## Context

Before this phase, the project had a fully operational NestJS backend (Phase 1A) and a complete Prisma schema (Phase 1B), but zero frontend code. This phase bootstraps the entire Flutter mobile app: app infrastructure, all auth flows wired to the backend API, onboarding, a functional dashboard with 50/30/20 budget visualization, transaction entry, profile management, and Spanish-only localization (the audience is Spanish-speaking Peruvian university students; locale is forced to `es` and there is no language switcher). User stories covered: US-027, US-028, (infrastructure: JWT guard), (infrastructure: password recovery), US-030 / US-032, US-005, US-019.

## Tasks Completed

1. `pubspec.yaml` — Flutter project with dependencies: `flutter_riverpod ^3.0.3`, `go_router ^17.0.0`, `google_fonts`, `fl_chart`, `image_picker`, `intl`, `shared_preferences`, `crypto`, `http`, `flutter_secure_storage`, `flutter_localizations`
2. `lib/main.dart` — entry point with `ProviderScope` wrapping `App`
3. `lib/app.dart` — `MaterialApp.router` with GoRouter, localization delegates, light theme (forced via `themeMode: ThemeMode.light`)
4. `lib/routing/app_router.dart` — GoRouter with all routes: `/`, `/onboarding`, `/auth/login`, `/auth/register`, `/auth/forgot-password`, `/auth/reset-password`, `/dashboard`, `/add-transaction`
5. `lib/core/theme/` — `AppTheme` (light only) using Material 3
6. `lib/core/models/` — `User`, `Transaction`, `Account`, `Streak`, `Breakdown503020`
7. `lib/core/services/api_client.dart` — base HTTP client with auth token injection and error normalization
8. `lib/core/services/auth_api_service.dart` — register, login, forgotPassword, resetPassword hitting the NestJS API
9. `lib/core/services/user_api_service.dart` — getProfile, updateProfile
10. `lib/core/services/local_kv_store.dart` — SharedPreferences wrapper for local persistence
11. `lib/core/services/transactions_repository.dart` — local transaction storage
12. `lib/core/services/accounts_repository.dart` — local account management (cash, debit, credit)
13. `lib/core/services/streak_repository.dart` — daily login streak tracking
14. `lib/core/services/ai_advice_service.dart` — stub returning hardcoded financial tips
15. `lib/core/services/ocr_service.dart` — stub (image picker integration, OCR pending Phase 7)
16. `lib/features/auth/auth_controller.dart` — Riverpod `Notifier` for auth state (login, register, clearError)
17. `lib/core/services/api_client.dart` — base HTTP client with `flutter_secure_storage`-backed JWT and refresh handling
18. `lib/features/auth/auth_gate.dart` — redirect guard: authenticated users bypassed from auth screens
19. `lib/features/auth/login_screen.dart` — email/password form, forgot-password link, "account not found" dialog
20. `lib/features/auth/register_screen.dart` — name/email/password form, privacy note
21. `lib/features/auth/forgot_password_screen.dart` — email form, shows code-received dialog on submit
22. `lib/features/auth/reset_password_screen.dart` — code + new password form
23. `lib/features/onboarding/onboarding_screen.dart` — 3-page onboarding carousel with skip/next/register/start controls
24. `lib/features/onboarding/onboarding_page.dart` — reusable page widget (title, subtitle, micro-copy, illustration)
25. `lib/features/onboarding/splash_decider.dart` — reads `SharedPreferences` to decide: onboarding → auth → dashboard
26. `lib/features/onboarding/onboarding_prefs.dart` — persistence helpers for onboarding completion flag
27. `lib/features/dashboard/dashboard_screen.dart` — bottom-nav shell with Home, Transactions, Budget, Profile tabs; greeting, accounts row, 50/30/20 chart, recent transactions list
28. `lib/features/dashboard/dashboard_providers.dart` — Riverpod providers for accounts and transactions state
29. `lib/features/dashboard/widgets/summary_card.dart` — today's spend + this-week totals
30. `lib/features/dashboard/widgets/streak_card.dart` — daily streak display with ICU plural label
31. `lib/features/dashboard/widgets/budget_pie_chart.dart` — fl_chart pie chart for needs/wants/savings breakdown
32. `lib/features/dashboard/widgets/zenda_ai_card.dart` — AI tip card (stub data)
33. `lib/features/dashboard/widgets/account_card.dart` — individual account balance tile
34. `lib/features/transactions/add_transaction_screen.dart` — type selector (expense/income/transfer), account picker, amount, category grid, note, date; saves locally
35. `lib/features/transactions/transaction_create_screen.dart` — alternative creation entry point
36. `lib/features/transactions/transaction_list_screen.dart` — paginated transaction list
37. `lib/features/transactions/controllers/new_transaction_controller.dart` — Riverpod controller for form state
38. `lib/features/profile/profile_screen.dart` — display/edit: full name, age, university, currency, income type, monthly income, financial literacy; sign-out with confirmation dialog
39. `lib/features/streak/streak_notifier.dart` — Riverpod notifier tracking current streak count
40. `lib/features/progress/progress_screen.dart` — stub screen (Phase 10+)
41. `lib/providers/providers.dart` — global provider declarations (authStateProvider, transactionsStateProvider, ocrServiceProvider, aiServiceProvider, streakNotifierProvider)
42. `lib/providers/repositories_providers.dart` — repository providers
43. `l10n.yaml` — codegen config: `arb-dir: lib/l10n`, output `app_localizations.dart`, `nullable-getter: false`
44. `lib/l10n/app_en.arb` — 130 English keys (common, validation, auth, onboarding, dashboard, summary, streak, budget, ai, transactions, categories, profile)
45. `lib/l10n/app_es.arb` — 130 Spanish translations of all keys
46. `lib/l10n/l10n_extension.dart` — `L10nX` extension: `BuildContext.l10n` → `AppLocalizations`

## What Was Built

### App Navigation (GoRouter)

| Route | Screen | Auth required |
|-------|--------|---------------|
| `/` | `SplashDecider` | No — decides where to go |
| `/onboarding` | `OnboardingScreen` | No |
| `/auth/login` | `LoginScreen` via `AuthGate` | No (redirects if already authed) |
| `/auth/register` | `RegisterScreen` via `AuthGate` | No |
| `/auth/forgot-password` | `ForgotPasswordScreen` | No |
| `/auth/reset-password` | `ResetPasswordScreen` | No |
| `/dashboard` | `DashboardScreen` | Yes |
| `/add-transaction` | `AddTransactionScreen` | Yes |

### Auth Flow (US-027, US-028, infrastructure: JWT guard)

- **Login**: email + password → `AuthApiService.login()` → JWT stored in `flutter_secure_storage` → navigate to `/dashboard`
- **Register**: name + email + password → `AuthApiService.register()` → auto-login → `/dashboard`
- **Forgot password**: email → `AuthApiService.forgotPassword()` → dialog → `/auth/reset-password`
- **Reset password**: code + new password → `AuthApiService.resetPassword()` → snackbar → `/auth/login`
- **Auth guard**: `AuthGate` wraps login/register screens — authenticated users are skipped to `/dashboard`

### Onboarding (infrastructure: password recovery)

Three-page carousel explaining: (1) record expenses, (2) 50/30/20 rule, (3) streak/consistency. Controls: skip (goes to login), next, register (goes to onboarding with register flow), start. Completion flag stored in SharedPreferences — seen once only.

### Dashboard (US-019)

Bottom navigation shell with four tabs. Home tab shows:
- Greeting with user's first name
- Account cards (cash, debit, credit balances)
- 50/30/20 pie chart with needs/wants/savings percentages
- AI tip card (stub)
- Recent transactions list (last 10)
- Summary card (today's spend, this-week total)
- Streak card with ICU plural label

### Transaction Entry (US-005)

`AddTransactionScreen` supports three types: Expense, Income, Transfer. Fields: account, amount (PEN), category (grid picker), note, date. Category grid maps to 50/30/20 buckets via `bucketForCategory()`. Saves locally to `TransactionsRepository`.

### Profile (US-030 / US-032)

View and edit: full name, age, university, currency, income type, monthly income, financial literacy level. Sign-out with `AlertDialog` confirmation. Calls `UserApiService.updateProfile()` on save.

### Internationalization

| File | Keys | Locale | Role |
|------|------|--------|------|
| `app_es.arb` | 130 | Spanish | Authoritative source — what users see |
| `app_en.arb` | 130 | English | Codegen template only (Flutter `gen-l10n` requires `template-arb-file`) |

- App locale is **forced to `es` in `lib/app.dart`** — device locale is ignored and there is no in-app language switcher. The previous `LocaleNotifier` / `localeProvider` and the language entry in `SettingsScreen` were removed.
- `supportedLocales` is `[Locale('es')]` only.
- `L10nX` extension for clean `context.l10n.key` access.
- ICU plural for streak: `{count, plural, =1{1-day streak} other{{count}-day streak}}` (Spanish copy in `app_es.arb`).
- Named placeholder for greeting: `{name}`.
- Hardcoded **mock/demo** data (transactions, education topics, badges, AI chat responses) is written in Spanish directly inside `lib/core/mock/demo_data.dart` and `mock_services.dart` — it does not flow through ARB files because it represents API payloads, not UI chrome.
