---
title: Feature Architecture — Layers and Folder Structure
impact: HIGH
tags: architecture, structure, repository, models
---

## Feature Architecture — Layers and Folder Structure

### Dependency Direction (enforced)

```
Widget / Screen
  └─ ref.watch(provider)
       └─ Notifier / AsyncNotifier
            └─ Repository (abstract interface)
                 └─ RepositoryImpl (concrete)
                      └─ ApiClient / LocalKvStore
```

No layer may skip levels. Widgets never call repositories directly. Notifiers never call `ApiClient` directly.

### Folder Structure

```
lib/
  core/
    models/          # Shared immutable data models (fromJson/toJson)
    services/        # Repositories + platform services (LocalKvStore, SecureStorage)
    network/         # ApiClient, interceptors, ApiException hierarchy
    theme/           # Light/dark themes, color tokens, text styles
    widgets/         # Shared reusable widgets (AppButton, CurrencyText, ErrorBanner)
    utils/           # Formatters, validators, extensions
  features/
    auth/
      providers/     # authNotifierProvider, authStateProvider
      repositories/  # AuthRepository (abstract) + AuthRepositoryImpl
      screens/       # LoginScreen, RegisterScreen
      widgets/       # LoginForm, PasswordField
    transactions/
      providers/     # transactionListProvider, createTransactionProvider
      repositories/  # TransactionRepository + TransactionRepositoryImpl
      models/        # Feature-specific DTOs (if they differ from core models)
      screens/       # TransactionsScreen, AddTransactionScreen
      widgets/       # TransactionTile, CategoryPicker
    dashboard/
      providers/     # dashboardSummaryProvider, budgetBreakdownProvider
      screens/
      widgets/       # SummaryCard, BudgetPieChart, StreakCard
  routing/
    app_router.dart
  main.dart
  app.dart           # MaterialApp.router + ProviderScope
```

### Repository Pattern

```dart
// Abstract interface — providers and notifiers depend on this
abstract class TransactionRepository {
  Future<List<Transaction>> fetchAll({String? accountId, DateRange? range});
  Future<Transaction> create(CreateTransactionDto dto);
  Future<void> delete(String id);
}

// Concrete implementation
class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(this._client);
  final ApiClient _client;

  @override
  Future<List<Transaction>> fetchAll({String? accountId, DateRange? range}) async {
    final response = await _client.get('/transactions', queryParameters: {
      if (accountId != null) 'accountId': accountId,
      if (range != null) 'from': range.from.toIso8601String(),
      if (range != null) 'to': range.to.toIso8601String(),
    });
    return (response.data as List)
        .map((j) => Transaction.fromJson(j as Map<String, dynamic>))
        .toList();
  }
}

// Riverpod provider — overridable in tests
@riverpod
TransactionRepository transactionRepository(Ref ref) {
  return TransactionRepositoryImpl(ref.watch(apiClientProvider));
}
```

### Model Layer — Immutability Rules

```dart
// All models: immutable, copyWith(), fromJson(), toJson()
@immutable
class Transaction {
  const Transaction({
    required this.id,
    required this.amount,
    required this.category,
    required this.occurredAt,
    this.notes,
  });

  final String id;
  final double amount;
  final TransactionCategory category;
  final DateTime occurredAt;
  final String? notes;

  Transaction copyWith({
    String? id,
    double? amount,
    TransactionCategory? category,
    DateTime? occurredAt,
    String? notes,
  }) => Transaction(
    id: id ?? this.id,
    amount: amount ?? this.amount,
    category: category ?? this.category,
    occurredAt: occurredAt ?? this.occurredAt,
    notes: notes ?? this.notes,
  );

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'] as String,
    amount: (json['amount'] as num).toDouble(),
    category: TransactionCategory.values.firstWhere(
      (e) => e.name == json['category'],
      orElse: () => TransactionCategory.outros,
    ),
    occurredAt: DateTime.parse(json['occurredAt'] as String),
    notes: json['notes'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'category': category.name,
    'occurredAt': occurredAt.toIso8601String(),
    if (notes != null) 'notes': notes,
  };
}
```

- Date fields: always parse to `DateTime`, format only at the display layer.
- Monetary amounts: store as `double`. Never store as a formatted string.
- Enum deserialization: always provide `orElse` fallback in `firstWhere` to handle unknown server values gracefully.
