import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/enums/reservation_enums.dart';
import 'package:padel_punilla/domain/models/reservation_model.dart';
import 'package:padel_punilla/presentation/widgets/timeline/timeline_config.dart';

/// Card que representa visualmente una reserva en el timeline.
///
/// Estados visuales:
/// - Pendiente: borde warning naranja + icono warning
/// - Aprobada: icono verde de check
/// - Incompleta (2vs2/falta1 sin completar): tenue/transparente
class TimelineReservationCard extends StatelessWidget {
  /// La reserva a mostrar
  final ReservationModel reservation;

  /// Píxeles por minuto para calcular el ancho
  final double widthPerMinute;

  /// Callback al hacer tap en la card
  final VoidCallback? onTap;

  /// Nombre del usuario que hizo la reserva (opcional)
  final String? userName;

  /// Configuración de visualización del timeline
  final TimelineConfig config;

  const TimelineReservationCard({
    super.key,
    required this.reservation,
    required this.widthPerMinute,
    this.onTap,
    this.userName,
    this.config = TimelineConfig.userView,
  });

  /// El color base según el tipo de reserva
  Color _getTypeColor(BuildContext context) {
    switch (reservation.type) {
      case ReservationType.normal:
        return Theme.of(context).colorScheme.primaryContainer;
      case ReservationType.match2vs2:
        return Theme.of(context).colorScheme.tertiaryContainer;
      case ReservationType.falta1:
        return Theme.of(context).colorScheme.secondaryContainer;
    }
  }

  /// El color del texto según el tipo de reserva
  Color _getOnTypeColor(BuildContext context) {
    switch (reservation.type) {
      case ReservationType.normal:
        return Theme.of(context).colorScheme.onPrimaryContainer;
      case ReservationType.match2vs2:
        return Theme.of(context).colorScheme.onTertiaryContainer;
      case ReservationType.falta1:
        return Theme.of(context).colorScheme.onSecondaryContainer;
    }
  }

  /// Determina si la reserva está "incompleta"
  /// (2vs2 sin equipo 2, o falta1 sin participante adicional)
  bool get _isIncomplete {
    if (reservation.type == ReservationType.match2vs2) {
      return reservation.team2Ids.isEmpty;
    }
    if (reservation.type == ReservationType.falta1) {
      // Falta1 necesita al menos 1 participante adicional para completarse
      return reservation.participantIds.isEmpty;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final width = reservation.durationMinutes * widthPerMinute;
    final baseColor = _getTypeColor(context);
    final textColor = _getOnTypeColor(context);

    final isPending = reservation.status == ReservationStatus.pending;
    final isIncomplete = _isIncomplete;

    // Determinar opacidad y estilo según estado
    // Incompletas -> muy tenue (0.4)
    // Pendientes -> semi-transparente (0.7)
    // Aprobadas -> sólido (1.0)
    double opacity = 1.0;
    if (isIncomplete) {
      opacity = 0.4;
    } else if (isPending) {
      opacity = 0.7;
    }

    // Border para pendientes (warning naranja)
    Border? border;
    if (isPending && !isIncomplete) {
      border = Border.all(color: Colors.orange.shade700, width: 2);
    } else if (isIncomplete) {
      border = Border.all(
        color: textColor.withValues(alpha: 0.3),
        width: 1,
        style: BorderStyle.solid,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 1),
        decoration: BoxDecoration(
          color: baseColor.withValues(alpha: opacity),
          borderRadius: BorderRadius.circular(8),
          border: border,
        ),
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Fila principal: título + indicadores de estado
            Row(
              children: [
                // Icono de solo mujeres si aplica
                if (reservation.womenOnly) ...[
                  Icon(Icons.female, size: 12, color: Colors.pink.shade300),
                  const SizedBox(width: 2),
                ],
                Expanded(
                  child: Text(
                    _getReservationTitle(),
                    style: TextStyle(
                      color: textColor.withValues(
                        alpha: isIncomplete ? 0.7 : 1.0,
                      ),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Indicador de estado
                _buildStatusIcon(textColor),
              ],
            ),

            // Info adicional si hay espacio suficiente
            if (width > 100) ...[
              const SizedBox(height: 2),
              Text(
                config.showReservationType ? reservation.type.displayName : '',
                style: TextStyle(
                  color: textColor.withValues(alpha: isIncomplete ? 0.5 : 0.8),
                  fontSize: 9,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Indicador de pago si está configurado y hay espacio
            if (config.showPaymentStatus && width > 140) ...[
              const SizedBox(height: 2),
              _buildPaymentIndicator(textColor),
            ],
          ],
        ),
      ),
    );
  }

  /// Construye el icono de estado según la reserva
  Widget _buildStatusIcon(Color textColor) {
    final isPending = reservation.status == ReservationStatus.pending;
    final isApproved = reservation.status == ReservationStatus.approved;
    final isIncomplete = _isIncomplete;

    if (isIncomplete) {
      // Incompleta: icono de búsqueda/espera
      return Icon(
        Icons.hourglass_empty,
        size: 12,
        color: textColor.withValues(alpha: 0.5),
      );
    } else if (isPending) {
      // Pendiente de aprobación: warning naranja
      return Icon(
        Icons.warning_amber_rounded,
        size: 14,
        color: Colors.orange.shade700,
      );
    } else if (isApproved) {
      // Aprobada: check verde
      return Icon(Icons.check_circle, size: 14, color: Colors.green.shade600);
    }

    return const SizedBox.shrink();
  }

  /// Obtiene el título a mostrar en la card
  String _getReservationTitle() {
    // Si tenemos nombre de usuario y está configurado para mostrarlo
    if (config.showUserName && userName != null && userName!.isNotEmpty) {
      return userName!;
    }

    // Si está incompleta, mostrar que busca jugadores
    if (_isIncomplete) {
      return 'Buscando...';
    }

    return 'Reservado';
  }

  /// Construye un indicador visual del estado de pago
  Widget _buildPaymentIndicator(Color color) {
    IconData icon;
    String text;

    switch (reservation.paymentStatus) {
      case PaymentStatus.paid:
        icon = Icons.check_circle;
        text = 'Pagado';
      case PaymentStatus.partial:
        icon = Icons.pie_chart;
        text = 'Parcial';
      case PaymentStatus.pending:
        icon = Icons.schedule;
        text = 'Pend.';
      case PaymentStatus.refunded:
        icon = Icons.replay;
        text = 'Reemb.';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: color.withValues(alpha: 0.8)),
        const SizedBox(width: 2),
        Text(
          text,
          style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 9),
        ),
      ],
    );
  }
}
