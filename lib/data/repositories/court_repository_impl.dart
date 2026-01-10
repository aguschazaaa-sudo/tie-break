import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:padel_punilla/domain/models/court_model.dart';
import 'package:padel_punilla/domain/repositories/court_repository.dart';

class CourtRepositoryImpl implements CourtRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> createCourt(String clubId, CourtModel court) async {
    await _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('courts')
        .doc(court.id)
        .set(court.toMap());
  }

  @override
  Future<List<CourtModel>> getCourts(String clubId) async {
    final snapshot =
        await _firestore
            .collection('clubs')
            .doc(clubId)
            .collection('courts')
            .get();

    return snapshot.docs.map((doc) => CourtModel.fromMap(doc.data())).toList();
  }

  @override
  Future<void> updateCourt(String clubId, CourtModel court) async {
    await _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('courts')
        .doc(court.id)
        .update(court.toMap());
  }

  @override
  Future<void> deleteCourt(String clubId, String courtId) async {
    await _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('courts')
        .doc(courtId)
        .delete();
  }

  @override
  Stream<List<CourtModel>> getCourtsStream(String clubId) {
    return _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('courts')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => CourtModel.fromMap(doc.data()))
                  .toList(),
        );
  }
}
