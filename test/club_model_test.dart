import 'package:padel_punilla/domain/enums/locality.dart';
import 'package:padel_punilla/domain/models/club_model.dart';

void main() {
  print('Verifying ClubModel Serialization...');

  final now = DateTime.now();
  final originalClub = ClubModel(
    id: 'test_club_1',
    name: 'Club Test',
    description: 'A test club',
    adminId: 'admin_123',
    address: 'Calle Falsa 123',
    locality: Locality.villaCarlosPaz,
    createdAt: now,
    expiresAt: now.add(const Duration(days: 15)),
    contactPhone: '123456789',
  );

  print(
    'Original Club: ${originalClub.name}, Locality: ${originalClub.locality.name}',
  );

  final map = originalClub.toMap();
  print('Serialized Map: $map');

  final deserializedClub = ClubModel.fromMap(map);
  print(
    'Deserialized Club: ${deserializedClub.name}, Locality: ${deserializedClub.locality.name}',
  );

  assert(originalClub.id == deserializedClub.id);
  assert(originalClub.locality == deserializedClub.locality);
  assert(
    originalClub.createdAt.toIso8601String() ==
        deserializedClub.createdAt.toIso8601String(),
  );
  assert(originalClub.isApproved == deserializedClub.isApproved);
  assert(originalClub.isApproved == false); // Default value check
  assert(originalClub.availableSchedules.length == 6);
  assert(originalClub.availableSchedules.contains('14:00'));
  assert(
    originalClub.availableSchedules.toString() ==
        deserializedClub.availableSchedules.toString(),
  );

  print('Verification Successful!');
}
