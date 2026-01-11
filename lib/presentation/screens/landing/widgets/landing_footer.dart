import 'package:flutter/material.dart';
import 'package:padel_punilla/presentation/screens/policies/privacy_policy_screen.dart';
import 'package:padel_punilla/presentation/screens/policies/terms_conditions_screen.dart';

/// Footer mejorado para la landing page.
/// Incluye links a políticas, redes sociales y branding.
class LandingFooter extends StatelessWidget {
  const LandingFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        border: Border(
          top: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
        ),
      ),
      child: Column(
        children: [
          // Sección superior - Logo y descripción
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildBrandSection(context)),
                    const SizedBox(width: 48),
                    Expanded(child: _buildLinksSection(context)),
                    Expanded(child: _buildLegalSection(context)),
                    Expanded(child: _buildSocialSection(context)),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildBrandSection(context),
                    const SizedBox(height: 32),
                    Wrap(
                      spacing: 48,
                      runSpacing: 24,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildLinksSection(context),
                        _buildLegalSection(context),
                        _buildSocialSection(context),
                      ],
                    ),
                  ],
                );
              }
            },
          ),

          const SizedBox(height: 40),
          Divider(color: colorScheme.outline.withValues(alpha: 0.1)),
          const SizedBox(height: 24),

          // Copyright y nota final
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sports_tennis, size: 16, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '© 2024 Padel Punilla. Hecho con ❤️ en el Valle de Punilla.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBrandSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo con ícono
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.tertiary],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.sports_tennis,
                color: colorScheme.onPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
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
        const SizedBox(height: 16),

        // Descripción
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Text(
            'La plataforma que conecta jugadores y clubes de pádel '
            'en el Valle de Punilla.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildLinksSection(BuildContext context) {
    return const _FooterColumn(
      title: 'Recursos',
      links: [
        _FooterLink('Cómo funciona', null),
        _FooterLink('Clubes afiliados', null),
        _FooterLink('Liga y puntajes', null),
        _FooterLink('Preguntas frecuentes', null),
      ],
    );
  }

  Widget _buildLegalSection(BuildContext context) {
    return _FooterColumn(
      title: 'Legal',
      links: [
        _FooterLink(
          'Términos y Condiciones',
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TermsConditionsScreen()),
          ),
        ),
        _FooterLink(
          'Política de Privacidad',
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seguinos',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),

        // Iconos de redes sociales
        Wrap(
          spacing: 12,
          children: [
            _buildSocialButton(
              context: context,
              icon: Icons.facebook,
              color: const Color(0xFF1877F2),
              onTap: () {},
            ),
            _buildSocialButton(
              context: context,
              icon: Icons.camera_alt_outlined,
              color: const Color(0xFFE4405F),
              onTap: () {},
            ),
            _buildSocialButton(
              context: context,
              icon: Icons.message_rounded,
              color: const Color(0xFF25D366),
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

/// Columna del footer con título y lista de links
class _FooterColumn extends StatelessWidget {
  const _FooterColumn({required this.title, required this.links});
  final String title;
  final List<_FooterLink> links;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ...links.map(
          (link) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: link.onTap,
              child: Text(
                link.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      link.onTap != null
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Modelo simple para un link del footer
class _FooterLink {
  const _FooterLink(this.label, this.onTap);
  final String label;
  final VoidCallback? onTap;
}
