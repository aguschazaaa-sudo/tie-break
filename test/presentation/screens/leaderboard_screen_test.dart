import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:padel_punilla/domain/models/season_model.dart';
import 'package:padel_punilla/domain/models/season_score_model.dart';
import 'package:padel_punilla/domain/models/user_model.dart';
import 'package:padel_punilla/domain/repositories/auth_repository.dart';
import 'package:padel_punilla/domain/repositories/season_repository.dart';
import 'package:padel_punilla/presentation/screens/season/leaderboard_screen.dart';
import 'package:provider/provider.dart';

// Mocks
class MockSeasonRepository extends Mock implements SeasonRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUser extends Mock implements auth.User {}

void main() {
  late MockSeasonRepository mockSeasonRepo;
  late MockAuthRepository mockAuthRepo;

  setUp(() {
    mockSeasonRepo = MockSeasonRepository();
    mockAuthRepo = MockAuthRepository();
    registerFallbackValue(
      SeasonModel(
        id: 'fallback',
        name: 'fallback',
        clubId: 'fallback',
        number: 0,
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        isActive: false,
      ),
    );
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        Provider<SeasonRepository>.value(value: mockSeasonRepo),
        Provider<AuthRepository>.value(value: mockAuthRepo),
      ],
      child: const MaterialApp(home: LeaderboardScreen()),
    );
  }

  testWidgets('Leaderboard shows "No seasons" when list is empty', (
    tester,
  ) async {
    when(() => mockSeasonRepo.getAllSeasons()).thenAnswer((_) async => []);
    when(() => mockAuthRepo.currentUser).thenReturn(null);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle(); // Wait for future

    expect(find.text('Ranking'), findsOneWidget);
    expect(
      find.textContaining('No hay registro de temporadas'),
      findsOneWidget,
    );
  });

  testWidgets('Leaderboard shows active season and list', (tester) async {
    // Data
    final now = DateTime.now();
    final season = SeasonModel(
      id: 's1',
      name: 'Season 1',
      clubId: 'club1',
      number: 1,
      startDate: now.subtract(const Duration(days: 10)),
      endDate: now.add(const Duration(days: 10)),
      isActive: true,
    );

    final scoreUser1 = SeasonScoreModel(
      userId: 'u1',
      score: 100,
      matchesPlayed: 1,
      matchesWon: 1,
    );
    final user1 = UserModel(
      id: 'u1',
      email: 'u@test.com',
      username: 'player1',
      displayName: 'Player One',
      discriminator: '0000',
      createdAt: now,
    );

    // Stubs
    when(
      () => mockSeasonRepo.getAllSeasons(),
    ).thenAnswer((_) async => [season]);
    when(
      () => mockSeasonRepo.getLeaderboard(any(), limit: any(named: 'limit')),
    ).thenAnswer((_) async => [scoreUser1]);
    when(
      () => mockAuthRepo.getUsersByIds(any()),
    ).thenAnswer((_) async => [user1]);
    when(() => mockAuthRepo.currentUser).thenReturn(null);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.textContaining('Season 1'), findsOneWidget);
    expect(find.textContaining('Player One'), findsOneWidget);
    expect(find.textContaining('100 pts'), findsOneWidget);
  });
}
