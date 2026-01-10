import 'package:padel_punilla/domain/models/court_model.dart';

abstract class CourtRepository {
  Future<void> createCourt(String clubId, CourtModel court);
  Future<List<CourtModel>> getCourts(String clubId);
  Future<void> updateCourt(String clubId, CourtModel court);
  Future<void> deleteCourt(String clubId, String courtId);
  Stream<List<CourtModel>> getCourtsStream(String clubId);
}
