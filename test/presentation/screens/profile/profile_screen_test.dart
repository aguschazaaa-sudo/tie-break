import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:padel_punilla/domain/enums/locality.dart';
import 'package:padel_punilla/domain/enums/paddle_category.dart';
import 'package:padel_punilla/domain/enums/player_gender.dart';
import 'package:padel_punilla/domain/models/user_model.dart';
import 'package:padel_punilla/domain/repositories/auth_repository.dart';
import 'package:padel_punilla/domain/repositories/club_repository.dart';
import 'package:padel_punilla/presentation/screens/profile/profile_screen.dart';
import 'package:provider/provider.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockClubRepository extends Mock implements ClubRepository {}

class MockUser extends Mock implements User {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockClubRepository mockClubRepository;
  late MockUser mockUser;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockClubRepository = MockClubRepository();
    mockUser = MockUser();

    // Default stubs
    when(() => mockAuthRepository.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('test_uid');
    when(
      () => mockClubRepository.getClubByUserId(any()),
    ).thenAnswer((_) async => null);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<AuthRepository>.value(value: mockAuthRepository),
          Provider<ClubRepository>.value(value: mockClubRepository),
        ],
        child: const ProfileScreen(),
      ),
    );
  }

  testWidgets('ProfileScreen displays user data correctly', (tester) async {
    final userModel = UserModel(
      id: 'test_uid',
      email: 'test@example.com',
      username: 'testuser',
      displayName: 'Test User',
      discriminator: '1234',
      createdAt: DateTime.now(),
      category: PaddleCategory.sixth,
      gender: PlayerGender.male,
      followers: ['follower1'],
      following: ['following1', 'following2'],
      locality: Locality.villaCarlosPaz,
    );

    when(
      () => mockAuthRepository.getUserData('test_uid'),
    ).thenAnswer((_) async => userModel);

    await tester.pumpWidget(createWidgetUnderTest());

    // Trigger initState and PostFrameCallback
    await tester.pump();

    // Verify currentUser was accessed
    verify(() => mockAuthRepository.currentUser).called(1);

    // Wait for future to complete
    await tester.pump(const Duration(milliseconds: 100));

    // Verify getUserData was called
    verify(() => mockAuthRepository.getUserData('test_uid')).called(1);

    // Settle animations/updates
    await tester.pumpAndSettle();

    // Verify TextFormField has value and label
    final textFormFieldFinder = find.byType(TextFormField);
    expect(textFormFieldFinder, findsOneWidget);
    final textFormField = tester.widget<TextFormField>(textFormFieldFinder);
    expect(textFormField.controller?.text, 'Test User');

    expect(find.text('@testuser'), findsOneWidget);
    expect(find.text('#1234'), findsOneWidget);
    expect(find.text('1'), findsOneWidget); // Followers count
    expect(find.text('2'), findsOneWidget); // Following count
  });

  testWidgets('Follow User button opens dialog', (tester) async {
    final userModel = UserModel(
      id: 'test_uid',
      email: 'test@example.com',
      username: 'testuser',
      displayName: 'Test User',
      discriminator: '1234',
      createdAt: DateTime.now(),
      category: PaddleCategory.sixth,
      gender: PlayerGender.male,
      followers: [],
      following: [],
    );

    when(
      () => mockAuthRepository.getUserData('test_uid'),
    ).thenAnswer((_) async => userModel);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Seguir Usuario'));
    await tester.pumpAndSettle();

    expect(find.text('Buscar Usuario'), findsOneWidget);
  });
}
