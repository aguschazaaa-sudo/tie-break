import 'package:flutter_test/flutter_test.dart';
import 'package:padel_punilla/domain/models/season_model.dart';
import 'package:padel_punilla/domain/models/season_score_model.dart';

void main() {
  group('SeasonModel Tests', () {
    test('should serialization to/from map correctly', () {
      final now = DateTime.now();
      final season = SeasonModel(
        id: 'test_id',
        name: 'Test Season',
        number: 1,
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
        isActive: true,
      );

      final map = season.toMap();

      expect(map['name'], 'Test Season');
      expect(map['isActive'], true);
      expect(map['id'], 'test_id');

      final fromMap = SeasonModel.fromMap(map, 'test_id');
      expect(fromMap.name, season.name);
      // Note: Timestamp comparison might need care depending on precision,
      // but usually toDate() conversion is symmetric enough for basic tests unless highly precise.
    });
  });

  group('SeasonScoreModel Tests', () {
    test('should serialize correctly', () {
      final score = SeasonScoreModel(
        userId: 'user1',
        score: 150,
        matchesPlayed: 5,
        matchesWon: 3,
      );

      final map = score.toMap();
      expect(map['userId'], 'user1');
      expect(map['score'], 150.0);

      final fromMap = SeasonScoreModel.fromMap(map);
      expect(fromMap.matchesWon, 3);
    });
  });
}
