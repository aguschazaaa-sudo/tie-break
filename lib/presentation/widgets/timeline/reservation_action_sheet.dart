import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/enums/reservation_enums.dart';
import 'package:padel_punilla/domain/models/reservation_model.dart';

/// Bottom sheet para mostrar acciones disponibles sobre una reserva.
///
/// Las acciones mostradas dependen del contexto:
/// - Status pendiente: Aprobar, Rechazar
/// - Status aprobada: Cancelar
/// - Tipo 2vs2 y completo: Definir ganador
/// - Siempre: Gestionar pago
class ReservationActionSheet extends StatelessWidget {
  /// La reserva sobre la que se realizarán acciones
  final ReservationModel reservation;

  /// Nombre del usuario que hizo la reserva (opcional)
  final String? userName;

  /// Nombre de la cancha (opcional)
  final String? courtName;

  /// Callback cuando se aprueba la reserva
  final VoidCallback? onApprove;

  /// Callback cuando se rechaza la reserva
  final VoidCallback? onReject;

  /// Callback cuando se cancela la reserva
  final VoidCallback? onCancel;

  /// Callback cuando se define el ganador (recibe 1 o 2 para team1 o team2)
  final void Function(int winningTeam)? onSetWinner;

  /// Callback para gestionar el pago
  final VoidCallback? onManagePayment;

  const ReservationActionSheet({
    super.key,
    required this.reservation,
    this.userName,
    this.courtName,
    this.onApprove,
    this.onReject,
    this.onCancel,
    this.onSetWinner,
    this.onManagePayment,
  });

  /// Muestra el bottom sheet. Método estático de conveniencia.
  static Future<void> show(
    BuildContext context, {
    required ReservationModel reservation,
    String? userName,
    String? courtName,
    VoidCallback? onApprove,
    VoidCallback? onReject,
    VoidCallback? onCancel,
    void Function(int winningTeam)? onSetWinner,
    VoidCallback? onManagePayment,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => ReservationActionSheet(
            reservation: reservation,
            userName: userName,
            courtName: courtName,
            onApprove: onApprove,
            onReject: onReject,
            onCancel: onCancel,
            onSetWinner: onSetWinner,
            onManagePayment: onManagePayment,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.outline.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header con información de la reserva
            _buildHeader(context, colorScheme, textTheme),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // Lista de acciones
            ..._buildActions(context, colorScheme),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Construye el header con información de la reserva
  Widget _buildHeader(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    // Formatea la hora de la reserva
    final timeString =
        '${reservation.startTime.hour.toString().padLeft(2, '0')}:'
        '${reservation.startTime.minute.toString().padLeft(2, '0')}';

    final endTime = reservation.endTime;
    final endTimeString =
        '${endTime.hour.toString().padLeft(2, '0')}:'
        '${endTime.minute.toString().padLeft(2, '0')}';

    return Row(
      children: [
        // Icono con color según tipo
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getTypeColor(colorScheme),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_getTypeIcon(), color: _getOnTypeColor(colorScheme)),
        ),
        const SizedBox(width: 12),

        // Info de la reserva
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Usuario y tipo
              Row(
                children: [
                  if (userName != null) ...[
                    Text(
                      userName!,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getTypeColor(colorScheme),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      reservation.type.displayName,
                      style: TextStyle(
                        color: _getOnTypeColor(colorScheme),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Hora y cancha
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: colorScheme.outline),
                  const SizedBox(width: 4),
                  Text(
                    '$timeString - $endTimeString',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                  if (courtName != null) ...[
                    const SizedBox(width: 12),
                    Icon(
                      Icons.sports_tennis,
                      size: 14,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      courtName!,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        // Status badge
        _buildStatusBadge(colorScheme),
      ],
    );
  }

  /// Construye el badge de status
  Widget _buildStatusBadge(ColorScheme colorScheme) {
    Color bgColor;
    Color fgColor;
    IconData icon;

    switch (reservation.status) {
      case ReservationStatus.pending:
        bgColor = Colors.amber.shade100;
        fgColor = Colors.amber.shade800;
        icon = Icons.hourglass_empty;
      case ReservationStatus.approved:
        bgColor = Colors.green.shade100;
        fgColor = Colors.green.shade800;
        icon = Icons.check_circle;
      case ReservationStatus.rejected:
        bgColor = Colors.red.shade100;
        fgColor = Colors.red.shade800;
        icon = Icons.cancel;
      case ReservationStatus.cancelled:
        bgColor = Colors.grey.shade200;
        fgColor = Colors.grey.shade600;
        icon = Icons.block;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fgColor),
          const SizedBox(width: 4),
          Text(
            reservation.status.displayName,
            style: TextStyle(
              color: fgColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye la lista de acciones disponibles
  List<Widget> _buildActions(BuildContext context, ColorScheme colorScheme) {
    final actions = <Widget>[];

    // Acciones según status
    if (reservation.status == ReservationStatus.pending) {
      // Pendiente: Aprobar / Rechazar
      if (onApprove != null) {
        actions.add(
          _buildActionTile(
            context: context,
            icon: Icons.check_circle,
            iconColor: Colors.green,
            title: 'Aprobar Reserva',
            subtitle: 'Confirmar esta reserva',
            onTap: () {
              Navigator.pop(context);
              onApprove!();
            },
          ),
        );
      }
      if (onReject != null) {
        actions.add(
          _buildActionTile(
            context: context,
            icon: Icons.cancel,
            iconColor: Colors.red,
            title: 'Rechazar Reserva',
            subtitle: 'Denegar esta reserva',
            onTap: () {
              Navigator.pop(context);
              onReject!();
            },
          ),
        );
      }
    } else if (reservation.status == ReservationStatus.approved) {
      // Aprobada: Cancelar
      if (onCancel != null) {
        actions.add(
          _buildActionTile(
            context: context,
            icon: Icons.block,
            iconColor: Colors.orange,
            title: 'Cancelar Reserva',
            subtitle: 'Cancelar esta reserva aprobada',
            onTap: () {
              Navigator.pop(context);
              _confirmCancel(context);
            },
          ),
        );
      }
    }

    // Definir ganador (solo para 2vs2 completos aprobados)
    if (reservation.type == ReservationType.match2vs2 &&
        reservation.status == ReservationStatus.approved &&
        reservation.team2Ids.isNotEmpty &&
        onSetWinner != null) {
      actions.add(
        _buildActionTile(
          context: context,
          icon: Icons.emoji_events,
          iconColor: Colors.amber,
          title: 'Definir Ganador',
          subtitle: 'Registrar el resultado del partido',
          onTap: () {
            Navigator.pop(context);
            _showWinnerDialog(context);
          },
        ),
      );
    }

    // Gestionar pago (siempre disponible si hay callback)
    if (onManagePayment != null) {
      actions.add(
        _buildActionTile(
          context: context,
          icon: Icons.payments,
          iconColor: colorScheme.primary,
          title: 'Gestionar Pago',
          subtitle: _getPaymentSubtitle(),
          onTap: () {
            Navigator.pop(context);
            onManagePayment!();
          },
        ),
      );
    }

    if (actions.isEmpty) {
      actions.add(
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No hay acciones disponibles',
            style: TextStyle(color: colorScheme.outline),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return actions;
  }

  /// Construye un tile de acción
  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  /// Obtiene el subtítulo para la acción de pago
  String _getPaymentSubtitle() {
    final paid = reservation.paidAmount;
    final total = reservation.price;
    final remaining = reservation.remainingAmount;

    if (reservation.paymentStatus == PaymentStatus.paid) {
      return 'Pagado: \$${total.toStringAsFixed(0)}';
    } else if (paid > 0) {
      return 'Pagado: \$${paid.toStringAsFixed(0)} / \$${total.toStringAsFixed(0)}';
    } else {
      return 'Pendiente: \$${remaining.toStringAsFixed(0)}';
    }
  }

  /// Muestra diálogo de confirmación para cancelar
  Future<void> _confirmCancel(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar Cancelación'),
            content: const Text(
              '¿Estás seguro de que deseas cancelar esta reserva? Esta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No, mantener'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Sí, cancelar'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      onCancel!();
    }
  }

  /// Muestra diálogo para seleccionar ganador
  Future<void> _showWinnerDialog(BuildContext context) async {
    final winner = await showDialog<int>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Definir Ganador'),
            content: const Text('¿Qué equipo ganó el partido?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 1),
                child: const Text('Equipo 1'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, 2),
                child: const Text('Equipo 2'),
              ),
            ],
          ),
    );

    if (winner != null) {
      onSetWinner!(winner);
    }
  }

  // Helpers para colores según tipo
  Color _getTypeColor(ColorScheme colorScheme) {
    switch (reservation.type) {
      case ReservationType.normal:
        return colorScheme.primaryContainer;
      case ReservationType.match2vs2:
        return colorScheme.tertiaryContainer;
      case ReservationType.falta1:
        return colorScheme.secondaryContainer;
    }
  }

  Color _getOnTypeColor(ColorScheme colorScheme) {
    switch (reservation.type) {
      case ReservationType.normal:
        return colorScheme.onPrimaryContainer;
      case ReservationType.match2vs2:
        return colorScheme.onTertiaryContainer;
      case ReservationType.falta1:
        return colorScheme.onSecondaryContainer;
    }
  }

  IconData _getTypeIcon() {
    switch (reservation.type) {
      case ReservationType.normal:
        return Icons.person;
      case ReservationType.match2vs2:
        return Icons.groups;
      case ReservationType.falta1:
        return Icons.person_add;
    }
  }
}
