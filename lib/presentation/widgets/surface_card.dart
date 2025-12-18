import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:padel_punilla/presentation/widgets/shimmer_overlay.dart';

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(24),
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.isGlass = false,
    this.isShiny = false,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool isGlass;
  final bool isShiny;

  @override
  Widget build(BuildContext context) {
    var cardContent = child;

    if (isGlass) {
      cardContent = ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: borderColor ?? Colors.white.withValues(alpha: 0.2),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.1),
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.05),
                ],
                stops: const [0.1, 1],
              ),
            ),
            child: child,
          ),
        ),
      );
    } else {
      cardContent = Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: borderColor ?? Colors.white.withValues(alpha: 0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: child,
      );
    }

    if (isShiny) {
      // For glass cards, we want the shimmer ON TOP of the glass effect
      // but respecting the border radius.
      cardContent = ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: ShimmerOverlay(child: cardContent),
      );
    }

    return GestureDetector(onTap: onTap, child: cardContent);
  }
}
