import 'package:padel_punilla/domain/enums/locality.dart';
import 'package:padel_punilla/domain/models/club_model.dart';

abstract class ClubRepository {
  Future<void> createClub(ClubModel club);
  Future<ClubModel?> getClub(String id);
  Future<void> updateClub(ClubModel club);
  Future<List<ClubModel>> getClubsByLocality(Locality locality);
  Future<List<ClubModel>> getAllActiveClubs();
  Future<ClubModel?> getClubByUserId(String userId);
  Future<List<ClubModel>> searchClubsByName(String query);
  Future<List<ClubModel>> getClubsByIds(List<String> clubIds);
}
