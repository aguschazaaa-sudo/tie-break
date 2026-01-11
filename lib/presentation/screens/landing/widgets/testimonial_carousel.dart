import 'package:flutter/material.dart';
import 'package:padel_punilla/presentation/widgets/surface_card.dart';

/// Carrusel de testimonios de usuarios.
/// Muestra cards con avatar, nombre, texto y rating.
class TestimonialCarousel extends StatefulWidget {
  const TestimonialCarousel({super.key});

  @override
  State<TestimonialCarousel> createState() => _TestimonialCarouselState();
}

class _TestimonialCarouselState extends State<TestimonialCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  // Datos de testimonios de ejemplo
  static const List<_Testimonial> _testimonials = [
    _Testimonial(
      name: 'Martín Rodríguez',
      role: 'Jugador - Cat. 3ra',
      text:
          'Desde que uso Padel Punilla, encontrar partidos se volvió '
          'súper fácil. ¡Ya subí dos categorías en la liga!',
      avatarColor: Colors.blue,
      rating: 5,
    ),
    _Testimonial(
      name: 'Club Costa Serrana',
      role: 'Club Afiliado',
      text:
          'La gestión de canchas nunca fue tan simple. Nuestros clientes '
          'reservan directamente y nosotros ahorramos tiempo.',
      avatarColor: Colors.green,
      rating: 5,
    ),
    _Testimonial(
      name: 'Laura Fernández',
      role: 'Jugadora - Cat. 4ta',
      text:
          '¡Me encanta la función de "Me falta uno"! Siempre encuentro '
          'con quién completar el cuarteto.',
      avatarColor: Colors.purple,
      rating: 5,
    ),
    _Testimonial(
      name: 'Diego Pérez',
      role: 'Jugador - Cat. 2da',
      text:
          'Los desafíos 2vs2 le agregaron emoción a cada partido. '
          'Ahora cada punto cuenta para la liga.',
      avatarColor: Colors.orange,
      rating: 4,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Título de la sección
        Text(
          'Lo que dicen nuestros usuarios',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '⭐ Calificación promedio: 4.9/5',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFFFFD700),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 32),

        // Carrusel de testimonios
        SizedBox(
          height: 260,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _testimonials.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return AnimatedScale(
                scale: _currentPage == index ? 1.0 : 0.9,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                child: _buildTestimonialCard(_testimonials[index]),
              );
            },
          ),
        ),

        // Indicadores de página
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _testimonials.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color:
                    _currentPage == index
                        ? colorScheme.primary
                        : colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTestimonialCard(_Testimonial testimonial) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SurfaceCard(
        isGlass: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con avatar y nombre
            Row(
              children: [
                // Avatar circular con iniciales
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        testimonial.avatarColor,
                        testimonial.avatarColor.withValues(alpha: 0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: testimonial.avatarColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _getInitials(testimonial.name),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Nombre y rol
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        testimonial.name,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        testimonial.role,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),

                // Rating stars
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < testimonial.rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: const Color(0xFFFFD700),
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Quote icon
            Icon(
              Icons.format_quote_rounded,
              color: colorScheme.primary.withValues(alpha: 0.3),
              size: 28,
            ),
            const SizedBox(height: 8),

            // Texto del testimonio
            Expanded(
              child: Text(
                testimonial.text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }
}

/// Modelo interno para testimonios
class _Testimonial {
  const _Testimonial({
    required this.name,
    required this.role,
    required this.text,
    required this.avatarColor,
    required this.rating,
  });
  final String name;
  final String role;
  final String text;
  final Color avatarColor;
  final int rating;
}
