---
name: flutter-development
description: Build beautiful cross-platform mobile apps with Flutter and Dart. Covers widgets, state management with Provider/BLoC, navigation, API integration, and material design.
---

# Flutter Development

## Overview

Create high-performance, visually stunning mobile applications using Flutter with Dart language. Master widget composition, state management patterns, navigation, and API integration.

## When to Use

- Building iOS and Android apps with native performance
- Designing custom UIs with Flutter's widget system
- Implementing complex animations and visual effects
- Rapid app development with hot reload
- Creating consistent UX across platforms

## Instructions

### 1. **Project Structure & Navigation**

```dart
// pubspec.yaml
name: my_flutter_app
version: 1.0.0

dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0
  http: ^1.1.0
  go_router: ^12.0.0

// main.dart with GoRouter navigation
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter App',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'details/:id',
          builder: (context, state) => DetailsScreen(
            itemId: state.pathParameters['id']!
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
```

### 2. **State Management with Provider**

```dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class User {
  final String id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}

class UserProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUser(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('https://api.example.com/users/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        _user = User.fromJson(jsonDecode(response.body));
      } else {
        _error = 'Failed to fetch user';
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}

class ItemsProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => _items;

  Future<void> fetchItems() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.example.com/items'),
      );

      if (response.statusCode == 200) {
        _items = List<Map<String, dynamic>>.from(
          jsonDecode(response.body) as List
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching items: $e');
    }
  }
}
```

### 3. **Screens with Provider Integration**

```dart
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ItemsProvider>(context, listen: false).fetchItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Feed')),
      body: Consumer<ItemsProvider>(
        builder: (context, itemsProvider, child) {
          if (itemsProvider.items.isEmpty) {
            return const Center(child: Text('No items found'));
          }
          return ListView.builder(
            itemCount: itemsProvider.items.length,
            itemBuilder: (context, index) {
              final item = itemsProvider.items[index];
              return ItemCard(item: item);
            },
          );
        },
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const ItemCard({required this.item, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(item['title'] ?? 'Untitled'),
        subtitle: Text(item['description'] ?? ''),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () => context.go('/details/${item['id']}'),
      ),
    );
  }
}

class DetailsScreen extends StatelessWidget {
  final String itemId;

  const DetailsScreen({required this.itemId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Item ID: $itemId', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (userProvider.error != null) {
            return Center(child: Text('Error: ${userProvider.error}'));
          }
          final user = userProvider.user;
          if (user == null) {
            return const Center(child: Text('No user data'));
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${user.name}', style: const TextStyle(fontSize: 18)),
                Text('Email: ${user.email}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => userProvider.logout(),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

### 4. **Internationalization (i18n)**

Every user-facing string must come from `AppLocalizations`. Never hardcode UI text.

#### Setup — `pubspec.yaml`
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.20.2        # already required by flutter_localizations

flutter:
  generate: true       # enables flutter gen-l10n
```

#### Setup — `l10n.yaml` (project root)
```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-dir: lib/l10n
nullable-getter: false
```

#### ARB file structure — `lib/l10n/app_en.arb`
```json
{
  "@@locale": "en",
  "appTitle": "Zenda",
  "commonCancel": "Cancel",
  "authLoginTitle": "Welcome to Zenda",
  "dashboardGreeting": "Hi, {name} 👋",
  "@dashboardGreeting": {
    "placeholders": {
      "name": { "type": "String" }
    }
  },
  "streakLabel": "{count, plural, =1{1-day streak} other{{count}-day streak}}",
  "@streakLabel": {
    "placeholders": {
      "count": { "type": "int" }
    }
  }
}
```

Mirror every key in `lib/l10n/app_es.arb` with `"@@locale": "es"`.

#### Context extension — `lib/l10n/l10n_extension.dart`
```dart
import 'package:flutter/material.dart';
import 'app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
```

#### Wire in `MaterialApp.router`
```dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

MaterialApp.router(
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: const [
    Locale('en'),
    Locale('es'),
  ],
  // ...
)
```

#### Usage in widgets
```dart
import '../../../l10n/l10n_extension.dart';

// In build():
Text(context.l10n.authLoginTitle)
Text(context.l10n.dashboardGreeting(user.firstName))
Text(context.l10n.streakLabel(streakDays))
```

#### Key naming convention
- Prefix by feature: `auth_`, `dashboard_`, `tx_`, `onboarding_`, `profile_`, `common_`
- Use camelCase (ARB requirement)
- Interpolated strings use named `{placeholders}`
- Plural strings use ICU syntax: `{count, plural, =1{...} other{...}}`

#### Rules
- No `String` literals in widget `build()` methods — use `context.l10n.*`
- ARB keys must exist in BOTH `app_en.arb` and `app_es.arb` before use
- Run `flutter gen-l10n` after adding new keys
- Locale preference persisted via `SharedPreferences` key `locale`

## Best Practices

### ✅ DO
- Use widgets for every UI element
- Implement proper state management
- Use const constructors where possible
- Dispose resources in state lifecycle
- Test on multiple device sizes
- Use meaningful widget names
- Implement error handling
- Use responsive design patterns
- Test on both iOS and Android
- Document custom widgets

### ❌ DON'T
- Build entire screens in build() method
- Use setState for complex state logic
- Make network calls in build()
- Ignore platform differences
- Create overly nested widget trees
- Hardcode strings
- Ignore performance warnings
- Skip testing
- Forget to handle edge cases
- Deploy without thorough testing
