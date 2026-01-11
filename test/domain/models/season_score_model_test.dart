import 'package:flutter_test/flutter_test.dart';
import 'package:padel_punilla/domain/models/season_score_model.dart';

void main() {
  group('SeasonScoreModel', () {
    final seasonScore = SeasonScoreModel(
      userId: 'user1',
      score: 100,
      matchesPlayed: 10,
      matchesWon: 5,
    );

    final seasonScoreMap = {
      'userId': 'user1',
      'score': 100,
      'matchesPlayed': 10,
      'matchesWon': 5,
    };

    test('supports value comparisons', () {
      expect(seasonScore, equals(seasonScore));
    });

    test('fromMap creates valid instance', () {
      expect(SeasonScoreModel.fromMap(seasonScoreMap), equals(seasonScore));
    });

    test('toMap creates valid map', () {
      expect(seasonScore.toMap(), equals(seasonScoreMap));
    });

    test('toString returns correct string', () {
      expect(
        seasonScore.toString(),
        equals(
          'SeasonScoreModel(userId: user1, score: 100.0, matchesPlayed: 10, matchesWon: 5)',
        ),
      );
    });
  });
}
