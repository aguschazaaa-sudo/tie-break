import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/models/season_model.dart';
import 'package:padel_punilla/domain/models/season_score_model.dart';
import 'package:padel_punilla/domain/models/user_model.dart';
import 'package:padel_punilla/presentation/widgets/leaderboard_user_tile.dart';

class LeaderboardListView extends StatelessWidget {
  const LeaderboardListView({
    required this.activeSeason,
    required this.topScores,
    required this.usersMap,
    required this.currentUserRank,
    super.key,
    this.futureSeason,
    this.currentUserScore,
    this.currentUser,
    this.isInterSeason = false,
  });
  final SeasonModel activeSeason;
  final SeasonModel? futureSeason;
  final List<SeasonScoreModel> topScores;
  final Map<String, UserModel> usersMap;
  final SeasonScoreModel? currentUserScore;
  final UserModel? currentUser;
  final int currentUserRank;
  final bool isInterSeason;

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isInterSeason && futureSeason != null)
          Container(
            color: Colors.blue.shade50,
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            child: Text(
              'Temporada finalizada. La próxima inicia el ${_formatDate(futureSeason!.startDate)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            activeSeason.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: topScores.length,
            itemBuilder: (context, index) {
              final score = topScores[index];
              final user = usersMap[score.userId];
              final rank = index + 1;
              final isMe =
                  currentUser != null && score.userId == currentUser!.id;

              return LeaderboardUserTile(
                score: score,
                user: user,
                rank: rank,
                isMe: isMe,
              );
            },
          ),
        ),
        if (currentUser != null && !_isInTop15()) _buildUserFooter(context),
      ],
    );
  }

  bool _isInTop15() {
    if (currentUser == null) return false;
    return topScores.any((s) => s.userId == currentUser!.id);
  }

  Widget _buildUserFooter(BuildContext context) {
    if (currentUserScore == null && currentUser == null) {
      return const SizedBox.shrink();
    }

    final displayScore =
        currentUserScore ??
        SeasonScoreModel(
          userId: currentUser?.id ?? '',
          score: 0,
          matchesPlayed: 0,
          matchesWon: 0,
        );

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: LeaderboardUserTile(
          score: displayScore,
          user: currentUser,
          rank: currentUserRank > 0 ? currentUserRank : 0,
          isMe: true,
        ),
      ),
    );
  }
}
