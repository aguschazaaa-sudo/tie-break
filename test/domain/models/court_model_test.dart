import 'package:flutter_test/flutter_test.dart';
import 'package:padel_punilla/domain/models/court_model.dart';

void main() {
  group('CourtModel', () {
    final court = CourtModel(
      id: 'court1',
      clubId: 'club1',
      name: 'Court 1',
      reservationPrice: 1000,
      isCovered: true,
      images: const ['image1.jpg'],
    );

    final courtMap = {
      'id': 'court1',
      'clubId': 'club1',
      'name': 'Court 1',
      'reservationPrice': 1000,
      'isCovered': true,
      'surfaceType': 'synthetic',
      'hasLighting': true,
      'sport': 'paddle',
      'images': ['image1.jpg'],
      'isAvailable': true,
      'slotDurationMinutes': 90,
    };

    test('supports value comparisons', () {
      expect(court, equals(court));
      expect(court, isNot(equals(court.copyWith(name: 'Court 2'))));
    });

    test('fromMap creates valid instance', () {
      expect(CourtModel.fromMap(courtMap), equals(court));
    });

    test('toMap creates valid map', () {
      expect(court.toMap(), equals(courtMap));
    });

    test('copyWith creates new instance with updated values', () {
      expect(
        court.copyWith(name: 'New Name'),
        equals(
          CourtModel(
            id: 'court1',
            clubId: 'club1',
            name: 'New Name',
            reservationPrice: 1000,
            isCovered: true,
            images: const ['image1.jpg'],
          ),
        ),
      );
    });

    test('toString returns correct string', () {
      expect(
        court.toString(),
        equals(
          'CourtModel(id: court1, clubId: club1, name: Court 1, reservationPrice: 1000.0, isCovered: true, surfaceType: CourtSurface.synthetic, hasLighting: true, sport: CourtSport.paddle, images: [image1.jpg], isAvailable: true, slotDurationMinutes: 90)',
        ),
      );
    });

    group('CourtSurface', () {
      test('displayName returns correct string', () {
        expect(CourtSurface.synthetic.displayName, 'Sintética');
        expect(CourtSurface.cement.displayName, 'Cemento');
        expect(CourtSurface.clay.displayName, 'Polvo de Ladrillo');
        expect(CourtSurface.grass.displayName, 'Césped');
        expect(CourtSurface.carpet.displayName, 'Alfombra');
        expect(CourtSurface.other.displayName, 'Otra');
      });
    });
  });
}
