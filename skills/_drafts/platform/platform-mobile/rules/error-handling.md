---
title: Error Handling — Typed Exceptions and UI Surfacing
impact: HIGH
tags: error, api, exceptions, async
---

## Error Handling — Typed Exceptions and UI Surfacing

### Typed API Exception Hierarchy

Never catch raw `Exception` or show `e.toString()` to users. Define a sealed exception hierarchy so every error case is handled explicitly.

```dart
// core/network/api_exception.dart
sealed class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  String get userMessage => switch (this) {
    NetworkException()     => 'Check your internet connection and try again.',
    UnauthorizedException()=> 'Your session expired. Please log in again.',
    NotFoundException()    => 'This item no longer exists.',
    ServerException()      => 'Server error. Try again in a moment.',
    ValidationException(errors: final e) => e.values.expand((v) => v).join('\n'),
    _                      => 'An unexpected error occurred.',
  };
}

class NetworkException extends ApiException {
  const NetworkException() : super('No internet connection.');
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException() : super('Session expired.');
}

class NotFoundException extends ApiException {
  const NotFoundException(String resource) : super('$resource not found.');
}

class ServerException extends ApiException {
  const ServerException(int code) : super('Server error ($code).');
}

class ValidationException extends ApiException {
  const ValidationException(this.errors) : super('Validation failed.');
  final Map<String, List<String>> errors;
}
```

### Three Layers of Error Surfacing

**Layer 1 — Inline in AsyncValue.when** (data screens):
```dart
ref.watch(transactionListProvider).when(
  loading: () => const CircularProgressIndicator(),
  error: (e, _) => ErrorBanner(
    message: e is ApiException ? e.userMessage : 'Something went wrong',
    onRetry: () => ref.invalidate(transactionListProvider),
  ),
  data: (items) => TransactionListView(items: items),
);
```

**Layer 2 — ref.listen for transient errors** (snackbars, one-time toasts):
```dart
// In build() — listen only, don't rebuild on every change
ref.listen(createTransactionProvider, (_, next) {
  next.whenOrNull(
    error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e is ApiException ? e.userMessage : 'Failed to save')),
    ),
  );
});
```

**Layer 3 — Global uncaught handler** (main.dart):
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    // Log to Crashlytics / Sentry
    debugPrint('Flutter error: ${details.exceptionAsString()}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Platform error: $error');
    return true; // handled
  };

  runApp(const ProviderScope(child: ZendaApp()));
}
```

### DioException → ApiException Mapping

```dart
ApiException mapDioError(DioException e) {
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.connectionError) {
    return const NetworkException();
  }
  return switch (e.response?.statusCode) {
    401 => const UnauthorizedException(),
    404 => NotFoundException(e.requestOptions.path),
    422 => ValidationException(_parseErrors(e.response!.data)),
    >= 500 => ServerException(e.response!.statusCode!),
    _ => ApiException('Unexpected error: ${e.message}'),
  };
}
```

Never retry on 401, 403, 422, or any 4xx — retrying them will not succeed and wastes bandwidth.

### Form Validation Errors

Inline validation errors (form fields) are distinct from API errors. Show inline under each field:

```dart
TextFormField(
  validator: (v) {
    if (v == null || v.isEmpty) return 'Amount is required';
    if (double.tryParse(v) == null) return 'Enter a valid number';
    if (double.parse(v) <= 0) return 'Amount must be greater than zero';
    return null;
  },
)
```

Validate the form before calling any provider method:

```dart
if (!_formKey.currentState!.validate()) return;
await ref.read(createTransactionProvider.notifier).save(dto);
```
