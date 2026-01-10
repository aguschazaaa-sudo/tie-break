import 'package:padel_punilla/domain/enums/club_amenity.dart';
import 'package:padel_punilla/domain/enums/locality.dart';

class ClubModel {
  ClubModel({
    required this.id,
    required this.name,
    required this.description,
    required this.adminId,
    required this.address,
    required this.locality,
    required this.createdAt,
    required this.expiresAt,
    this.logoUrl,
    this.helperIds = const [],
    this.contactPhone,
    this.isActive = true,
    this.isApproved = false,
    this.availableSchedules = const [
      '14:00',
      '15:30',
      '17:00',
      '18:30',
      '20:00',
      '21:30',
    ],
    this.amenities = const [],
  });

  factory ClubModel.fromMap(Map<String, dynamic> map) {
    return ClubModel(
      id: (map['id'] as String?) ?? '',
      name: (map['name'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      logoUrl: map['logoUrl'] as String?,
      adminId: (map['adminId'] as String?) ?? '',
      helperIds: List<String>.from((map['helperIds'] as List<dynamic>?) ?? []),
      address: (map['address'] as String?) ?? '',
      locality: Locality.values.firstWhere(
        (e) => e.name == map['locality'],
        orElse: () => Locality.villaCarlosPaz,
      ),
      createdAt: DateTime.parse(map['createdAt'] as String),
      expiresAt: DateTime.parse(map['expiresAt'] as String),
      contactPhone: map['contactPhone'] as String?,
      isActive: (map['isActive'] as bool?) ?? true,
      isApproved: (map['isApproved'] as bool?) ?? false,
      availableSchedules: List<String>.from(
        (map['availableSchedules'] as List<dynamic>?) ?? [],
      ),
      amenities:
          ((map['amenities'] as List<dynamic>?) ?? [])
              .map(
                (e) => ClubAmenity.values.firstWhere(
                  (a) => a.name == e,
                  orElse:
                      () =>
                          ClubAmenity
                              .wifi, // Fallback safe, though risky logic if new enums appear
                ),
              )
              .toList(),
    );
  }
  final String id;
  final String name;
  final String description;
  final String? logoUrl;
  final String adminId;
  final List<String> helperIds;
  final String address;
  final Locality locality;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String? contactPhone;
  final bool isActive;
  final bool isApproved;
  final List<String> availableSchedules;
  final List<ClubAmenity> amenities;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'adminId': adminId,
      'helperIds': helperIds,
      'address': address,
      'locality': locality.name,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'contactPhone': contactPhone,
      'isActive': isActive,
      'isApproved': isApproved,
      'availableSchedules': availableSchedules,
      'amenities': amenities.map((e) => e.name).toList(),
    };
  }

  ClubModel copyWith({
    String? id,
    String? name,
    String? description,
    String? logoUrl,
    String? adminId,
    List<String>? helperIds,
    String? address,
    Locality? locality,
    DateTime? createdAt,
    DateTime? expiresAt,
    String? contactPhone,
    bool? isActive,
    bool? isApproved,
    List<String>? availableSchedules,
    List<ClubAmenity>? amenities,
  }) {
    return ClubModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      adminId: adminId ?? this.adminId,
      helperIds: helperIds ?? this.helperIds,
      address: address ?? this.address,
      locality: locality ?? this.locality,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      contactPhone: contactPhone ?? this.contactPhone,
      isActive: isActive ?? this.isActive,
      isApproved: isApproved ?? this.isApproved,
      availableSchedules: availableSchedules ?? this.availableSchedules,
      amenities: amenities ?? this.amenities,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ClubModel &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.logoUrl == logoUrl &&
        other.adminId == adminId &&
        other.helperIds.length == helperIds.length &&
        other.helperIds.every(helperIds.contains) &&
        other.address == address &&
        other.locality == locality &&
        other.createdAt == createdAt &&
        other.expiresAt == expiresAt &&
        other.contactPhone == contactPhone &&
        other.isActive == isActive &&
        other.isApproved == isApproved &&
        other.availableSchedules.length == availableSchedules.length &&
        other.availableSchedules.every(availableSchedules.contains) &&
        other.amenities.length == amenities.length &&
        other.amenities.every(amenities.contains);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        logoUrl.hashCode ^
        adminId.hashCode ^
        Object.hashAll(helperIds) ^
        address.hashCode ^
        locality.hashCode ^
        createdAt.hashCode ^
        expiresAt.hashCode ^
        contactPhone.hashCode ^
        isActive.hashCode ^
        isApproved.hashCode ^
        Object.hashAll(availableSchedules) ^
        Object.hashAll(amenities);
  }

  @override
  String toString() {
    return 'ClubModel(id: $id, name: $name, description: $description, logoUrl: $logoUrl, adminId: $adminId, helperIds: $helperIds, address: $address, locality: $locality, createdAt: $createdAt, expiresAt: $expiresAt, contactPhone: $contactPhone, isActive: $isActive, isApproved: $isApproved, availableSchedules: $availableSchedules, amenities: $amenities)';
  }
}
