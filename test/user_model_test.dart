import 'package:flutter_test/flutter_test.dart';
import 'package:padel_punilla/domain/enums/locality.dart';
import 'package:padel_punilla/domain/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('should create UserModel with discriminator', () {
      final user = UserModel(
        id: '123',
        email: 'test@example.com',
        username: 'testuser',
        displayName: 'Test User',
        discriminator: '1234',
        createdAt: DateTime.now(),
        locality: Locality.valleHermoso,
      );

      expect(user.discriminator, '1234');
      expect(user.locality, Locality.valleHermoso);
    });

    test('should serialize and deserialize correctly', () {
      final user = UserModel(
        id: '123',
        email: 'test@example.com',
        username: 'testuser',
        displayName: 'Test User',
        discriminator: '1234',
        createdAt: DateTime(2023),
        locality: Locality.laFalda,
      );

      final map = user.toMap();
      final newUser = UserModel.fromMap(map);

      expect(newUser.id, user.id);
      expect(newUser.discriminator, user.discriminator);
      expect(newUser.email, user.email);
      expect(newUser.locality, Locality.laFalda);
    });

    test('should default locality to null if missing in map', () {
      final map = {
        'id': '123',
        'email': 'test@example.com',
        'username': 'testuser',
        'displayName': 'Test User',
        'createdAt': DateTime.now().toIso8601String(),
      };

      final user = UserModel.fromMap(map);
      expect(user.locality, null);
    });
  });
}
