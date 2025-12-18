import 'package:flutter/material.dart';

/// Sección de estadísticas con contadores animados.
/// Muestra métricas clave como jugadores, clubes y partidos.
class StatsCounterSection extends StatefulWidget {
  const StatsCounterSection({super.key});

  @override
  State<StatsCounterSection> createState() => _StatsCounterSectionState();
}

class _StatsCounterSectionState extends State<StatsCounterSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _countAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _countAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    // Iniciar animación con un pequeño delay
    Future.delayed(const Duration(milliseconds: 300), () {
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.3),
            colorScheme.tertiaryContainer.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          // Título de la sección
          Text(
            'Nuestra Comunidad',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Creciendo cada día en el Valle de Punilla',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 40),

          // Grid de estadísticas responsive
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                // Desktop: row horizontal
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _buildStatItems(),
                );
              } else {
                // Mobile: wrap
                return Wrap(
                  spacing: 32,
                  runSpacing: 24,
                  alignment: WrapAlignment.center,
                  children: _buildStatItems(),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStatItems() {
    return [
      _buildStatItem(
        icon: Icons.people_alt_rounded,
        targetValue: 500,
        suffix: '+',
        label: 'Jugadores',
        color: Theme.of(context).colorScheme.primary,
      ),
      _buildStatItem(
        icon: Icons.sports_tennis,
        targetValue: 1000,
        suffix: '+',
        label: 'Partidos Jugados',
        color: Theme.of(context).colorScheme.secondary,
      ),
      _buildStatItem(
        icon: Icons.business_rounded,
        targetValue: 20,
        suffix: '+',
        label: 'Clubes Afiliados',
        color: Theme.of(context).colorScheme.tertiary,
      ),
      _buildStatItem(
        icon: Icons.emoji_events_rounded,
        targetValue: 50,
        suffix: '+',
        label: 'Premios Entregados',
        color: const Color(0xFFFFD700), // Gold
      ),
    ];
  }

  Widget _buildStatItem({
    required IconData icon,
    required int targetValue,
    required String suffix,
    required String label,
    required Color color,
  }) {
    return AnimatedBuilder(
      animation: _countAnimation,
      builder: (context, child) {
        final currentValue = (targetValue * _countAnimation.value).round();
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Ícono con glow
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.2),
                      color.withValues(alpha: 0.1),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 16,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 16),

              // Número animado
              Text(
                '$currentValue$suffix',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),

              // Label
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
