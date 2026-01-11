import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_punilla/data/repositories/reservation_repository_impl.dart';
import 'package:padel_punilla/domain/enums/reservation_enums.dart';
import 'package:padel_punilla/domain/models/reservation_model.dart';

void main() {
  group('ReservationRepositoryImpl (FakeFirestore)', () {
    late FakeFirebaseFirestore fakeFirestore;
    late ReservationRepositoryImpl repository;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = ReservationRepositoryImpl(firestore: fakeFirestore);
    });

    test('createReservation adds a document to Firestore', () async {
      final reservation = ReservationModel(
        id: 'res1',
        courtId: 'court1',
        clubId: 'club1',
        userId: 'user1',
        reservedDate: DateTime(2025),
        startTime: DateTime(2025, 1, 1, 10),
        durationMinutes: 90,
        createdAt: DateTime.now(),
        price: 1500,
      );

      await repository.createReservation(reservation);

      final snapshot =
          await fakeFirestore.collection('reservations').doc('res1').get();
      expect(snapshot.exists, true);
      expect(snapshot.data()?['clubId'], 'club1');
      expect(snapshot.data()?['price'], 1500);
    });

    test('updateReservation modifies existing document', () async {
      // 1. Pre-populate
      await fakeFirestore.collection('reservations').doc('res1').set({
        'id': 'res1',
        'courtId': 'court1',
        'clubId': 'club1',
        'status': 'pending',
        'price': 1000,
        'createdAt': DateTime.now().toIso8601String(),
        'reservedDate': DateTime.now().toIso8601String(),
        'startTime': DateTime.now().toIso8601String(),
        // Add other required fields if needed by fromMap, but updates rely on toMap
      });

      final reservation = ReservationModel(
        id: 'res1',
        courtId: 'court1',
        clubId: 'club1',
        userId: 'user1',
        reservedDate: DateTime(2025),
        startTime: DateTime(2025, 1, 1, 10),
        durationMinutes: 90,
        createdAt: DateTime.now(),
        price: 2000, // Changed
        status: ReservationStatus.approved, // Changed
      );

      await repository.updateReservation(reservation);

      final snapshot =
          await fakeFirestore.collection('reservations').doc('res1').get();
      expect(snapshot.data()?['price'], 2000);
      expect(snapshot.data()?['status'], 'approved');
      expect(snapshot.data()?['clubId'], 'club1'); // unchanged
    });

    test('getReservationsByClubAndDate filters correctly', () async {
      final targetDate = DateTime(2025, 5, 20);
      // Start of target date
      final d1 = DateTime(2025, 5, 20, 10);
      // End of target date
      final d2 = DateTime(2025, 5, 20, 22);
      // Different date
      final d3 = DateTime(2025, 5, 21, 10);

      // 1. Populate
      await fakeFirestore.collection('reservations').add({
        'id': 'r1',
        'clubId': 'c1',
        'startTime': d1.toIso8601String(),
        'status': 'pending',
        'courtId': 'ct1',
        'userId': 'u1',
        'reservedDate': d1.toIso8601String(),
        'durationMinutes': 60,
        'price': 100,
        'createdAt': DateTime.now().toIso8601String(),
        'type': 'match2vs2',
      });
      await fakeFirestore.collection('reservations').add({
        'id': 'r2',
        'clubId': 'c1',
        'startTime': d2.toIso8601String(),
        'status': 'approved',
        'courtId': 'ct1',
        'userId': 'u1',
        'reservedDate': d2.toIso8601String(),
        'durationMinutes': 60,
        'price': 100,
        'createdAt': DateTime.now().toIso8601String(),
        'type': 'match2vs2',
      });
      await fakeFirestore.collection('reservations').add({
        'id': 'r3',
        'clubId': 'c2',
        'startTime': d1.toIso8601String(),
        'status': 'pending', // Different club
        'courtId': 'ct2',
        'userId': 'u1',
        'reservedDate': d1.toIso8601String(),
        'durationMinutes': 60,
        'price': 100,
        'createdAt': DateTime.now().toIso8601String(),
        'type': 'match2vs2',
      });
      await fakeFirestore.collection('reservations').add({
        'id': 'r4',
        'clubId': 'c1',
        'startTime': d3.toIso8601String(),
        'status': 'pending', // Different date
        'courtId': 'ct1',
        'userId': 'u1',
        'reservedDate': d3.toIso8601String(),
        'durationMinutes': 60,
        'price': 100,
        'createdAt': DateTime.now().toIso8601String(),
        'type': 'match2vs2',
      });

      final results = await repository.getReservationsByClubAndDate(
        'c1',
        targetDate,
      );

      expect(results.length, 2);
      // Should contain r1 and r2
      final ids = results.map((r) => r.id).toList();
      expect(ids, containsAll(['r1', 'r2']));
    });
  });
}
