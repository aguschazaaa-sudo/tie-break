import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/models/reservation_model.dart';
import 'package:padel_punilla/presentation/widgets/timeline/timeline_config.dart';
import 'package:padel_punilla/presentation/widgets/timeline/timeline_reservation_card.dart';

/// Widget que representa una fila del timeline para una cancha específica.
///
/// Muestra las reservas de la cancha posicionadas según su hora de inicio,
/// con divisores de slots según [slotDurationMinutes].
/// También muestra slots "Disponible" en los espacios vacíos.
class CourtTimelineRow extends StatelessWidget {
  const CourtTimelineRow({
    required this.reservations,
    required this.widthPerMinute,
    required this.totalWidth,
    super.key,
    this.startHour = 8,
    this.endHour = 23,
    this.height = 60,
    this.onReservationTap,
    this.onAvailableSlotTap,
    this.slotDurationMinutes = 90,
    this.userNames = const {},
    this.config = TimelineConfig.userView,
    this.clubSchedules = const [],
  });

  /// Lista de reservas a mostrar en esta fila
  final List<ReservationModel> reservations;

  /// Píxeles por minuto para calcular posiciones y anchos
  final double widthPerMinute;

  /// Hora de inicio del timeline (por defecto 8:00)
  final int startHour;

  /// Hora de fin del timeline (por defecto 23:00)
  final int endHour;

  /// Altura de la fila
  final double height;

  /// Ancho total del timeline
  final double totalWidth;

  /// Duración de cada slot en minutos (para los divisores)
  final int slotDurationMinutes;

  /// Callback cuando se hace tap en una reserva
  final void Function(ReservationModel)? onReservationTap;

  /// Callback cuando se hace tap en un slot disponible
  /// Recibe la hora de inicio del slot
  final void Function(DateTime slotTime)? onAvailableSlotTap;

  /// Mapa de userId -> displayName para mostrar nombres de usuarios
  final Map<String, String> userNames;

  /// Configuración de visualización del timeline
  final TimelineConfig config;

  /// Horarios disponibles del club (ej: ['14:00', '15:30', ...])
  final List<String> clubSchedules;

  /// Verifica si un slot está ocupado por alguna reserva
  bool _isSlotOccupied(DateTime slotStart, DateTime slotEnd) {
    for (final res in reservations) {
      final resEnd = res.startTime.add(Duration(minutes: res.durationMinutes));
      // Hay colisión si el slot se superpone con la reserva
      if (slotStart.isBefore(resEnd) && slotEnd.isAfter(res.startTime)) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Genera divisores de slots para ayudar visualmente
    final totalMinutes = totalWidth / widthPerMinute;
    final slotDividers = <Widget>[];

    for (var i = 0; i < totalMinutes; i += slotDurationMinutes) {
      final left = i * widthPerMinute;
      slotDividers.add(
        Positioned(
          left: left,
          top: 0,
          bottom: 0,
          child: Container(
            width: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      );
    }

    // Genera slots "Disponible" para los horarios vacíos
    final availableSlots = <Widget>[];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Usar horarios del club si están disponibles
    if (clubSchedules.isNotEmpty) {
      for (final timeStr in clubSchedules) {
        final parts = timeStr.split(':');
        if (parts.length != 2) continue;
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour == null || minute == null) continue;

        final slotStart = today.add(Duration(hours: hour, minutes: minute));
        final slotEnd = slotStart.add(Duration(minutes: slotDurationMinutes));

        // Verificar que esté dentro del rango del timeline
        if (hour < startHour || hour > endHour) continue;

        // Verificar que no esté ocupado
        if (_isSlotOccupied(slotStart, slotEnd)) continue;

        // Calcular posición
        final startMinutes = hour * 60 + minute;
        final offsetMinutes = startMinutes - (startHour * 60);
        final left = offsetMinutes * widthPerMinute;
        final width = slotDurationMinutes * widthPerMinute;

        availableSlots.add(
          Positioned(
            left: left,
            top: 0,
            bottom: 0,
            child: _AvailableSlotCard(
              width: width,
              slotTime: slotStart,
              onTap:
                  onAvailableSlotTap != null
                      ? () => onAvailableSlotTap!(slotStart)
                      : null,
            ),
          ),
        );
      }
    } else {
      // Si no hay horarios definidos, generar slots cada slotDurationMinutes
      for (
        var minutes = 0;
        minutes < totalMinutes;
        minutes += slotDurationMinutes
      ) {
        final hour = startHour + (minutes ~/ 60);
        final minute = minutes % 60;

        if (hour > endHour) break;

        final slotStart = today.add(Duration(hours: hour, minutes: minute));
        final slotEnd = slotStart.add(Duration(minutes: slotDurationMinutes));

        // Verificar que no esté ocupado
        if (_isSlotOccupied(slotStart, slotEnd)) continue;

        // Calcular posición
        final left = minutes * widthPerMinute;
        final width = slotDurationMinutes * widthPerMinute;

        availableSlots.add(
          Positioned(
            left: left,
            top: 0,
            bottom: 0,
            child: _AvailableSlotCard(
              width: width,
              slotTime: slotStart,
              onTap:
                  onAvailableSlotTap != null
                      ? () => onAvailableSlotTap!(slotStart)
                      : null,
            ),
          ),
        );
      }
    }

    return Container(
      height: height,
      width: totalWidth,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Divisores de slots
          ...slotDividers,

          // Slots disponibles (detrás de las reservas)
          ...availableSlots,

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

/// Card para un slot disponible
class _AvailableSlotCard extends StatelessWidget {
  const _AvailableSlotCard({
    required this.width,
    required this.slotTime,
    this.onTap,
  });

  final double width;
  final DateTime slotTime;
  final VoidCallback? onTap;

  String get _timeLabel {
    final hour = slotTime.hour.toString().padLeft(2, '0');
    final minute = slotTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 1),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
        ),
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Disponible',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
            if (width > 80) ...[
              const SizedBox(height: 2),
              Text(
                _timeLabel,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  fontSize: 9,
                ),
              ),
            ],
            if (onTap != null && width > 100) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Reservar',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
