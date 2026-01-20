import 'package:flutter_test/flutter_test.dart';
import 'package:padel_punilla/domain/enums/player_gender.dart';
import 'package:padel_punilla/domain/enums/reservation_enums.dart';
import 'package:padel_punilla/domain/models/reservation_model.dart';
import 'package:padel_punilla/domain/models/user_model.dart';
import 'package:padel_punilla/domain/services/join_match_service.dart';

void main() {
  group('JoinMatchService', () {
    late JoinMatchService service;

    setUp(() {
      service = JoinMatchService();
    });

    // =========================================================================
    // Helper para crear reservas de prueba
    // =========================================================================
    ReservationModel createReservation({
      String id = 'res1',
      ReservationType type = ReservationType.falta1,
      List<String> team1Ids = const ['user1'],
      List<String> team2Ids = const [],
      bool womenOnly = false,
      DateTime? startTime,
      int durationMinutes = 60,
      ReservationStatus status = ReservationStatus.pending,
    }) {
      return ReservationModel(
        id: id,
        courtId: 'court1',
        clubId: 'club1',
        userId: 'user1',
        reservedDate: DateTime(2025, 6, 15),
        startTime: startTime ?? DateTime(2025, 6, 15, 10),
        durationMinutes: durationMinutes,
        createdAt: DateTime.now(),
        price: 1500,
        type: type,
        team1Ids: team1Ids,
        team2Ids: team2Ids,
        womenOnly: womenOnly,
        status: status,
      );
    }

    // Helper para crear usuarios de prueba
    UserModel createUser({
      String id = 'user2',
      PlayerGender? gender = PlayerGender.male,
    }) {
      return UserModel(
        id: id,
        email: 'test@test.com',
        username: 'testuser',
        displayName: 'Test User',
        discriminator: '0001',
        createdAt: DateTime.now(),
        gender: gender,
      );
    }

    // =========================================================================
    // Tests de validateJoin
    // =========================================================================

    group('validateJoin', () {
      test('should return null when user can join falta1', () {
        // Arrange
        final reservation = createReservation(type: ReservationType.falta1);
        final user = createUser(id: 'user2');

        // Act
        final result = service.validateJoin(
          reservation: reservation,
          currentUser: user,
          partnerId: null,
          userReservations: [],
        );

        // Assert
        expect(result, isNull);
      });

      test('should return null when user can join 2vs2 with partner', () {
        // Arrange
        final reservation = createReservation(type: ReservationType.match2vs2);
        final user = createUser(id: 'user2');

        // Act
        final result = service.validateJoin(
          reservation: reservation,
          currentUser: user,
          partnerId: 'user3',
          userReservations: [],
        );

        // Assert
        expect(result, isNull);
      });

      test('should return error when user is already in team1', () {
        // Arrange
        final reservation = createReservation(team1Ids: ['user1', 'user2']);
        final user = createUser(id: 'user2');

        // Act
        final result = service.validateJoin(
          reservation: reservation,
          currentUser: user,
          partnerId: null,
          userReservations: [],
        );

        // Assert
        expect(result, isNotNull);
        expect(result, contains('Ya'));
      });

      test('should return error when user is already in team2', () {
        // Arrange
        final reservation = createReservation(team2Ids: ['user2']);
        final user = createUser(id: 'user2');

        // Act
        final result = service.validateJoin(
          reservation: reservation,
          currentUser: user,
          partnerId: null,
          userReservations: [],
        );

        // Assert
        expect(result, isNotNull);
      });

      test('should return error when partner is already in reservation', () {
        // Arrange
        final reservation = createReservation(
          type: ReservationType.match2vs2,
          team1Ids: ['user1', 'user3'],
        );
        final user = createUser(id: 'user2');

        // Act
        final result = service.validateJoin(
          reservation: reservation,
          currentUser: user,
          partnerId: 'user3', // user3 ya está en team1
          userReservations: [],
        );

        // Assert
        expect(result, isNotNull);
        expect(result, contains('compañero'));
      });

      test('should return error when womenOnly and user is male', () {
        // Arrange
        final reservation = createReservation(womenOnly: true);
        final user = createUser(id: 'user2', gender: PlayerGender.male);

        // Act
        final result = service.validateJoin(
          reservation: reservation,
          currentUser: user,
          partnerId: null,
          userReservations: [],
        );

        // Assert
        expect(result, isNotNull);
        expect(result, contains('mujeres'));
      });

      test('should return null when womenOnly and user is female', () {
        // Arrange
        final reservation = createReservation(womenOnly: true);
        final user = createUser(id: 'user2', gender: PlayerGender.female);

        // Act
        final result = service.validateJoin(
          reservation: reservation,
          currentUser: user,
          partnerId: null,
          userReservations: [],
        );

        // Assert
        expect(result, isNull);
      });

      test('should return error when 2vs2 without partnerId', () {
        // Arrange
        final reservation = createReservation(type: ReservationType.match2vs2);
        final user = createUser(id: 'user2');

        // Act
        final result = service.validateJoin(
          reservation: reservation,
          currentUser: user,
          partnerId: null, // Sin compañero
          userReservations: [],
        );

        // Assert
        expect(result, isNotNull);
        expect(result, contains('compañero'));
      });

      test('should return error when user has overlapping reservation', () {
        // Arrange
        final reservation = createReservation(
          startTime: DateTime(2025, 6, 15, 10),
          durationMinutes: 60,
        );
        final user = createUser(id: 'user2');
        // Usuario tiene otra reserva que se solapa (9:30 - 10:30)
        final overlapping = createReservation(
          id: 'res2',
          startTime: DateTime(2025, 6, 15, 9, 30),
          durationMinutes: 60,
        );

        // Act
        final result = service.validateJoin(
          reservation: reservation,
          currentUser: user,
          partnerId: null,
          userReservations: [overlapping],
        );

        // Assert
        expect(result, isNotNull);
        expect(result, contains('horario'));
      });

      test('should return null when user reservations do not overlap', () {
        // Arrange
        final reservation = createReservation(
          startTime: DateTime(2025, 6, 15, 10),
          durationMinutes: 60,
        );
        final user = createUser(id: 'user2');
        // Usuario tiene otra reserva que NO se solapa (8:00 - 9:00)
        final nonOverlapping = createReservation(
          id: 'res2',
          startTime: DateTime(2025, 6, 15, 8),
          durationMinutes: 60,
        );

        // Act
        final result = service.validateJoin(
          reservation: reservation,
          currentUser: user,
          partnerId: null,
          userReservations: [nonOverlapping],
        );

        // Assert
        expect(result, isNull);
      });
    });

    // =========================================================================
    // Tests de applyJoin
    // =========================================================================

    group('applyJoin', () {
      test('should add user to team2Ids for falta1', () {
        // Arrange
        final reservation = createReservation(
          type: ReservationType.falta1,
          team1Ids: ['user1', 'user1b', 'user1c'],
          team2Ids: [],
        );

        // Act
        final result = service.applyJoin(
          reservation: reservation,
          userId: 'user2',
          partnerId: null,
        );

        // Assert
        expect(result.team2Ids, contains('user2'));
      });

      test('should add user and partner to team2Ids for 2vs2', () {
        // Arrange
        final reservation = createReservation(
          type: ReservationType.match2vs2,
          team1Ids: ['user1', 'user1b'],
          team2Ids: [],
        );

        // Act
        final result = service.applyJoin(
          reservation: reservation,
          userId: 'user2',
          partnerId: 'user3',
        );

        // Assert
        expect(result.team2Ids, contains('user2'));
        expect(result.team2Ids, contains('user3'));
        expect(result.team2Ids.length, 2);
      });

      test('should set status to approved when match is complete', () {
        // Arrange - falta1 necesita 4 jugadores, ya hay 3
        final reservation = createReservation(
          type: ReservationType.falta1,
          team1Ids: ['user1', 'user1b'],
          team2Ids: ['user1c'],
          status: ReservationStatus.pending,
        );

        // Act
        final result = service.applyJoin(
          reservation: reservation,
          userId: 'user2',
          partnerId: null,
        );

        // Assert
        expect(result.status, ReservationStatus.approved);
      });

      test('should set status to approved for 2vs2 when team2 is filled', () {
        // Arrange
        final reservation = createReservation(
          type: ReservationType.match2vs2,
          team1Ids: ['user1', 'user1b'],
          team2Ids: [],
          status: ReservationStatus.pending,
        );

        // Act
        final result = service.applyJoin(
          reservation: reservation,
          userId: 'user2',
          partnerId: 'user3',
        );

        // Assert
        expect(result.status, ReservationStatus.approved);
        expect(result.team2Ids.length, 2);
      });
    });
  });
}
