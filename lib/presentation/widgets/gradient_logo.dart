import 'package:flutter/material.dart';

/// Widget reutilizable que muestra el logo de Padel Punilla
/// con fondo degradé (primary → tertiary).
///
/// Uso:
/// ```dart
/// GradientLogo(size: 32) // Tamaño del logo
/// GradientLogo.small()   // 24px
/// GradientLogo.medium()  // 32px
/// GradientLogo.large()   // 48px
/// ```
class GradientLogo extends StatelessWidget {
  const GradientLogo({
    super.key,
    this.size = 32,
    this.borderRadius = 8,
    this.padding = 6,
  });

  /// Logo pequeño para espacios reducidos (24px)
  const GradientLogo.small({super.key})
    : size = 24,
      borderRadius = 6,
      padding = 4;

  /// Logo mediano para AppBar y headers (32px)
  const GradientLogo.medium({super.key})
    : size = 32,
      borderRadius = 8,
      padding = 6;

  /// Logo grande para splash y landing (48px)
  const GradientLogo.large({super.key})
    : size = 48,
      borderRadius = 12,
      padding = 8;

  /// Tamaño del logo en píxeles
  final double size;

  /// Radio de las esquinas del contenedor
  final double borderRadius;

  /// Padding interno del contenedor
  final double padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Logo monocromo: negro en dark mode, blanco en light mode
    final logoAsset =
        isDark
            ? 'assets/icons/imagotipo monocromo negro.png'
            : 'assets/icons/imagotipo monocromo blanco.png';

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.tertiary],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Opacity(
        opacity: 0.5,
        child: Image.asset(
          logoAsset,
          height: size,
          width: size,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
