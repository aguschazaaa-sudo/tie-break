import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:padel_punilla/domain/enums/reservation_enums.dart';
import 'package:padel_punilla/domain/models/notification_model.dart';
import 'package:padel_punilla/domain/models/reservation_model.dart';
import 'package:padel_punilla/domain/repositories/reservation_repository.dart';
import 'package:uuid/uuid.dart';

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
    final snapshot =
        await _firestore
            .collection('reservations')
            .where('userId', isEqualTo: userId)
            .orderBy('startTime', descending: true)
            .get();

    return snapshot.docs
        .map((doc) => ReservationModel.fromMap(doc.data()))
        .toList();
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

      // 2. Calcular nuevos team2Ids
      final newTeam2Ids = List<String>.from(reservation.team2Ids);
      newTeam2Ids.add(userId);
      if (partnerId != null) {
        newTeam2Ids.add(partnerId);
      }

      // 3. Determinar si el partido está completo
      final totalPlayers = reservation.team1Ids.length + newTeam2Ids.length;
      final isComplete =
          reservation.type == ReservationType.match2vs2
              ? (reservation.team1Ids.length >= 2 && newTeam2Ids.length >= 2)
              : totalPlayers >= 4;

      // 4. Calcular isOpenMatch (Lógica duplicada de Service por seguridad en transacción)
      bool newIsOpenMatch = reservation.isOpenMatch;
      if (reservation.type == ReservationType.falta1) {
        newIsOpenMatch = false; // Se cierra al primer join
      } else if (reservation.type == ReservationType.match2vs2) {
        if (isComplete) {
          newIsOpenMatch = false;
        }
      } else if (isComplete) {
        newIsOpenMatch = false;
      }

      // 5. Actualizar con los nuevos datos
      transaction.update(docRef, {
        'team2Ids': newTeam2Ids,
        if (isComplete) 'status': ReservationStatus.approved.name,
        'isOpenMatch': newIsOpenMatch,
      });

      // 5. Crear notificaciones para los miembros del team1 si el partido se completó
      // O si se unió alguien (según el requerimiento: "cuando a un 2 vs 2 se le suma la segunda pareja notficar a la primera")
      if (reservation.type == ReservationType.match2vs2 &&
          newTeam2Ids.length == 2) {
        for (final receiverId in reservation.team1Ids) {
          final notificationId = const Uuid().v4();
          final notification = NotificationModel(
            id: notificationId,
            title: '¡Partido Completado!',
            body:
                'Una pareja se ha unido a tu partido de 2vs2. ¡Ya pueden jugar!',
            receiverId: receiverId,
            createdAt: DateTime.now(),
            reservationId: reservationId,
          );

          final notificationRef = _firestore
              .collection('notifications')
              .doc(notificationId);
          transaction.set(notificationRef, notification.toMap());
        }
      } else if (reservation.type == ReservationType.falta1 && isComplete) {
        for (final receiverId in reservation.team1Ids) {
          final notificationId = const Uuid().v4();
          final notification = NotificationModel(
            id: notificationId,
            title: '¡Partido Completado!',
            body:
                'Alguien se ha unido para completar el Falta 1. ¡Ya pueden jugar!',
            receiverId: receiverId,
            createdAt: DateTime.now(),
            reservationId: reservationId,
          );

          final notificationRef = _firestore
              .collection('notifications')
              .doc(notificationId);
          transaction.set(notificationRef, notification.toMap());
        }
      }
    });
  }
}
