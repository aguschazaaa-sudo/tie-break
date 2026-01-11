import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:padel_punilla/presentation/screens/auth/login_screen.dart';
import 'package:padel_punilla/presentation/screens/auth/signup_screen.dart';
import 'package:padel_punilla/presentation/screens/landing/widgets/widgets.dart';
import 'package:padel_punilla/presentation/widgets/ambient_glow.dart';
import 'package:padel_punilla/presentation/widgets/surface_card.dart';

/// Landing screen principal con diseño premium.
/// Incluye hero animado, bento cards y footer.
class LandingScreen extends StatelessWidget {
  const LandingScreen({required this.onToggleTheme, super.key});
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Theme.of(
                context,
              ).scaffoldBackgroundColor.withValues(alpha: 0.5),
            ),
          ),
        ),
        title: Row(
          children: [
            // Logo con gradiente
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.tertiary],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.sports_tennis,
                color: colorScheme.onPrimary,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'Padel Punilla',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text('Ingresar'),
          ),
          FilledButton.tonal(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignupScreen()),
              );
            },
            child: const Text('Registrarse'),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: onToggleTheme,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          // Ambient Background Glows - Más glows para efecto premium
          Positioned(
            top: -100,
            right: -100,
            child: AmbientGlow(
              color: colorScheme.primary,
              size: 350,
              opacity: 0.15,
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: AmbientGlow(color: colorScheme.secondary, opacity: 0.12),
          ),
          // Glow adicional tertiary en el centro
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            left: MediaQuery.of(context).size.width * 0.3,
            child: AmbientGlow(
              color: colorScheme.tertiary,
              size: 400,
              opacity: 0.08,
            ),
          ),

          // Main Content
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 120),
            child: Column(
              children: [
                _buildHeroSection(context),
                const SizedBox(height: 80),
                _buildBentoGridSection(context),
                const SizedBox(height: 60),
                // Footer al final del scroll
                const LandingFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Sección hero con layout responsive
  Widget _buildHeroSection(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          // Desktop layout: texto izquierda, visual derecha
          return Row(
            children: [
              Expanded(
                child: AnimatedHeroSection(
                  onPlayerPressed: () => _navigateToSignup(context),
                  onClubPressed: () => _navigateToSignup(context),
                ),
              ),
              const SizedBox(width: 48),
              Expanded(child: _buildHeroVisual(context)),
            ],
          );
        } else {
          // Mobile layout: apilado vertical centrado
          return Column(
            children: [
              AnimatedHeroSection(
                centerContent: true,
                onPlayerPressed: () => _navigateToSignup(context),
                onClubPressed: () => _navigateToSignup(context),
              ),
              const SizedBox(height: 60),
              _buildHeroVisual(context),
            ],
          );
        }
      },
    );
  }

  void _navigateToSignup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );
  }

  /// Visual del hero - mockup de la app
  Widget _buildHeroVisual(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surface.withValues(alpha: 0.5),
            colorScheme.surface.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 40,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Mockup visual principal
          Positioned(
            top: 40,
            left: 40,
            right: 40,
            bottom: 100,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart_rounded,
                      size: 80,
                      color: colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Leaderboard',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Card flotante de notificación
          Positioned(
            bottom: 40,
            right: -20,
            child: SurfaceCard(
              isGlass: true,
              isShiny: true,
              padding: const EdgeInsets.all(16),
              borderColor: colorScheme.secondary.withValues(alpha: 0.3),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Partido Finalizado',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Text(
                        '+250 Puntos',
                        style: TextStyle(
                          color: colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Card flotante de reserva
          Positioned(
            top: 20,
            left: -10,
            child: SurfaceCard(
              isGlass: true,
              padding: const EdgeInsets.all(12),
              borderColor: colorScheme.primary.withValues(alpha: 0.3),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: colorScheme.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Cancha reservada',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Sección de bento grid con las 3 formas de jugar
  Widget _buildBentoGridSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Título con badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.tertiaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '✨ Modalidades de juego',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: colorScheme.tertiary),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '3 Formas de Jugar',
          style: Theme.of(
            context,
          ).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          'Elige la modalidad que mejor se adapte a tu estilo',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 48),

        // Bento Grid
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              // Desktop: layout horizontal - más compacto
              return SizedBox(
                height: 280,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: AnimatedBentoCard(
                        title: 'Desafío 2vs2',
                        subtitle:
                            'Compite por puntos, sube en el ranking y gana premios.',
                        icon: Icons.emoji_events,
                        color: colorScheme.tertiary,
                        isLarge: true,
                        onTap:
                            () => _showModeInfo(
                              context,
                              title: 'Desafío 2vs2',
                              icon: Icons.emoji_events,
                              color: colorScheme.tertiary,
                              description:
                                  'El modo competitivo de Padel Punilla. Cada partido '
                                  'suma puntos para el ranking de la liga.',
                              features: const [
                                '🏆 Acumulá puntos en cada partido',
                                '📊 Subí en el ranking de tu categoría',
                                '🎁 Ganá premios al final de cada temporada',
                                '🤝 Patrocinadores exclusivos',
                              ],
                            ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: AnimatedBentoCard(
                              title: 'Reserva Normal',
                              subtitle:
                                  'Tu partido amistoso, reservado en segundos.',
                              icon: Icons.calendar_today,
                              color: colorScheme.primary,
                              animationDelay: const Duration(milliseconds: 150),
                              onTap:
                                  () => _showModeInfo(
                                    context,
                                    title: 'Reserva Normal',
                                    icon: Icons.calendar_today,
                                    color: colorScheme.primary,
                                    description:
                                        'Reservá tu cancha de forma rápida y sencilla '
                                        'en cualquiera de nuestros clubes afiliados.',
                                    features: const [
                                      '⚡ Reserva instantánea',
                                      '📱 Disponibilidad en tiempo real',
                                      '🏟️ Múltiples clubes para elegir',
                                      '💳 Pago online o en el club',
                                    ],
                                  ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: AnimatedBentoCard(
                              title: '¡Me Falta Uno!',
                              subtitle: 'Encuentra al 4to jugador al instante.',
                              icon: Icons.group_add,
                              color: colorScheme.secondary,
                              animationDelay: const Duration(milliseconds: 300),
                              onTap:
                                  () => _showModeInfo(
                                    context,
                                    title: '¡Me Falta Uno!',
                                    icon: Icons.group_add,
                                    color: colorScheme.secondary,
                                    description:
                                        '¿Te falta un jugador para completar el partido? '
                                        'Publicá tu reserva y encontrá compañeros.',
                                    features: const [
                                      '👥 Conectá con otros jugadores',
                                      '🎯 Filtrá por nivel de juego',
                                      '📍 Jugadores cerca de tu club',
                                      '💬 Chat para coordinar',
                                    ],
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // Mobile: layout vertical - más compacto
              return Column(
                children: [
                  SizedBox(
                    height: 160,
                    child: AnimatedBentoCard(
                      title: 'Desafío 2vs2',
                      subtitle: 'Compite por puntos y premios en la liga.',
                      icon: Icons.emoji_events,
                      color: colorScheme.tertiary,
                      isLarge: true,
                      onTap:
                          () => _showModeInfo(
                            context,
                            title: 'Desafío 2vs2',
                            icon: Icons.emoji_events,
                            color: colorScheme.tertiary,
                            description:
                                'El modo competitivo. Cada partido suma puntos.',
                            features: const [
                              '🏆 Acumulá puntos',
                              '📊 Subí en el ranking',
                              '🎁 Ganá premios',
                            ],
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 140,
                    child: AnimatedBentoCard(
                      title: 'Reserva Normal',
                      subtitle: 'Reserva tu cancha al instante.',
                      icon: Icons.calendar_today,
                      color: colorScheme.primary,
                      animationDelay: const Duration(milliseconds: 150),
                      onTap:
                          () => _showModeInfo(
                            context,
                            title: 'Reserva Normal',
                            icon: Icons.calendar_today,
                            color: colorScheme.primary,
                            description: 'Reservá tu cancha rápido y fácil.',
                            features: const [
                              '⚡ Reserva instantánea',
                              '📱 Disponibilidad real',
                              '🏟️ Múltiples clubes',
                            ],
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 140,
                    child: AnimatedBentoCard(
                      title: '¡Me Falta Uno!',
                      subtitle: 'Completa tu partido con la comunidad.',
                      icon: Icons.group_add,
                      color: colorScheme.secondary,
                      animationDelay: const Duration(milliseconds: 300),
                      onTap:
                          () => _showModeInfo(
                            context,
                            title: '¡Me Falta Uno!',
                            icon: Icons.group_add,
                            color: colorScheme.secondary,
                            description: 'Encontrá al jugador que te falta.',
                            features: const [
                              '👥 Conectá con otros',
                              '🎯 Filtrá por nivel',
                              '💬 Chat incluido',
                            ],
                          ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  /// Muestra un bottom sheet con información detallada de un modo de juego
  void _showModeInfo(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String description,
    required List<String> features,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),

                // Header con ícono
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 16),

                // Título
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Descripción
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 24),

                // Features
                ...features.map(
                  (feature) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Text(
                          feature,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Botón CTA
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateToSignup(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '¡Empezar ahora!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }
}
