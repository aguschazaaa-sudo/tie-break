import 'package:flutter/material.dart';
import 'package:padel_punilla/presentation/screens/policies/widgets/widgets.dart';

/// Pantalla de Términos y Condiciones con diseño premium.
/// Muestra las secciones legales de forma visualmente atractiva
/// utilizando componentes reutilizables.
class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

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
              icon: Icons.description_outlined,
              title: 'Términos y Condiciones',
              subtitle: 'Por favor lee atentamente',
            ),

            // Contenido principal con padding
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Sección 1: Aceptación
                  PolicySectionCard(
                    sectionNumber: '1',
                    title: 'Aceptación de los Términos',
                    content: Text(
                      'Al descargar o utilizar "Padel Punilla", usted acepta estos '
                      'términos y condiciones en su totalidad. Si no está de acuerdo, '
                      'no debe utilizar la aplicación.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                  ),

                  // Sección 2: Uso de la Aplicación
                  PolicySectionCard(
                    sectionNumber: '2',
                    title: 'Uso de la Aplicación',
                    useSecondaryColor: true,
                    content: Text(
                      'La aplicación sirve como plataforma para gestionar reservas de '
                      'canchas y participar en ligas deportivas. Usted se compromete '
                      'a utilizarla de manera responsable y legal.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                  ),

                  // Sección 3: Reservas y Cancelaciones
                  PolicySectionCard(
                    sectionNumber: '3',
                    title: 'Reservas y Cancelaciones',
                    content: const PolicyBulletList(
                      items: [
                        'Las reservas están sujetas a la disponibilidad de los clubes.',
                        'Las políticas de cancelación y reembolso son determinadas por '
                            'cada club. Es su responsabilidad informarse sobre estas reglas '
                            'antes de reservar.',
                        'El incumplimiento reiterado de reservas (no show) puede '
                            'resultar en la suspensión de su cuenta.',
                      ],
                    ),
                  ),

                  // Sección 4: Competencias, Ligas y Premios
                  PolicySectionCard(
                    sectionNumber: '4',
                    title: 'Competencias, Ligas y Premios',
                    useSecondaryColor: true,
                    content: const PolicyBulletList(
                      items: [
                        'Puntajes: La aplicación gestiona tablas de puntuación para '
                            'ligas y torneos. Nos esforzamos por mantener la precisión, '
                            'pero nos reservamos el derecho de corregir errores en los puntajes.',
                        'Premios y Patrocinios: Los premios otorgados a los ganadores '
                            'de ligas o torneos pueden ser proporcionados por terceros patrocinadores.',
                        'Entrega de Premios: Nos pondremos en contacto con los ganadores '
                            'utilizando los datos registrados en la app (email o teléfono) '
                            'para coordinar la entrega. Es responsabilidad del usuario '
                            'mantener sus datos actualizados.',
                        'Responsabilidad: "Padel Punilla" actúa como organizador y '
                            'facilitador, pero no garantiza la disponibilidad perpetua de '
                            'premios específicos ofrecidos por terceros. Nos reservamos el '
                            'derecho de modificar o cancelar premios en caso de fuerza mayor '
                            'o cambios en los acuerdos con patrocinadores.',
                      ],
                    ),
                  ),

                  // Sección 5: Conducta del Usuario
                  PolicySectionCard(
                    sectionNumber: '5',
                    title: 'Conducta del Usuario',
                    content: Text(
                      'Se espera que los usuarios mantengan una conducta deportiva y '
                      'respetuosa. El lenguaje ofensivo o comportamiento inapropiado '
                      'hacia otros usuarios o personal de los clubes no será tolerado.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                  ),

                  // Sección 6: Limitación de Responsabilidad
                  PolicySectionCard(
                    sectionNumber: '6',
                    title: 'Limitación de Responsabilidad',
                    useSecondaryColor: true,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '"Padel Punilla" actúa como intermediario. No somos '
                          'responsables por:',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const PolicyBulletList(
                          items: [
                            'Cancelaciones por parte de los clubes.',
                            'Lesiones o accidentes ocurridos en las instalaciones deportivas.',
                            'Disputas entre jugadores.',
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Sección 7: Modificaciones
                  PolicySectionCard(
                    sectionNumber: '7',
                    title: 'Modificaciones',
                    content: Text(
                      'Nos reservamos el derecho de modificar estos términos en '
                      'cualquier momento. Las modificaciones serán efectivas '
                      'inmediatamente después de su publicación en la aplicación.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                  ),

                  // Footer con información de última actualización
                  const PolicyFooter(lastUpdated: 'Diciembre 2025'),

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
}
