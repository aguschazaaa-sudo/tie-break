import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/models/club_model.dart';
import 'package:padel_punilla/presentation/widgets/skeleton_loader.dart';

/// Sección horizontal de clubes favoritos con acceso rápido.
///
/// Muestra los clubes guardados como favoritos por el usuario
/// en un ListView horizontal para navegación rápida.
class FavoriteClubsSection extends StatelessWidget {
  const FavoriteClubsSection({
    required this.favoriteClubs,
    required this.onClubTap,
    this.isLoading = false,
    super.key,
  });

  /// Lista de clubes favoritos
  final List<ClubModel> favoriteClubs;

  /// Callback cuando se toca un club
  final void Function(ClubModel club) onClubTap;

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

    // Si no hay favoritos, mostrar sugerencia
    if (favoriteClubs.isEmpty) {
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
                Icons.favorite_rounded,
                color: colorScheme.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Tus Clubes Favoritos',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Lista horizontal de clubes
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: favoriteClubs.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final club = favoriteClubs[index];
              return _FavoriteClubChip(
                club: club,
                onTap: () => onClubTap(club),
                colorScheme: colorScheme,
              );
            },
          ),
        ),
      ],
    );
  }

  /// Estado vacío cuando no hay favoritos
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 32,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Guarda tus clubes favoritos!',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Busca un club y toca el corazón para agregarlo a tus favoritos',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
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
          child: SkeletonLoader(width: 180, height: 20),
        ),
        const SizedBox(height: 12),

        // Chips skeleton
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 4,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder:
                (context, index) => const SkeletonLoader(
                  width: 80,
                  height: 100,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Widget para cada club favorito
// -----------------------------------------------------------------------------

/// Chip visual para un club favorito
class _FavoriteClubChip extends StatelessWidget {
  const _FavoriteClubChip({
    required this.club,
    required this.onTap,
    required this.colorScheme,
  });

  final ClubModel club;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo o placeholder
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  club.logoUrl != null && club.logoUrl!.isNotEmpty
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          club.logoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  _buildPlaceholder(),
                        ),
                      )
                      : _buildPlaceholder(),
            ),

            const SizedBox(height: 8),

            // Nombre del club
            Text(
              club.name,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.sports_tennis_rounded,
        color: colorScheme.onSurfaceVariant,
        size: 20,
      ),
    );
  }
}
