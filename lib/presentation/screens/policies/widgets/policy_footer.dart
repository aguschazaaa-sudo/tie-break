import 'package:flutter/material.dart';

/// Widget de pie de página para pantallas de políticas.
/// Muestra información de contacto y última actualización.
class PolicyFooter extends StatelessWidget {
  const PolicyFooter({required this.lastUpdated, super.key, this.contactEmail});

  /// Fecha de última actualización
  final String lastUpdated;

  /// Email de contacto (opcional)
  final String? contactEmail;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            colorScheme.surfaceContainerHigh.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          // Ícono decorativo
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.tertiaryContainer.withValues(alpha: 0.5),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: colorScheme.tertiary,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),

          // Texto de última actualización
          Text(
            'Última actualización',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            lastUpdated,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),

          // Información de contacto si existe
          if (contactEmail != null) ...[
            const SizedBox(height: 16),
            Divider(
              color: colorScheme.outline.withValues(alpha: 0.1),
              height: 1,
            ),
            const SizedBox(height: 16),
            Text(
              '¿Preguntas? Contáctanos',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  contactEmail!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
