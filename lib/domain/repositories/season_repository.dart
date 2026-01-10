import 'package:padel_punilla/domain/models/season_model.dart';
import 'package:padel_punilla/domain/models/season_score_model.dart';

abstract class SeasonRepository {
  Future<void> createSeason(SeasonModel season);
  Future<List<SeasonModel>> getAllSeasons();
  Future<List<SeasonModel>> getSeasonsByClub(String clubId);
  Future<SeasonModel?> getActiveSeason();
  Future<SeasonModel?> getActiveSeasonByClub(String clubId);
  Future<List<SeasonScoreModel>> getLeaderboard(
    String seasonId, {
    int limit = 50,
  });
  Future<SeasonScoreModel?> getUserScore(String seasonId, String userId);
  Future<int> getUserRank(String seasonId, double score);
  Future<void> updateUserScore(String seasonId, String userId, double newScore);
}
