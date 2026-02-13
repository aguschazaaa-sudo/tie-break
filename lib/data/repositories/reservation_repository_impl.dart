import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:padel_punilla/domain/enums/reservation_enums.dart';
import 'package:padel_punilla/domain/models/reservation_model.dart';
import 'package:padel_punilla/domain/repositories/reservation_repository.dart';

class ReservationRepositoryImpl implements ReservationRepository {
  ReservationRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  @override
  Future<void> createReservation(ReservationModel reservation) async {
    await _firestore
        .collection('reservations')
        .doc(reservation.id)
        .set(reservation.toMap());
  }

  @override
  Future<void> updateReservation(ReservationModel reservation) async {
    await _firestore
        .collection('reservations')
        .doc(reservation.id)
        .update(reservation.toMap());
  }

  @override
  Future<void> deleteReservation(String reservationId) async {
    await _firestore.collection('reservations').doc(reservationId).delete();
  }

  @override
  Future<ReservationModel?> getReservationById(String id) async {
    final doc = await _firestore.collection('reservations').doc(id).get();
    if (doc.exists && doc.data() != null) {
      return ReservationModel.fromMap(doc.data()!);
    }
    return null;
  }

  @override
  Future<List<ReservationModel>> getReservationsByCourtAndDate(
    String courtId,
    DateTime date,
  ) async {
    // Create range for the whole day
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot =
        await _firestore
            .collection('reservations')
            .where('courtId', isEqualTo: courtId)
            .where(
              'startTime',
              isGreaterThanOrEqualTo: startOfDay.toIso8601String(),
            )
            .where('startTime', isLessThan: endOfDay.toIso8601String())
            .get();

    return snapshot.docs
        .map((doc) => ReservationModel.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<List<ReservationModel>> getReservationsByUser(String userId) async {
    // Query 1: Reservas donde el usuario es owner
    // (cubre Falta1 y Normal donde el creador no está en teams)
    final ownerSnapshot =
        await _firestore
            .collection('reservations')
            .where('userId', isEqualTo: userId)
            .get();

    // Query 2: Reservas donde el usuario está en team1 (2vs2)
    final team1Snapshot =
        await _firestore
            .collection('reservations')
            .where('team1Ids', arrayContains: userId)
            .get();

    // Query 3: Reservas donde el usuario está en team2 (se unió a 2vs2)
    final team2Snapshot =
        await _firestore
            .collection('reservations')
            .where('team2Ids', arrayContains: userId)
            .get();

    // Merge y deduplicar por ID
    final allDocs = <String, ReservationModel>{};

    for (var doc in ownerSnapshot.docs) {
      final reservation = ReservationModel.fromMap(doc.data());
      allDocs[reservation.id] = reservation;
    }

    for (var doc in team1Snapshot.docs) {
      final reservation = ReservationModel.fromMap(doc.data());
      allDocs[reservation.id] = reservation;
    }

    for (var doc in team2Snapshot.docs) {
      final reservation = ReservationModel.fromMap(doc.data());
      allDocs[reservation.id] = reservation;
    }

    final result = allDocs.values.toList();

    // Ordenar por startTime descendente (más reciente primero)
    result.sort((a, b) => b.startTime.compareTo(a.startTime));

    return result;
  }

  @override
  Future<List<ReservationModel>> getReservationsByClubAndDate(
    String clubId,
    DateTime date,
  ) async {
    // Create range for the whole day
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot =
        await _firestore
            .collection('reservations')
            .where('clubId', isEqualTo: clubId)
            .where(
              'startTime',
              isGreaterThanOrEqualTo: startOfDay.toIso8601String(),
            )
            .where('startTime', isLessThan: endOfDay.toIso8601String())
            .get();

    return snapshot.docs
        .map((doc) => ReservationModel.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<List<ReservationModel>> getActiveSearchReservations(
    List<String> clubIds,
  ) async {
    if (clubIds.isEmpty) return [];

    // Hora actual para filtrar solo reservas futuras
    final now = DateTime.now();

    // Firestore 'whereIn' soporta hasta 30 elementos.
    // Dividimos en chunks si es necesario.
    const chunkSize = 30;
    final allReservations = <ReservationModel>[];

    for (var i = 0; i < clubIds.length; i += chunkSize) {
      final chunk = clubIds.skip(i).take(chunkSize).toList();

      // Consulta para reservas tipo match2vs2
      final match2vs2Snapshot =
          await _firestore
              .collection('reservations')
              .where('clubId', whereIn: chunk)
              .where('type', isEqualTo: ReservationType.match2vs2.name)
              .where('status', isEqualTo: ReservationStatus.pending.name)
              .where('isOpenMatch', isEqualTo: true) // Filter by isOpenMatch
              .where('startTime', isGreaterThanOrEqualTo: now.toIso8601String())
              .orderBy('startTime')
              .get();

      // Consulta para reservas tipo falta1
      final falta1Snapshot =
          await _firestore
              .collection('reservations')
              .where('clubId', whereIn: chunk)
              .where('type', isEqualTo: ReservationType.falta1.name)
              .where('status', isEqualTo: ReservationStatus.pending.name)
              .where('isOpenMatch', isEqualTo: true) // Filter by isOpenMatch
              .where('startTime', isGreaterThanOrEqualTo: now.toIso8601String())
              .orderBy('startTime')
              .get();

      // Agregar resultados de ambas consultas
      allReservations.addAll(
        match2vs2Snapshot.docs.map(
          (doc) => ReservationModel.fromMap(doc.data()),
        ),
      );
      allReservations.addAll(
        falta1Snapshot.docs.map((doc) => ReservationModel.fromMap(doc.data())),
      );
    }

    // Ordenar por startTime ya que mezclamos resultados de múltiples queries
    allReservations.sort((a, b) => a.startTime.compareTo(b.startTime));

    return allReservations;
  }

  @override
  Future<void> joinMatch({
    required String reservationId,
    required String userId,
    String? partnerId,
  }) async {
    // Usamos una transacción para garantizar consistencia
    await _firestore.runTransaction((transaction) async {
      // 1. Obtener la reserva actual
      final docRef = _firestore.collection('reservations').doc(reservationId);
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists || snapshot.data() == null) {
        throw Exception('Reserva no encontrada');
      }

      final reservation = ReservationModel.fromMap(snapshot.data()!);

      // Falta1: el jugador va a participantIds (teams solo aplican a 2vs2)
      if (reservation.type == ReservationType.falta1) {
        final newParticipantIds = List<String>.from(reservation.participantIds);
        newParticipantIds.add(userId);

        // Falta1 se cierra y aprueba inmediatamente al primer join
        transaction.update(docRef, {
          'participantIds': newParticipantIds,
          'isOpenMatch': false,
          'status': ReservationStatus.approved.name,
        });
        return;
      }

      // 2vs2 y otros: el jugador (y partner) van a team2Ids
      final newTeam2Ids = List<String>.from(reservation.team2Ids);
      newTeam2Ids.add(userId);
      if (partnerId != null) {
        newTeam2Ids.add(partnerId);
      }

      // Determinar si el partido está completo
      final isComplete =
          reservation.team1Ids.length >= 2 && newTeam2Ids.length >= 2;

      // Si está completo, cerrar búsqueda
      final newIsOpenMatch = isComplete ? false : reservation.isOpenMatch;

      // Actualizar con los nuevos datos
      transaction.update(docRef, {
        'team2Ids': newTeam2Ids,
        if (isComplete) 'status': ReservationStatus.approved.name,
        'isOpenMatch': newIsOpenMatch,
      });

      // Nota: Las notificaciones son manejadas por la Cloud Function onMatchFull
      // que detecta cambios en team2Ids y genera las notificaciones correspondientes
    });
  }
}
