import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:padel_punilla/domain/models/season_model.dart';
import 'package:padel_punilla/presentation/providers/club_management_provider.dart';
import 'package:provider/provider.dart';

class ClubSeasonsTab extends StatefulWidget {
  const ClubSeasonsTab({required this.isDesktop, super.key});
  final bool isDesktop;

  @override
  State<ClubSeasonsTab> createState() => _ClubSeasonsTabState();
}

class _ClubSeasonsTabState extends State<ClubSeasonsTab> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClubManagementProvider>();
    final seasons = provider.seasons;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSeasonDialog(context),
        label: const Text('Nueva Temporada'),
        icon: const Icon(Icons.add),
      ),
      body:
          seasons.isEmpty
              ? _buildEmptyState(context)
              : ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: seasons.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final season = seasons[index];
                  return _buildSeasonCard(context, season, colorScheme);
                },
              ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay temporadas registradas',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonCard(
    BuildContext context,
    SeasonModel season,
    ColorScheme colorScheme,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final isActive = season.isActive;

    return Card(
      elevation: 0,
      color:
          isActive
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side:
            isActive
                ? BorderSide(color: colorScheme.primary, width: 2)
                : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isActive
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isActive ? Icons.emoji_events : Icons.history,
                color:
                    isActive
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    season.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dateFormat.format(season.startDate)} - ${dateFormat.format(season.endDate)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isActive,
              onChanged: (value) async {
                try {
                  await context
                      .read<ClubManagementProvider>()
                      .toggleSeasonStatus(season.id);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al actualizar: $e')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateSeasonDialog(BuildContext context) async {
    final nameController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Nueva Temporada'),
            content: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la Temporada',
                        hintText: 'Ej. Verano 2024',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDatePicker(
                      context,
                      'Fecha Inicio',
                      startDate,
                      (date) => setState(() => startDate = date),
                    ),
                    const SizedBox(height: 16),
                    _buildDatePicker(
                      context,
                      'Fecha Fin',
                      endDate,
                      (date) => setState(() => endDate = date),
                    ),
                  ],
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () async {
                  if (nameController.text.isEmpty ||
                      startDate == null ||
                      endDate == null) {
                    return;
                  }
                  if (endDate!.isBefore(startDate!)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'La fecha fin debe ser posterior al inicio',
                        ),
                      ),
                    );
                    return;
                  }

                  try {
                    await context.read<ClubManagementProvider>().createSeason(
                      name: nameController.text,
                      startDate: startDate!,
                      endDate: endDate!,
                    );
                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
                child: const Text('Crear'),
              ),
            ],
          ),
    );
  }

  Widget _buildDatePicker(
    BuildContext context,
    String label,
    DateTime? selectedDate,
    Function(DateTime) onSelect,
  ) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (date != null) onSelect(date);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          selectedDate != null
              ? DateFormat('dd/MM/yyyy').format(selectedDate)
              : 'Seleccionar fecha',
        ),
      ),
    );
  }
}
