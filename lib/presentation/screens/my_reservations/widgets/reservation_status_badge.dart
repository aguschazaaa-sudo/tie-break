import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/enums/reservation_enums.dart';

/// Badge que muestra el estado de una reserva con color y icono distintivo.
///
/// Utiliza la paleta de colores del tema:
/// - Pendiente: tertiary (púrpura) - esperando aprobación
/// - Aprobada: secondary (verde) - confirmada
/// - Rechazada: error (rojo) - no aceptada
/// - Cancelada: outline (gris) - inactiva
class ReservationStatusBadge extends StatelessWidget {
  const ReservationStatusBadge({
    required this.status,
    super.key,
    this.size = 'medium',
  });

  /// Estado de la reserva a mostrar
  final ReservationStatus status;

  /// Tamaño del badge: 'small' o 'medium'
  final String size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = _getStatusColors(colorScheme);

    // Ajustar padding y tamaño según el size
    final isSmall = size == 'small';
    final horizontalPadding = isSmall ? 6.0 : 10.0;
    final verticalPadding = isSmall ? 3.0 : 5.0;
    final iconSize = isSmall ? 12.0 : 14.0;
    final fontSize = isSmall ? 10.0 : 11.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.foreground.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(colors.icon, size: iconSize, color: colors.foreground),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              color: colors.foreground,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Obtiene los colores e icono correspondientes al estado
  _StatusColors _getStatusColors(ColorScheme colorScheme) {
    switch (status) {
      case ReservationStatus.pending:
        // Púrpura (tertiary) - esperando aprobación
        return _StatusColors(
          background: colorScheme.tertiaryContainer,
          foreground: colorScheme.onTertiaryContainer,
          icon: Icons.hourglass_empty_rounded,
        );

      case ReservationStatus.approved:
        // Verde (secondary) - confirmada
        return _StatusColors(
          background: colorScheme.secondaryContainer,
          foreground: colorScheme.onSecondaryContainer,
          icon: Icons.check_circle_rounded,
        );

      case ReservationStatus.rejected:
        // Rojo (error) - no aceptada
        return _StatusColors(
          background: colorScheme.errorContainer,
          foreground: colorScheme.onErrorContainer,
          icon: Icons.cancel_rounded,
        );

      case ReservationStatus.cancelled:
        // Gris (outline) - inactiva
        return _StatusColors(
          background: colorScheme.surfaceContainerHighest,
          foreground: colorScheme.outline,
          icon: Icons.block_rounded,
        );
    }
  }
}

/// Clase auxiliar para agrupar colores e icono de un estado
class _StatusColors {
  const _StatusColors({
    required this.background,
    required this.foreground,
    required this.icon,
  });
  final Color background;
  final Color foreground;
  final IconData icon;
}
