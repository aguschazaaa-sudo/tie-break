import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/models/reservation_model.dart';
import 'package:padel_punilla/presentation/screens/my_reservations/widgets/reservation_card.dart';

/// Widget que muestra la lista de reservas agrupadas por categoría temporal.
///
/// Agrupa las reservas en:
/// - Hoy
/// - Mañana
/// - Próximas (siguientes 7 días)
/// - Más adelante
/// - Pasadas
class ReservationListContent extends StatelessWidget {
  /// Lista de reservas a mostrar
  final List<ReservationModel> reservations;

  /// Mapa de clubId -> nombre del club
  final Map<String, String> clubNames;

  /// Mapa de courtId -> nombre de la cancha
  final Map<String, String> courtNames;

  /// Callback al hacer tap en una reserva
  final void Function(ReservationModel reservation)? onReservationTap;

  const ReservationListContent({
    super.key,
    required this.reservations,
    this.clubNames = const {},
    this.courtNames = const {},
    this.onReservationTap,
  });

  @override
  Widget build(BuildContext context) {
    // Agrupar reservas por categoría temporal
    final groups = _groupReservations();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return _buildGroup(context, group);
      },
    );
  }

  /// Agrupa las reservas por categoría temporal
  List<_ReservationGroup> _groupReservations() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final nextWeek = today.add(const Duration(days: 7));

    // Listas para cada categoría
    final todayList = <ReservationModel>[];
    final tomorrowList = <ReservationModel>[];
    final upcomingList = <ReservationModel>[];
    final laterList = <ReservationModel>[];
    final pastList = <ReservationModel>[];

    for (final reservation in reservations) {
      final date = DateTime(
        reservation.reservedDate.year,
        reservation.reservedDate.month,
        reservation.reservedDate.day,
      );

      if (date.isBefore(today)) {
        pastList.add(reservation);
      } else if (date.isAtSameMomentAs(today)) {
        todayList.add(reservation);
      } else if (date.isAtSameMomentAs(tomorrow)) {
        tomorrowList.add(reservation);
      } else if (date.isBefore(nextWeek)) {
        upcomingList.add(reservation);
      } else {
        laterList.add(reservation);
      }
    }

    // Ordenar cada lista por hora
    _sortByTime(todayList);
    _sortByTime(tomorrowList);
    _sortByTime(upcomingList);
    _sortByTime(laterList);
    _sortByTimeDescending(pastList);

    // Construir grupos no vacíos
    final groups = <_ReservationGroup>[];

    if (todayList.isNotEmpty) {
      groups.add(
        _ReservationGroup(
          title: 'Hoy',
          icon: Icons.today_rounded,
          reservations: todayList,
          isHighlighted: true,
        ),
      );
    }

    if (tomorrowList.isNotEmpty) {
      groups.add(
        _ReservationGroup(
          title: 'Mañana',
          icon: Icons.wb_sunny_outlined,
          reservations: tomorrowList,
        ),
      );
    }

    if (upcomingList.isNotEmpty) {
      groups.add(
        _ReservationGroup(
          title: 'Próximos días',
          icon: Icons.date_range_rounded,
          reservations: upcomingList,
        ),
      );
    }

    if (laterList.isNotEmpty) {
      groups.add(
        _ReservationGroup(
          title: 'Más adelante',
          icon: Icons.event_rounded,
          reservations: laterList,
        ),
      );
    }

    if (pastList.isNotEmpty) {
      groups.add(
        _ReservationGroup(
          title: 'Pasadas',
          icon: Icons.history_rounded,
          reservations: pastList,
          isPast: true,
        ),
      );
    }

    return groups;
  }

  /// Ordena por hora ascendente
  void _sortByTime(List<ReservationModel> list) {
    list.sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  /// Ordena por hora descendente (más recientes primero)
  void _sortByTimeDescending(List<ReservationModel> list) {
    list.sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  /// Construye un grupo de reservas con su header
  Widget _buildGroup(BuildContext context, _ReservationGroup group) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header del grupo
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Row(
            children: [
              // Ícono del grupo
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color:
                      group.isHighlighted
                          ? colorScheme.primaryContainer
                          : group.isPast
                          ? colorScheme.surfaceContainerHighest
                          : colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  group.icon,
                  size: 18,
                  color:
                      group.isHighlighted
                          ? colorScheme.primary
                          : group.isPast
                          ? colorScheme.outline
                          : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 10),

              // Título del grupo
              Text(
                group.title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color:
                      group.isPast
                          ? colorScheme.outline
                          : colorScheme.onSurface,
                ),
              ),

              const SizedBox(width: 8),

              // Contador
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${group.reservations.length}',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Lista de cards
        ...group.reservations.map((reservation) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ReservationCard(
              reservation: reservation,
              clubName: clubNames[reservation.clubId],
              courtName: courtNames[reservation.courtId],
              onTap:
                  onReservationTap != null
                      ? () => onReservationTap!(reservation)
                      : null,
            ),
          );
        }),
      ],
    );
  }
}

/// Clase auxiliar para representar un grupo de reservas
class _ReservationGroup {
  final String title;
  final IconData icon;
  final List<ReservationModel> reservations;
  final bool isHighlighted;
  final bool isPast;

  const _ReservationGroup({
    required this.title,
    required this.icon,
    required this.reservations,
    this.isHighlighted = false,
    this.isPast = false,
  });
}
