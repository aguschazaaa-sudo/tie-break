/// Clase base sellada para todas las excepciones de la aplicación.
///
/// Usar excepciones tipadas permite mejor manejo de errores y
/// mensajes más específicos para el usuario.
sealed class AppException implements Exception {
  const AppException({required this.message, this.code});

  /// Mensaje descriptivo del error.
  final String message;

  /// Código de error opcional (ej: 'network-request-failed').
  final String? code;

  @override
  String toString() =>
      '$runtimeType: $message${code != null ? ' ($code)' : ''}';
}

/// Excepción lanzada cuando hay problemas de conectividad de red.
class NetworkException extends AppException {
  const NetworkException({required super.message, super.code});
}

/// Excepción lanzada cuando el servidor responde con un error.
class ServerException extends AppException {
  const ServerException({required super.message, super.code});
}

/// Excepción lanzada cuando hay problemas con el caché local.
class CacheException extends AppException {
  const CacheException({required super.message, super.code});
}

/// Excepción lanzada para errores de autenticación.
class AuthException extends AppException {
  const AuthException({required super.message, super.code});
}

/// Excepción lanzada para errores de validación de datos.
class ValidationException extends AppException {
  const ValidationException({required super.message, super.code});
}
