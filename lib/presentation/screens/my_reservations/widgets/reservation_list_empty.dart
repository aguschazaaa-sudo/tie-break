import 'package:flutter/material.dart';

/// Widget que muestra un estado vacío cuando no hay reservas.
///
/// Incluye un ícono ilustrativo, mensaje descriptivo y un CTA
/// opcional para realizar la primera reserva.
class ReservationListEmpty extends StatelessWidget {
  /// Callback al presionar el botón de acción (opcional)
  final VoidCallback? onActionPressed;

  const ReservationListEmpty({super.key, this.onActionPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícono ilustrativo con fondo decorativo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primaryContainer.withValues(alpha: 0.6),
                    colorScheme.tertiaryContainer.withValues(alpha: 0.4),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_month_outlined,
                size: 56,
                color: colorScheme.primary,
              ),
            ),

            const SizedBox(height: 24),

            // Título
            Text(
              'Sin reservas aún',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Descripción
            Text(
              'Cuando hagas tu primera reserva,\naparecerá aquí para que puedas hacer seguimiento.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.outline,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Botón de acción (opcional)
            if (onActionPressed != null)
              FilledButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.search),
                label: const Text('Buscar canchas'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
