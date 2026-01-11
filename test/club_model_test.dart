import 'package:padel_punilla/domain/enums/locality.dart';
import 'package:padel_punilla/domain/models/club_model.dart';

void main() {
  // Verifying ClubModel Serialization...

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

  // Original Club: ${originalClub.name}, Locality: ${originalClub.locality.name}

  final map = originalClub.toMap();
  // Serialized Map: $map

  final deserializedClub = ClubModel.fromMap(map);
  // Deserialized Club: ${deserializedClub.name}, Locality: ${deserializedClub.locality.name}

  assert(originalClub.id == deserializedClub.id, 'IDs should match');
  assert(
    originalClub.locality == deserializedClub.locality,
    'Localities should match',
  );
  assert(
    originalClub.createdAt.toIso8601String() ==
        deserializedClub.createdAt.toIso8601String(),
    'Dates should match',
  );
  assert(
    originalClub.isApproved == deserializedClub.isApproved,
    'Approval status should match',
  );
  assert(originalClub.isApproved == false, 'Default approval should be false');
  assert(
    originalClub.availableSchedules.length == 6,
    'Should have 6 schedules',
  );
  assert(
    originalClub.availableSchedules.contains('14:00'),
    'Should contain 14:00',
  );
  assert(
    originalClub.availableSchedules.toString() ==
        deserializedClub.availableSchedules.toString(),
    'Schedules should match',
  );
}
