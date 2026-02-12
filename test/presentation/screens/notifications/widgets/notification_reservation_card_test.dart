import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:padel_punilla/domain/enums/reservation_enums.dart';
import 'package:padel_punilla/domain/models/club_model.dart';
import 'package:padel_punilla/domain/models/court_model.dart';
import 'package:padel_punilla/domain/models/reservation_model.dart';
import 'package:padel_punilla/domain/repositories/club_repository.dart';
import 'package:padel_punilla/domain/repositories/court_repository.dart';
import 'package:padel_punilla/domain/repositories/reservation_repository.dart';
import 'package:padel_punilla/presentation/screens/notifications/widgets/notification_reservation_card.dart';
import 'package:padel_punilla/presentation/screens/notifications/widgets/notification_reservation_card_skeleton.dart';
import 'package:provider/provider.dart';
import 'package:padel_punilla/domain/enums/locality.dart';
import 'package:intl/date_symbol_data_local.dart';

class MockReservationRepository extends Mock implements ReservationRepository {}

class MockClubRepository extends Mock implements ClubRepository {}

class MockCourtRepository extends Mock implements CourtRepository {}

void main() {
  late MockReservationRepository mockReservationRepository;
  late MockClubRepository mockClubRepository;
  late MockCourtRepository mockCourtRepository;

  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  setUp(() {
    mockReservationRepository = MockReservationRepository();
    mockClubRepository = MockClubRepository();
    mockCourtRepository = MockCourtRepository();
  });

  final testReservation = ReservationModel(
    id: 'res1',
    courtId: 'court1',
    clubId: 'club1',
    userId: 'user1',
    reservedDate: DateTime(2023, 10, 20),
    startTime: DateTime(2023, 10, 20, 10, 0),
    durationMinutes: 90,
    createdAt: DateTime.now(),
    price: 100.0,
    status: ReservationStatus.approved,
    type: ReservationType.normal,
  );

  final testClub = ClubModel(
    id: 'club1',
    name: 'Padel Club',
    description: 'A great place',
    adminId: 'admin1',
    address: 'Fake St 123',
    locality: Locality.villaCarlosPaz,
    createdAt: DateTime.now(),
    expiresAt: DateTime.now().add(const Duration(days: 365)),
    availableSchedules: ['10:00', '11:00'],
  );

  final testCourt = CourtModel(
    id: 'court1',
    clubId: 'club1',
    name: 'Court 1',
    reservationPrice: 100.0,
    isCovered: true,
  );

  Widget createWidgetUnderTest(String reservationId) {
    return MultiProvider(
      providers: [
        Provider<ReservationRepository>.value(value: mockReservationRepository),
        Provider<ClubRepository>.value(value: mockClubRepository),
        Provider<CourtRepository>.value(value: mockCourtRepository),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: NotificationReservationCard(reservationId: reservationId),
        ),
      ),
    );
  }

  testWidgets('renders loading state initially', (tester) async {
    when(() => mockReservationRepository.getReservationById('res1')).thenAnswer(
      (_) async {
        // Add delay to simulate network
        await Future.delayed(const Duration(milliseconds: 100));
        return testReservation;
      },
    );

    await tester.pumpWidget(createWidgetUnderTest('res1'));

    // Expect skeleton instead of circular progress indicator
    expect(find.byType(NotificationReservationCardSkeleton), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('renders reservation details when loaded', (tester) async {
    when(
      () => mockReservationRepository.getReservationById('res1'),
    ).thenAnswer((_) async => testReservation);
    when(
      () => mockClubRepository.getClub('club1'),
    ).thenAnswer((_) async => testClub);
    when(
      () => mockCourtRepository.getCourt('club1', 'court1'),
    ).thenAnswer((_) async => testCourt);

    await tester.pumpWidget(createWidgetUnderTest('res1'));
    await tester.pumpAndSettle();

    expect(find.text('Padel Club'), findsOneWidget);
    expect(find.text('Court 1'), findsOneWidget);
  });

  testWidgets('renders error or empty if not found', (tester) async {
    when(
      () => mockReservationRepository.getReservationById('res1'),
    ).thenAnswer((_) async => null);

    await tester.pumpWidget(createWidgetUnderTest('res1'));
    await tester.pumpAndSettle();

    expect(find.text('Reserva no encontrada'), findsOneWidget);
  });
}
