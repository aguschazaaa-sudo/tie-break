import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/enums/player_gender.dart';
import 'package:padel_punilla/domain/models/user_model.dart';
import 'package:padel_punilla/domain/repositories/auth_repository.dart';
import 'package:provider/provider.dart';

/// Diálogo para seleccionar un usuario (para pareja, oponente, etc.)
///
/// [genderFilter] - Si se especifica, solo se permitirán usuarios de ese género.
/// Por ejemplo, para reservas "solo mujeres" se pasa [PlayerGender.female].
class UserSelectionDialog extends StatelessWidget {
  /// Filtro de género opcional. Si es null, se aceptan todos los géneros.
  final PlayerGender? genderFilter;

  const UserSelectionDialog({super.key, this.genderFilter});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          height: 500,
          child: Column(
            children: [
              // Título con indicador de filtro si aplica
              if (genderFilter != null)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.female,
                        color: Theme.of(context).colorScheme.tertiary,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Solo Mujeres',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              const TabBar(
                tabs: [
                  Tab(text: 'Buscar', icon: Icon(Icons.search)),
                  Tab(text: 'Siguiendo', icon: Icon(Icons.people)),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _SearchTab(genderFilter: genderFilter),
                    _FollowingTab(genderFilter: genderFilter),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchTab extends StatefulWidget {
  final PlayerGender? genderFilter;
  const _SearchTab({this.genderFilter});

  @override
  State<_SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<_SearchTab> {
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _results = [];
  bool _isLoading = false;
  String? _error;

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authRepo = context.read<AuthRepository>();
      final results = await authRepo.searchUsers(query);
      if (mounted) {
        setState(() => _results = results);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Buscar por @usuario...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: _search,
          ),
        ),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_error != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(_error!, style: const TextStyle(color: Colors.red)),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final user = _results[index];
                final matchesFilter =
                    widget.genderFilter == null ||
                    user.gender == widget.genderFilter;

                return _UserListTile(
                  user: user,
                  enabled: matchesFilter,
                  disabledReason:
                      matchesFilter ? null : 'Solo mujeres pueden participar',
                  onTap:
                      matchesFilter ? () => Navigator.pop(context, user) : null,
                );
              },
            ),
          ),
      ],
    );
  }
}

class _FollowingTab extends StatelessWidget {
  final PlayerGender? genderFilter;
  const _FollowingTab({this.genderFilter});

  @override
  Widget build(BuildContext context) {
    final authRepo = context.watch<AuthRepository>();
    final currentUser = authRepo.currentUser;

    if (currentUser == null) {
      return const Center(child: Text('Debes iniciar sesión'));
    }

    // We need to fetch the full user model to get the 'following' list
    // because authRepo.currentUser is just the Firebase User,
    // but the following list is in the Firestore UserModel.
    // However, usually we might have the UserModel stored in a provider.
    // Assuming we need to fetch it or it's available.
    // Based on previous files, AuthRepository has getUserData.

    return FutureBuilder<UserModel?>(
      future: authRepo.getUserData(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final userModel = snapshot.data;
        if (userModel == null || userModel.following.isEmpty) {
          return const Center(child: Text('No sigues a nadie aún'));
        }

        return FutureBuilder<List<UserModel>>(
          future: authRepo.getUsersByIds(userModel.following),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final following = snapshot.data ?? [];
            if (following.isEmpty) {
              return const Center(child: Text('No se encontraron usuarios'));
            }

            return ListView.builder(
              itemCount: following.length,
              itemBuilder: (context, index) {
                final user = following[index];
                final matchesFilter =
                    genderFilter == null || user.gender == genderFilter;

                return _UserListTile(
                  user: user,
                  enabled: matchesFilter,
                  disabledReason:
                      matchesFilter ? null : 'Solo mujeres pueden participar',
                  onTap:
                      matchesFilter ? () => Navigator.pop(context, user) : null,
                );
              },
            );
          },
        );
      },
    );
  }
}

/// Tile para mostrar un usuario en la lista de selección
class _UserListTile extends StatelessWidget {
  const _UserListTile({
    required this.user,
    this.onTap,
    this.enabled = true,
    this.disabledReason,
  });

  final UserModel user;
  final VoidCallback? onTap;
  final bool enabled;
  final String? disabledReason;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage:
              user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
          child:
              user.photoUrl == null
                  ? Text(user.displayName[0].toUpperCase())
                  : null,
        ),
        title: Text(user.displayName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('@${user.username}'),
            if (!enabled && disabledReason != null)
              Text(
                disabledReason!,
                style: TextStyle(color: colorScheme.error, fontSize: 11),
              ),
          ],
        ),
        trailing:
            enabled
                ? const Icon(Icons.check_circle_outline)
                : Icon(
                  Icons.block,
                  color: colorScheme.error.withValues(alpha: 0.5),
                ),
        onTap: onTap,
      ),
    );
  }
}
