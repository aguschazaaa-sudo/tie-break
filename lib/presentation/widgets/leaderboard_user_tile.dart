import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/models/season_score_model.dart';
import 'package:padel_punilla/domain/models/user_model.dart';
import 'package:padel_punilla/presentation/widgets/surface_card.dart';

class LeaderboardUserTile extends StatelessWidget {
  const LeaderboardUserTile({
    required this.score,
    required this.user,
    required this.rank,
    super.key,
    this.isMe = false,
  });
  final SeasonScoreModel score;
  final UserModel? user;
  final int rank;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: SurfaceCard(
        padding: const EdgeInsets.all(12),
        // Highlight current user with a subtle primary container background or just shiny
        backgroundColor:
            isMe
                ? Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.1)
                : null,
        isGlass:
            isMe, // Make "Me" items glass for emphasis? Or maybe just shiny?
        isShiny: isMe,
        child: Row(
          children: [
            _buildRankBadge(context),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.displayName ?? 'Usuario desconocido',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: isMe ? FontWeight.bold : FontWeight.w500,
                      color:
                          isMe
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '@${user?.username ?? ""}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${score.score.toStringAsFixed(0)} pts',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankBadge(BuildContext context) {
    Color badgeColor;
    var textColor = Colors.white; // Default for medals usually

    switch (rank) {
      case 1:
        badgeColor = const Color(0xFFFFD700); // Gold
      case 2:
        badgeColor = const Color(0xFFC0C0C0); // Silver
      case 3:
        badgeColor = const Color(0xFFCD7F32); // Bronze
      default:
        badgeColor = Theme.of(context).colorScheme.surfaceContainerHighest;
        textColor = Theme.of(context).colorScheme.onSurfaceVariant;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
        boxShadow: [
          if (rank <= 3)
            BoxShadow(
              color: badgeColor.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '$rank',
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
