import 'package:flutter_test/flutter_test.dart';
import 'package:padel_punilla/domain/models/season_model.dart';

void main() {
  group('SeasonModel', () {
    test('supports value equality', () {
      final date1 = DateTime(2023, 1, 1);
      final date2 = DateTime(2023, 12, 31);
      final season1 = SeasonModel(
        id: '1',
        name: 'Season 1',
        number: 1,
        startDate: date1,
        endDate: date2,
        isActive: true,
      );
      final season2 = SeasonModel(
        id: '1',
        name: 'Season 1',
        number: 1,
        startDate: date1,
        endDate: date2,
        isActive: true,
      );

      expect(season1, equals(season2));
    });

    test('fromMap handles DateTime objects correctly', () {
      final date1 = DateTime(2023, 1, 1);
      final date2 = DateTime(2023, 12, 31);
      final map = {
        'name': 'Season 1',
        'number': 1,
        'startDate': date1,
        'endDate': date2,
        'isActive': true,
      };

      final season = SeasonModel.fromMap(map, '1');

      expect(season.startDate, equals(date1));
      expect(season.endDate, equals(date2));
    });

    test('fromMap handles ISO String dates correctly', () {
      final date1 = DateTime(2023, 1, 1);
      final date2 = DateTime(2023, 12, 31);
      final map = {
        'name': 'Season 1',
        'number': 1,
        'startDate': date1.toIso8601String(),
        'endDate': date2.toIso8601String(),
        'isActive': true,
      };

      final season = SeasonModel.fromMap(map, '1');

      expect(season.startDate, equals(date1));
      expect(season.endDate, equals(date2));
    });

    test('toMap converts dates to ISO strings', () {
      final date1 = DateTime(2023, 1, 1);
      final date2 = DateTime(2023, 12, 31);
      final season = SeasonModel(
        id: '1',
        name: 'Season 1',
        number: 1,
        startDate: date1,
        endDate: date2,
        isActive: true,
      );

      final map = season.toMap();

      expect(map['startDate'], equals(date1.toIso8601String()));
      expect(map['endDate'], equals(date2.toIso8601String()));
    });
  });
}
