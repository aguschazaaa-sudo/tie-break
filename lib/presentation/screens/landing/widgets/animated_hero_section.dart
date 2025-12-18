import 'package:flutter/material.dart';
import 'package:padel_punilla/presentation/widgets/status_badge.dart';

/// Hero section con animaciones staggered de entrada.
/// Los elementos aparecen secuencialmente con un efecto elegante.
class AnimatedHeroSection extends StatefulWidget {
  /// Si el contenido debe estar centrado (para mobile)
  final bool centerContent;

  /// Callback para el botón "Soy Jugador"
  final VoidCallback onPlayerPressed;

  /// Callback para el botón "Soy Club"
  final VoidCallback onClubPressed;

  const AnimatedHeroSection({
    super.key,
    this.centerContent = false,
    required this.onPlayerPressed,
    required this.onClubPressed,
  });

  @override
  State<AnimatedHeroSection> createState() => _AnimatedHeroSectionState();
}

class _AnimatedHeroSectionState extends State<AnimatedHeroSection>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _badgeAnimation;
  late Animation<double> _titleAnimation;
  late Animation<double> _subtitleAnimation;
  late Animation<double> _buttonsAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Animaciones staggered - cada elemento aparece secuencialmente
    _badgeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    );
    _titleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 0.5, curve: Curves.easeOut),
    );
    _subtitleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.7, curve: Curves.easeOut),
    );
    _buttonsAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );

    // Iniciar la animación
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final crossAxisAlignment =
        widget.centerContent
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start;
    final textAlign = widget.centerContent ? TextAlign.center : TextAlign.start;

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        // Badge animado
        FadeTransition(
          opacity: _badgeAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.5),
              end: Offset.zero,
            ).animate(_badgeAnimation),
            child: StatusBadge(
              label: 'La Revolución del Padel en Punilla',
              color: colorScheme.primary,
              icon: Icons.sports_tennis,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Título con gradiente animado
        FadeTransition(
          opacity: _titleAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(_titleAnimation),
            child: ShaderMask(
              shaderCallback:
                  (bounds) => LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.secondary,
                      colorScheme.tertiary,
                    ],
                  ).createShader(bounds),
              child: Text(
                'Tu Club, Tu Liga,\nTu Pasión',
                textAlign: textAlign,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 64,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Subtítulo animado
        FadeTransition(
          opacity: _subtitleAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(_subtitleAnimation),
            child: Text(
              'La plataforma definitiva que conecta a jugadores y clubes.\n'
              'Organización profesional para clubes, beneficios exclusivos para jugadores.',
              textAlign: textAlign,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),

        // Botones animados
        FadeTransition(
          opacity: _buttonsAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.5),
              end: Offset.zero,
            ).animate(_buttonsAnimation),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment:
                  widget.centerContent
                      ? WrapAlignment.center
                      : WrapAlignment.start,
              children: [
                // Botón primario con glow
                _buildPrimaryButton(context),
                // Botón secundario outline
                _buildSecondaryButton(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Botón primario con efecto glow
  Widget _buildPrimaryButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: widget.onPlayerPressed,
        icon: const Icon(Icons.person),
        label: const Text('Soy Jugador'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  /// Botón secundario con borde
  Widget _buildSecondaryButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return OutlinedButton.icon(
      onPressed: widget.onClubPressed,
      icon: const Icon(Icons.business),
      label: const Text('Soy Club'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.5),
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
