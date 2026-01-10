import 'package:padel_punilla/domain/models/reservation_model.dart';

abstract class ReservationRepository {
  Future<void> createReservation(ReservationModel reservation);
  Future<void> updateReservation(ReservationModel reservation);
  Future<void> deleteReservation(String reservationId);
  Future<ReservationModel?> getReservationById(String id);
  Future<List<ReservationModel>> getReservationsByCourtAndDate(
    String courtId,
    DateTime date,
  );
  Future<List<ReservationModel>> getReservationsByUser(String userId);
  Future<List<ReservationModel>> getReservationsByClubAndDate(
    String clubId,
    DateTime date,
  );
  Future<List<ReservationModel>> getActiveSearchReservations(
    List<String> clubIds,
  );
}
