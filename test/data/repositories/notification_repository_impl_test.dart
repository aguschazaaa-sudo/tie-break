import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_punilla/data/repositories/notification_repository_impl.dart';
import 'package:padel_punilla/domain/models/notification_model.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late NotificationRepositoryImpl repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = NotificationRepositoryImpl(firestore: fakeFirestore);
  });

  test(
    'getUserNotifications should stream notifications for specific user',
    () async {
      // Arrange
      const userId = 'user1';
      final notification = NotificationModel(
        id: '1',
        title: 'Test',
        body: 'Body',
        receiverId: userId,
        createdAt: DateTime.now(),
        isRead: false,
      );

      // Add notification to fake firestore
      await fakeFirestore
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toMap());

      // Act
      final stream = repository.getUserNotifications(userId);

      // Assert
      expect(stream, emits([isA<NotificationModel>()]));
      final list = await stream.first;
      expect(list.length, 1);
      expect(list.first.id, notification.id);
    },
  );

  test('markAsRead should update isRead to true', () async {
    // Arrange
    const userId = 'user1';
    final notification = NotificationModel(
      id: '1',
      title: 'Test',
      body: 'Body',
      receiverId: userId,
      createdAt: DateTime.now(),
      isRead: false,
    );

    await fakeFirestore
        .collection('notifications')
        .doc(notification.id)
        .set(notification.toMap());

    // Act
    await repository.markAsRead(notification.id);

    // Assert
    final doc =
        await fakeFirestore
            .collection('notifications')
            .doc(notification.id)
            .get();
    expect(doc.data()?['isRead'], true);
  });

  test(
    'markAllAsRead should update all user notifications to isRead: true',
    () async {
      // Arrange
      const userId = 'user1';
      final n1 = NotificationModel(
        id: '1',
        title: 'Test 1',
        body: 'Body',
        receiverId: userId,
        createdAt: DateTime.now(),
        isRead: false,
      );
      final n2 = NotificationModel(
        id: '2',
        title: 'Test 2',
        body: 'Body',
        receiverId: userId,
        createdAt: DateTime.now(),
        isRead: false,
      );
      // Notification for another user (should not be touched)
      final n3 = NotificationModel(
        id: '3',
        title: 'Test 3',
        body: 'Body',
        receiverId: 'otherUser',
        createdAt: DateTime.now(),
        isRead: false,
      );

      await fakeFirestore
          .collection('notifications')
          .doc(n1.id)
          .set(n1.toMap());
      await fakeFirestore
          .collection('notifications')
          .doc(n2.id)
          .set(n2.toMap());
      await fakeFirestore
          .collection('notifications')
          .doc(n3.id)
          .set(n3.toMap());

      // Act
      await repository.markAllAsRead(userId);

      // Assert
      final d1 =
          await fakeFirestore.collection('notifications').doc(n1.id).get();
      final d2 =
          await fakeFirestore.collection('notifications').doc(n2.id).get();
      final d3 =
          await fakeFirestore.collection('notifications').doc(n3.id).get();

      expect(d1.data()?['isRead'], true);
      expect(d2.data()?['isRead'], true);
      expect(d3.data()?['isRead'], false);
    },
  );
}
