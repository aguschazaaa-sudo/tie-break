import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/models/club_model.dart';
import 'package:padel_punilla/presentation/widgets/surface_card.dart';

/// Card compacta para mostrar un club en los resultados de búsqueda.
///
/// Incluye:
/// - Logo del club (o placeholder)
/// - Nombre y localidad
/// - Botón de favorito (corazón)
/// - Tap para navegar al detalle
class ClubResultCard extends StatelessWidget {
  const ClubResultCard({
    required this.club,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
    super.key,
  });

  /// Club a mostrar
  final ClubModel club;

  /// Si el club está en favoritos
  final bool isFavorite;

  /// Callback al tocar la card (navegar a detalle)
  final VoidCallback onTap;

  /// Callback al togglear favorito
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          // Logo del club o placeholder
          _ClubLogo(logoUrl: club.logoUrl, colorScheme: colorScheme),

          const SizedBox(width: 12),

          // Nombre y localidad
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  club.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  club.locality.displayName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Botón de favorito
          _FavoriteButton(
            isFavorite: isFavorite,
            onTap: onFavoriteToggle,
            colorScheme: colorScheme,
          ),

          const SizedBox(width: 4),

          // Flecha
          Icon(
            Icons.chevron_right_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Widgets privados
// -----------------------------------------------------------------------------

/// Logo del club con placeholder
class _ClubLogo extends StatelessWidget {
  const _ClubLogo({required this.logoUrl, required this.colorScheme});

  final String? logoUrl;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child:
          logoUrl != null && logoUrl!.isNotEmpty
              ? ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Image.network(
                  logoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => _buildPlaceholder(),
                ),
              )
              : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.sports_tennis_rounded,
        color: colorScheme.onSurfaceVariant,
        size: 24,
      ),
    );
  }
}

/// Botón de favorito animado
class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({
    required this.isFavorite,
    required this.onTap,
    required this.colorScheme,
  });

  final bool isFavorite;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder:
            (child, animation) =>
                ScaleTransition(scale: animation, child: child),
        child: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          key: ValueKey(isFavorite),
          color:
              isFavorite ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
      ),
      tooltip: isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
    );
  }
}
