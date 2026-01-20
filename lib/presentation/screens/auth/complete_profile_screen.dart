import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/enums/locality.dart';
import 'package:padel_punilla/domain/enums/paddle_category.dart';
import 'package:padel_punilla/domain/enums/player_gender.dart';
import 'package:padel_punilla/presentation/screens/home/home_screen.dart';
import 'package:padel_punilla/presentation/widgets/auth_card.dart';
import 'package:padel_punilla/presentation/widgets/gradient_background.dart';
import 'package:padel_punilla/presentation/widgets/primary_button.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  PaddleCategory? _selectedCategory;
  PlayerGender? _selectedGender;
  Locality? _selectedLocality;
  bool _isLoading = false;

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No hay usuario autenticado');

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
            'category': _selectedCategory?.name,
            'gender': _selectedGender?.name,
            'locality': _selectedLocality?.name,
          });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar perfil: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: AuthCard(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 64,
                  color: Color(0xFF00838F),
                ),
                const SizedBox(height: 24),
                Text(
                  'Completa tu Perfil',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Necesitamos algunos datos más para continuar',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 32),
                DropdownButtonFormField<PaddleCategory>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    prefixIcon: Icon(Icons.stars_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items:
                      PaddleCategory.values.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(
                            category.label,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        );
                      }).toList(),
                  onChanged:
                      (value) => setState(() => _selectedCategory = value),
                  validator:
                      (value) =>
                          value == null ? 'Selecciona una categoría' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<PlayerGender>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Género',
                    prefixIcon: Icon(Icons.people_outline),
                    border: OutlineInputBorder(),
                  ),
                  items:
                      PlayerGender.values.map((gender) {
                        return DropdownMenuItem(
                          value: gender,
                          child: Text(
                            gender.label,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        );
                      }).toList(),
                  onChanged: (value) => setState(() => _selectedGender = value),
                  validator:
                      (value) => value == null ? 'Selecciona un género' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Locality>(
                  value: _selectedLocality,
                  decoration: const InputDecoration(
                    labelText: 'Localidad',
                    prefixIcon: Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items:
                      Locality.values.map((locality) {
                        return DropdownMenuItem(
                          value: locality,
                          child: Text(
                            locality.displayName,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        );
                      }).toList(),
                  onChanged:
                      (value) => setState(() => _selectedLocality = value),
                  validator:
                      (value) =>
                          value == null ? 'Selecciona tu localidad' : null,
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  PrimaryButton(text: 'Continuar', onPressed: _saveProfile),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
