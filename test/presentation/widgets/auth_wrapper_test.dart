import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:padel_punilla/domain/repositories/auth_repository.dart';
import 'package:padel_punilla/presentation/widgets/auth_wrapper.dart';
import 'package:provider/provider.dart';

// Mocks
class MockAuthRepository extends Mock implements AuthRepository {}

class MockUser extends Mock implements User {}

void main() {
  group('AuthWrapper', () {
    late MockAuthRepository mockAuthRepository;
    late StreamController<User?> authStreamController;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      authStreamController = StreamController<User?>.broadcast();
      when(
        () => mockAuthRepository.authStateChanges,
      ).thenAnswer((_) => authStreamController.stream);
    });

    tearDown(() {
      authStreamController.close();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: Provider<AuthRepository>.value(
          value: mockAuthRepository,
          child: AuthWrapper(onToggleTheme: () {}),
        ),
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
      // Arrange
      await tester.pumpWidget(createTestWidget());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Act - emit authenticated user
      authStreamController.add(MockUser());
      await tester.pump();

      // Assert - loading should be gone
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
