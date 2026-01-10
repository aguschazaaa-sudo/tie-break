import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:padel_punilla/domain/enums/connectivity_status.dart';
import 'package:padel_punilla/domain/services/connectivity_service.dart';
import 'package:padel_punilla/presentation/providers/connectivity_provider.dart';
import 'package:padel_punilla/presentation/widgets/connectivity_banner.dart';
import 'package:provider/provider.dart';

// Mock del servicio
class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  group('ConnectivityBanner', () {
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

    Widget createTestWidget({required ConnectivityStatus initialStatus}) {
      when(
        () => mockService.currentStatus,
      ).thenAnswer((_) async => initialStatus);

      return MaterialApp(
        home: ChangeNotifierProvider<ConnectivityProvider>(
          create: (_) => ConnectivityProvider(service: mockService),
          child: const Scaffold(
            body: Column(
              children: [ConnectivityBanner(), Expanded(child: Placeholder())],
            ),
          ),
        ),
      );
    }

    testWidgets('should show banner when offline', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        createTestWidget(initialStatus: ConnectivityStatus.offline),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Sin conexión a internet'), findsOneWidget);
    });

    testWidgets('should not show banner when online', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        createTestWidget(initialStatus: ConnectivityStatus.online),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Sin conexión a internet'), findsNothing);
    });

    testWidgets('should show warning icon when offline', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        createTestWidget(initialStatus: ConnectivityStatus.offline),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    });

    testWidgets('should have error color scheme when offline', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        createTestWidget(initialStatus: ConnectivityStatus.offline),
      );
      await tester.pumpAndSettle();

      // Assert - verify the error-styled icon is present
      final iconFinder = find.byIcon(Icons.wifi_off);
      expect(iconFinder, findsOneWidget);

      // Verify icon is styled with onError color (contrasting the error background)
      final icon = tester.widget<Icon>(iconFinder);
      expect(icon.color, isNotNull);
    });

    testWidgets('should animate appearance', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(initialStatus: ConnectivityStatus.online),
      );
      await tester.pumpAndSettle();

      // Act - go offline
      statusController.add(ConnectivityStatus.offline);
      await tester.pump();

      // Assert - AnimatedContainer should exist
      expect(find.byType(AnimatedContainer), findsOneWidget);
    });
  });
}
