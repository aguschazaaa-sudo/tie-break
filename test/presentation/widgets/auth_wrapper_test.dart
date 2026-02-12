import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:padel_punilla/domain/repositories/auth_repository.dart';
import 'package:padel_punilla/domain/repositories/club_repository.dart';
import 'package:padel_punilla/domain/repositories/notification_repository.dart';
import 'package:padel_punilla/domain/repositories/reservation_repository.dart';
import 'package:padel_punilla/presentation/providers/notification_provider.dart';
import 'package:padel_punilla/presentation/widgets/auth_wrapper.dart';
import 'package:provider/provider.dart';

// Mocks
class MockAuthRepository extends Mock implements AuthRepository {}

class MockUser extends Mock implements User {}

class MockClubRepository extends Mock implements ClubRepository {}

class MockReservationRepository extends Mock implements ReservationRepository {}

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  group('AuthWrapper', () {
    late MockAuthRepository mockAuthRepository;
    late MockClubRepository mockClubRepository;
    late MockReservationRepository mockReservationRepository;
    late MockNotificationRepository mockNotificationRepository;
    late StreamController<User?> authStreamController;
    late MockUser mockUser;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockClubRepository = MockClubRepository();
      mockReservationRepository = MockReservationRepository();
      mockNotificationRepository = MockNotificationRepository();
      authStreamController = StreamController<User?>.broadcast();
      mockUser = MockUser();

      when(
        () => mockAuthRepository.authStateChanges,
      ).thenAnswer((_) => authStreamController.stream);

      // currentUser necesario cuando HomeScreen se renderiza
      when(() => mockAuthRepository.currentUser).thenReturn(null);

      // getUserData necesario al cargar home
      when(
        () => mockAuthRepository.getUserData(any()),
      ).thenAnswer((_) async => null);

      // ClubRepository mocks
      when(
        () => mockClubRepository.getClubsByIds(any()),
      ).thenAnswer((_) async => []);

      // NotificationRepository mock (stream vacío)
      when(
        () => mockNotificationRepository.getUserNotifications(any()),
      ).thenAnswer((_) => const Stream.empty());
    });

    tearDown(() {
      authStreamController.close();
    });

    Widget createTestWidget() {
      return MultiProvider(
        providers: [
          Provider<AuthRepository>.value(value: mockAuthRepository),
          Provider<ClubRepository>.value(value: mockClubRepository),
          Provider<ReservationRepository>.value(
            value: mockReservationRepository,
          ),
          ChangeNotifierProvider<NotificationProvider>(
            create:
                (_) => NotificationProvider(
                  notificationRepository: mockNotificationRepository,
                  authRepository: mockAuthRepository,
                ),
          ),
        ],
        child: MaterialApp(home: AuthWrapper(onToggleTheme: () {})),
      );
    }

    testWidgets('should show loading indicator while waiting for auth state', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());

      // Assert - should show loading while stream has no data
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should navigate away from loading after auth resolves', (
      tester,
    ) async {
      // Suppress RenderFlex overflow warnings (HomeScreen AppBar en viewport de test)
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.toString().contains('overflowed')) return;
        originalOnError?.call(details);
      };

      // Arrange - currentUser retorna el mock una vez autenticado
      when(() => mockAuthRepository.currentUser).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('test-uid');
      when(() => mockUser.photoURL).thenReturn(null);
      when(() => mockUser.displayName).thenReturn('Test User');

      await tester.pumpWidget(createTestWidget());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Act - emit authenticated user
      authStreamController.add(mockUser);
      await tester.pump();

      // Assert - loading should be gone (HomeScreen is rendered)
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Restaurar handler de errores
      FlutterError.onError = originalOnError;
    });
  });
}
