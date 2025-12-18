import 'package:flutter/material.dart';
import 'package:padel_punilla/presentation/screens/policies/widgets/widgets.dart';

/// Pantalla de Política de Privacidad con diseño premium.
/// Muestra las secciones de privacidad de forma visualmente atractiva
/// utilizando componentes reutilizables.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar transparente para que el header se vea completo
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header decorativo con ícono y título
            const PolicyHeader(
              icon: Icons.privacy_tip_outlined,
              title: 'Política de Privacidad',
              subtitle: 'Tu privacidad es importante',
            ),

            // Contenido principal con padding
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Sección 1: Información que Recopilamos
                  PolicySectionCard(
                    sectionNumber: '1',
                    title: 'Información que Recopilamos',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recopilamos información personal que usted nos proporciona '
                          'voluntariamente al registrarse en la aplicación, incluyendo:',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 12),
                        PolicyBulletList(
                          items: const [
                            'Nombre y Apellido',
                            'Dirección de correo electrónico',
                            'Número de teléfono',
                            'Fotografía de perfil',
                          ],
                          bulletColor: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'También recopilamos datos sobre su actividad en la aplicación, '
                          'como reservaciones de canchas, participación en ligas y '
                          'resultados de partidos.',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Sección 2: Uso de la Información
                  PolicySectionCard(
                    sectionNumber: '2',
                    title: 'Uso de la Información',
                    useSecondaryColor: true,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Utilizamos su información para:',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 12),
                        PolicyBulletList(
                          items: const [
                            'Gestionar su cuenta y autenticación.',
                            'Procesar sus reservaciones de canchas en los clubes afiliados.',
                            'Facilitar la organización de partidos y ligas.',
                            'Comunicarnos con usted sobre actualizaciones, confirmaciones '
                                'de reserva o cambios en el servicio.',
                            'Competencias y Premios: Contactar a los ganadores de ligas o '
                                'torneos para coordinar la entrega de premios.',
                          ],
                          bulletColor: Theme.of(context).colorScheme.secondary,
                        ),
                      ],
                    ),
                  ),

                  // Sección 3: Compartir Información
                  PolicySectionCard(
                    sectionNumber: '3',
                    title: 'Compartir Información',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sus datos pueden ser compartidos con:',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Cards individuales para cada tipo de compartición
                        _buildShareInfoCard(
                          context,
                          icon: Icons.sports_tennis,
                          title: 'Clubes Deportivos',
                          description: 'Para gestionar sus reservas.',
                        ),
                        const SizedBox(height: 8),
                        _buildShareInfoCard(
                          context,
                          icon: Icons.people_outline,
                          title: 'Otros Usuarios',
                          description:
                              'Su nombre y nivel de juego pueden ser visibles '
                              'en las tablas de clasificación y programación de partidos.',
                        ),
                        const SizedBox(height: 8),
                        _buildShareInfoCard(
                          context,
                          icon: Icons.handshake_outlined,
                          title: 'Patrocinadores (Limitado)',
                          description:
                              'No compartimos sus datos personales directamente '
                              'con patrocinadores sin su consentimiento explícito. Sin embargo, '
                              'utilizaremos sus datos de contacto para gestionar la entrega de '
                              'premios proporcionados por estos.',
                        ),
                      ],
                    ),
                  ),

                  // Sección 4: Seguridad de los Datos
                  PolicySectionCard(
                    sectionNumber: '4',
                    title: 'Seguridad de los Datos',
                    useSecondaryColor: true,
                    content: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ícono de seguridad
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.security_outlined,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Implementamos medidas de seguridad razonables para proteger '
                            'su información. Sin embargo, ninguna transmisión por internet '
                            'es 100% segura.',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Sección 5: Sus Derechos
                  PolicySectionCard(
                    sectionNumber: '5',
                    title: 'Sus Derechos',
                    content: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ícono de derechos
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .tertiaryContainer
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.verified_user_outlined,
                            color: Theme.of(context).colorScheme.tertiary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Usted tiene derecho a acceder, corregir o eliminar su '
                            'información personal. Puede gestionar su perfil desde la '
                            'aplicación o contactarnos para solicitar la baja definitiva.',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Footer con información de última actualización
                  const PolicyFooter(
                    lastUpdated: 'Diciembre 2025',
                    contactEmail: 'privacidad@padelpunilla.com',
                  ),

                  // Espacio extra al final para navegación cómoda
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget helper para mostrar una tarjeta de información sobre
  /// con quién se comparten los datos.
  Widget _buildShareInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
