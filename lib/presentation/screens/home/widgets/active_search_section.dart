import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/enums/locality.dart';
import 'package:padel_punilla/domain/models/club_model.dart';
import 'package:padel_punilla/domain/models/reservation_model.dart';
import 'package:padel_punilla/presentation/screens/home/widgets/active_search_card.dart';
import 'package:padel_punilla/presentation/widgets/skeleton_loader.dart';

/// Sección que muestra las búsquedas activas (2v2 y Falta 1).
///
/// Organiza las reservas en dos grupos:
/// - "Tu localidad": reservas del club de la localidad del usuario
/// - "Localidades cercanas": reservas de clubes en localidades próximas
class ActiveSearchSection extends StatelessWidget {
  const ActiveSearchSection({
    required this.localReservations,
    required this.nearbyReservations,
    required this.clubs,
    required this.userLocality,
    required this.onReservationTap,
    this.isLoading = false,
    super.key,
  });

  /// Reservas de la localidad del usuario
  final List<ReservationModel> localReservations;

  /// Reservas de localidades cercanas
  final List<ReservationModel> nearbyReservations;

  /// Mapa de clubId -> ClubModel para mostrar info
  final Map<String, ClubModel> clubs;

  /// Localidad del usuario actual
  final Locality? userLocality;

  /// Callback cuando se toca una reserva
  final void Function(ReservationModel reservation) onReservationTap;

  /// Si está cargando, muestra skeleton
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Si está cargando, mostrar skeleton
    if (isLoading) {
      return _buildSkeleton(context);
    }

    // Si no hay reservas en ningún grupo
    if (localReservations.isEmpty && nearbyReservations.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la sección
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                Icons.sports_tennis_rounded,
                color: colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Partidos Disponibles',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Sección "Tu localidad"
        if (localReservations.isNotEmpty) ...[
          _SectionHeader(
            title: 'En ${userLocality?.displayName ?? 'tu localidad'}',
            icon: Icons.location_on_rounded,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 8),
          _buildReservationsList(localReservations),
          const SizedBox(height: 24),
        ],

        // Sección "Localidades cercanas"
        if (nearbyReservations.isNotEmpty) ...[
          _SectionHeader(
            title: 'Localidades cercanas',
            icon: Icons.near_me_rounded,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 8),
          _buildReservationsList(nearbyReservations),
        ],
      ],
    );
  }

  /// Construye la lista horizontal de reservas
  Widget _buildReservationsList(List<ReservationModel> reservations) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: reservations.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final reservation = reservations[index];
          final club = clubs[reservation.clubId];

          // Si no encontramos el club, no mostrar la card
          if (club == null) return const SizedBox.shrink();

          return SizedBox(
            width: 280,
            child: ActiveSearchCard(
              reservation: reservation,
              club: club,
              onTap: () => onReservationTap(reservation),
            ),
          );
        },
      ),
    );
  }

  /// Estado vacío cuando no hay búsquedas activas
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.sports_tennis_outlined,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'No hay partidos disponibles',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Cuando alguien busque jugadores en tu zona, aparecerá aquí',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Skeleton loader mientras carga
  Widget _buildSkeleton(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título skeleton
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SkeletonLoader(width: 200, height: 24),
        ),
        const SizedBox(height: 16),

        // Subtitle skeleton
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SkeletonLoader(width: 150, height: 16),
        ),
        const SizedBox(height: 8),

        // Cards skeleton
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder:
                (context, index) => const SkeletonLoader(
                  width: 280,
                  height: 150,
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Widget para el encabezado de sección
// -----------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.colorScheme,
  });

  final String title;
  final IconData icon;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.secondary),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
