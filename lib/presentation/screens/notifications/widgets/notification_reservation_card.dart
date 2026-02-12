import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:padel_punilla/domain/models/club_model.dart';
import 'package:padel_punilla/domain/models/court_model.dart';
import 'package:padel_punilla/domain/models/reservation_model.dart';
import 'package:padel_punilla/domain/repositories/club_repository.dart';
import 'package:padel_punilla/domain/repositories/court_repository.dart';
import 'package:padel_punilla/domain/repositories/reservation_repository.dart';
import 'package:padel_punilla/presentation/screens/notifications/widgets/notification_reservation_card_skeleton.dart';
import 'package:provider/provider.dart';

class NotificationReservationCard extends StatefulWidget {
  const NotificationReservationCard({required this.reservationId, super.key});

  final String reservationId;

  @override
  State<NotificationReservationCard> createState() =>
      _NotificationReservationCardState();
}

class _NotificationReservationCardState
    extends State<NotificationReservationCard> {
  late Future<_ReservationDetails?> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _detailsFuture = _fetchDetails();
  }

  Future<_ReservationDetails?> _fetchDetails() async {
    try {
      final reservationRepo = context.read<ReservationRepository>();
      final clubRepo = context.read<ClubRepository>();
      final courtRepo = context.read<CourtRepository>();

      final reservation = await reservationRepo.getReservationById(
        widget.reservationId,
      );
      if (reservation == null) return null;

      final club = await clubRepo.getClub(reservation.clubId);
      final court = await courtRepo.getCourt(
        reservation.clubId,
        reservation.courtId,
      );

      return _ReservationDetails(
        reservation: reservation,
        club: club,
        court: court,
      );
    } catch (e) {
      debugPrint('Error fetching reservation details: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FutureBuilder<_ReservationDetails?>(
      future: _detailsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const NotificationReservationCardSkeleton();
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Reserva no encontrada',
              style: TextStyle(color: colorScheme.error),
            ),
          );
        }

        final details = snapshot.data!;
        final reservation = details.reservation;
        final club = details.club;
        final court = details.court;

        final dateFormat = DateFormat('EEE d MMM', 'es');
        final timeFormat = DateFormat('HH:mm');

        return Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outlineVariant.withOpacity(0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateFormat.format(reservation.startTime),
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${timeFormat.format(reservation.startTime)} - ${timeFormat.format(reservation.endTime)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (club != null)
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        club.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              if (court != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 24),
                  child: Text(
                    court.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ReservationDetails {
  _ReservationDetails({required this.reservation, this.club, this.court});

  final ReservationModel reservation;
  final ClubModel? club;
  final CourtModel? court;
}
