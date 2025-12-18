import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/models/season_model.dart';

class LeaderboardPreSeasonState extends StatelessWidget {
  const LeaderboardPreSeasonState({required this.futureSeason, super.key});
  final SeasonModel futureSeason;

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Próxima Temporada',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Inicia el ${_formatDate(futureSeason.startDate)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
