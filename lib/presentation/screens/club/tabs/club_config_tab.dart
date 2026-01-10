import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:padel_punilla/domain/enums/club_amenity.dart';
import 'package:padel_punilla/presentation/providers/club_management_provider.dart';
import 'package:provider/provider.dart';

/// Tab de configuración del club que combina la información general
/// y los horarios de operación en una sola vista.
///
/// Incluye dos secciones principales:
/// 1. Información General: nombre, teléfono, descripción, dirección
/// 2. Horarios de Operación: gestión de horarios disponibles para reservas
class ClubConfigTab extends StatefulWidget {
  final bool isDesktop;

  const ClubConfigTab({super.key, required this.isDesktop});

  @override
  State<ClubConfigTab> createState() => _ClubConfigTabState();
}

class _ClubConfigTabState extends State<ClubConfigTab> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para el formulario de información del club
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
    _initControllers();
  }

  /// Inicializa los controladores con los valores actuales del club
  void _initControllers() {
    final provider = context.read<ClubManagementProvider>();
    final club = provider.club;
    if (club != null) {
      _nameController.text = club.name;
      _descriptionController.text = club.description;
      _addressController.text = club.address;
      _phoneController.text = club.contactPhone ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Guarda los cambios de información del club
  Future<void> _saveDetails() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await context.read<ClubManagementProvider>().updateClubDetails(
        name: _nameController.text,
        description: _descriptionController.text,
        address: _addressController.text,
        phone: _phoneController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Detalles actualizados correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar cambios: $e')));
      }
    }
  }

  /// Abre el TimePicker y agrega un nuevo horario al club
  Future<void> _addSchedule() async {
    final provider = context.read<ClubManagementProvider>();
    final club = provider.club;
    if (club == null) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );

    if (selectedTime != null) {
      // Formatea la hora en formato HH:MM
      final formattedTime =
          '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';

      try {
        await provider.addSchedule(formattedTime);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al agregar horario: $e')),
          );
        }
      }
    }
  }

  /// Elimina un horario existente del club
  Future<void> _removeSchedule(String schedule) async {
    try {
      await context.read<ClubManagementProvider>().removeSchedule(schedule);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar horario: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final club = context.watch<ClubManagementProvider>().club;
    if (club == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================================
          // SECCIÓN 1: Información General del Club
          // ============================================================
          _buildSectionHeader(
            context,
            'Información General',
            'Mantén actualizada la información de tu club para que los usuarios puedan encontrarte fácilmente.',
          ),
          const SizedBox(height: 24),

          // Card con formulario de información
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: _buildLogoPicker(context)),
                    const SizedBox(height: 32),
                    // Layout responsivo para nombre y teléfono
                    if (widget.isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildNameField()),
                          const SizedBox(width: 24),
                          Expanded(child: _buildPhoneField()),
                        ],
                      )
                    else ...[
                      _buildNameField(),
                      const SizedBox(height: 16),
                      _buildPhoneField(),
                    ],
                    const SizedBox(height: 16),
                    _buildDescriptionField(),
                    const SizedBox(height: 16),
                    _buildAddressField(),
                    const SizedBox(height: 32),

                    // Botón de guardar
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton.icon(
                        onPressed: _saveDetails,
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar Cambios'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 48),

          // ============================================================
          // SECCIÓN 2: Horarios de Operación
          // ============================================================
          _buildResponsiveSectionHeader(
            context,
            'Horarios de Operación',
            'Gestiona los horarios en los que tu club está abierto para reservas.',
            FloatingActionButton.extended(
              heroTag: 'add_schedule_fab',
              onPressed: _addSchedule,
              icon: const Icon(Icons.add),
              label: const Text('Nuevo Horario'),
            ),
          ),
          const SizedBox(height: 24),

          // Card con chips de horarios o estado vacío
          if (club.availableSchedules.isEmpty)
            _buildEmptyState(
              context,
              'No hay horarios configurados',
              Icons.access_time_outlined,
            )
          else
            Card(
              elevation: 0,
              color: colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children:
                      club.availableSchedules.map((schedule) {
                        return InputChip(
                          avatar: const Icon(Icons.access_time, size: 18),
                          label: Text(
                            schedule,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onDeleted: () => _removeSchedule(schedule),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          backgroundColor: colorScheme.surface,
                          padding: const EdgeInsets.all(8),
                        );
                      }).toList(),
                ),
              ),
            ),

          const SizedBox(height: 48),

          // ============================================================
          // SECCIÓN 3: Comodidades y Servicios
          // ============================================================
          _buildSectionHeader(
            context,
            'Comodidades',
            'Selecciona los servicios que ofrece tu club.',
          ),
          const SizedBox(height: 24),

          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children:
                    ClubAmenity.values.map((amenity) {
                      final isSelected = club.amenities.contains(amenity);
                      return FilterChip(
                        selected: isSelected,
                        label: Text(amenity.displayName),
                        onSelected: (selected) async {
                          try {
                            await context
                                .read<ClubManagementProvider>()
                                .toggleAmenity(amenity);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error al actualizar: $e'),
                                ),
                              );
                            }
                          }
                        },
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && mounted) {
      try {
        await context.read<ClubManagementProvider>().updateClubLogo(pickedFile);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logo actualizado correctamente')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar logo: $e')),
          );
        }
      }
    }
  }

  // ============================================================
  // Widgets auxiliares para construir la UI
  // ============================================================

  Widget _buildLogoPicker(BuildContext context) {
    final club = context.watch<ClubManagementProvider>().club;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.outlineVariant, width: 2),
              image:
                  club?.logoUrl != null
                      ? DecorationImage(
                        image: NetworkImage(club!.logoUrl!),
                        fit: BoxFit.cover,
                      )
                      : null,
            ),
            child:
                club?.logoUrl == null
                    ? Icon(
                      Icons.store_mall_directory,
                      size: 60,
                      color: colorScheme.outline,
                    )
                    : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Material(
              color: colorScheme.primary,
              shape: const CircleBorder(),
              elevation: 4,
              child: InkWell(
                onTap: _pickLogo,
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.camera_alt,
                    size: 20,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye un header de sección con título y subtítulo
  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Construye un header responsivo con acción (FAB) a la derecha en desktop
  Widget _buildResponsiveSectionHeader(
    BuildContext context,
    String title,
    String subtitle,
    Widget action,
  ) {
    if (widget.isDesktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildSectionHeader(context, title, subtitle)),
          const SizedBox(width: 24),
          action,
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionHeader(context, title, subtitle),
          const SizedBox(height: 16),
          action,
        ],
      );
    }
  }

  /// Estado vacío cuando no hay horarios configurados
  Widget _buildEmptyState(BuildContext context, String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Campos del formulario de información
  // ============================================================

  Widget _buildNameField() => TextFormField(
    controller: _nameController,
    decoration: const InputDecoration(
      labelText: 'Nombre del Club',
      prefixIcon: Icon(Icons.business),
      border: OutlineInputBorder(),
      filled: true,
    ),
    validator:
        (v) => v == null || v.isEmpty ? 'El nombre es obligatorio' : null,
  );

  Widget _buildPhoneField() => TextFormField(
    controller: _phoneController,
    decoration: const InputDecoration(
      labelText: 'Teléfono de Contacto',
      prefixIcon: Icon(Icons.phone),
      border: OutlineInputBorder(),
      filled: true,
    ),
    keyboardType: TextInputType.phone,
  );

  Widget _buildDescriptionField() => TextFormField(
    controller: _descriptionController,
    decoration: const InputDecoration(
      labelText: 'Descripción',
      prefixIcon: Icon(Icons.description),
      border: OutlineInputBorder(),
      filled: true,
      hintText: 'Cuenta un poco sobre tu club, canchas, servicios...',
    ),
    maxLines: 3,
    validator:
        (v) => v == null || v.isEmpty ? 'La descripción es obligatoria' : null,
  );

  Widget _buildAddressField() => TextFormField(
    controller: _addressController,
    decoration: const InputDecoration(
      labelText: 'Dirección',
      prefixIcon: Icon(Icons.location_on),
      border: OutlineInputBorder(),
      filled: true,
    ),
    validator:
        (v) => v == null || v.isEmpty ? 'La dirección es obligatoria' : null,
  );
}
