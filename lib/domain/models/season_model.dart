class SeasonModel {
  SeasonModel({
    required this.id,
    required this.name,
    required this.clubId,
    required this.number,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  factory SeasonModel.fromMap(Map<String, dynamic> map, String id) {
    return SeasonModel(
      id: id,
      name: map['name'] as String? ?? '',
      clubId: map['clubId'] as String? ?? '',
      number: map['number'] as int? ?? 0,
      startDate:
          map['startDate'] is DateTime
              ? map['startDate'] as DateTime
              : DateTime.parse(map['startDate'].toString()),
      endDate:
          map['endDate'] is DateTime
              ? map['endDate'] as DateTime
              : DateTime.parse(map['endDate'].toString()),
      isActive: map['isActive'] as bool? ?? false,
    );
  }
  final String id;
  final String name;
  final String clubId;
  final int number;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'clubId': clubId,
      'number': number,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
    };
  }

  SeasonModel copyWith({
    String? id,
    String? name,
    String? clubId,
    int? number,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) {
    return SeasonModel(
      id: id ?? this.id,
      name: name ?? this.name,
      clubId: clubId ?? this.clubId,
      number: number ?? this.number,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SeasonModel &&
        other.id == id &&
        other.name == name &&
        other.clubId == clubId &&
        other.number == number &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        clubId.hashCode ^
        number.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        isActive.hashCode;
  }

  @override
  String toString() {
    return 'SeasonModel(id: $id, name: $name, clubId: $clubId, number: $number, startDate: $startDate, endDate: $endDate, isActive: $isActive)';
  }
}
