import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/models/user_model.dart';
import 'package:padel_punilla/domain/repositories/auth_repository.dart';
import 'package:padel_punilla/presentation/providers/club_management_provider.dart';
import 'package:padel_punilla/presentation/widgets/skeleton_loader.dart';
import 'package:padel_punilla/presentation/widgets/user_search_dialog.dart';
import 'package:provider/provider.dart';

class ClubTeamTab extends StatelessWidget {
  final bool isDesktop;

  const ClubTeamTab({super.key, required this.isDesktop});

  Future<void> _addHelper(BuildContext context) async {
    final provider = context.read<ClubManagementProvider>();
    final club = provider.club;

    if (club == null) return;

    showDialog(
      context: context,
      builder:
          (context) => UserSearchDialog(
            onUserSelected: (user) async {
              try {
                // Determine if we need to verify here or if provider does it.
                // Provider throws if invalid.
                // But better to check locally for immediate feedback if data is available?
                // The provider checks:
                // if (helperIds.contains) throw
                // if (adminId == uid) throw

                await provider.addHelper(user.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${user.displayName} agregado como colaborador',
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  // Strip "Exception: " if present for cleaner message
                  final message = e.toString().replaceAll('Exception: ', '');
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(message)));
                }
              }
            },
          ),
    );
  }

  Future<void> _removeHelper(BuildContext context, String helperId) async {
    try {
      await context.read<ClubManagementProvider>().removeHelper(helperId);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar colaborador: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final club = context.watch<ClubManagementProvider>().club;
    if (club == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResponsiveSectionHeader(
            context,
            'Equipo de Trabajo',
            'Los administradores tienen acceso total. Los colaboradores pueden gestionar reservas.',
            FilledButton.icon(
              onPressed: () => _addHelper(context),
              icon: const Icon(Icons.person_add),
              label: const Text('Agregar Colaborador'),
              style: FilledButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.secondaryContainer,
                foregroundColor:
                    Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            isDesktop,
          ),
          const SizedBox(height: 24),
          _buildAdminSection(context, club.adminId),
          const SizedBox(height: 24),
          Text(
            'Colaboradores',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (club.helperIds.isEmpty)
            _buildEmptyState(
              context,
              'No hay colaboradores asignados.',
              Icons.people_outline,
            )
          else
            isDesktop
                ? GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: club.helperIds.length,
                  itemBuilder:
                      (context, index) =>
                          _buildHelperCard(context, club.helperIds[index]),
                )
                : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: club.helperIds.length,
                  itemBuilder:
                      (context, index) =>
                          _buildHelperCard(context, club.helperIds[index]),
                ),
        ],
      ),
    );
  }

  Widget _buildAdminSection(BuildContext context, String adminId) {
    return Card(
      elevation: 0,
      color: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ADMINISTRADOR',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            FutureBuilder<UserModel?>(
              future: context.read<AuthRepository>().getUserData(adminId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SkeletonLoader(height: 50);
                final user = snapshot.data!;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 28,
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(user.displayName),
                  trailing: const Icon(Icons.verified, color: Colors.blue),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelperCard(BuildContext context, String helperId) {
    return FutureBuilder<UserModel?>(
      future: context.read<AuthRepository>().getUserData(helperId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SkeletonLoader(height: 80);
        final user = snapshot.data!;
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              radius: 24,
              backgroundImage:
                  user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
              child:
                  user.photoUrl == null
                      ? Text(user.displayName[0].toUpperCase())
                      : null,
            ),
            title: Text(
              '@${user.username}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(user.displayName),
            trailing: IconButton(
              icon: Icon(
                Icons.remove_circle_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              onPressed: () => _removeHelper(context, helperId),
              tooltip: 'Eliminar Colaborador',
            ),
          ),
        );
      },
    );
  }

  Widget _buildResponsiveSectionHeader(
    BuildContext context,
    String title,
    String subtitle,
    Widget action,
    bool isDesktop,
  ) {
    if (isDesktop) {
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
}
