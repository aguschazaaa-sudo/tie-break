import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:padel_punilla/domain/models/court_model.dart';

class CourtRepository {
  CourtRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  Future<void> createCourt(String clubId, CourtModel court) async {
    await _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('courts')
        .doc(court.id)
        .set(court.toMap());
  }

  Future<List<CourtModel>> getCourts(String clubId) async {
    final snapshot =
        await _firestore
            .collection('clubs')
            .doc(clubId)
            .collection('courts')
            .get();

    return snapshot.docs.map((doc) => CourtModel.fromMap(doc.data())).toList();
  }

  Future<void> updateCourt(String clubId, CourtModel court) async {
    await _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('courts')
        .doc(court.id)
        .update(court.toMap());
  }

  Future<void> deleteCourt(String clubId, String courtId) async {
    await _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('courts')
        .doc(courtId)
        .delete();
  }

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
