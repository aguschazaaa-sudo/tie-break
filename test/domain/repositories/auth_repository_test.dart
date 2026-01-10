import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:padel_punilla/data/repositories/auth_repository_impl.dart';

// Mocks
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockUserCredential extends Mock
    implements UserCredential {} // MockUserCredential must be mocked
// Notes on mocking UserCredential: converting it to a concrete mock might be needed depending on usage.

void main() {
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockGoogleSignIn mockGoogleSignIn;
  late AuthRepositoryImpl authRepository;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockGoogleSignIn = MockGoogleSignIn();

    // Inject mocks
    authRepository = AuthRepositoryImpl(
      auth: mockAuth,
      firestore: mockFirestore,
      googleSignIn: mockGoogleSignIn,
    );
  });

  group('AuthRepository', () {
    test(
      'signInWithEmailAndPassword should return UserCredential on success',
      () async {
        // Arrange
        final email = 'test@test.com';
        final password = 'password123';
        final mockCredential = MockUserCredential();

        when(
          () => mockAuth.signInWithEmailAndPassword(
            email: email,
            password: password,
          ),
        ).thenAnswer((_) async => mockCredential);

        // Act
        final result = await authRepository.signInWithEmailAndPassword(
          email,
          password,
        );

        // Assert
        expect(result, mockCredential);
        verify(
          () => mockAuth.signInWithEmailAndPassword(
            email: email,
            password: password,
          ),
        ).called(1);
      },
    );

    test(
      'signInWithEmailAndPassword should throw exception with friendly message on auth error',
      () async {
        // Arrange
        final email = 'test@test.com';
        final password = 'password123';

        when(
          () => mockAuth.signInWithEmailAndPassword(
            email: email,
            password: password,
          ),
        ).thenThrow(
          FirebaseAuthException(
            code: 'user-not-found',
            message: 'User not found',
          ),
        );

        // Act & Assert
        expect(
          () => authRepository.signInWithEmailAndPassword(email, password),
          throwsA(
            predicate(
              (e) =>
                  e.toString().contains('No existe un usuario con este correo'),
            ),
          ),
        );
      },
    );
  });
}
