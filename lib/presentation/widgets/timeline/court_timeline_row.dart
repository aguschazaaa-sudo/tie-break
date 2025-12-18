import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/models/reservation_model.dart';
import 'package:padel_punilla/presentation/widgets/timeline/timeline_config.dart';
import 'package:padel_punilla/presentation/widgets/timeline/timeline_reservation_card.dart';

/// Widget que representa una fila del timeline para una cancha específica.
///
/// Muestra las reservas de la cancha posicionadas según su hora de inicio,
/// con divisores de slots según [slotDurationMinutes].
class CourtTimelineRow extends StatelessWidget {
  /// Lista de reservas a mostrar en esta fila
  final List<ReservationModel> reservations;

  /// Píxeles por minuto para calcular posiciones y anchos
  final double widthPerMinute;

  /// Hora de inicio del timeline (por defecto 8:00)
  final int startHour;

  /// Altura de la fila
  final double height;

  /// Ancho total del timeline
  final double totalWidth;

  /// Duración de cada slot en minutos (para los divisores)
  final int slotDurationMinutes;

  /// Callback cuando se hace tap en una reserva
  final void Function(ReservationModel)? onReservationTap;

  /// Mapa de userId -> displayName para mostrar nombres de usuarios
  final Map<String, String> userNames;

  /// Configuración de visualización del timeline
  final TimelineConfig config;

  const CourtTimelineRow({
    super.key,
    required this.reservations,
    required this.widthPerMinute,
    required this.totalWidth,
    this.startHour = 8,
    this.height = 60,
    this.onReservationTap,
    this.slotDurationMinutes = 90,
    this.userNames = const {},
    this.config = TimelineConfig.userView,
  });

  @override
  Widget build(BuildContext context) {
    // Genera divisores de slots para ayudar visualmente
    final totalMinutes = totalWidth / widthPerMinute;
    final List<Widget> slotDividers = [];

    for (var i = 0; i < totalMinutes; i += slotDurationMinutes) {
      final left = i * widthPerMinute;
      slotDividers.add(
        Positioned(
          left: left,
          top: 0,
          bottom: 0,
          child: Container(
            width: 1,
            color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
          ),
        ),
      );
    }

    return Container(
      height: height,
      width: totalWidth,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Divisores de slots
          ...slotDividers,

          // Reservas posicionadas según su hora de inicio
          ...reservations.map((reservation) {
            final startTime = reservation.startTime;
            final startMinutes = startTime.hour * 60 + startTime.minute;
            final offsetMinutes = startMinutes - (startHour * 60);
            final left = offsetMinutes * widthPerMinute;

            // Obtiene el nombre del usuario si está disponible
            final userName = userNames[reservation.userId];

            return Positioned(
              left: left,
              top: 0,
              bottom: 0,
              child: TimelineReservationCard(
                reservation: reservation,
                widthPerMinute: widthPerMinute,
                userName: userName,
                config: config,
                onTap: () => onReservationTap?.call(reservation),
              ),
            );
          }),
        ],
      ),
    );
  }
}
