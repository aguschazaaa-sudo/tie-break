import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:padel_punilla/core/utils/timeout_wrapper.dart';
import 'package:padel_punilla/domain/exceptions/app_exception.dart';

void main() {
  group('withTimeout', () {
    test(
      'should return result when operation completes within timeout',
      () async {
        // Arrange
        Future<String> fastOperation() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return 'success';
        }

        // Act
        final result = await withTimeout(
          fastOperation(),
          timeout: const Duration(seconds: 1),
        );

        // Assert
        expect(result, 'success');
      },
    );

    test(
      'should throw TimeoutException when operation exceeds timeout',
      () async {
        // Arrange
        Future<String> slowOperation() async {
          await Future<void>.delayed(const Duration(seconds: 5));
          return 'too late';
        }

        // Act & Assert
        expect(
          () => withTimeout(
            slowOperation(),
            timeout: const Duration(milliseconds: 100),
          ),
          throwsA(isA<TimeoutException>()),
        );
      },
    );

    test('should use default timeout of 15 seconds', () async {
      // Arrange
      Future<String> fastOperation() async {
        return 'quick';
      }

      // Act - should not throw with default timeout
      final result = await withTimeout(fastOperation());

      // Assert
      expect(result, 'quick');
    });

    test('should propagate original exception if operation fails', () async {
      // Arrange
      Future<String> failingOperation() async {
        throw const NetworkException(message: 'Network error');
      }

      // Act & Assert
      expect(
        () => withTimeout(
          failingOperation(),
          timeout: const Duration(seconds: 1),
        ),
        throwsA(isA<NetworkException>()),
      );
    });

    test('should include custom message in TimeoutException', () async {
      // Arrange
      Future<String> slowOperation() async {
        await Future<void>.delayed(const Duration(seconds: 5));
        return 'too late';
      }

      // Act & Assert
      try {
        await withTimeout(
          slowOperation(),
          timeout: const Duration(milliseconds: 50),
          operationName: 'Cargando datos',
        );
        fail('Should have thrown TimeoutException');
      } on TimeoutException catch (e) {
        expect(e.message, contains('Cargando datos'));
      }
    });
  });

  group('withTimeoutOr', () {
    test('should return fallback value on timeout', () async {
      // Arrange
      Future<String> slowOperation() async {
        await Future<void>.delayed(const Duration(seconds: 5));
        return 'too late';
      }

      // Act
      final result = await withTimeoutOr(
        slowOperation(),
        timeout: const Duration(milliseconds: 50),
        fallback: 'default',
      );

      // Assert
      expect(result, 'default');
    });

    test('should return result when operation completes in time', () async {
      // Arrange
      Future<String> fastOperation() async {
        return 'success';
      }

      // Act
      final result = await withTimeoutOr(
        fastOperation(),
        timeout: const Duration(seconds: 1),
        fallback: 'default',
      );

      // Assert
      expect(result, 'success');
    });
  });
}
