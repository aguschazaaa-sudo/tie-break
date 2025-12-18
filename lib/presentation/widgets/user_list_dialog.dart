import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/models/user_model.dart';
import 'package:padel_punilla/domain/repositories/auth_repository.dart';
import 'package:provider/provider.dart';

class UserListDialog extends StatefulWidget {
  const UserListDialog({
    required this.title,
    required this.userIds,
    required this.isFollowersList,
    required this.currentUserId,
    required this.onUpdate,
    super.key,
  });
  final String title;
  final List<String> userIds;
  final bool isFollowersList;
  final String currentUserId;
  final VoidCallback onUpdate;

  @override
  State<UserListDialog> createState() => _UserListDialogState();
}

class _UserListDialogState extends State<UserListDialog> {
  bool _isLoading = true;
  List<UserModel> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final authRepo = Provider.of<AuthRepository>(context, listen: false);
      final users = await authRepo.getUsersByIds(widget.userIds);
      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar usuarios: $e')));
      }
    }
  }

  Future<void> _handleAction(UserModel targetUser) async {
    try {
      final authRepo = Provider.of<AuthRepository>(context, listen: false);

      if (widget.isFollowersList) {
        // Eliminar seguidor (hacer que me deje de seguir)
        await authRepo.removeFollower(widget.currentUserId, targetUser.id);
      } else {
        // Dejar de seguir (yo dejo de seguirlo a él)
        await authRepo.unfollowUser(widget.currentUserId, targetUser.id);
      }

      if (mounted) {
        // Actualizar lista local
        setState(() {
          _users.removeWhere((u) => u.id == targetUser.id);
        });
        // Notificar al padre para actualizar contadores
        widget.onUpdate();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Acción completada')));

        if (_users.isEmpty) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                ? const Center(child: Text('No hay usuarios'))
                : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            user.photoUrl != null
                                ? NetworkImage(user.photoUrl!)
                                : null,
                        child:
                            user.photoUrl == null
                                ? Text(user.displayName[0].toUpperCase())
                                : null,
                      ),
                      title: Text(
                        '@${user.username}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.displayName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '#${user.discriminator}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.outline,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          widget.isFollowersList
                              ? Icons.remove_circle_outline
                              : Icons.person_remove,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        tooltip:
                            widget.isFollowersList
                                ? 'Eliminar seguidor'
                                : 'Dejar de seguir',
                        onPressed: () => _handleAction(user),
                      ),
                    );
                  },
                ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
