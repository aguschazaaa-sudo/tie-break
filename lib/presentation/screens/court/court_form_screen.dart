import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/models/court_model.dart';
import 'package:padel_punilla/domain/repositories/court_repository.dart';
import 'package:padel_punilla/presentation/widgets/custom_text_field.dart';
import 'package:padel_punilla/presentation/widgets/primary_button.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CourtFormScreen extends StatefulWidget {
  const CourtFormScreen({required this.clubId, super.key, this.court});
  final String clubId;
  final CourtModel? court;

  @override
  State<CourtFormScreen> createState() => _CourtFormScreenState();
}

class _CourtFormScreenState extends State<CourtFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _durationController;

  // Default to paddle as requested
  final CourtSport _selectedSport = CourtSport.paddle;
  late CourtSurface _selectedSurface;
  bool _isCovered = false;
  bool _hasLighting = true;
  bool _isAvailable = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.court?.name);
    _priceController = TextEditingController(
      text: widget.court?.reservationPrice.toString(),
    );
    _durationController = TextEditingController(
      text: (widget.court?.slotDurationMinutes ?? 90).toString(),
    );
    _selectedSurface = widget.court?.surfaceType ?? CourtSurface.synthetic;
    _isCovered = widget.court?.isCovered ?? false;
    _hasLighting = widget.court?.hasLighting ?? true;
    _isAvailable = widget.court?.isAvailable ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _saveCourt() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final courtRepo = Provider.of<CourtRepository>(context, listen: false);

      final courtId = widget.court?.id ?? const Uuid().v4();

      final newCourt = CourtModel(
        id: courtId,
        clubId: widget.clubId,
        name: _nameController.text,
        reservationPrice: double.parse(_priceController.text),
        slotDurationMinutes: int.parse(_durationController.text),
        isCovered: _isCovered,
        surfaceType: _selectedSurface,
        hasLighting: _hasLighting,
        sport: _selectedSport,
        isAvailable: _isAvailable,
        images: widget.court?.images ?? [],
      );

      if (widget.court != null) {
        await courtRepo.updateCourt(widget.clubId, newCourt);
      } else {
        await courtRepo.createCourt(widget.clubId, newCourt);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cancha guardada correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar la cancha: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.court != null ? 'Editar Cancha' : 'Nueva Cancha',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colorScheme.primary, colorScheme.secondary],
            ),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Información Básica'),
                  const SizedBox(height: 16),
                  _buildNameField(),
                  const SizedBox(height: 16),
                  const SizedBox(height: 16),
                  _buildPriceField(),
                  const SizedBox(height: 16),
                  _buildDurationField(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Detalles de la Cancha'),
                  const SizedBox(height: 16),
                  _buildSurfaceDropdown(),
                  const SizedBox(height: 24),
                  _buildFeaturesCard(),
                  const SizedBox(height: 32),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildNameField() {
    return CustomTextField(
      controller: _nameController,
      label: 'Nombre / Número',
      hint: 'Ej: Cancha 1, Central',
      prefixIcon: Icons.sports_tennis,
      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
    );
  }

  Widget _buildPriceField() {
    return CustomTextField(
      controller: _priceController,
      label: 'Precio por Turno',
      prefixIcon: Icons.attach_money,
      keyboardType: TextInputType.number,
      validator: (v) {
        if (v == null || v.isEmpty) return 'Requerido';
        if (double.tryParse(v) == null) return 'Ingrese un número válido';
        return null;
      },
    );
  }

  Widget _buildDurationField() {
    return CustomTextField(
      controller: _durationController,
      label: 'Duración del Turno (minutos)',
      hint: 'Ej: 90',
      prefixIcon: Icons.timer,
      keyboardType: TextInputType.number,
      validator: (v) {
        if (v == null || v.isEmpty) return 'Requerido';
        if (int.tryParse(v) == null) return 'Ingrese un número válido';
        return null;
      },
    );
  }

  Widget _buildSurfaceDropdown() {
    return DropdownButtonFormField<CourtSurface>(
      value: _selectedSurface,
      decoration: InputDecoration(
        labelText: 'Superficie',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.layers),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      items:
          CourtSurface.values.map((s) {
            return DropdownMenuItem(value: s, child: Text(s.displayName));
          }).toList(),
      onChanged: (v) => setState(() => _selectedSurface = v!),
    );
  }

  Widget _buildFeaturesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _buildSwitchTile(
            'Techada',
            '¿La cancha tiene techo?',
            _isCovered,
            (v) => setState(() => _isCovered = v),
            Icons.roofing,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildSwitchTile(
            'Iluminación',
            '¿Tiene luces para jugar de noche?',
            _hasLighting,
            (v) => setState(() => _hasLighting = v),
            Icons.lightbulb_outline,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildSwitchTile(
            'Disponible',
            'Desactiva para mantenimiento',
            _isAvailable,
            (v) => setState(() => _isAvailable = v),
            Icons.check_circle_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    IconData icon, {
    Color? activeColor,
  }) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: value,
      onChanged: onChanged,
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      activeColor: activeColor,
    );
  }

  Widget _buildSaveButton() {
    return PrimaryButton(
      text: 'GUARDAR CANCHA',
      onPressed: _saveCourt,
      isLoading: _isLoading,
    );
  }
}
