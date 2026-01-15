import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:padel_punilla/domain/enums/locality.dart';
import 'package:padel_punilla/domain/models/club_model.dart';
import 'package:padel_punilla/domain/models/court_model.dart';
import 'package:padel_punilla/domain/models/reservation_model.dart';
import 'package:padel_punilla/domain/repositories/club_repository.dart';
import 'package:padel_punilla/domain/repositories/court_repository.dart';
import 'package:padel_punilla/domain/repositories/reservation_repository.dart';
import 'package:padel_punilla/presentation/screens/club/club_details_screen.dart';
import 'package:provider/provider.dart';

// Mocks
class MockClubRepository extends Mock implements ClubRepository {}

class MockCourtRepository extends Mock implements CourtRepository {}

class MockReservationRepository extends Mock implements ReservationRepository {}

void main() {
  late MockClubRepository mockClubRepo;
  late MockCourtRepository mockCourtRepo;
  late MockReservationRepository mockReservationRepo;
  late ClubModel testClub;

  setUp(() {
    mockClubRepo = MockClubRepository();
    mockCourtRepo = MockCourtRepository();
    mockReservationRepo = MockReservationRepository();

    testClub = ClubModel(
      id: 'club1',
      name: 'Club Test',
      description: 'Description for testing',
      adminId: 'admin1',
      address: 'Calle Falsa 123',
      locality: Locality.villaCarlosPaz,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 365)),
      availableSchedules: ['14:00', '15:30', '17:00', '18:30', '20:00'],
    );

    // Default mock for reservation repo
    when(
      () => mockReservationRepo.getReservationsByClubAndDate(any(), any()),
    ).thenAnswer((_) async => <ReservationModel>[]);
  });

  Widget createWidgetUnderTest(ClubModel club) {
    return MultiProvider(
      providers: [
        Provider<ClubRepository>.value(value: mockClubRepo),
        Provider<CourtRepository>.value(value: mockCourtRepo),
        Provider<ReservationRepository>.value(value: mockReservationRepo),
      ],
      child: MaterialApp(home: ClubDetailsScreen(club: club)),
    );
  }

  CourtModel createTestCourt({required String id, required String name}) {
    return CourtModel(
      id: id,
      clubId: 'club1',
      name: name,
      sport: CourtSport.paddle,
      surfaceType: CourtSurface.synthetic,
      reservationPrice: 5000,
      slotDurationMinutes: 90,
      isCovered: false,
    );
  }

  group('ClubDetailsScreen', () {
    testWidgets('renders club name and address', (tester) async {
      // Arrange
      when(
        () => mockCourtRepo.getCourtsStream(any()),
      ).thenAnswer((_) => Stream.value(<CourtModel>[]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(testClub));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Club Test'), findsWidgets);
      expect(find.textContaining('Calle Falsa 123'), findsOneWidget);
    });

    testWidgets('renders date selector with today date', (tester) async {
      // Arrange
      when(
        () => mockCourtRepo.getCourtsStream(any()),
      ).thenAnswer((_) => Stream.value(<CourtModel>[]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(testClub));
      await tester.pumpAndSettle();

      // Assert - should find date navigation icons
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('renders timeline with courts from stream', (tester) async {
      // Arrange
      final courts = <CourtModel>[
        createTestCourt(id: 'court1', name: 'Cancha 1'),
        createTestCourt(id: 'court2', name: 'Cancha 2'),
      ];

      when(
        () => mockCourtRepo.getCourtsStream(any()),
      ).thenAnswer((_) => Stream.value(courts));
      when(
        () => mockReservationRepo.getReservationsByClubAndDate(any(), any()),
      ).thenAnswer((_) async => <ReservationModel>[]);

      // Act
      await tester.pumpWidget(createWidgetUnderTest(testClub));
      await tester.pumpAndSettle();

      // Assert - should find court names in timeline headers
      expect(find.text('Cancha 1'), findsOneWidget);
      expect(find.text('Cancha 2'), findsOneWidget);
    });

    testWidgets('tapping court header opens reservation modal', (tester) async {
      // Arrange
      final courts = <CourtModel>[
        createTestCourt(id: 'court1', name: 'Cancha 1'),
      ];

      when(
        () => mockCourtRepo.getCourtsStream(any()),
      ).thenAnswer((_) => Stream.value(courts));
      when(
        () => mockReservationRepo.getReservationsByClubAndDate(any(), any()),
      ).thenAnswer((_) async => <ReservationModel>[]);

      // Act
      await tester.pumpWidget(createWidgetUnderTest(testClub));
      await tester.pumpAndSettle();

      // Tap on court header to open modal
      await tester.tap(find.text('Cancha 1'));
      await tester.pumpAndSettle();

      // Assert - should open reservation modal
      expect(find.text('Nueva Reserva'), findsOneWidget);
    });

    testWidgets('date navigation changes displayed date', (tester) async {
      // Arrange
      when(
        () => mockCourtRepo.getCourtsStream(any()),
      ).thenAnswer((_) => Stream.value(<CourtModel>[]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(testClub));
      await tester.pumpAndSettle();

      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));

      // Tap next day
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      // Assert - date should change to tomorrow
      expect(
        find.textContaining('${tomorrow.day}/${tomorrow.month}'),
        findsOneWidget,
      );
    });
  });
}
