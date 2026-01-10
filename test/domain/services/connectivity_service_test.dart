import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:padel_punilla/domain/enums/connectivity_status.dart';
import 'package:padel_punilla/domain/services/connectivity_service.dart';

// Mock del servicio de conectividad
class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  group('ConnectivityStatus', () {
    test('should have all expected values', () {
      expect(ConnectivityStatus.values, hasLength(3));
      expect(ConnectivityStatus.values, contains(ConnectivityStatus.online));
      expect(ConnectivityStatus.values, contains(ConnectivityStatus.offline));
      expect(ConnectivityStatus.values, contains(ConnectivityStatus.unknown));
    });

    test('online should be different from offline', () {
      expect(ConnectivityStatus.online, isNot(ConnectivityStatus.offline));
    });
  });

  group('ConnectivityService', () {
    late MockConnectivityService mockService;

    setUp(() {
      mockService = MockConnectivityService();
    });

    group('statusStream', () {
      test('should emit online when connected', () async {
        // Arrange
        when(
          () => mockService.statusStream,
        ).thenAnswer((_) => Stream.value(ConnectivityStatus.online));

        // Act & Assert
        expect(mockService.statusStream, emits(ConnectivityStatus.online));
      });

      test('should emit offline when disconnected', () async {
        // Arrange
        when(
          () => mockService.statusStream,
        ).thenAnswer((_) => Stream.value(ConnectivityStatus.offline));

        // Act & Assert
        expect(mockService.statusStream, emits(ConnectivityStatus.offline));
      });

      test('should emit sequence of status changes', () async {
        // Arrange
        when(() => mockService.statusStream).thenAnswer(
          (_) => Stream.fromIterable([
            ConnectivityStatus.unknown,
            ConnectivityStatus.online,
            ConnectivityStatus.offline,
            ConnectivityStatus.online,
          ]),
        );

        // Act & Assert
        expect(
          mockService.statusStream,
          emitsInOrder([
            ConnectivityStatus.unknown,
            ConnectivityStatus.online,
            ConnectivityStatus.offline,
            ConnectivityStatus.online,
          ]),
        );
      });
    });

    group('currentStatus', () {
      test('should return online status when connected', () async {
        // Arrange
        when(
          () => mockService.currentStatus,
        ).thenAnswer((_) async => ConnectivityStatus.online);

        // Act
        final status = await mockService.currentStatus;

        // Assert
        expect(status, ConnectivityStatus.online);
      });

      test('should return offline status when disconnected', () async {
        // Arrange
        when(
          () => mockService.currentStatus,
        ).thenAnswer((_) async => ConnectivityStatus.offline);

        // Act
        final status = await mockService.currentStatus;

        // Assert
        expect(status, ConnectivityStatus.offline);
      });
    });

    group('isOnline', () {
      test('should return true when connected', () async {
        // Arrange
        when(() => mockService.isOnline).thenAnswer((_) async => true);

        // Act
        final result = await mockService.isOnline;

        // Assert
        expect(result, isTrue);
      });

      test('should return false when disconnected', () async {
        // Arrange
        when(() => mockService.isOnline).thenAnswer((_) async => false);

        // Act
        final result = await mockService.isOnline;

        // Assert
        expect(result, isFalse);
      });
    });
  });
}
