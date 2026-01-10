import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/enums/reservation_enums.dart';
import 'package:padel_punilla/domain/models/reservation_model.dart';
import 'package:padel_punilla/presentation/screens/my_reservations/widgets/reservation_status_badge.dart';

/// Card que muestra la información de una reserva individual.
///
/// Incluye:
/// - Fecha y hora de la reserva
/// - Nombre del club/cancha (si está disponible)
/// - Tipo de reserva
/// - Badge de estado con color distintivo
/// - Indicador de pago (si aplica)
class ReservationCard extends StatelessWidget {
  /// La reserva a mostrar
  final ReservationModel reservation;

  /// Nombre del club (opcional)
  final String? clubName;

  /// Nombre de la cancha (opcional)
  final String? courtName;

  /// Callback al hacer tap en la card
  final VoidCallback? onTap;

  const ReservationCard({
    super.key,
    required this.reservation,
    this.clubName,
    this.courtName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Determinar si la reserva está inactiva (cancelada o rechazada)
    final isInactive =
        reservation.status == ReservationStatus.cancelled ||
        reservation.status == ReservationStatus.rejected;

    return Card(
      elevation: isInactive ? 0 : 2,
      color:
          isInactive
              ? colorScheme.surfaceContainerLow.withValues(alpha: 0.5)
              : colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color:
              isInactive
                  ? colorScheme.outlineVariant.withValues(alpha: 0.3)
                  : colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila superior: Fecha/Hora y Badge de estado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fecha y hora
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fecha
                        Text(
                          _formatDate(reservation.reservedDate),
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color:
                                isInactive
                                    ? colorScheme.outline
                                    : colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Hora
                        Text(
                          _formatTimeRange(),
                          style: textTheme.bodyLarge?.copyWith(
                            color:
                                isInactive
                                    ? colorScheme.outline
                                    : colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Badge de estado
                  ReservationStatusBadge(status: reservation.status),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Información del club y cancha
              Row(
                children: [
                  // Ícono de ubicación
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.sports_tennis_rounded,
                      size: 20,
                      color:
                          isInactive
                              ? colorScheme.outline
                              : colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Nombres
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (clubName != null)
                          Text(
                            clubName!,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color:
                                  isInactive
                                      ? colorScheme.outline
                                      : colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (courtName != null)
                          Text(
                            courtName!,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.outline,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),

                  // Tipo de reserva chip
                  _buildTypeChip(context, isInactive),
                ],
              ),

              // Indicador de pago (solo si hay info relevante)
              if (reservation.status == ReservationStatus.approved) ...[
                const SizedBox(height: 12),
                _buildPaymentIndicator(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Formatea la fecha para mostrar
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reservationDay = DateTime(date.year, date.month, date.day);
    final difference = reservationDay.difference(today).inDays;

    if (difference == 0) {
      return 'Hoy';
    } else if (difference == 1) {
      return 'Mañana';
    } else if (difference == -1) {
      return 'Ayer';
    } else if (difference > 1 && difference <= 7) {
      return _getDayName(date.weekday);
    } else {
      // Formato: "Lun, 16 Dic"
      return '${_getShortDayName(date.weekday)}, ${date.day} ${_getMonthName(date.month)}';
    }
  }

  /// Formatea el rango de horas
  String _formatTimeRange() {
    final start = reservation.startTime;
    final end = reservation.endTime;

    final startStr =
        '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final endStr =
        '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';

    return '$startStr - $endStr';
  }

  /// Construye el chip de tipo de reserva
  Widget _buildTypeChip(BuildContext context, bool isInactive) {
    final colorScheme = Theme.of(context).colorScheme;

    // Color según tipo
    Color chipColor;
    switch (reservation.type) {
      case ReservationType.match2vs2:
        chipColor = colorScheme.tertiary;
      case ReservationType.falta1:
        chipColor = colorScheme.secondary;
      case ReservationType.normal:
        chipColor = colorScheme.primary;
      case ReservationType.maintenance:
        chipColor = colorScheme.outline;
      case ReservationType.coaching:
        chipColor = colorScheme.tertiary;
    }

    if (isInactive) {
      chipColor = colorScheme.outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        reservation.type.displayName,
        style: TextStyle(
          color: chipColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Construye el indicador de estado de pago
  Widget _buildPaymentIndicator(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color indicatorColor;
    IconData icon;
    String label;

    switch (reservation.paymentStatus) {
      case PaymentStatus.paid:
        indicatorColor = colorScheme.secondary;
        icon = Icons.check_circle_outline_rounded;
        label = 'Pagado';
      case PaymentStatus.partial:
        indicatorColor = colorScheme.tertiary;
        icon = Icons.pie_chart_outline_rounded;
        label = 'Pago parcial';
      case PaymentStatus.pending:
        indicatorColor = colorScheme.outline;
        icon = Icons.schedule_rounded;
        label = 'Pago pendiente';
      case PaymentStatus.refunded:
        indicatorColor = colorScheme.error;
        icon = Icons.undo_rounded;
        label = 'Reembolsado';
    }

    return Row(
      children: [
        Icon(icon, size: 16, color: indicatorColor),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: indicatorColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (reservation.paymentStatus == PaymentStatus.partial) ...[
          Text(
            ' (\$${reservation.paidAmount.toStringAsFixed(0)} / \$${reservation.price.toStringAsFixed(0)})',
            style: TextStyle(color: colorScheme.outline, fontSize: 12),
          ),
        ],
      ],
    );
  }

  // Helpers para nombres de días y meses
  String _getDayName(int weekday) {
    const days = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    return days[weekday - 1];
  }

  String _getShortDayName(int weekday) {
    const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
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
    return months[month - 1];
  }
}
