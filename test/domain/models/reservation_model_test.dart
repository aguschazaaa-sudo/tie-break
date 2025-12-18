import 'package:flutter_test/flutter_test.dart';
import 'package:padel_punilla/domain/enums/reservation_enums.dart';
import 'package:padel_punilla/domain/models/reservation_model.dart';

void main() {
  group('ReservationModel', () {
    /// Fecha base para los tests
    final baseDate = DateTime(2024, 1, 15, 14);
    final createdAt = DateTime(2024, 1, 14, 10);

    /// Helper para crear un modelo base
    ReservationModel createBaseReservation({
      bool womenOnly = false,
      ReservationType type = ReservationType.normal,
    }) {
      return ReservationModel(
        id: 'test_reservation_1',
        courtId: 'court_1',
        clubId: 'club_1',
        userId: 'user_1',
        reservedDate: baseDate,
        startTime: baseDate,
        durationMinutes: 90,
        createdAt: createdAt,
        price: 5000.0,
        type: type,
        womenOnly: womenOnly,
      );
    }

    group('womenOnly field', () {
      test('should default to false when not specified', () {
        final reservation = ReservationModel(
          id: 'test_1',
          courtId: 'court_1',
          clubId: 'club_1',
          userId: 'user_1',
          reservedDate: baseDate,
          startTime: baseDate,
          durationMinutes: 60,
          createdAt: createdAt,
          price: 3000.0,
        );

        expect(reservation.womenOnly, false);
      });

      test('should be true when explicitly set', () {
        final reservation = createBaseReservation(womenOnly: true);

        expect(reservation.womenOnly, true);
      });

      test('should serialize womenOnly to map', () {
        final reservation = createBaseReservation(womenOnly: true);
        final map = reservation.toMap();

        expect(map['womenOnly'], true);
      });

      test('should deserialize womenOnly from map', () {
        final map = {
          'id': 'test_1',
          'courtId': 'court_1',
          'clubId': 'club_1',
          'userId': 'user_1',
          'reservedDate': baseDate.toIso8601String(),
          'startTime': baseDate.toIso8601String(),
          'durationMinutes': 60,
          'createdAt': createdAt.toIso8601String(),
          'price': 3000.0,
          'womenOnly': true,
        };

        final reservation = ReservationModel.fromMap(map);

        expect(reservation.womenOnly, true);
      });

      test('should default womenOnly to false if missing in map', () {
        final map = {
          'id': 'test_1',
          'courtId': 'court_1',
          'clubId': 'club_1',
          'userId': 'user_1',
          'reservedDate': baseDate.toIso8601String(),
          'startTime': baseDate.toIso8601String(),
          'durationMinutes': 60,
          'createdAt': createdAt.toIso8601String(),
          'price': 3000.0,
        };

        final reservation = ReservationModel.fromMap(map);

        expect(reservation.womenOnly, false);
      });
    });

    group('copyWith womenOnly', () {
      test('should preserve womenOnly when not changed', () {
        final original = createBaseReservation(womenOnly: true);
        final copied = original.copyWith(price: 6000.0);

        expect(copied.womenOnly, true);
        expect(copied.price, 6000.0);
      });

      test('should update womenOnly when changed', () {
        final original = createBaseReservation(womenOnly: false);
        final copied = original.copyWith(womenOnly: true);

        expect(copied.womenOnly, true);
      });
    });

    group('equality', () {
      test('reservations with different womenOnly should not be equal', () {
        final reservation1 = createBaseReservation(womenOnly: false);
        final reservation2 = createBaseReservation(womenOnly: true);

        expect(reservation1 == reservation2, false);
      });

      test('reservations with same womenOnly should be equal', () {
        final reservation1 = createBaseReservation(womenOnly: true);
        final reservation2 = createBaseReservation(womenOnly: true);

        expect(reservation1 == reservation2, true);
      });
    });

    group('hashCode', () {
      test(
        'reservations with different womenOnly should have different hashCodes',
        () {
          final reservation1 = createBaseReservation(womenOnly: false);
          final reservation2 = createBaseReservation(womenOnly: true);

          expect(reservation1.hashCode == reservation2.hashCode, false);
        },
      );
    });

    group('toString', () {
      test('should include womenOnly in string representation', () {
        final reservation = createBaseReservation(womenOnly: true);
        final str = reservation.toString();

        expect(str.contains('womenOnly: true'), true);
      });
    });

    group('womenOnly with reservation types', () {
      test('womenOnly can be set for match2vs2 type', () {
        final reservation = createBaseReservation(
          type: ReservationType.match2vs2,
          womenOnly: true,
        );

        expect(reservation.type, ReservationType.match2vs2);
        expect(reservation.womenOnly, true);
      });

      test('womenOnly can be set for falta1 type', () {
        final reservation = createBaseReservation(
          type: ReservationType.falta1,
          womenOnly: true,
        );

        expect(reservation.type, ReservationType.falta1);
        expect(reservation.womenOnly, true);
      });

      test('womenOnly can be set for normal type (edge case)', () {
        // Aunque no tiene sentido lógico, el modelo lo permite
        final reservation = createBaseReservation(
          type: ReservationType.normal,
          womenOnly: true,
        );

        expect(reservation.type, ReservationType.normal);
        expect(reservation.womenOnly, true);
      });
    });

    group('full serialization roundtrip', () {
      test('should preserve all fields including womenOnly', () {
        final original = ReservationModel(
          id: 'roundtrip_test',
          courtId: 'court_123',
          clubId: 'club_456',
          userId: 'user_789',
          reservedDate: baseDate,
          startTime: baseDate,
          durationMinutes: 120,
          createdAt: createdAt,
          price: 7500.0,
          type: ReservationType.match2vs2,
          status: ReservationStatus.approved,
          paymentStatus: PaymentStatus.paid,
          team1Ids: ['user_a', 'user_b'],
          team2Ids: ['user_c', 'user_d'],
          womenOnly: true,
          paidAmount: 7500.0,
        );

        final map = original.toMap();
        final deserialized = ReservationModel.fromMap(map);

        expect(deserialized.id, original.id);
        expect(deserialized.womenOnly, original.womenOnly);
        expect(deserialized.type, original.type);
        expect(deserialized.team1Ids, original.team1Ids);
        expect(deserialized.team2Ids, original.team2Ids);
        expect(deserialized == original, true);
      });
    });
  });
}
