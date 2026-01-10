import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/models/season_model.dart';
import 'package:padel_punilla/domain/models/season_score_model.dart';
import 'package:padel_punilla/domain/models/user_model.dart';
import 'package:padel_punilla/domain/repositories/auth_repository.dart';
import 'package:padel_punilla/domain/repositories/season_repository.dart';
import 'package:padel_punilla/presentation/widgets/leaderboard/leaderboard_empty_state.dart';
import 'package:padel_punilla/presentation/widgets/leaderboard/leaderboard_list_view.dart';
import 'package:padel_punilla/presentation/widgets/leaderboard/leaderboard_pre_season_state.dart';
import 'package:provider/provider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  bool _isLoading = true;

  // Data State
  List<SeasonScoreModel> _topScores = [];
  Map<String, UserModel> _usersMap = {};
  SeasonModel? _activeSeason;
  SeasonModel? _pastSeason;
  SeasonModel? _futureSeason;

  // User specific
  SeasonScoreModel? _currentUserScore;
  int _currentUserRank = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final seasonRepo = context.read<SeasonRepository>();
    final authRepo = context.read<AuthRepository>();
    final currentUser = authRepo.currentUser;
    final now = DateTime.now();

    try {
      final seasons = await seasonRepo.getAllSeasons();

      if (seasons.isEmpty) {
        // Case A: No seasons
        _resetData();
      } else {
        // Find Active Season
        try {
          _activeSeason = seasons.firstWhere(
            (s) {
              return s.startDate.isBefore(now) && s.endDate.isAfter(now);
            },
            orElse: () => seasons.where((s) => s.isActive).first,
          ); // Fallback to isActive flag if needed
        } catch (_) {
          _activeSeason = null;
        }

        if (_activeSeason != null) {
          // Case B: Active Season
          await _loadSeasonStats(
            _activeSeason!,
            seasonRepo,
            authRepo,
            currentUser?.uid,
          );
        } else {
          // No active season. Check for Past and Future.

          // Future: First season starting after Now
          try {
            final futureSeasons =
                seasons.where((s) => s.startDate.isAfter(now)).toList();
            futureSeasons.sort((a, b) => a.startDate.compareTo(b.startDate));
            if (futureSeasons.isNotEmpty) _futureSeason = futureSeasons.first;
          } catch (_) {}

          // Past: First season ended before Now (closest to now)
          try {
            final pastSeasons =
                seasons.where((s) => s.endDate.isBefore(now)).toList();
            // Sort emerging from closest past
            pastSeasons.sort((a, b) => b.endDate.compareTo(a.endDate));
            if (pastSeasons.isNotEmpty) _pastSeason = pastSeasons.first;
          } catch (_) {}

          if (_pastSeason != null) {
            // Case D: Inter-Season (Show past season results)
            await _loadSeasonStats(
              _pastSeason!,
              seasonRepo,
              authRepo,
              currentUser?.uid,
            );
          }
          // Case C: Pre-Season (only future exists) -> Managed in build
        }
      }
    } catch (e) {
      debugPrint('Error loading leaderboard data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _resetData() {
    _activeSeason = null;
    _pastSeason = null;
    _futureSeason = null;
    _topScores = [];
    _usersMap = {};
    _currentUserScore = null;
    _currentUserRank = 0;
  }

  Future<void> _loadSeasonStats(
    SeasonModel season,
    SeasonRepository seasonRepo,
    AuthRepository authRepo,
    String? currentUserId,
  ) async {
    // 1. Get Top 15
    final scores = await seasonRepo.getLeaderboard(season.id, limit: 15);
    _topScores = scores;

    // 2. Get User Info for these scores
    final userIds = scores.map((e) => e.userId).toSet().toList();
    if (currentUserId != null) userIds.add(currentUserId);

    if (userIds.isNotEmpty) {
      final users = await authRepo.getUsersByIds(userIds);
      _usersMap = {for (final u in users) u.id: u};
    }

    // 3. Check current user status
    if (currentUserId != null) {
      // Check if in top list first
      final inTopIndex = scores.indexWhere((s) => s.userId == currentUserId);
      if (inTopIndex != -1) {
        _currentUserScore = scores[inTopIndex];
        _currentUserRank = inTopIndex + 1;
      } else {
        // Helper method to get individual score
        final userScore = await seasonRepo.getUserScore(
          season.id,
          currentUserId,
        );
        if (userScore != null) {
          _currentUserScore = userScore;
          _currentUserRank = await seasonRepo.getUserRank(
            season.id,
            userScore.score,
          );
        } else {
          _currentUserScore = null;
          _currentUserRank = 0;
        }
      }
    }
  }

  Future<void> _seedTestData() async {
    final seasonRepo = context.read<SeasonRepository>();
    final authRepo = context.read<AuthRepository>();

    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      // Create Active Season
      final seasonId = 'season_active_${DateTime.now().millisecondsSinceEpoch}';
      final newSeason = SeasonModel(
        id: seasonId,
        name: 'Temporada Activa',
        clubId: 'debug_club',
        number: 1,
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        endDate: DateTime.now().add(const Duration(days: 20)),
        isActive: true,
      );
      await seasonRepo.createSeason(newSeason);

      // Add scores
      final currentUser = authRepo.currentUser;
      if (currentUser != null) {
        await seasonRepo.updateUserScore(seasonId, currentUser.uid, 500);
      }

      // Add dummy scores
      for (var i = 0; i < 20; i++) {
        await seasonRepo.updateUserScore(
          seasonId,
          'bot_$i',
          (1000 - i * 50).toDouble(),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Datos generados. Temporada Activa creada.'),
          ),
        );
      }
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _seedTestData,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildBody(),
    );
  }

  Widget _buildBody() {
    // Case A: No Seasons at all
    if (_activeSeason == null && _pastSeason == null && _futureSeason == null) {
      return const LeaderboardEmptyState();
    }

    // Case C: Only Future Season (Pre-Season)
    if (_activeSeason == null && _pastSeason == null && _futureSeason != null) {
      return LeaderboardPreSeasonState(futureSeason: _futureSeason!);
    }

    // Case B & D: Active or Past Season
    final displaySeason = _activeSeason ?? _pastSeason;
    final isInterSeason = _activeSeason == null && _pastSeason != null;
    final authUser = context.read<AuthRepository>().currentUser;
    final currentUserModel = authUser != null ? _usersMap[authUser.uid] : null;

    return LeaderboardListView(
      activeSeason: displaySeason!,
      futureSeason: _futureSeason,
      topScores: _topScores,
      usersMap: _usersMap,
      currentUserScore: _currentUserScore,
      currentUser: currentUserModel,
      currentUserRank: _currentUserRank,
      isInterSeason: isInterSeason,
    );
  }
}
