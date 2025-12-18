import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadClubLogo(XFile file, String clubId) async {
    try {
      final ref = _storage.ref().child('clubs/$clubId/logo.jpg');
      final data = await file.readAsBytes();
      final uploadTask = ref.putData(
        data,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error uploading logo: $e');
    }
  }
}
