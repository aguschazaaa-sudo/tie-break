import 'package:firebase_auth/firebase_auth.dart';
import 'package:padel_punilla/domain/enums/locality.dart';
import 'package:padel_punilla/domain/enums/paddle_category.dart';
import 'package:padel_punilla/domain/enums/player_gender.dart';
import 'package:padel_punilla/domain/models/user_model.dart';

abstract class AuthRepository {
  static const int maxFavoriteClubs = 10;

  Stream<User?> get authStateChanges;
  User? get currentUser;

  Future<bool> isUsernameAvailable(String username);
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  );
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    required String username,
    required PaddleCategory category,
    required PlayerGender gender,
    required Locality locality,
  });
  Future<UserCredential?> signInWithGoogle();
  Future<void> signOut();
  Future<UserModel?> getUserData(String uid);
  Future<void> updateUser(UserModel user);
  Future<UserModel?> getUserByUsernameAndDiscriminator(
    String username,
    String discriminator,
  );
  Future<List<UserModel>> searchUsers(String query);
  Future<void> followUser(String currentUserId, String targetUserId);
  Future<void> unfollowUser(String currentUserId, String targetUserId);
  Future<List<UserModel>> getUsersByIds(List<String> userIds);
  Future<void> removeFollower(String currentUserId, String followerId);
  Future<void> addFavoriteClub(String userId, String clubId);
  Future<void> removeFavoriteClub(String userId, String clubId);
}
