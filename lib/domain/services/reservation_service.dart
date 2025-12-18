import 'package:padel_punilla/domain/models/reservation_model.dart';
import 'package:padel_punilla/domain/repositories/reservation_repository.dart';

class ReservationService {
  ReservationService({ReservationRepository? reservationRepository})
    : _reservationRepository = reservationRepository ?? ReservationRepository();
  final ReservationRepository _reservationRepository;

  Future<bool> checkAvailability(
    String courtId,
    DateTime startTime,
    int durationMinutes,
  ) async {
    // Get reservations for the same day
    final existingReservations = await _reservationRepository
        .getReservationsByCourtAndDate(courtId, startTime);

    final newEndTime = startTime.add(Duration(minutes: durationMinutes));

    for (final reservation in existingReservations) {
      // Skip cancelled reservations
      if (reservation.status.name == 'cancelled') continue;

      final existingStart = reservation.startTime;
      final existingEnd = reservation.endTime;

      // Check for overlap
      // Overlap exists if (StartA < EndB) and (EndA > StartB)
      if (startTime.isBefore(existingEnd) &&
          newEndTime.isAfter(existingStart)) {
        return false; // Not available
      }
    }

    return true; // Available
  }

  Future<void> createReservation(ReservationModel reservation) async {
    final isAvailable = await checkAvailability(
      reservation.courtId,
      reservation.startTime,
      reservation.durationMinutes,
    );

    if (!isAvailable) {
      throw Exception('El turno seleccionado ya no está disponible.');
    }

    await _reservationRepository.createReservation(reservation);
  }
}
