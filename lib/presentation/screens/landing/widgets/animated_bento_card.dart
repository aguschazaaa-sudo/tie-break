import 'package:flutter/material.dart';
import 'package:padel_punilla/presentation/widgets/surface_card.dart';

/// Bento card con animaciones de entrada y efectos hover.
/// Escala ligeramente en hover y tiene un glow dinámico del color asignado.
class AnimatedBentoCard extends StatefulWidget {
  /// Título de la card
  final String title;

  /// Subtítulo o descripción
  final String subtitle;

  /// Ícono principal
  final IconData icon;

  /// Color del acento (para glow e ícono)
  final Color color;

  /// Si es la card grande del bento
  final bool isLarge;

  /// Callback al hacer tap
  final VoidCallback? onTap;

  /// Delay para la animación de entrada (para stagger)
  final Duration animationDelay;

  const AnimatedBentoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.isLarge = false,
    this.onTap,
    this.animationDelay = Duration.zero,
  });

  @override
  State<AnimatedBentoCard> createState() => _AnimatedBentoCardState();
}

class _AnimatedBentoCardState extends State<AnimatedBentoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Iniciar con delay para efecto staggered
    Future.delayed(widget.animationDelay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
              transformAlignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  // Glow que se intensifica en hover
                  BoxShadow(
                    color: widget.color.withValues(
                      alpha: _isHovered ? 0.3 : 0.1,
                    ),
                    blurRadius: _isHovered ? 30 : 15,
                    spreadRadius: _isHovered ? 2 : 0,
                  ),
                ],
              ),
              child: SurfaceCard(
                isGlass: true,
                backgroundColor: widget.color.withValues(alpha: 0.05),
                borderColor: widget.color.withValues(
                  alpha: _isHovered ? 0.4 : 0.15,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ícono con container animado
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(
                        milliseconds:
                            800 + widget.animationDelay.inMilliseconds,
                      ),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(scale: value, child: child);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              widget.color.withValues(alpha: 0.2),
                              widget.color.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: widget.color.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Icon(widget.icon, color: widget.color, size: 28),
                      ),
                    ),
                    const Spacer(),

                    // Título
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: widget.isLarge ? 32 : 20,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtítulo
                    Text(
                      widget.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                        height: 1.4,
                      ),
                    ),

                    // Indicador de "aprender más" en hover
                    AnimatedOpacity(
                      opacity: _isHovered ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Row(
                          children: [
                            Text(
                              'Descubrir más',
                              style: TextStyle(
                                color: widget.color,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: widget.color,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
