import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/models/club_model.dart';
import 'package:padel_punilla/presentation/screens/home/widgets/club_result_card.dart';
import 'package:padel_punilla/presentation/screens/home/widgets/club_search_bar.dart';
import 'package:padel_punilla/presentation/widgets/skeleton_loader.dart';

/// Sección completa de búsqueda de clubes.
///
/// Incluye:
/// - Barra de búsqueda con debounce
/// - Resultados de búsqueda
/// - Estados de carga, vacío y error
class ClubSearchSection extends StatelessWidget {
  const ClubSearchSection({
    required this.searchResults,
    required this.favoriteClubIds,
    required this.onSearch,
    required this.onClubTap,
    required this.onFavoriteToggle,
    this.searchQuery = '',
    this.isSearching = false,
    super.key,
  });

  /// Resultados de la búsqueda actual
  final List<ClubModel> searchResults;

  /// IDs de clubes favoritos del usuario
  final Set<String> favoriteClubIds;

  /// Callback cuando cambia el texto de búsqueda
  final void Function(String query) onSearch;

  /// Callback cuando se toca un club
  final void Function(ClubModel club) onClubTap;

  /// Callback para agregar/quitar favorito
  final void Function(String clubId) onFavoriteToggle;

  /// Query de búsqueda actual
  final String searchQuery;

  /// Si está ejecutando una búsqueda
  final bool isSearching;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la sección
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: colorScheme.secondary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Buscar Clubes',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Barra de búsqueda
        ClubSearchBar(onSearch: onSearch, initialValue: searchQuery),

        const SizedBox(height: 16),

        // Resultados de búsqueda
        _buildSearchResults(context),
      ],
    );
  }

  /// Construye los resultados de búsqueda según el estado
  Widget _buildSearchResults(BuildContext context) {
    // Si no hay query, mostrar sugerencia
    if (searchQuery.isEmpty) {
      return _buildSuggestion(context);
    }

    // Si está buscando, mostrar skeleton
    if (isSearching) {
      return _buildLoadingSkeleton();
    }

    // Si no hay resultados
    if (searchResults.isEmpty) {
      return _buildNoResults(context);
    }

    // Mostrar resultados
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: searchResults.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final club = searchResults[index];
        final isFavorite = favoriteClubIds.contains(club.id);

        return ClubResultCard(
          club: club,
          isFavorite: isFavorite,
          onTap: () => onClubTap(club),
          onFavoriteToggle: () => onFavoriteToggle(club.id),
        );
      },
    );
  }

  /// Sugerencia cuando no hay búsqueda activa
  Widget _buildSuggestion(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'Escribe el nombre de un club para buscarlo',
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  /// Skeleton mientras busca
  Widget _buildLoadingSkeleton() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 3,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder:
          (context, index) => const SkeletonLoader(
            height: 72,
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
    );
  }

  /// Mensaje de sin resultados
  Widget _buildNoResults(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 40,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'No se encontraron clubes',
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Intenta con otro nombre',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
