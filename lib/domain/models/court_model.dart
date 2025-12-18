enum CourtSurface {
  synthetic,
  cement,
  clay,
  grass,
  carpet,
  other;

  String get displayName {
    switch (this) {
      case CourtSurface.synthetic:
        return 'Sintética';
      case CourtSurface.cement:
        return 'Cemento';
      case CourtSurface.clay:
        return 'Polvo de Ladrillo';
      case CourtSurface.grass:
        return 'Césped';
      case CourtSurface.carpet:
        return 'Alfombra';
      case CourtSurface.other:
        return 'Otra';
    }
  }
}

enum CourtSport { paddle, tennis, football, other }

class CourtModel {
  CourtModel({
    required this.id,
    required this.clubId,
    required this.name,
    required this.reservationPrice,
    required this.isCovered,
    this.surfaceType = CourtSurface.synthetic,
    this.hasLighting = true,
    this.sport = CourtSport.paddle,
    this.images = const [],
    this.isAvailable = true,
    this.slotDurationMinutes = 90,
  });

  factory CourtModel.fromMap(Map<String, dynamic> map) {
    return CourtModel(
      id: (map['id'] as String?) ?? '',
      clubId: (map['clubId'] as String?) ?? '',
      name: (map['name'] as String?) ?? '',
      reservationPrice: ((map['reservationPrice'] as num?) ?? 0.0).toDouble(),
      isCovered: (map['isCovered'] as bool?) ?? false,
      surfaceType: CourtSurface.values.firstWhere(
        (e) => e.name == map['surfaceType'],
        orElse: () => CourtSurface.synthetic,
      ),
      hasLighting: (map['hasLighting'] as bool?) ?? true,
      sport: CourtSport.values.firstWhere(
        (e) => e.name == map['sport'],
        orElse: () => CourtSport.paddle,
      ),
      images: List<String>.from((map['images'] as List<dynamic>?) ?? []),
      isAvailable: (map['isAvailable'] as bool?) ?? true,
      slotDurationMinutes: (map['slotDurationMinutes'] as int?) ?? 90,
    );
  }
  final String id;
  final String clubId;
  final String name;
  final double reservationPrice;
  final bool isCovered;
  final CourtSurface surfaceType;
  final bool hasLighting;
  final CourtSport sport;
  final List<String> images;
  final bool isAvailable;
  final int slotDurationMinutes;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clubId': clubId,
      'name': name,
      'reservationPrice': reservationPrice,
      'isCovered': isCovered,
      'surfaceType': surfaceType.name,
      'hasLighting': hasLighting,
      'sport': sport.name,
      'images': images,
      'isAvailable': isAvailable,
      'slotDurationMinutes': slotDurationMinutes,
    };
  }

  CourtModel copyWith({
    String? id,
    String? clubId,
    String? name,
    double? reservationPrice,
    bool? isCovered,
    CourtSurface? surfaceType,
    bool? hasLighting,
    CourtSport? sport,
    List<String>? images,
    bool? isAvailable,
    int? slotDurationMinutes,
  }) {
    return CourtModel(
      id: id ?? this.id,
      clubId: clubId ?? this.clubId,
      name: name ?? this.name,
      reservationPrice: reservationPrice ?? this.reservationPrice,
      isCovered: isCovered ?? this.isCovered,
      surfaceType: surfaceType ?? this.surfaceType,
      hasLighting: hasLighting ?? this.hasLighting,
      sport: sport ?? this.sport,
      images: images ?? this.images,
      isAvailable: isAvailable ?? this.isAvailable,
      slotDurationMinutes: slotDurationMinutes ?? this.slotDurationMinutes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CourtModel &&
        other.id == id &&
        other.clubId == clubId &&
        other.name == name &&
        other.reservationPrice == reservationPrice &&
        other.isCovered == isCovered &&
        other.surfaceType == surfaceType &&
        other.hasLighting == hasLighting &&
        other.sport == sport &&
        other.images.length == images.length &&
        other.images.every(images.contains) &&
        other.isAvailable == isAvailable &&
        other.slotDurationMinutes == slotDurationMinutes;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        clubId.hashCode ^
        name.hashCode ^
        reservationPrice.hashCode ^
        isCovered.hashCode ^
        surfaceType.hashCode ^
        hasLighting.hashCode ^
        sport.hashCode ^
        Object.hashAll(images) ^
        isAvailable.hashCode ^
        slotDurationMinutes.hashCode;
  }

  @override
  String toString() {
    return 'CourtModel(id: $id, clubId: $clubId, name: $name, reservationPrice: $reservationPrice, isCovered: $isCovered, surfaceType: $surfaceType, hasLighting: $hasLighting, sport: $sport, images: $images, isAvailable: $isAvailable, slotDurationMinutes: $slotDurationMinutes)';
  }
}
