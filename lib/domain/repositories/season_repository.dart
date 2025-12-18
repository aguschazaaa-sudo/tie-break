import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:padel_punilla/domain/models/season_model.dart';
import 'package:padel_punilla/domain/models/season_score_model.dart';

class SeasonRepository {
  SeasonRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  Future<void> createSeason(SeasonModel season) async {
    final seasonMap = season.toMap();
    // Convert DateTimes to Timestamps for Firestore consistency
    seasonMap['startDate'] = Timestamp.fromDate(season.startDate);
    seasonMap['endDate'] = Timestamp.fromDate(season.endDate);

    await _firestore.collection('seasons').doc(season.id).set(seasonMap);
  }

  Future<List<SeasonModel>> getAllSeasons() async {
    final snapshot =
        await _firestore
            .collection('seasons')
            .orderBy('startDate', descending: true)
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      // Handle Timestamp to DateTime conversion manually
      if (data['startDate'] is Timestamp) {
        data['startDate'] = (data['startDate'] as Timestamp).toDate();
      }
      if (data['endDate'] is Timestamp) {
        data['endDate'] = (data['endDate'] as Timestamp).toDate();
      }
      return SeasonModel.fromMap(data, doc.id);
    }).toList();
  }

  Future<SeasonModel?> getActiveSeason() async {
    final snapshot =
        await _firestore
            .collection('seasons')
            .where('isActive', isEqualTo: true)
            .limit(1)
            .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      if (data['startDate'] is Timestamp) {
        data['startDate'] = (data['startDate'] as Timestamp).toDate();
      }
      if (data['endDate'] is Timestamp) {
        data['endDate'] = (data['endDate'] as Timestamp).toDate();
      }
      return SeasonModel.fromMap(data, snapshot.docs.first.id);
    }
    return null;
  }

  Future<List<SeasonScoreModel>> getLeaderboard(
    String seasonId, {
    int limit = 50,
  }) async {
    final snapshot =
        await _firestore
            .collection('seasons')
            .doc(seasonId)
            .collection('scores')
            .orderBy('score', descending: true)
            .limit(limit)
            .get();

    return snapshot.docs
        .map((doc) => SeasonScoreModel.fromMap(doc.data()))
        .toList();
  }

  Future<SeasonScoreModel?> getUserScore(String seasonId, String userId) async {
    final doc =
        await _firestore
            .collection('seasons')
            .doc(seasonId)
            .collection('scores')
            .doc(userId)
            .get();

    if (doc.exists) {
      return SeasonScoreModel.fromMap(doc.data()!);
    }
    return null;
  }

  Future<int> getUserRank(String seasonId, double score) async {
    // Count how many users have a higher score
    final countQuery =
        await _firestore
            .collection('seasons')
            .doc(seasonId)
            .collection('scores')
            .where('score', isGreaterThan: score)
            .count()
            .get();

    return countQuery.count! + 1;
  }

  Future<void> updateUserScore(
    String seasonId,
    String userId,
    double newScore,
  ) async {
    await _firestore
        .collection('seasons')
        .doc(seasonId)
        .collection('scores')
        .doc(userId)
        .set({
          'userId': userId,
          'score': newScore,
          'lastUpdated': FieldValue.serverTimestamp(),
          // We might want to increment matchesPlayed/Won here or use FieldValue.increment
          // For now, simple set for simulation
        }, SetOptions(merge: true),);
  }
}
