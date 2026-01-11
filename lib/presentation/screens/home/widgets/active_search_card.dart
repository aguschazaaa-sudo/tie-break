import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/enums/reservation_enums.dart';
import 'package:padel_punilla/domain/models/club_model.dart';
import 'package:padel_punilla/domain/models/reservation_model.dart';
import 'package:padel_punilla/presentation/widgets/surface_card.dart';

/// Card para mostrar una reserva de tipo 2v2 o Falta 1.
///
/// Muestra información del partido buscado incluyendo:
/// - Tipo de reserva (2vs2 / Falta 1)
/// - Badge "Solo Mujeres" si aplica
/// - Club, fecha y hora
/// - Botón para ver detalle/unirse
class ActiveSearchCard extends StatelessWidget {
  const ActiveSearchCard({
    required this.reservation,
    required this.club,
    required this.onTap,
    super.key,
  });

  /// Reserva a mostrar (debe ser tipo match2vs2 o falta1)
  final ReservationModel reservation;

  /// Club donde se juega el partido
  final ClubModel club;

  /// Callback cuando se toca la card
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      isGlass: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila de badges: tipo de reserva + solo mujeres
          Row(
            children: [
              // Badge del tipo de reserva
              _TypeBadge(type: reservation.type, colorScheme: colorScheme),
              const SizedBox(width: 8),

              // Badge "Solo Mujeres" si aplica
              if (reservation.womenOnly)
                _WomenOnlyBadge(colorScheme: colorScheme),

              const Spacer(),

              // Icono de flecha para indicar acción
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Nombre del club
          Text(
            club.name,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // Localidad del club
          Text(
            club.locality.displayName,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 12),

          // Fecha y hora
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                _formatDate(reservation.startTime),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.access_time_rounded,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                _formatTime(reservation.startTime),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Formatea la fecha en formato legible (ej: "Mié 18 Dic")
  String _formatDate(DateTime date) {
    const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${days[date.weekday - 1]} ${date.day} ${months[date.month - 1]}';
  }

  /// Formatea la hora en formato HH:mm
  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// -----------------------------------------------------------------------------
// Widgets privados para los badges
// -----------------------------------------------------------------------------

/// Badge que muestra el tipo de reserva (2vs2 o Falta 1)
class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type, required this.colorScheme});

  final ReservationType type;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    // Usamos secondary para 2vs2 y tertiary para falta1
    final is2vs2 = type == ReservationType.match2vs2;
    final backgroundColor =
        is2vs2 ? colorScheme.secondaryContainer : colorScheme.tertiaryContainer;
    final foregroundColor =
        is2vs2
            ? colorScheme.onSecondaryContainer
            : colorScheme.onTertiaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        type.displayName,
        style: TextStyle(
          color: foregroundColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Badge que indica "Solo Mujeres"
class _WomenOnlyBadge extends StatelessWidget {
  const _WomenOnlyBadge({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.tertiary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.female_rounded, size: 14, color: colorScheme.onTertiary),
          const SizedBox(width: 4),
          Text(
            'Solo Mujeres',
            style: TextStyle(
              color: colorScheme.onTertiary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
