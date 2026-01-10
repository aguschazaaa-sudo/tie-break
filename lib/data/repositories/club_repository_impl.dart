import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:padel_punilla/domain/enums/locality.dart';
import 'package:padel_punilla/domain/models/club_model.dart';
import 'package:padel_punilla/domain/repositories/club_repository.dart';

class ClubRepositoryImpl implements ClubRepository {
  final FirebaseFirestore _firestore;

  ClubRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _clubsCollection =>
      _firestore.collection('clubs');

  @override
  Future<void> createClub(ClubModel club) async {
    try {
      await _clubsCollection.doc(club.id).set(club.toMap());
    } catch (e) {
      throw Exception('Error al crear el club: $e');
    }
  }

  @override
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

  @override
  Future<void> updateClub(ClubModel club) async {
    try {
      await _clubsCollection.doc(club.id).update(club.toMap());
    } catch (e) {
      throw Exception('Error al actualizar el club: $e');
    }
  }

  @override
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

  @override
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

  @override
  Future<ClubModel?> getClubByUserId(String userId) async {
    try {
      final adminQuery =
          await _clubsCollection
              .where('adminId', isEqualTo: userId)
              .where('isActive', isEqualTo: true)
              .limit(1)
              .get();

      if (adminQuery.docs.isNotEmpty) {
        return ClubModel.fromMap(adminQuery.docs.first.data());
      }

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

  @override
  Future<List<ClubModel>> searchClubsByName(String query) async {
    try {
      if (query.isEmpty) return [];

      final queryLower = query.toLowerCase();
      final querySnapshot =
          await _clubsCollection.where('isActive', isEqualTo: true).get();

      final allClubs =
          querySnapshot.docs
              .map((doc) => ClubModel.fromMap(doc.data()))
              .toList();

      final filtered =
          allClubs
              .where((club) => club.name.toLowerCase().contains(queryLower))
              .take(20)
              .toList();

      return filtered;
    } catch (e) {
      throw Exception('Error al buscar clubes: $e');
    }
  }

  @override
  Future<List<ClubModel>> getClubsByIds(List<String> clubIds) async {
    try {
      if (clubIds.isEmpty) return [];

      final clubs = <ClubModel>[];
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
