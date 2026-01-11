import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:padel_punilla/domain/enums/locality.dart';
import 'package:padel_punilla/domain/models/club_model.dart';
import 'package:padel_punilla/domain/repositories/auth_repository.dart';
import 'package:padel_punilla/domain/repositories/club_repository.dart';
import 'package:padel_punilla/domain/repositories/storage_repository.dart';
import 'package:padel_punilla/presentation/widgets/auth_card.dart';
import 'package:padel_punilla/presentation/widgets/custom_text_field.dart';
import 'package:padel_punilla/presentation/widgets/gradient_background.dart';
import 'package:padel_punilla/presentation/widgets/primary_button.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CreateClubScreen extends StatefulWidget {
  const CreateClubScreen({super.key});

  @override
  State<CreateClubScreen> createState() => _CreateClubScreenState();
}

class _CreateClubScreenState extends State<CreateClubScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  XFile? _imageFile;
  Uint8List? _imageBytes;
  Locality _selectedLocality = Locality.villaCarlosPaz;
  bool _isLoading = false;

  final _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageFile = pickedFile;
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _createClub() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authRepo = context.read<AuthRepository>();
      final clubRepo = context.read<ClubRepository>();
      final storageRepo =
          context
              .read<
                StorageRepository
              >(); // Ensure this is provided in main.dart!

      final user = authRepo.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      final now = DateTime.now();
      final clubId = const Uuid().v4();
      String? logoUrl;

      if (_imageFile != null) {
        logoUrl = await storageRepo.uploadClubLogo(_imageFile!, clubId);
      }

      final club = ClubModel(
        id: clubId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        logoUrl: logoUrl,
        adminId: user.uid,
        address: _addressController.text.trim(),
        locality: _selectedLocality,
        createdAt: now,
        expiresAt: now.add(const Duration(days: 15)),
        contactPhone:
            _phoneController.text.trim().isNotEmpty
                ? _phoneController.text.trim()
                : null,
      );

      await clubRepo.createClub(club);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Club creado exitosamente')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      extendBodyBehindAppBar: true,
      body: GradientBackground(
        child: AuthCard(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Nuevo Club',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                _buildSectionTitle(context, 'Información Básica'),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _nameController,
                  label: 'Nombre del Club',
                  prefixIcon: Icons.business,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa el nombre del club';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Descripción',
                  prefixIcon: Icons.description,
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa una descripción';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),
                _buildSectionTitle(context, 'Ubicación'),
                const SizedBox(height: 16),
                DropdownButtonFormField<Locality>(
                  value: _selectedLocality,
                  decoration: InputDecoration(
                    labelText: 'Localidad',
                    prefixIcon: const Icon(Icons.location_city),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  items:
                      Locality.values.map((locality) {
                        return DropdownMenuItem(
                          value: locality,
                          child: Text(
                            locality.displayName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedLocality = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _addressController,
                  label: 'Dirección',
                  prefixIcon: Icons.location_on,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa la dirección';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),
                _buildSectionTitle(context, 'Contacto'),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _phoneController,
                  label: 'Teléfono de Contacto',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final phoneRegExp = RegExp(r'^[0-9]+$');
                      if (!phoneRegExp.hasMatch(value)) {
                        return 'Solo se permiten números';
                      }
                      if (value.length < 7) {
                        return 'El número es muy corto';
                      }
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),
                _buildSectionTitle(context, 'Branding'),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Toca para subir el logo del club',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor:
                              Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                          backgroundImage:
                              _imageBytes != null
                                  ? MemoryImage(_imageBytes!)
                                  : null,
                          child:
                              _imageBytes == null
                                  ? Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  )
                                  : null,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                PrimaryButton(
                  text: 'Crear Club',
                  onPressed: _createClub,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const Divider(),
      ],
    );
  }
}
