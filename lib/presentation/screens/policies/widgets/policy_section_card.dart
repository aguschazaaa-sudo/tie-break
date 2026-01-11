import 'package:flutter/material.dart';

/// Widget que representa una sección dentro de las políticas.
/// Muestra un número/índice colorido, título destacado y contenido.
class PolicySectionCard extends StatelessWidget {
  const PolicySectionCard({
    required this.sectionNumber,
    required this.title,
    required this.content,
    super.key,
    this.useSecondaryColor = false,
  });

  /// Número o índice de la sección (ej: "1", "2", etc.)
  final String sectionNumber;

  /// Título de la sección
  final String title;

  /// Contenido de texto o widget personalizado
  final Widget content;

  /// Si la sección debe usar el color secundario (para alternar)
  final bool useSecondaryColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Colores según si es primario, secundario o terciario (alternando)
    final accentColor =
        useSecondaryColor ? colorScheme.secondary : colorScheme.primary;
    final containerColor =
        useSecondaryColor
            ? colorScheme.secondaryContainer
            : colorScheme.primaryContainer;
    final onContainerColor =
        useSecondaryColor
            ? colorScheme.onSecondaryContainer
            : colorScheme.onPrimaryContainer;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la sección con número y título
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: containerColor.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Badge numérico con gradiente
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [accentColor, accentColor.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    sectionNumber,
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Título de la sección
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: onContainerColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Contenido de la sección
          Padding(
            padding: const EdgeInsets.all(16),
            child: DefaultTextStyle(
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
              child: content,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para mostrar una lista de puntos con bullets estilizados
class PolicyBulletList extends StatelessWidget {
  const PolicyBulletList({required this.items, super.key, this.bulletColor});

  /// Lista de textos para mostrar como bullets
  final List<String> items;

  /// Color del bullet (por defecto usa el primary)
  final Color? bulletColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = bulletColor ?? colorScheme.tertiary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bullet decorativo con gradiente
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [color, color.withValues(alpha: 0.5)],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Texto del item
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
