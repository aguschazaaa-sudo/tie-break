class SeasonModel {
  SeasonModel({
    required this.id,
    required this.name,
    required this.number,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  factory SeasonModel.fromMap(Map<String, dynamic> map, String id) {
    return SeasonModel(
      id: id,
      name: map['name'] as String? ?? '',
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
  final int number;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'number': number,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SeasonModel &&
        other.id == id &&
        other.name == name &&
        other.number == number &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        number.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        isActive.hashCode;
  }

  @override
  String toString() {
    return 'SeasonModel(id: $id, name: $name, number: $number, startDate: $startDate, endDate: $endDate, isActive: $isActive)';
  }
}
