import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_punilla/data/repositories/court_repository_impl.dart';
import 'package:padel_punilla/domain/models/court_model.dart';
// import 'package:padel_punilla/domain/enums/surface_type.dart'; // Removed as it is part of court_model.dart or not needed

void main() {
  group('CourtRepositoryImpl (FakeFirestore)', () {
    late FakeFirebaseFirestore fakeFirestore;
    late CourtRepositoryImpl repository;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = CourtRepositoryImpl(firestore: fakeFirestore);
    });

    final testCourt = CourtModel(
      id: 'court1',
      clubId: 'club1',
      name: 'Court 1',
      surfaceType: CourtSurface.synthetic, // Fixed property name and enum
      isCovered: true,
      reservationPrice: 100.0,
      // availability: {}, // Removed as it is not in the model
    );

    test('getCourt returns proper CourtModel', () async {
      await fakeFirestore
          .collection('clubs')
          .doc('club1')
          .collection('courts')
          .doc('court1')
          .set(testCourt.toMap());

      final court = await repository.getCourt('club1', 'court1');
      expect(court, isNotNull);
      expect(court?.id, 'court1');
      expect(court?.name, 'Court 1');
      expect(court?.surfaceType, CourtSurface.synthetic);
    });

    test('getCourt returns null if not exists', () async {
      final court = await repository.getCourt('club1', 'non_existent');
      expect(court, isNull);
    });
  });
}
