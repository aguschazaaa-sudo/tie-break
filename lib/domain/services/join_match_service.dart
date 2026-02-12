import 'package:padel_punilla/domain/enums/player_gender.dart';
import 'package:padel_punilla/domain/enums/reservation_enums.dart';
import 'package:padel_punilla/domain/models/reservation_model.dart';
import 'package:padel_punilla/domain/models/user_model.dart';

/// Servicio que maneja la lógica de unión a partidos incompletos.
///
/// Este servicio valida si un usuario puede unirse a una reserva
/// de tipo 2vs2 o Falta1, y aplica los cambios al modelo.
class JoinMatchService {
  /// Valida si un usuario puede unirse a una reserva.
  ///
  /// Retorna `null` si el usuario puede unirse correctamente.
  /// Retorna un mensaje de error si la validación falla.
  ///
  /// Validaciones realizadas:
  /// - La reserva debe estar abierta (isOpenMatch == true)
  /// - Usuario no está ya en la reserva (team1 o team2)
  /// - Si es womenOnly, el usuario debe ser mujer
  /// - Si es 2vs2, debe proporcionar un partnerId válido
  /// - El partner no debe estar ya en la reserva
  /// - El usuario no debe tener reservas que se solapen en horario
  String? validateJoin({
    required ReservationModel reservation,
    required UserModel currentUser,
    required String? partnerId,
    required List<ReservationModel> userReservations,
  }) {
    // Validación 0: La reserva debe estar abierta para nuevos jugadores
    if (!reservation.isOpenMatch) {
      return 'El partido ya no busca jugadores';
    }

    // Validación 1: Usuario no está ya en la reserva
    // (puede estar en team1, team2, o participantIds según el tipo)
    if (reservation.team1Ids.contains(currentUser.id) ||
        reservation.team2Ids.contains(currentUser.id) ||
        reservation.participantIds.contains(currentUser.id) ||
        reservation.userId == currentUser.id) {
      return 'Ya formas parte de este partido';
    }

    // Validación 2: Partido solo para mujeres
    if (reservation.womenOnly && currentUser.gender != PlayerGender.female) {
      return 'Este partido es solo para mujeres';
    }

    // Validación 3: Para 2vs2 se requiere compañero
    if (reservation.type == ReservationType.match2vs2) {
      if (partnerId == null || partnerId.isEmpty) {
        return 'Debes seleccionar un compañero para unirte al 2vs2';
      }

      // Validación 4: El compañero no debe estar ya en la reserva
      if (reservation.team1Ids.contains(partnerId) ||
          reservation.team2Ids.contains(partnerId)) {
        return 'Tu compañero ya forma parte de este partido';
      }
    }

    // Validación 5: No tener reservas que se solapen
    if (_hasOverlappingReservation(reservation, userReservations)) {
      return 'Ya tienes una reserva en este horario';
    }

    // Todas las validaciones pasaron
    return null;
  }

  /// Aplica la unión del usuario (y compañero si es 2vs2) a la reserva.
  ///
  /// Retorna una nueva instancia de [ReservationModel] con los IDs
  /// agregados al team2 y el status actualizado si corresponde.
  ReservationModel applyJoin({
    required ReservationModel reservation,
    required String userId,
    required String? partnerId,
  }) {
    // Falta1: el jugador va a participantIds (teams solo para 2vs2)
    if (reservation.type == ReservationType.falta1) {
      final newParticipantIds = List<String>.from(reservation.participantIds);
      newParticipantIds.add(userId);

      // Falta1 se cierra inmediatamente al primer join
      return reservation.copyWith(
        participantIds: newParticipantIds,
        isOpenMatch: false,
      );
    }

    // 2vs2 y otros tipos: el jugador (y partner) van a team2Ids
    final newTeam2Ids = List<String>.from(reservation.team2Ids);
    newTeam2Ids.add(userId);

    if (partnerId != null) {
      newTeam2Ids.add(partnerId);
    }

    // Determinar si el partido está completo
    final isMatchComplete = _isMatchComplete(
      type: reservation.type,
      team1Count: reservation.team1Ids.length,
      team2Count: newTeam2Ids.length,
    );

    // Si está completo, aprobar automáticamente
    final newStatus =
        isMatchComplete ? ReservationStatus.approved : reservation.status;

    // Lógica para cerrar el partido (isOpenMatch = false)
    bool newIsOpenMatch = reservation.isOpenMatch;
    if (isMatchComplete) {
      newIsOpenMatch = false;
    }

    return reservation.copyWith(
      team2Ids: newTeam2Ids,
      status: newStatus,
      isOpenMatch: newIsOpenMatch,
    );
  }

  /// Verifica si hay reservas que se solapen en horario.
  ///
  /// Dos reservas se solapan si:
  /// - Son del mismo día
  /// - El intervalo [startTime, endTime) de una intersecta con el de la otra
  bool _hasOverlappingReservation(
    ReservationModel targetReservation,
    List<ReservationModel> userReservations,
  ) {
    final targetStart = targetReservation.startTime;
    final targetEnd = targetReservation.endTime;

    for (final existing in userReservations) {
      // Ignorar reservas canceladas o rechazadas
      if (existing.status == ReservationStatus.cancelled ||
          existing.status == ReservationStatus.rejected) {
        continue;
      }

      // Verificar si es el mismo día
      if (!_isSameDay(existing.startTime, targetStart)) {
        continue;
      }

      final existingStart = existing.startTime;
      final existingEnd = existing.endTime;

      // Verificar solapamiento: [A, B) y [C, D) se solapan si A < D && C < B
      if (targetStart.isBefore(existingEnd) &&
          existingStart.isBefore(targetEnd)) {
        return true;
      }
    }

    return false;
  }

  /// Verifica si un partido está completo según su tipo.
  ///
  /// - 2vs2: 2 jugadores en cada equipo
  /// - Falta1: 4 jugadores en total (puede ser cualquier distribución,
  ///           normalmente 3 en team1 y 1 que se une en team2)
  bool _isMatchComplete({
    required ReservationType type,
    required int team1Count,
    required int team2Count,
  }) {
    final totalPlayers = team1Count + team2Count;

    switch (type) {
      case ReservationType.match2vs2:
        // 2vs2 necesita 2 en cada equipo
        return team1Count >= 2 && team2Count >= 2;
      case ReservationType.falta1:
        // Falta1 necesita 4 jugadores en total
        // NOTA: Esta lógica es para saber si el partido en SÍ está completo para jugarse (status approved),
        // no necesariamente si se cerró la búsqueda (isOpenMatch), aunque suelen coincidir
        // excepto en el caso especial de Falta 1 donde cerramos la búsqueda al primer join.
        return totalPlayers >= 4;
      default:
        // Para otros tipos, siempre está completo
        return true;
    }
  }

  /// Verifica si dos fechas son del mismo día.
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
