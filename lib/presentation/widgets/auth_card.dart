import 'package:flutter/material.dart';
import 'package:padel_punilla/presentation/widgets/surface_card.dart';

class AuthCard extends StatelessWidget {
  const AuthCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(32),
  });
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SurfaceCard(
            isGlass: true,
            isShiny: true,
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
