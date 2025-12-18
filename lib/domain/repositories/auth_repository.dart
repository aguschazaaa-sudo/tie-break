import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:padel_punilla/domain/enums/locality.dart';
import 'package:padel_punilla/domain/enums/paddle_category.dart';
import 'package:padel_punilla/domain/enums/player_gender.dart';
import 'package:padel_punilla/domain/models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream para escuchar cambios en el estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Obtener usuario actual
  User? get currentUser => _auth.currentUser;

  // Helper para mensajes de error amigables
  String _getErrorMessage(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No existe un usuario con este correo.';
        case 'wrong-password':
          return 'Contraseña incorrecta.';
        case 'email-already-in-use':
          return 'El correo ya está registrado.';
        case 'invalid-email':
          return 'El correo no es válido.';
        case 'weak-password':
          return 'La contraseña es muy débil.';
        case 'network-request-failed':
          return 'Error de conexión. Verifica tu internet.';
        default:
          return 'Error de autenticación: ${e.message}';
      }
    }
    return 'Error inesperado: $e';
  }

  // Helper para generar discriminador
  String _generateDiscriminator() {
    final random = Random();
    final discriminator = random.nextInt(10000).toString().padLeft(4, '0');
    return discriminator;
  }

  // Verificar disponibilidad de nombre de usuario
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('users')
              .where('username', isEqualTo: username.toLowerCase())
              .limit(1)
              .get();
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      throw Exception('Error al verificar usuario: $e');
    }
  }

  // Iniciar sesión con Email y Contraseña
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // Crear usuario con Email y Contraseña
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    required String username,
    required PaddleCategory category,
    required PlayerGender gender,
    required Locality locality,
  }) async {
    try {
      // 0. Verificar disponibilidad de username (ELIMINADO: Usamos discriminador)
      // final isAvailable = await isUsernameAvailable(username);
      // if (!isAvailable) {
      //   throw Exception('El nombre de usuario ya está en uso.');
      // }

      // 1. Crear usuario en Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Actualizar Display Name
      await userCredential.user!.updateDisplayName(displayName);

      // 3. Guardar usuario en Firestore
      final newUser = UserModel(
        id: userCredential.user!.uid,
        email: email,
        username: username.toLowerCase(),
        displayName: displayName,
        discriminator: _generateDiscriminator(),
        createdAt: DateTime.now(),
        category: category,
        gender: gender,
        locality: locality,
      );

      await _firestore.collection('users').doc(newUser.id).set(newUser.toMap());
    } catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // Iniciar sesión con Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Iniciar flujo de Google
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Usuario canceló

      // 2. Obtener credenciales de autenticación
      final googleAuth = await googleUser.authentication;

      // 3. Crear credencial para Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Iniciar sesión en Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      // 5. Verificar si el usuario ya existe en Firestore, si no, crearlo
      final userDoc =
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();

      if (!userDoc.exists) {
        // Generar username base (la unicidad la da el discriminador)
        final baseUsername = userCredential.user!.email!
            .split('@')[0]
            .replaceAll('.', '_');
        final uniqueUsername = baseUsername;

        final newUser = UserModel(
          id: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          username: uniqueUsername.toLowerCase(),
          displayName: userCredential.user!.displayName ?? 'Usuario',
          discriminator: _generateDiscriminator(),
          photoUrl: userCredential.user!.photoURL,
          createdAt: DateTime.now(),
        );
        await _firestore
            .collection('users')
            .doc(newUser.id)
            .set(newUser.toMap());
      }

      return userCredential;
    } catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      // Intentamos desconectar Google, pero si falla (ej. en web sin config),
      // continuamos con el logout de Firebase.
      try {
        await _googleSignIn.signOut();
      } catch (_) {
        // Ignoramos errores específicos de Google Sign In
      }
      await _auth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  // Obtener datos del usuario
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener datos del usuario: $e');
    }
  }

  // Actualizar datos del usuario
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toMap());
    } catch (e) {
      throw Exception('Error al actualizar perfil: $e');
    }
  }

  // Buscar usuario por username y discriminador
  Future<UserModel?> getUserByUsernameAndDiscriminator(
    String username,
    String discriminator,
  ) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('users')
              .where('username', isEqualTo: username.toLowerCase())
              .where('discriminator', isEqualTo: discriminator)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        return UserModel.fromMap(querySnapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      throw Exception('Error al buscar usuario: $e');
    }
  }

  // Buscar usuarios por nombre de usuario (búsqueda parcial)
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      if (query.isEmpty) return [];

      final queryLower = query.toLowerCase();

      // Realizamos una búsqueda por rango para simular "starts with"
      final querySnapshot =
          await _firestore
              .collection('users')
              .where('username', isGreaterThanOrEqualTo: queryLower)
              .where('username', isLessThan: '$queryLower\uf8ff')
              .limit(10)
              .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error al buscar usuarios: $e');
    }
  }

  // Seguir a un usuario
  Future<void> followUser(String currentUserId, String targetUserId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final currentUserRef = _firestore
            .collection('users')
            .doc(currentUserId);
        final targetUserRef = _firestore.collection('users').doc(targetUserId);

        final currentUserDoc = await transaction.get(currentUserRef);
        final targetUserDoc = await transaction.get(targetUserRef);

        if (!currentUserDoc.exists || !targetUserDoc.exists) {
          throw Exception('Usuario no encontrado');
        }

        final currentUserData = UserModel.fromMap(currentUserDoc.data()!);
        final targetUserData = UserModel.fromMap(targetUserDoc.data()!);

        if (currentUserData.following.contains(targetUserId)) {
          throw Exception('Ya sigues a este usuario');
        }

        final newFollowing = List<String>.from(currentUserData.following)
          ..add(targetUserId);
        final newFollowers = List<String>.from(targetUserData.followers)
          ..add(currentUserId);

        transaction.update(currentUserRef, {'following': newFollowing});
        transaction.update(targetUserRef, {'followers': newFollowers});
      });
    } catch (e) {
      throw Exception('Error al seguir usuario: $e');
    }
  }

  // Dejar de seguir a un usuario
  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final currentUserRef = _firestore
            .collection('users')
            .doc(currentUserId);
        final targetUserRef = _firestore.collection('users').doc(targetUserId);

        final currentUserDoc = await transaction.get(currentUserRef);
        final targetUserDoc = await transaction.get(targetUserRef);

        if (!currentUserDoc.exists || !targetUserDoc.exists) {
          throw Exception('Usuario no encontrado');
        }

        final currentUserData = UserModel.fromMap(currentUserDoc.data()!);
        final targetUserData = UserModel.fromMap(targetUserDoc.data()!);

        if (!currentUserData.following.contains(targetUserId)) {
          throw Exception('No sigues a este usuario');
        }

        final newFollowing = List<String>.from(currentUserData.following)
          ..remove(targetUserId);
        final newFollowers = List<String>.from(targetUserData.followers)
          ..remove(currentUserId);

        transaction.update(currentUserRef, {'following': newFollowing});
        transaction.update(targetUserRef, {'followers': newFollowers});
      });
    } catch (e) {
      throw Exception('Error al dejar de seguir usuario: $e');
    }
  }

  // Obtener usuarios por lista de IDs
  Future<List<UserModel>> getUsersByIds(List<String> userIds) async {
    try {
      if (userIds.isEmpty) return [];

      // Firestore 'in' query supports up to 10 items.
      // For larger lists, we need to chunk or fetch individually.
      // For simplicity in this iteration, we'll fetch individually to avoid limits,
      // though for production 'where in' chunks is better.
      final users = <UserModel>[];
      for (final id in userIds) {
        final doc = await _firestore.collection('users').doc(id).get();
        if (doc.exists) {
          users.add(UserModel.fromMap(doc.data()!));
        }
      }
      return users;
    } catch (e) {
      throw Exception('Error al obtener usuarios: $e');
    }
  }

  // Eliminar un seguidor (Forzar que deje de seguir)
  Future<void> removeFollower(String currentUserId, String followerId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final currentUserRef = _firestore
            .collection('users')
            .doc(currentUserId);
        final followerRef = _firestore.collection('users').doc(followerId);

        final currentUserDoc = await transaction.get(currentUserRef);
        final followerDoc = await transaction.get(followerRef);

        if (!currentUserDoc.exists || !followerDoc.exists) {
          throw Exception('Usuario no encontrado');
        }

        final currentUserData = UserModel.fromMap(currentUserDoc.data()!);
        final followerData = UserModel.fromMap(followerDoc.data()!);

        if (!currentUserData.followers.contains(followerId)) {
          throw Exception('Este usuario no te sigue');
        }

        // Remove followerId from my followers
        final newFollowers = List<String>.from(currentUserData.followers)
          ..remove(followerId);

        // Remove myId from their following
        final newFollowing = List<String>.from(followerData.following)
          ..remove(currentUserId);

        transaction.update(currentUserRef, {'followers': newFollowers});
        transaction.update(followerRef, {'following': newFollowing});
      });
    } catch (e) {
      throw Exception('Error al eliminar seguidor: $e');
    }
  }

  // -------------------------------------------------------------------------
  // Gestión de clubes favoritos
  // -------------------------------------------------------------------------

  /// Cantidad máxima de clubes favoritos permitidos por usuario
  static const int maxFavoriteClubs = 10;

  /// Agrega un club a la lista de favoritos del usuario.
  /// Lanza excepción si ya alcanzó el máximo de 10 favoritos.
  Future<void> addFavoriteClub(String userId, String clubId) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        throw Exception('Usuario no encontrado');
      }

      final userData = UserModel.fromMap(userDoc.data()!);

      // Verificar si ya es favorito
      if (userData.favoriteClubIds.contains(clubId)) {
        return; // Ya es favorito, no hacer nada
      }

      // Verificar límite máximo
      if (userData.favoriteClubIds.length >= maxFavoriteClubs) {
        throw Exception(
          'Has alcanzado el máximo de $maxFavoriteClubs clubes favoritos',
        );
      }

      // Agregar el club a favoritos
      final newFavorites = List<String>.from(userData.favoriteClubIds)
        ..add(clubId);

      await userRef.update({'favoriteClubIds': newFavorites});
    } catch (e) {
      if (e.toString().contains('máximo')) {
        rethrow;
      }
      throw Exception('Error al agregar club a favoritos: $e');
    }
  }

  /// Elimina un club de la lista de favoritos del usuario.
  Future<void> removeFavoriteClub(String userId, String clubId) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        throw Exception('Usuario no encontrado');
      }

      final userData = UserModel.fromMap(userDoc.data()!);

      // Verificar si es favorito
      if (!userData.favoriteClubIds.contains(clubId)) {
        return; // No es favorito, no hacer nada
      }

      // Quitar el club de favoritos
      final newFavorites = List<String>.from(userData.favoriteClubIds)
        ..remove(clubId);

      await userRef.update({'favoriteClubIds': newFavorites});
    } catch (e) {
      throw Exception('Error al quitar club de favoritos: $e');
    }
  }
}
