import 'package:flutter_test/flutter_test.dart';
import 'package:padel_punilla/domain/enums/player_gender.dart';
import 'package:padel_punilla/domain/enums/reservation_enums.dart';
import 'package:padel_punilla/domain/models/reservation_model.dart';
import 'package:padel_punilla/domain/models/user_model.dart';
import 'package:padel_punilla/domain/services/join_match_service.dart';

/// Tests exhaustivos para todos los caminos de Falta 1 + unión.
///
/// Cubre:
/// - Creación con owner solo y con extras
/// - Join: va a participantIds, cierra isOpenMatch
/// - Validaciones: duplicados, womenOnly, reservas solapadas, match cerrado
/// - Casos borde: owner como participante, doble join
void main() {
  group('Falta 1 - Flujo Completo', () {
    late JoinMatchService service;

    setUp(() {
      service = JoinMatchService();
    });

    // =========================================================================
    // Helper: Reserva Falta 1 base
    // =========================================================================
    ReservationModel createFalta1({
      String ownerId = 'owner1',
      List<String> participantIds = const [],
      bool isOpenMatch = true,
      bool womenOnly = false,
      ReservationStatus status = ReservationStatus.pending,
      DateTime? startTime,
    }) {
      return ReservationModel(
        id: 'falta1-res',
        courtId: 'court1',
        clubId: 'club1',
        userId: ownerId,
        reservedDate: DateTime(2025, 6, 15),
        startTime: startTime ?? DateTime(2025, 6, 15, 10),
        durationMinutes: 90,
        createdAt: DateTime.now(),
        price: 1500,
        type: ReservationType.falta1,
        team1Ids: const [], // Falta1 no usa teams
        team2Ids: const [], // Falta1 no usa teams
        participantIds: participantIds,
        isOpenMatch: isOpenMatch,
        womenOnly: womenOnly,
        status: status,
      );
    }

    // Helper: Usuario de prueba
    UserModel createUser({
      String id = 'joiner1',
      PlayerGender? gender = PlayerGender.male,
    }) {
      return UserModel(
        id: id,
        email: '$id@test.com',
        username: id,
        displayName: 'Test $id',
        discriminator: '0001',
        createdAt: DateTime.now(),
        gender: gender,
      );
    }

    // =========================================================================
    // Tests de CREACIÓN (estructura de datos al crear)
    // =========================================================================

    group('Estructura de datos', () {
      test('Falta1 creada sin extras: teams vacíos, participantIds vacío', () {
        // Simula la creación de una Falta 1 por el owner sin agregar extras
        final reservation = createFalta1(ownerId: 'owner1');

        // Assert - owner solo está en userId, NO en teams
        expect(reservation.userId, 'owner1');
        expect(reservation.team1Ids, isEmpty);
        expect(reservation.team2Ids, isEmpty);
        expect(reservation.participantIds, isEmpty);
        expect(reservation.isOpenMatch, isTrue);
      });

      test('Falta1 creada con 1 extra: el extra va a participantIds', () {
        // Simula que el owner agrega un amigo al crear la reserva
        final reservation = createFalta1(
          ownerId: 'owner1',
          participantIds: ['extra1'],
        );

        // Assert - owner en userId, extra en participantIds
        expect(reservation.userId, 'owner1');
        expect(reservation.participantIds, ['extra1']);
        expect(reservation.team1Ids, isEmpty);
        expect(reservation.team2Ids, isEmpty);
        expect(reservation.isOpenMatch, isTrue);
      });
    });

    // =========================================================================
    // Tests de VALIDACIÓN (validateJoin)
    // =========================================================================

    group('validateJoin', () {
      test('debería permitir join si la reserva está abierta', () {
        final reservation = createFalta1();
        final user = createUser(id: 'joiner1');

        final error = service.validateJoin(
          reservation: reservation,
          currentUser: user,
          partnerId: null,
          userReservations: [],
        );

        expect(error, isNull);
      });

      test('debería rechazar join si isOpenMatch es false', () {
        // Arrange - reserva ya cerrada
        final reservation = createFalta1(isOpenMatch: false);
        final user = createUser(id: 'joiner1');

        final error = service.validateJoin(
          reservation: reservation,
          currentUser: user,
          partnerId: null,
          userReservations: [],
        );

        expect(error, isNotNull);
        expect(error, contains('ya no busca'));
      });

      test('debería rechazar si el usuario ya es participante', () {
        // Arrange - joiner1 ya está en participantIds
        final reservation = createFalta1(participantIds: ['joiner1']);
        final user = createUser(id: 'joiner1');

        final error = service.validateJoin(
          reservation: reservation,
          currentUser: user,
          partnerId: null,
          userReservations: [],
        );

        expect(error, isNotNull);
        expect(error, contains('Ya formas parte'));
      });

      test('debería rechazar si el usuario es el owner', () {
        // Arrange - el owner intenta unirse a su propia reserva
        final reservation = createFalta1(ownerId: 'owner1');
        final user = createUser(id: 'owner1');

        final error = service.validateJoin(
          reservation: reservation,
          currentUser: user,
          partnerId: null,
          userReservations: [],
        );

        expect(error, isNotNull);
        expect(error, contains('Ya formas parte'));
      });

      test('debería rechazar hombre en womenOnly', () {
        final reservation = createFalta1(womenOnly: true);
        final user = createUser(id: 'joiner1', gender: PlayerGender.male);

        final error = service.validateJoin(
          reservation: reservation,
          currentUser: user,
          partnerId: null,
          userReservations: [],
        );

        expect(error, isNotNull);
        expect(error, contains('solo para mujeres'));
      });

      test('debería aceptar mujer en womenOnly', () {
        final reservation = createFalta1(womenOnly: true);
        final user = createUser(id: 'joiner1', gender: PlayerGender.female);

        final error = service.validateJoin(
          reservation: reservation,
          currentUser: user,
          partnerId: null,
          userReservations: [],
        );

        expect(error, isNull);
      });

      test('debería rechazar si hay reserva solapada', () {
        final reservation = createFalta1(startTime: DateTime(2025, 6, 15, 10));
        final user = createUser(id: 'joiner1');

        // Reserva existente del usuario que se solapa (10:30, mismo día)
        final existingReservation = ReservationModel(
          id: 'existing',
          courtId: 'court2',
          clubId: 'club2',
          userId: 'joiner1',
          reservedDate: DateTime(2025, 6, 15),
          startTime: DateTime(2025, 6, 15, 10, 30),
          durationMinutes: 90,
          createdAt: DateTime.now(),
          price: 1000,
          type: ReservationType.normal,
          status: ReservationStatus.approved,
        );

        final error = service.validateJoin(
          reservation: reservation,
          currentUser: user,
          partnerId: null,
          userReservations: [existingReservation],
        );

        expect(error, isNotNull);
        expect(error, contains('Ya tienes una reserva'));
      });

      test('debería aceptar si la reserva existente NO se solapa', () {
        final reservation = createFalta1(startTime: DateTime(2025, 6, 15, 10));
        final user = createUser(id: 'joiner1');

        // Reserva existente que NO se solapa (14:00, mismo día)
        final existingReservation = ReservationModel(
          id: 'existing',
          courtId: 'court2',
          clubId: 'club2',
          userId: 'joiner1',
          reservedDate: DateTime(2025, 6, 15),
          startTime: DateTime(2025, 6, 15, 14),
          durationMinutes: 60,
          createdAt: DateTime.now(),
          price: 1000,
          type: ReservationType.normal,
          status: ReservationStatus.approved,
        );

        final error = service.validateJoin(
          reservation: reservation,
          currentUser: user,
          partnerId: null,
          userReservations: [existingReservation],
        );

        expect(error, isNull);
      });

      test('debería ignorar reservas canceladas al verificar solapamiento', () {
        final reservation = createFalta1(startTime: DateTime(2025, 6, 15, 10));
        final user = createUser(id: 'joiner1');

        // Reserva cancelada que se solaparía
        final cancelledReservation = ReservationModel(
          id: 'cancelled',
          courtId: 'court2',
          clubId: 'club2',
          userId: 'joiner1',
          reservedDate: DateTime(2025, 6, 15),
          startTime: DateTime(2025, 6, 15, 10, 30),
          durationMinutes: 90,
          createdAt: DateTime.now(),
          price: 1000,
          type: ReservationType.normal,
          status: ReservationStatus.cancelled,
        );

        final error = service.validateJoin(
          reservation: reservation,
          currentUser: user,
          partnerId: null,
          userReservations: [cancelledReservation],
        );

        expect(error, isNull);
      });
    });

    // =========================================================================
    // Tests de applyJoin (aplicar la unión)
    // =========================================================================

    group('applyJoin', () {
      test('jugador va a participantIds, NO a team2Ids', () {
        final reservation = createFalta1();

        final result = service.applyJoin(
          reservation: reservation,
          userId: 'joiner1',
          partnerId: null,
        );

        // Assert
        expect(result.participantIds, contains('joiner1'));
        expect(result.team2Ids, isEmpty);
        expect(result.team1Ids, isEmpty);
      });

      test('isOpenMatch se cierra al primer join', () {
        final reservation = createFalta1();
        expect(reservation.isOpenMatch, isTrue); // precondición

        final result = service.applyJoin(
          reservation: reservation,
          userId: 'joiner1',
          partnerId: null,
        );

        expect(result.isOpenMatch, isFalse);
      });

      test('participantIds existentes se conservan al agregar joiner', () {
        // Owner ya tenía un extra
        final reservation = createFalta1(participantIds: ['extra1']);

        final result = service.applyJoin(
          reservation: reservation,
          userId: 'joiner1',
          partnerId: null,
        );

        // Assert - ambos deben estar en participantIds
        expect(result.participantIds, ['extra1', 'joiner1']);
        expect(result.participantIds.length, 2);
      });

      test('status no cambia por el service (se maneja en la pantalla)', () {
        final reservation = createFalta1(status: ReservationStatus.pending);

        final result = service.applyJoin(
          reservation: reservation,
          userId: 'joiner1',
          partnerId: null,
        );

        // El service no cambia el status para Falta 1
        expect(result.status, ReservationStatus.pending);
      });

      test('partnerId es ignorado en Falta 1 (solo para 2vs2)', () {
        final reservation = createFalta1();

        final result = service.applyJoin(
          reservation: reservation,
          userId: 'joiner1',
          partnerId: 'partner1', // Esto no debería tener efecto
        );

        // Solo el joiner debe aparecer, no el partner
        expect(result.participantIds, ['joiner1']);
        expect(result.participantIds.length, 1);
      });
    });

    // =========================================================================
    // Tests de flujo E2E (validar + aplicar)
    // =========================================================================

    group('Flujo completo: validar + aplicar', () {
      test('flujo exitoso: validar OK → aplicar → cerrar búsqueda', () {
        final reservation = createFalta1(ownerId: 'owner1');
        final user = createUser(id: 'joiner1');

        // 1. Validar
        final error = service.validateJoin(
          reservation: reservation,
          currentUser: user,
          partnerId: null,
          userReservations: [],
        );
        expect(error, isNull);

        // 2. Aplicar
        final result = service.applyJoin(
          reservation: reservation,
          userId: user.id,
          partnerId: null,
        );

        // 3. Verificar resultado final
        expect(result.participantIds, contains('joiner1'));
        expect(result.isOpenMatch, isFalse);
        expect(result.team1Ids, isEmpty);
        expect(result.team2Ids, isEmpty);

        // 4. Verificar que un segundo join sería rechazado
        final secondUser = createUser(id: 'joiner2');
        final secondError = service.validateJoin(
          reservation: result,
          currentUser: secondUser,
          partnerId: null,
          userReservations: [],
        );
        expect(secondError, isNotNull);
        expect(secondError, contains('ya no busca'));
      });

      test('owner NO puede unirse a su propia Falta 1', () {
        final reservation = createFalta1(ownerId: 'owner1');
        final ownerAsUser = createUser(id: 'owner1');

        final error = service.validateJoin(
          reservation: reservation,
          currentUser: ownerAsUser,
          partnerId: null,
          userReservations: [],
        );

        expect(error, isNotNull);
        expect(error, contains('Ya formas parte'));
      });

      test('joiner no puede unirse dos veces', () {
        final reservation = createFalta1(ownerId: 'owner1');
        final user = createUser(id: 'joiner1');

        // Primer join exitoso
        final error1 = service.validateJoin(
          reservation: reservation,
          currentUser: user,
          partnerId: null,
          userReservations: [],
        );
        expect(error1, isNull);

        final afterJoin = service.applyJoin(
          reservation: reservation,
          userId: user.id,
          partnerId: null,
        );

        // Segundo intento: rechazado por isOpenMatch=false
        final error2 = service.validateJoin(
          reservation: afterJoin,
          currentUser: user,
          partnerId: null,
          userReservations: [],
        );
        expect(error2, isNotNull);
      });
    });
  });
}
