---
title: GoRouter 17 — Routes, Guards, and Data Passing
impact: HIGH
tags: navigation, gorouter, routing, auth
---

## GoRouter 17 — Routes, Guards, and Data Passing

All routing logic lives in `routing/app_router.dart`. Never push routes imperatively from business logic or providers.

### Route Definition — Named Routes

```dart
// lib/routing/app_router.dart
final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authNotifierProvider);
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) => _redirect(auth, state),
    routes: [
      GoRoute(path: '/splash',   name: 'splash',   builder: (_, __) => const SplashDecider()),
      GoRoute(path: '/onboarding', name: 'onboarding', builder: (_, s) => OnboardingScreen(
        redirectToRegister: s.uri.queryParameters['flow'] == 'register',
      )),
      GoRoute(path: '/auth/login',    name: 'login',    builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/auth/register', name: 'register', builder: (_, __) => const RegisterScreen()),
      ShellRoute(
        builder: (ctx, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/dashboard',    name: 'dashboard',    builder: (_, __) => const DashboardScreen()),
          GoRoute(path: '/transactions', name: 'transactions', builder: (_, __) => const TransactionsScreen()),
          GoRoute(
            path: '/transactions/:id',
            name: 'transaction-detail',
            builder: (_, s) => TransactionDetailScreen(id: s.pathParameters['id']!),
          ),
        ],
      ),
    ],
  );
});
```

### Auth Guard — Single Redirect Function

```dart
String? _redirect(AsyncValue<AuthState> auth, GoRouterState state) {
  final isLoggedIn = auth.valueOrNull?.isAuthenticated ?? false;
  final isAuthRoute = state.matchedLocation.startsWith('/auth') ||
      state.matchedLocation == '/splash' ||
      state.matchedLocation == '/onboarding';

  if (!isLoggedIn && !isAuthRoute) return '/auth/login';
  if (isLoggedIn && isAuthRoute) return '/dashboard';
  return null;
}
```

- `redirect` fires on every navigation — keep it pure and synchronous.
- Wrapping the `GoRouter` inside a `Provider` that watches `authNotifierProvider` makes the router rebuild (and re-evaluate redirects) automatically when auth state changes.
- Never call `context.go('/login')` inside a Notifier — trigger navigation only via `ref.listen` in a widget's `build()`.

### Passing Data Between Routes — Priority Order

| Method | When to use | Survives deep link / cold start? |
|--------|-------------|----------------------------------|
| Path parameter (`/transactions/:id`) | IDs that must be bookmarkable | Yes |
| Query parameter (`?filter=needs`) | Optional filters and flags | Yes |
| `state.extra` | Complex objects that can't be serialized | No |

```dart
// Path parameter — preferred for IDs
context.goNamed('transaction-detail', pathParameters: {'id': tx.id});

// Query parameter — optional filters
context.goNamed('transactions', queryParameters: {'filter': 'needs', 'month': '2026-03'});

// extra — only for non-linkable ephemeral data
context.go('/add-transaction', extra: prefillData);
// Read: final data = state.extra as PrefillData?;
```

**Never rely on `extra` for data that must survive a cold launch or deep link.**

### Navigation Methods

| Method | When to use |
|--------|-------------|
| `context.go('/path')` | Replace entire stack (logout → login, bottom nav tabs) |
| `context.push('/path')` | Push on stack (detail screens, modals) |
| `context.pop()` | Go back one level |
| `context.goNamed('name', ...)` | Preferred over hardcoded path strings |

**Never use `Navigator.of(context).push(...)` in a GoRouter app** — it bypasses redirect logic.

### ShellRoute — Persistent Bottom Navigation

```dart
ShellRoute(
  builder: (context, state, child) => AppShell(child: child),
  routes: [
    GoRoute(path: '/dashboard',    builder: ...),
    GoRoute(path: '/transactions', builder: ...),
    GoRoute(path: '/budget',       builder: ...),
    GoRoute(path: '/profile',      builder: ...),
  ],
)
```

Use `ShellRoute` for tabs that share a persistent scaffold. Each tab maintains its own navigator stack.
