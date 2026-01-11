import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_punilla/data/repositories/club_repository_impl.dart';
import 'package:padel_punilla/domain/enums/locality.dart';
import 'package:padel_punilla/domain/models/club_model.dart';

void main() {
  group('ClubRepositoryImpl (FakeFirestore)', () {
    late FakeFirebaseFirestore fakeFirestore;
    late ClubRepositoryImpl repository;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = ClubRepositoryImpl(firestore: fakeFirestore);
    });

    final testClub = ClubModel(
      id: 'club1',
      name: 'Padel Club',
      description: 'A great place',
      adminId: 'admin1',
      address: 'Fake St 123',
      locality: Locality.villaCarlosPaz,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 365)),
      availableSchedules: ['10:00', '11:00'],
    );

    test('createClub adds a document to Firestore', () async {
      await repository.createClub(testClub);

      final snapshot =
          await fakeFirestore.collection('clubs').doc('club1').get();
      expect(snapshot.exists, true);
      expect(snapshot.data()?['name'], 'Padel Club');
      expect(snapshot.data()?['locality'], 'villaCarlosPaz');
    });

    test('getClub returns null if not exists', () async {
      final club = await repository.getClub('non_existent');
      expect(club, isNull);
    });

    test('getClub returns proper ClubModel', () async {
      await fakeFirestore
          .collection('clubs')
          .doc('club1')
          .set(testClub.toMap());

      final club = await repository.getClub('club1');
      expect(club, isNotNull);
      expect(club?.id, 'club1');
      expect(club?.name, 'Padel Club');
      expect(club?.locality, Locality.villaCarlosPaz);
    });

    test('updateClub modifies the document', () async {
      await fakeFirestore
          .collection('clubs')
          .doc('club1')
          .set(testClub.toMap());

      final updatedClub = testClub.copyWith(name: 'Updated Padel Club');
      await repository.updateClub(updatedClub);

      final snapshot =
          await fakeFirestore.collection('clubs').doc('club1').get();
      expect(snapshot.data()?['name'], 'Updated Padel Club');
    });

    test('getClubsByLocality returns only active clubs in locality', () async {
      final club2 = testClub.copyWith(
        id: 'club2',
        locality: Locality.villaCarlosPaz,
        isActive: true,
      );
      final club3 = testClub.copyWith(
        id: 'club3',
        locality: Locality.cosquin,
        isActive: true,
      ); // Different locality
      final club4 = testClub.copyWith(
        id: 'club4',
        locality: Locality.villaCarlosPaz,
        isActive: false,
      ); // Inactive

      await fakeFirestore
          .collection('clubs')
          .doc('club1')
          .set(testClub.toMap());
      await fakeFirestore.collection('clubs').doc('club2').set(club2.toMap());
      await fakeFirestore.collection('clubs').doc('club3').set(club3.toMap());
      await fakeFirestore.collection('clubs').doc('club4').set(club4.toMap());

      final clubs = await repository.getClubsByLocality(
        Locality.villaCarlosPaz,
      );

      expect(clubs.length, 2);
      expect(clubs.map((c) => c.id), containsAll(['club1', 'club2']));
      expect(clubs.map((c) => c.id), isNot(contains('club3')));
      expect(clubs.map((c) => c.id), isNot(contains('club4')));
    });
  });
}
