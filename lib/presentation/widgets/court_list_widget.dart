import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/models/court_model.dart';
import 'package:padel_punilla/domain/repositories/court_repository.dart';
import 'package:padel_punilla/presentation/screens/court/court_form_screen.dart';
import 'package:provider/provider.dart';

class CourtListWidget extends StatelessWidget {
  const CourtListWidget({
    required this.clubId,
    super.key,
    this.isDesktop = false,
    this.canManage = true,
    this.onCourtTap,
  });
  final String clubId;
  final bool isDesktop;

  final bool canManage;
  final Function(CourtModel)? onCourtTap;

  @override
  Widget build(BuildContext context) {
    final courtRepo = Provider.of<CourtRepository>(context, listen: false);

    return StreamBuilder<List<CourtModel>>(
      stream: courtRepo.getCourtsStream(clubId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final courts = snapshot.data ?? [];

        if (courts.isEmpty) {
          return _buildEmptyState(context);
        }

        if (isDesktop) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: courts.length,
            itemBuilder:
                (context, index) => _buildCourtCard(context, courts[index]),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: courts.length,
          itemBuilder:
              (context, index) => _buildCourtCard(context, courts[index]),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_tennis,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay canchas registradas',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          if (canManage)
            FilledButton.icon(
              onPressed: () => _navigateToForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Agregar Cancha'),
            ),
        ],
      ),
    );
  }

  Widget _buildCourtCard(BuildContext context, CourtModel court) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap:
            () =>
                onCourtTap != null
                    ? onCourtTap!(court)
                    : (canManage ? _navigateToForm(context, court) : null),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      court.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusChip(context, court),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${court.sport.name.toUpperCase()} - ${court.surfaceType.displayName.toUpperCase()}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (court.isCovered)
                    const Tooltip(
                      message: 'Techada',
                      child: Icon(Icons.roofing, size: 20),
                    ),
                  if (court.isCovered) const SizedBox(width: 8),
                  if (court.hasLighting)
                    const Tooltip(
                      message: 'Iluminación',
                      child: Icon(Icons.lightbulb, size: 20),
                    ),
                ],
              ),
              if (isDesktop) const Spacer() else const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${court.reservationPrice.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  if (canManage)
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _navigateToForm(context, court),
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, CourtModel court) {
    final color =
        court.isAvailable
            ? const Color(0xFF4CAF50)
            : Theme.of(context).colorScheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        court.isAvailable ? 'Activa' : 'Inactiva',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _navigateToForm(BuildContext context, [CourtModel? court]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourtFormScreen(clubId: clubId, court: court),
      ),
    );
  }
}
