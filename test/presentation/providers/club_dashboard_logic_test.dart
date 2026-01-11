import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:padel_punilla/domain/enums/locality.dart';
import 'package:padel_punilla/domain/enums/reservation_enums.dart';
import 'package:padel_punilla/domain/models/club_model.dart';
import 'package:padel_punilla/domain/models/reservation_model.dart';
import 'package:padel_punilla/domain/repositories/auth_repository.dart';
import 'package:padel_punilla/domain/repositories/club_repository.dart';
import 'package:padel_punilla/domain/repositories/reservation_repository.dart';
import 'package:padel_punilla/domain/repositories/season_repository.dart';
import 'package:padel_punilla/domain/repositories/storage_repository.dart';
import 'package:padel_punilla/presentation/providers/club_management_provider.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockClubRepository extends Mock implements ClubRepository {}

class MockReservationRepository extends Mock implements ReservationRepository {}

class MockSeasonRepository extends Mock implements SeasonRepository {}

class MockStorageRepository extends Mock implements StorageRepository {}

class MockUser extends Mock implements User {}

void main() {
  group('ClubDashboardLogic Tests', () {
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

      when(() => authRepo.currentUser).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('admin1');

      final testClub = ClubModel(
        id: 'club1',
        name: 'Club Test',
        adminId: 'admin1',
        availableSchedules: [],
        address: 'Test',
        locality: Locality.villaCarlosPaz,
        description: '',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now(),
      );

      when(
        () => clubRepo.getClubByUserId('admin1'),
      ).thenAnswer((_) async => testClub);
      when(
        () => seasonRepo.getSeasonsByClub(any()),
      ).thenAnswer((_) async => []);
      when(
        () => reservationRepo.getReservationsByClubAndDate(any(), any()),
      ).thenAnswer((_) async => []);

      provider = ClubManagementProvider(
        authRepository: authRepo,
        clubRepository: clubRepo,
        reservationRepository: reservationRepo,
        seasonRepository: seasonRepo,
        storageRepository: storageRepo,
      );

      await Future<void>.delayed(
        const Duration(milliseconds: 1000),
      ); // Init wait
    });

    test('loadDailyStats calculates correctly', () async {
      // Data
      final now = DateTime.now();
      final reservations = [
        ReservationModel(
          id: '1',
          courtId: 'c1',
          clubId: 'club1',
          userId: 'u1',
          reservedDate: now,
          startTime: now,
          durationMinutes: 60,
          createdAt: now,
          status: ReservationStatus.approved,
          price: 1000,
          paidAmount: 1000,
        ),
        ReservationModel(
          id: '2',
          courtId: 'c2',
          clubId: 'club1',
          userId: 'u2',
          reservedDate: now,
          startTime: now,
          durationMinutes: 60,
          createdAt: now,
          // Let's go with: Revenue = Sum of price of Approved reservations.
          price: 1500,
        ),
        ReservationModel(
          id: '3',
          courtId: 'c1', // Same court as 1
          clubId: 'club1',
          userId: 'u3',
          reservedDate: now,
          startTime: now,
          durationMinutes: 60,
          createdAt: now,
          status: ReservationStatus.cancelled, // Should be ignored
          price: 2000,
        ),
      ];

      when(
        () => reservationRepo.getReservationsByClubAndDate(any(), any()),
      ).thenAnswer((_) async => reservations);

      // Action
      // We expect the provider to have a method calculateDailyStats or loadDailyStats
      // Since it doesn't exist yet, this test will fail compilation if I write it directly against the class type.
      // But in Dart dynamic or if I cast, I can try.
      // However, typical TDD in strict languages implies writing the interface first.
      // I'll assume I will add `Future<void> loadDailyStats()` and getter `ClubDashboardStats dashboardStats`.

      await provider.loadDailyStats();

      // Assert
      final stats = provider.dashboardStats;

      // Total Reservations: 1 Approved + 1 Pending = 2 (Cancelled ignored)
      expect(stats.totalReservations, 2);

      // Revenue: 1000 (Approved) + 0 (Pending is not realized revenue yet? Or projected?)
      // Let's decide: Revenue = Sum of Approved Price.
      expect(stats.totalRevenue, 1000.0);

      // Active Courts: c1 and c2. = 2.
      expect(stats.activeCourts, 2);

      // Pending
      expect(stats.pendingReservations, 1);
    });
  });
}
