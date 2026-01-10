import 'package:flutter_test/flutter_test.dart';
import 'package:padel_punilla/domain/exceptions/app_exception.dart';

void main() {
  group('AppException', () {
    group('NetworkException', () {
      test('should create with message', () {
        const exception = NetworkException(message: 'Sin conexión a internet');

        expect(exception.message, 'Sin conexión a internet');
        expect(exception.code, isNull);
      });

      test('should create with message and code', () {
        const exception = NetworkException(
          message: 'Error de conexión',
          code: 'network-request-failed',
        );

        expect(exception.message, 'Error de conexión');
        expect(exception.code, 'network-request-failed');
      });

      test('toString should contain exception type and message', () {
        const exception = NetworkException(message: 'Test error');

        expect(exception.toString(), contains('NetworkException'));
        expect(exception.toString(), contains('Test error'));
      });
    });

    group('ServerException', () {
      test('should create with message', () {
        const exception = ServerException(message: 'Error del servidor');

        expect(exception.message, 'Error del servidor');
        expect(exception.code, isNull);
      });

      test('should create with message and code', () {
        const exception = ServerException(
          message: 'Internal server error',
          code: '500',
        );

        expect(exception.message, 'Internal server error');
        expect(exception.code, '500');
      });
    });

    group('CacheException', () {
      test('should create with message', () {
        const exception = CacheException(message: 'Error de caché');

        expect(exception.message, 'Error de caché');
        expect(exception.code, isNull);
      });
    });

    group('AuthException', () {
      test('should create with message and code', () {
        const exception = AuthException(
          message: 'Usuario no encontrado',
          code: 'user-not-found',
        );

        expect(exception.message, 'Usuario no encontrado');
        expect(exception.code, 'user-not-found');
      });
    });

    group('ValidationException', () {
      test('should create with message', () {
        const exception = ValidationException(message: 'El email no es válido');

        expect(exception.message, 'El email no es válido');
      });
    });

    group('Exception comparison', () {
      test('different exception types should be distinguishable', () {
        const networkException = NetworkException(message: 'Error');
        const serverException = ServerException(message: 'Error');
        const cacheException = CacheException(message: 'Error');

        expect(networkException, isA<NetworkException>());
        expect(networkException, isNot(isA<ServerException>()));

        expect(serverException, isA<ServerException>());
        expect(serverException, isNot(isA<CacheException>()));

        expect(cacheException, isA<CacheException>());
        expect(cacheException, isNot(isA<NetworkException>()));
      });

      test('all exceptions should implement AppException', () {
        const networkException = NetworkException(message: 'Error');
        const serverException = ServerException(message: 'Error');
        const cacheException = CacheException(message: 'Error');
        const authException = AuthException(message: 'Error');
        const validationException = ValidationException(message: 'Error');

        expect(networkException, isA<AppException>());
        expect(serverException, isA<AppException>());
        expect(cacheException, isA<AppException>());
        expect(authException, isA<AppException>());
        expect(validationException, isA<AppException>());
      });
    });
  });
}
