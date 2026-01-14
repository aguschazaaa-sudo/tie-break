import 'package:flutter/material.dart';

/// Widget reutilizable que muestra el logo de Padel Punilla
/// con fondo sólido (mismo color que el splash screen #0a1628).
///
/// Uso:
/// ```dart
/// Logo(size: 32) // Tamaño del logo
/// Logo.small()   // 24px
/// Logo.medium()  // 32px
/// Logo.large()   // 48px
/// ```
class Logo extends StatelessWidget {
  const Logo({
    super.key,
    this.size = 32,
    this.borderRadius = 8,
    this.padding = 6,
  });

  /// Logo pequeño para espacios reducidos (24px)
  const Logo.small({super.key}) : size = 24, borderRadius = 6, padding = 4;

  /// Logo mediano para AppBar y headers (32px)
  const Logo.medium({super.key}) : size = 32, borderRadius = 8, padding = 6;

  /// Logo grande para splash y landing (48px)
  const Logo.large({super.key}) : size = 48, borderRadius = 12, padding = 8;

  /// Tamaño del logo en píxeles
  final double size;

  /// Radio de las esquinas del contenedor
  final double borderRadius;

  /// Padding interno del contenedor
  final double padding;

  /// Color de fondo sólido (mismo que el splash screen)
  static const Color _backgroundColor = Color(0xFF0a1628);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Image.asset(
        'assets/icons/imagotipo.png',
        height: size,
        width: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

/// Alias para mantener compatibilidad con código existente.
/// @Deprecated('Use Logo instead')
typedef GradientLogo = Logo;
