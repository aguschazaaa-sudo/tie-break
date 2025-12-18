import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:padel_punilla/domain/enums/locality.dart';
import 'package:padel_punilla/domain/models/club_model.dart';

class ClubRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference
  CollectionReference<Map<String, dynamic>> get _clubsCollection =>
      _firestore.collection('clubs');

  // Create a new club
  Future<void> createClub(ClubModel club) async {
    try {
      await _clubsCollection.doc(club.id).set(club.toMap());
    } catch (e) {
      throw Exception('Error al crear el club: $e');
    }
  }

  // Get a club by ID
  Future<ClubModel?> getClub(String id) async {
    try {
      final doc = await _clubsCollection.doc(id).get();
      if (doc.exists) {
        return ClubModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener el club: $e');
    }
  }

  // Update a club
  Future<void> updateClub(ClubModel club) async {
    try {
      await _clubsCollection.doc(club.id).update(club.toMap());
    } catch (e) {
      throw Exception('Error al actualizar el club: $e');
    }
  }

  // Get clubs by locality
  Future<List<ClubModel>> getClubsByLocality(Locality locality) async {
    try {
      final querySnapshot =
          await _clubsCollection
              .where('locality', isEqualTo: locality.name)
              .where('isActive', isEqualTo: true)
              .get();

      return querySnapshot.docs
          .map((doc) => ClubModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener clubes por localidad: $e');
    }
  }

  // Get all active clubs
  Future<List<ClubModel>> getAllActiveClubs() async {
    try {
      final querySnapshot =
          await _clubsCollection.where('isActive', isEqualTo: true).get();

      return querySnapshot.docs
          .map((doc) => ClubModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener todos los clubes: $e');
    }
  }

  // Get club by user ID (admin or helper)
  Future<ClubModel?> getClubByUserId(String userId) async {
    try {
      // Check if user is admin
      final adminQuery =
          await _clubsCollection
              .where('adminId', isEqualTo: userId)
              .where('isActive', isEqualTo: true)
              .limit(1)
              .get();

      if (adminQuery.docs.isNotEmpty) {
        return ClubModel.fromMap(adminQuery.docs.first.data());
      }

      // Check if user is helper
      final helperQuery =
          await _clubsCollection
              .where('helperIds', arrayContains: userId)
              .where('isActive', isEqualTo: true)
              .limit(1)
              .get();

      if (helperQuery.docs.isNotEmpty) {
        return ClubModel.fromMap(helperQuery.docs.first.data());
      }

      return null;
    } catch (e) {
      throw Exception('Error al buscar club del usuario: $e');
    }
  }

  /// Busca clubes activos por nombre (búsqueda parcial, case-insensitive).
  /// Retorna máximo 20 resultados.
  Future<List<ClubModel>> searchClubsByName(String query) async {
    try {
      if (query.isEmpty) return [];

      // Firestore no soporta búsqueda case-insensitive de forma nativa.
      // Usamos un campo auxiliar 'nameLower' o hacemos búsqueda por rango.
      // Aquí usamos búsqueda por rango similar a la de usuarios.
      final queryLower = query.toLowerCase();

      final querySnapshot =
          await _clubsCollection
              .where('isActive', isEqualTo: true)
              .orderBy('name')
              .startAt([queryLower])
              .endAt(['$queryLower\uf8ff'])
              .limit(20)
              .get();

      return querySnapshot.docs
          .map((doc) => ClubModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error al buscar clubes: $e');
    }
  }

  /// Obtiene múltiples clubes por sus IDs.
  /// Útil para cargar clubes favoritos del usuario.
  Future<List<ClubModel>> getClubsByIds(List<String> clubIds) async {
    try {
      if (clubIds.isEmpty) return [];

      final clubs = <ClubModel>[];

      // Firestore 'whereIn' soporta hasta 30 elementos
      const chunkSize = 30;

      for (var i = 0; i < clubIds.length; i += chunkSize) {
        final chunk = clubIds.skip(i).take(chunkSize).toList();

        final querySnapshot =
            await _clubsCollection
                .where(FieldPath.documentId, whereIn: chunk)
                .where('isActive', isEqualTo: true)
                .get();

        clubs.addAll(
          querySnapshot.docs.map((doc) => ClubModel.fromMap(doc.data())),
        );
      }

      // Ordenar por el orden original de clubIds para mantener consistencia
      clubs.sort((a, b) {
        final indexA = clubIds.indexOf(a.id);
        final indexB = clubIds.indexOf(b.id);
        return indexA.compareTo(indexB);
      });

      return clubs;
    } catch (e) {
      throw Exception('Error al obtener clubes por IDs: $e');
    }
  }
}
