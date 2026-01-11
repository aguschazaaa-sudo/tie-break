import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/enums/paddle_category.dart';
import 'package:padel_punilla/domain/enums/player_gender.dart';
import 'package:padel_punilla/domain/models/user_model.dart';
import 'package:padel_punilla/domain/repositories/auth_repository.dart';
import 'package:padel_punilla/domain/repositories/club_repository.dart';
import 'package:padel_punilla/presentation/screens/auth/login_screen.dart';
import 'package:padel_punilla/presentation/screens/club/club_management_screen.dart';
import 'package:padel_punilla/presentation/screens/policies/privacy_policy_screen.dart';
import 'package:padel_punilla/presentation/screens/policies/terms_conditions_screen.dart';
import 'package:padel_punilla/presentation/screens/profile/widgets/profile_header.dart';
import 'package:padel_punilla/presentation/screens/profile/widgets/profile_stats.dart';
import 'package:padel_punilla/presentation/widgets/ambient_glow.dart';
import 'package:padel_punilla/presentation/widgets/surface_card.dart';
import 'package:padel_punilla/presentation/widgets/user_list_dialog.dart';
import 'package:padel_punilla/presentation/widgets/user_search_dialog.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  PaddleCategory? _selectedCategory;
  PlayerGender? _selectedGender;
  bool _isLoading = false;
  UserModel? _currentUser;
  bool _hasClubAccess = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final authRepo = Provider.of<AuthRepository>(context, listen: false);
      final clubRepo = Provider.of<ClubRepository>(context, listen: false);
      final user = authRepo.currentUser;
      if (user != null) {
        final userData = await authRepo.getUserData(user.uid);
        final club = await clubRepo.getClubByUserId(user.uid);

        if (userData != null) {
          setState(() {
            _currentUser = userData;
            _displayNameController.text = userData.displayName;
            _selectedCategory = userData.category;
            _selectedGender = userData.gender;
            _hasClubAccess = club != null;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar perfil: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentUser == null) return;

    setState(() => _isLoading = true);
    try {
      final updatedUser = _currentUser!.copyWith(
        displayName: _displayNameController.text.trim(),
        category: _selectedCategory,
        gender: _selectedGender,
      );

      await Provider.of<AuthRepository>(
        context,
        listen: false,
      ).updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await Provider.of<AuthRepository>(context, listen: false).signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cerrar sesión: $e')));
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body:
          _currentUser == null
              ? const Center(child: Text('No se pudo cargar el perfil'))
              : Stack(
                children: [
                  Positioned(
                    top: -100,
                    right: -100,
                    child: AmbientGlow(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Positioned(
                    bottom: -100,
                    left: -100,
                    child: AmbientGlow(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: SurfaceCard(
                          isGlass: true,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                ProfileHeader(user: _currentUser!),
                                const SizedBox(height: 24),
                                ProfileStats(
                                  user: _currentUser!,
                                  onFollowersTap:
                                      () => _showUsersListDialog(
                                        title: 'Seguidores',
                                        userIds: _currentUser!.followers,
                                        isFollowersList: true,
                                      ),
                                  onFollowingTap:
                                      () => _showUsersListDialog(
                                        title: 'Seguidos',
                                        userIds: _currentUser!.following,
                                        isFollowersList: false,
                                      ),
                                ),
                                const SizedBox(height: 16),
                                OutlinedButton.icon(
                                  onPressed: _showFollowDialog,
                                  icon: const Icon(Icons.person_add),
                                  label: const Text('Seguir Usuario'),
                                ),
                                const SizedBox(height: 24),
                                TextFormField(
                                  controller: _displayNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Nombre Visible',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.person),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingresa un nombre';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                DropdownButtonFormField<PaddleCategory>(
                                  value: _selectedCategory,
                                  decoration: const InputDecoration(
                                    labelText: 'Categoría',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.sports_tennis),
                                  ),
                                  items:
                                      PaddleCategory.values.map((category) {
                                        return DropdownMenuItem(
                                          value: category,
                                          child: Text(category.label),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedCategory = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<PlayerGender>(
                                  value: _selectedGender,
                                  decoration: const InputDecoration(
                                    labelText: 'Género',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.people),
                                  ),
                                  items:
                                      PlayerGender.values.map((gender) {
                                        return DropdownMenuItem(
                                          value: gender,
                                          child: Text(gender.label),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedGender = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 32),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _saveProfile,
                                    child:
                                        _isLoading
                                            ? const CircularProgressIndicator()
                                            : const Text('Guardar Cambios'),
                                  ),
                                ),
                                if (_hasClubAccess) ...[
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    const ClubManagementScreen(),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.store),
                                      label: const Text('Gestionar Mi Club'),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 24),
                                const Divider(),
                                const SizedBox(height: 16),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Legales',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(
                                    Icons.privacy_tip_outlined,
                                  ),
                                  title: const Text('Política de Privacidad'),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                const PrivacyPolicyScreen(),
                                      ),
                                    );
                                  },
                                ),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(
                                    Icons.description_outlined,
                                  ),
                                  title: const Text('Términos y Condiciones'),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                const TermsConditionsScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  Future<void> _showUsersListDialog({
    required String title,
    required List<String> userIds,
    required bool isFollowersList,
  }) async {
    if (userIds.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('La lista está vacía')));
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => UserListDialog(
            title: title,
            userIds: userIds,
            isFollowersList: isFollowersList,
            currentUserId: _currentUser!.id,
            onUpdate: _loadUserData,
          ),
    );
  }

  Future<void> _showFollowDialog() async {
    await showDialog(
      context: context,
      builder: (context) => const UserSearchDialog(),
    );
    _loadUserData(); // Recargar al cerrar por si siguió a alguien
  }
}
