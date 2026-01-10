import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:padel_punilla/domain/enums/connectivity_status.dart';
import 'package:padel_punilla/domain/services/connectivity_service.dart';
import 'package:padel_punilla/presentation/providers/connectivity_provider.dart';

// Mock del servicio de conectividad
class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  group('ConnectivityProvider', () {
    late MockConnectivityService mockService;
    late StreamController<ConnectivityStatus> statusController;

    setUp(() {
      mockService = MockConnectivityService();
      statusController = StreamController<ConnectivityStatus>.broadcast();
      when(
        () => mockService.statusStream,
      ).thenAnswer((_) => statusController.stream);
    });

    tearDown(() {
      statusController.close();
    });

    group('initialization', () {
      test('should start with unknown status', () async {
        // Arrange
        when(
          () => mockService.currentStatus,
        ).thenAnswer((_) async => ConnectivityStatus.unknown);

        // Act
        final provider = ConnectivityProvider(service: mockService);

        // Assert - before async init completes, status should be unknown
        expect(provider.status, ConnectivityStatus.unknown);

        // Wait for async init to complete before dispose
        await Future<void>.delayed(const Duration(milliseconds: 50));

        provider.dispose();
      });

      test('should check current status on init', () async {
        // Arrange
        when(
          () => mockService.currentStatus,
        ).thenAnswer((_) async => ConnectivityStatus.online);

        // Act
        final provider = ConnectivityProvider(service: mockService);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Assert
        verify(() => mockService.currentStatus).called(1);

        provider.dispose();
      });
    });

    group('status updates', () {
      test('should update status when stream emits online', () async {
        // Arrange
        when(
          () => mockService.currentStatus,
        ).thenAnswer((_) async => ConnectivityStatus.offline);

        final provider = ConnectivityProvider(service: mockService);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Act
        statusController.add(ConnectivityStatus.online);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(provider.status, ConnectivityStatus.online);

        provider.dispose();
      });

      test('should update status when stream emits offline', () async {
        // Arrange
        when(
          () => mockService.currentStatus,
        ).thenAnswer((_) async => ConnectivityStatus.online);

        final provider = ConnectivityProvider(service: mockService);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Act
        statusController.add(ConnectivityStatus.offline);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(provider.status, ConnectivityStatus.offline);

        provider.dispose();
      });

      test('should notify listeners on status change', () async {
        // Arrange
        when(
          () => mockService.currentStatus,
        ).thenAnswer((_) async => ConnectivityStatus.online);

        final provider = ConnectivityProvider(service: mockService);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        var notified = false;
        provider.addListener(() => notified = true);

        // Act
        statusController.add(ConnectivityStatus.offline);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(notified, isTrue);

        provider.dispose();
      });
    });

    group('isOffline getter', () {
      test('should return true when status is offline', () async {
        // Arrange
        when(
          () => mockService.currentStatus,
        ).thenAnswer((_) async => ConnectivityStatus.offline);

        final provider = ConnectivityProvider(service: mockService);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(provider.isOffline, isTrue);

        provider.dispose();
      });

      test('should return false when status is online', () async {
        // Arrange
        when(
          () => mockService.currentStatus,
        ).thenAnswer((_) async => ConnectivityStatus.online);

        final provider = ConnectivityProvider(service: mockService);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(provider.isOffline, isFalse);

        provider.dispose();
      });

      test('should return false when status is unknown', () async {
        // Arrange
        when(
          () => mockService.currentStatus,
        ).thenAnswer((_) async => ConnectivityStatus.unknown);

        final provider = ConnectivityProvider(service: mockService);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(provider.isOffline, isFalse);

        provider.dispose();
      });
    });

    group('isOnline getter', () {
      test('should return true when status is online', () async {
        // Arrange
        when(
          () => mockService.currentStatus,
        ).thenAnswer((_) async => ConnectivityStatus.online);

        final provider = ConnectivityProvider(service: mockService);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(provider.isOnline, isTrue);

        provider.dispose();
      });

      test('should return false when status is offline', () async {
        // Arrange
        when(
          () => mockService.currentStatus,
        ).thenAnswer((_) async => ConnectivityStatus.offline);

        final provider = ConnectivityProvider(service: mockService);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(provider.isOnline, isFalse);

        provider.dispose();
      });
    });
  });
}
