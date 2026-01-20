import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/enums/player_gender.dart';
import 'package:padel_punilla/domain/models/user_model.dart';
import 'package:padel_punilla/domain/repositories/auth_repository.dart';
import 'package:provider/provider.dart';

/// Widget para seleccionar un compañero de partido.
///
/// Muestra:
/// - Usuarios seguidos del usuario actual
/// - Campo de búsqueda para buscar cualquier usuario
/// - Filtro por género si es necesario (partidos solo mujeres)
class PartnerSelector extends StatefulWidget {
  const PartnerSelector({
    required this.onPartnerSelected,
    super.key,
    this.excludeUserIds = const [],
    this.womenOnly = false,
  });

  /// IDs de usuarios a excluir (ya están en el partido)
  final List<String> excludeUserIds;

  /// Si es true, solo muestra mujeres
  final bool womenOnly;

  /// Callback cuando se selecciona un compañero
  final void Function(UserModel? partner) onPartnerSelected;

  @override
  State<PartnerSelector> createState() => _PartnerSelectorState();
}

class _PartnerSelectorState extends State<PartnerSelector> {
  final _searchController = TextEditingController();

  // Estado del widget
  bool _isLoading = true;
  List<UserModel> _followingUsers = [];
  List<UserModel> _searchResults = [];
  UserModel? _selectedPartner;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadFollowingUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Carga los usuarios que sigue el usuario actual
  Future<void> _loadFollowingUsers() async {
    setState(() => _isLoading = true);

    try {
      final authRepo = context.read<AuthRepository>();
      final firebaseUser = authRepo.currentUser;

      if (firebaseUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Obtener el usuario actual para ver a quiénes sigue
      final currentUser = await authRepo.getUserData(firebaseUser.uid);
      if (currentUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Cargar usuarios seguidos usando getUsersByIds
      final following = await authRepo.getUsersByIds(currentUser.following);

      // Filtrar usuarios
      final filtered = _filterUsers(following);

      setState(() {
        _followingUsers = filtered;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading following users: $e');
      setState(() => _isLoading = false);
    }
  }

  /// Busca usuarios por nombre o username
  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final authRepo = context.read<AuthRepository>();
      final results = await authRepo.searchUsers(query);

      // Filtrar resultados
      final filtered = _filterUsers(results);

      setState(() {
        _searchResults = filtered;
        _isSearching = false;
      });
    } catch (e) {
      debugPrint('Error searching users: $e');
      setState(() => _isSearching = false);
    }
  }

  /// Filtra usuarios según las restricciones
  List<UserModel> _filterUsers(List<UserModel> users) {
    final authRepo = context.read<AuthRepository>();
    final currentUserId = authRepo.currentUser?.uid;

    return users.where((user) {
      // Excluir usuarios que ya están en el partido
      if (widget.excludeUserIds.contains(user.id)) return false;

      // Excluir al usuario actual
      if (user.id == currentUserId) return false;

      // Filtrar por género si es solo mujeres
      if (widget.womenOnly && user.gender != PlayerGender.female) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo de búsqueda
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Buscar usuario...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon:
                _searchController.text.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _searchUsers('');
                      },
                    )
                    : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
          ),
          onChanged: (value) {
            // Debounce la búsqueda
            Future.delayed(const Duration(milliseconds: 300), () {
              if (_searchController.text == value) {
                _searchUsers(value);
              }
            });
          },
        ),

        const SizedBox(height: 12),

        // Contenedor de resultados
        Container(
          constraints: const BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _buildUsersList(colorScheme, textTheme),
        ),

        // Usuario seleccionado
        if (_selectedPartner != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.primary),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Compañero: ${_selectedPartner!.displayName}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: colorScheme.primary, size: 18),
                  onPressed: () {
                    setState(() => _selectedPartner = null);
                    widget.onPartnerSelected(null);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Construye la lista de usuarios
  Widget _buildUsersList(ColorScheme colorScheme, TextTheme textTheme) {
    // Mostrar estado de carga
    if (_isLoading || _isSearching) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Determinar qué lista mostrar
    final usersToShow =
        _searchController.text.isNotEmpty ? _searchResults : _followingUsers;

    // Estado vacío
    if (usersToShow.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_search,
                size: 32,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                _searchController.text.isNotEmpty
                    ? 'No se encontraron usuarios'
                    : 'No tienes usuarios seguidos',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Lista de usuarios
    return ListView.builder(
      shrinkWrap: true,
      itemCount: usersToShow.length,
      itemBuilder: (context, index) {
        final user = usersToShow[index];
        final isSelected = _selectedPartner?.id == user.id;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: colorScheme.primaryContainer,
            backgroundImage:
                user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
            child:
                user.photoUrl == null
                    ? Text(
                      user.displayName[0].toUpperCase(),
                      style: TextStyle(color: colorScheme.onPrimaryContainer),
                    )
                    : null,
          ),
          title: Text(user.displayName),
          subtitle: Text('@${user.username}'),
          trailing:
              isSelected
                  ? Icon(Icons.check_circle, color: colorScheme.primary)
                  : null,
          selected: isSelected,
          selectedTileColor: colorScheme.primaryContainer.withValues(
            alpha: 0.3,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          onTap: () {
            setState(() => _selectedPartner = isSelected ? null : user);
            widget.onPartnerSelected(isSelected ? null : user);
          },
        );
      },
    );
  }
}
