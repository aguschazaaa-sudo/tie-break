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
}
