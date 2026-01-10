import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:padel_punilla/domain/models/club_model.dart';
import 'package:padel_punilla/domain/models/reservation_model.dart';
import 'package:padel_punilla/domain/models/season_model.dart';

import 'package:padel_punilla/domain/models/user_model.dart';
import 'package:padel_punilla/domain/repositories/auth_repository.dart';
import 'package:padel_punilla/domain/repositories/club_repository.dart';
import 'package:padel_punilla/domain/repositories/reservation_repository.dart';
import 'package:padel_punilla/domain/repositories/season_repository.dart';
import 'package:padel_punilla/domain/repositories/storage_repository.dart';
import 'package:padel_punilla/presentation/providers/club_management_provider.dart';
import 'package:padel_punilla/domain/enums/reservation_enums.dart';
import 'package:padel_punilla/domain/enums/locality.dart';

// Mocks
class MockAuthRepository extends Mock implements AuthRepository {}

class MockClubRepository extends Mock implements ClubRepository {}

class MockReservationRepository extends Mock implements ReservationRepository {}

class MockSeasonRepository extends Mock implements SeasonRepository {}

class MockStorageRepository extends Mock implements StorageRepository {}

class MockUser extends Mock implements User {}

class MockUserModel extends Mock implements UserModel {}

void main() {
  group('ClubManagementProvider Tests', () {
    late ClubManagementProvider provider;
    late MockAuthRepository authRepo;
    late MockClubRepository clubRepo;
    late MockReservationRepository reservationRepo;
    late MockSeasonRepository seasonRepo;
    late MockStorageRepository storageRepo;
    late MockUser mockUser;

    setUp(() async {
      authRepo = MockAuthRepository();
      clubRepo = MockClubRepository();
      reservationRepo = MockReservationRepository();
      seasonRepo = MockSeasonRepository();
      storageRepo = MockStorageRepository();
      mockUser = MockUser();

      registerFallbackValue(DateTime.now());
      // Register fallback for ReservationModel for verify
      registerFallbackValue(
        ReservationModel(
          id: 'fallback',
          courtId: '',
          clubId: '',
          userId: '',
          reservedDate: DateTime.now(),
          startTime: DateTime.now(),
          durationMinutes: 60,
          createdAt: DateTime.now(),
          price: 0,
        ),
      );

      // Stubs
      when(() => authRepo.currentUser).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('admin1');

      final testClub = ClubModel(
        id: 'club1',
        name: 'Club Test',
        adminId: 'admin1',
        availableSchedules: [],
        address: 'Test Address',
        locality: Locality.villaCarlosPaz,
        description: 'Test',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 365)),
      );
      when(
        () => clubRepo.getClubByUserId('admin1'),
      ).thenAnswer((_) async => testClub);

      // Stub getSeasonsByClub to return empty by default
      when(
        () => seasonRepo.getSeasonsByClub(any()),
      ).thenAnswer((_) async => []);

      when(
        () => reservationRepo.getReservationsByClubAndDate(any(), any()),
      ).thenAnswer((_) async => []);

      when(() => authRepo.getUsersByIds(any())).thenAnswer((invocation) async {
        final ids = invocation.positionalArguments[0] as List<String>;
        return ids.map((id) {
          final user = MockUserModel();
          when(() => user.id).thenReturn(id);
          when(() => user.displayName).thenReturn('User $id');
          return user;
        }).toList();
      });

      provider = ClubManagementProvider(
        authRepository: authRepo,
        clubRepository: clubRepo,
        reservationRepository: reservationRepo,
        seasonRepository: seasonRepo,
        storageRepository: storageRepo,
      );

      // Async init wait
      await Future.delayed(const Duration(milliseconds: 1000));
    });

    test(
      'setMatchWinner updates reservation winner and assigns points correctly',
      () async {
        // 1. Setup Data
        final reservation = ReservationModel(
          id: 'res1',
          courtId: 'court1',
          clubId: 'club1',
          userId: 'user1',
          reservedDate: DateTime.now(),
          startTime: DateTime.now(),
          durationMinutes: 60,
          createdAt: DateTime.now(),
          price: 100,
          team1Ids: ['p1', 'p2'],
          team2Ids: ['p3', 'p4'],
          status: ReservationStatus.approved,
          type: ReservationType.match2vs2,
        );

        when(
          () => reservationRepo.getReservationsByClubAndDate(any(), any()),
        ).thenAnswer((_) async => [reservation]);

        when(
          () => reservationRepo.updateReservation(any()),
        ).thenAnswer((_) async {});

        // Reload to populate provider
        provider.setSelectedDate(DateTime.now());
        await Future.delayed(const Duration(milliseconds: 1000));

        // 2. Setup Active Season
        final season = SeasonModel(
          id: 'season1',
          name: 'Season 1',
          clubId: 'club1',
          number: 1,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
          isActive: true,
        );
        when(
          () => seasonRepo.getActiveSeasonByClub(any()),
        ).thenAnswer((_) async => season);

        // Stub scores
        when(
          () => seasonRepo.getUserScore(any(), any()),
        ).thenAnswer((_) async => null);
        when(
          () => seasonRepo.updateUserScore(any(), any(), any()),
        ).thenAnswer((_) async {});

        // 3. Action
        await provider.setMatchWinner('res1', 1);

        // 4. Verify
        final captured =
            verify(
                  () => reservationRepo.updateReservation(captureAny()),
                ).captured.first
                as ReservationModel;

        expect(captured.id, 'res1');
        expect(captured.winnerTeam, 1);

        // Winners +3
        verify(
          () => seasonRepo.updateUserScore('season1', 'p1', 3.0),
        ).called(1);
        verify(
          () => seasonRepo.updateUserScore('season1', 'p2', 3.0),
        ).called(1);

        // Losers +1
        verify(
          () => seasonRepo.updateUserScore('season1', 'p3', 1.0),
        ).called(1);
        verify(
          () => seasonRepo.updateUserScore('season1', 'p4', 1.0),
        ).called(1);
      },
    );

    test('blockCourt creates an approved maintenance reservation', () async {
      when(
        () => reservationRepo.createReservation(any()),
      ).thenAnswer((_) async {});

      final date = DateTime.now();
      await provider.blockCourt(
        courtId: 'court1',
        date: date,
        durationMinutes: 60,
        type: ReservationType.maintenance,
        description: 'Reparación de red',
      );

      final captured =
          verify(
            () => reservationRepo.createReservation(captureAny()),
          ).captured;
      final reservation = captured.first as ReservationModel;

      expect(reservation.courtId, 'court1');
      expect(reservation.type, ReservationType.maintenance);
      expect(reservation.status, ReservationStatus.approved);
      expect(reservation.price, 0);
      expect(reservation.reservedDate.year, date.year);
    });
  });
}
