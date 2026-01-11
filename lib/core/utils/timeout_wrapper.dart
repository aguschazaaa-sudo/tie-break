import 'dart:async';

/// Default timeout for operations.
const Duration defaultTimeout = Duration(seconds: 15);

/// Executes an async operation with a timeout.
///
/// Throws [TimeoutException] if the operation exceeds the timeout.
/// The original exception is propagated if the operation fails.
///
/// Example:
/// ```dart
/// final result = await withTimeout(
///   repository.fetchData(),
///   timeout: Duration(seconds: 10),
///   operationName: 'Cargando datos',
/// );
/// ```
Future<T> withTimeout<T>(
  Future<T> operation, {
  Duration timeout = defaultTimeout,
  String? operationName,
}) async {
  try {
    return await operation.timeout(
      timeout,
      onTimeout: () {
        final message =
            operationName != null
                ? '$operationName tardó demasiado. Intentá de nuevo.'
                : 'La operación tardó demasiado. Intentá de nuevo.';
        throw TimeoutException(message, timeout);
      },
    );
  } on TimeoutException {
    rethrow;
  }
}

/// Executes an async operation with a timeout, returning a fallback on timeout.
///
/// Unlike [withTimeout], this doesn't throw on timeout - it returns [fallback].
/// Useful for non-critical operations where a default is acceptable.
///
/// Example:
/// ```dart
/// final clubs = await withTimeoutOr(
///   repository.fetchClubs(),
///   timeout: Duration(seconds: 5),
///   fallback: <Club>[],
/// );
/// ```
Future<T> withTimeoutOr<T>(
  Future<T> operation, {
  required T fallback,
  Duration timeout = defaultTimeout,
}) async {
  try {
    return await operation.timeout(timeout);
  } on TimeoutException {
    return fallback;
  }
}
