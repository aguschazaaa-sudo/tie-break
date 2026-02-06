import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:padel_punilla/domain/models/notification_model.dart';
import 'package:padel_punilla/domain/repositories/auth_repository.dart';
import 'package:padel_punilla/domain/repositories/notification_repository.dart';
import 'package:padel_punilla/presentation/providers/notification_provider.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUser extends Mock implements User {}

void main() {
  late MockNotificationRepository mockNotificationRepository;
  late MockAuthRepository mockAuthRepository;
  late NotificationProvider provider;

  setUp(() {
    mockNotificationRepository = MockNotificationRepository();
    mockAuthRepository = MockAuthRepository();
  });

  tearDown(() {
    provider.dispose();
  });

  test('should load notifications when initialized with a user', () async {
    // Arrange
    const userId = 'user1';
    final user = MockUser();
    when(() => user.uid).thenReturn(userId);
    when(() => mockAuthRepository.currentUser).thenReturn(user);

    final notifications = [
      NotificationModel(
        id: '1',
        title: 'Test',
        body: 'Body',
        receiverId: userId,
        createdAt: DateTime.now(),
        isRead: false,
      ),
    ];

    when(
      () => mockNotificationRepository.getUserNotifications(userId),
    ).thenAnswer((_) => Stream.value(notifications));

    // Act
    provider = NotificationProvider(
      notificationRepository: mockNotificationRepository,
      authRepository: mockAuthRepository,
    );

    // Assert
    expect(provider.isLoading, true);
    await Future.delayed(Duration.zero); // Wait for stream to emit
    expect(provider.notifications, notifications);
    expect(provider.isLoading, false);
    expect(provider.unreadCount, 1);
  });

  test('should mark notification as read', () async {
    // Arrange
    const userId = 'user1';
    final user = MockUser();
    when(() => user.uid).thenReturn(userId);
    when(() => mockAuthRepository.currentUser).thenReturn(user);

    when(
      () => mockNotificationRepository.getUserNotifications(userId),
    ).thenAnswer((_) => Stream.value([]));
    when(
      () => mockNotificationRepository.markAsRead('1'),
    ).thenAnswer((_) async {});

    provider = NotificationProvider(
      notificationRepository: mockNotificationRepository,
      authRepository: mockAuthRepository,
    );

    // Act
    await provider.markAsRead('1');

    // Assert
    verify(() => mockNotificationRepository.markAsRead('1')).called(1);
  });
}
