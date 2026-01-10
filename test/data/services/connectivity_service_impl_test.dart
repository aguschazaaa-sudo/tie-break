import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:padel_punilla/data/services/connectivity_service_impl.dart';
import 'package:padel_punilla/domain/enums/connectivity_status.dart';

// Mock de Connectivity
class MockConnectivity extends Mock implements Connectivity {}

void main() {
  group('ConnectivityServiceImpl', () {
    late MockConnectivity mockConnectivity;
    late ConnectivityServiceImpl service;

    setUp(() {
      mockConnectivity = MockConnectivity();
      service = ConnectivityServiceImpl(connectivity: mockConnectivity);
    });

    tearDown(() {
      service.dispose();
    });

    group('currentStatus', () {
      test('should return online when connected via WiFi', () async {
        // Arrange
        when(
          () => mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.wifi]);

        // Act
        final status = await service.currentStatus;

        // Assert
        expect(status, ConnectivityStatus.online);
      });

      test('should return online when connected via mobile', () async {
        // Arrange
        when(
          () => mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.mobile]);

        // Act
        final status = await service.currentStatus;

        // Assert
        expect(status, ConnectivityStatus.online);
      });

      test('should return online when connected via ethernet', () async {
        // Arrange
        when(
          () => mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.ethernet]);

        // Act
        final status = await service.currentStatus;

        // Assert
        expect(status, ConnectivityStatus.online);
      });

      test('should return offline when no connection', () async {
        // Arrange
        when(
          () => mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.none]);

        // Act
        final status = await service.currentStatus;

        // Assert
        expect(status, ConnectivityStatus.offline);
      });
    });

    group('isOnline', () {
      test('should return true when connected', () async {
        // Arrange
        when(
          () => mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.wifi]);

        // Act
        final result = await service.isOnline;

        // Assert
        expect(result, isTrue);
      });

      test('should return false when not connected', () async {
        // Arrange
        when(
          () => mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.none]);

        // Act
        final result = await service.isOnline;

        // Assert
        expect(result, isFalse);
      });
    });

    group('statusStream', () {
      test('should emit online when connectivity changes to wifi', () async {
        // Arrange
        when(
          () => mockConnectivity.onConnectivityChanged,
        ).thenAnswer((_) => Stream.value([ConnectivityResult.wifi]));

        // Act & Assert
        expect(service.statusStream, emits(ConnectivityStatus.online));
      });

      test('should emit offline when connectivity is lost', () async {
        // Arrange
        when(
          () => mockConnectivity.onConnectivityChanged,
        ).thenAnswer((_) => Stream.value([ConnectivityResult.none]));

        // Act & Assert
        expect(service.statusStream, emits(ConnectivityStatus.offline));
      });

      test('should emit sequence of status changes', () async {
        // Arrange
        when(() => mockConnectivity.onConnectivityChanged).thenAnswer(
          (_) => Stream.fromIterable([
            [ConnectivityResult.wifi],
            [ConnectivityResult.none],
            [ConnectivityResult.mobile],
          ]),
        );

        // Act & Assert
        expect(
          service.statusStream,
          emitsInOrder([
            ConnectivityStatus.online,
            ConnectivityStatus.offline,
            ConnectivityStatus.online,
          ]),
        );
      });
    });
  });
}
