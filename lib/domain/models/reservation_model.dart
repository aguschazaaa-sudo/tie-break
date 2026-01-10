import 'package:padel_punilla/domain/enums/reservation_enums.dart';

class ReservationModel {
  ReservationModel({
    required this.id,
    required this.courtId,
    required this.clubId,
    required this.userId,
    required this.reservedDate,
    required this.startTime,
    required this.durationMinutes,
    required this.createdAt,
    required this.price,
    this.participantIds = const [],
    this.status = ReservationStatus.pending,
    this.paymentStatus = PaymentStatus.pending,
    this.cancellationReason,
    this.paidAmount = 0.0,
    this.type = ReservationType.normal,
    this.team1Ids = const [],
    this.team2Ids = const [],
    this.womenOnly = false,
    this.winnerTeam,
  });

  factory ReservationModel.fromMap(Map<String, dynamic> map) {
    return ReservationModel(
      id: map['id'] as String? ?? '',
      courtId: map['courtId'] as String? ?? '',
      clubId: map['clubId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      participantIds: List<String>.from((map['participantIds'] as List?) ?? []),
      reservedDate: DateTime.parse(map['reservedDate'] as String),
      startTime: DateTime.parse(map['startTime'] as String),
      durationMinutes: map['durationMinutes'] as int? ?? 60,
      createdAt: DateTime.parse(map['createdAt'] as String),
      status: ReservationStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ReservationStatus.pending,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == map['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      cancellationReason: map['cancellationReason'] as String?,
      price: (map['price'] as num? ?? 0.0).toDouble(),
      paidAmount: (map['paidAmount'] as num? ?? 0.0).toDouble(),
      type: ReservationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ReservationType.normal,
      ),
      team1Ids: List<String>.from((map['team1Ids'] as List?) ?? []),
      team2Ids: List<String>.from((map['team2Ids'] as List?) ?? []),
      womenOnly: map['womenOnly'] as bool? ?? false,
      winnerTeam: map['winnerTeam'] as int?,
    );
  }
  final String id;
  final String courtId;
  final String clubId;
  final String userId;
  final List<String> participantIds;
  final DateTime reservedDate;
  final DateTime startTime;
  final int durationMinutes;
  final DateTime createdAt;
  final ReservationStatus status;
  final PaymentStatus paymentStatus;
  final String? cancellationReason;
  final double price;
  final double paidAmount;
  final ReservationType type;
  final List<String> team1Ids;
  final List<String> team2Ids;

  /// Si es true, solo mujeres pueden participar (para 2vs2 y falta1)
  final bool womenOnly;

  /// Equipo ganador (1 o 2). Null si no se ha jugado o definido.
  final int? winnerTeam;

  double get remainingAmount => price - paidAmount;

  // A reservation is considered complete if it is confirmed/approved.
  // Pending reservations are essentially "Pre-Reservations" waiting for something (payment or players).
  // Normal reservations are always considered "complete" regarding the slot occupation, UNLESS they are cancelled (which is usually filtered out).
  bool get isComplete {
    if (type == ReservationType.normal) return true;
    return status == ReservationStatus.approved;
  }

  DateTime get endTime => startTime.add(Duration(minutes: durationMinutes));

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courtId': courtId,
      'clubId': clubId,
      'userId': userId,
      'participantIds': participantIds,
      'reservedDate': reservedDate.toIso8601String(),
      'startTime': startTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'paymentStatus': paymentStatus.name,
      'cancellationReason': cancellationReason,
      'price': price,
      'paidAmount': paidAmount,
      'type': type.name,
      'team1Ids': team1Ids,
      'team2Ids': team2Ids,
      'womenOnly': womenOnly,
      'winnerTeam': winnerTeam,
    };
  }

  ReservationModel copyWith({
    String? id,
    String? courtId,
    String? clubId,
    String? userId,
    List<String>? participantIds,
    DateTime? reservedDate,
    DateTime? startTime,
    int? durationMinutes,
    DateTime? createdAt,
    ReservationStatus? status,
    PaymentStatus? paymentStatus,
    String? cancellationReason,
    double? price,
    double? paidAmount,
    ReservationType? type,
    List<String>? team1Ids,
    List<String>? team2Ids,
    bool? womenOnly,
    int? winnerTeam,
  }) {
    return ReservationModel(
      id: id ?? this.id,
      courtId: courtId ?? this.courtId,
      clubId: clubId ?? this.clubId,
      userId: userId ?? this.userId,
      participantIds: participantIds ?? this.participantIds,
      reservedDate: reservedDate ?? this.reservedDate,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      price: price ?? this.price,
      paidAmount: paidAmount ?? this.paidAmount,
      type: type ?? this.type,
      team1Ids: team1Ids ?? this.team1Ids,
      team2Ids: team2Ids ?? this.team2Ids,
      womenOnly: womenOnly ?? this.womenOnly,
      winnerTeam: winnerTeam ?? this.winnerTeam,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ReservationModel &&
        other.id == id &&
        other.courtId == courtId &&
        other.clubId == clubId &&
        other.userId == userId &&
        other.participantIds.length == participantIds.length &&
        other.participantIds.every(participantIds.contains) &&
        other.reservedDate == reservedDate &&
        other.startTime == startTime &&
        other.durationMinutes == durationMinutes &&
        other.createdAt == createdAt &&
        other.status == status &&
        other.paymentStatus == paymentStatus &&
        other.cancellationReason == cancellationReason &&
        other.price == price &&
        other.paidAmount == paidAmount &&
        other.type == type &&
        other.team1Ids.length == team1Ids.length &&
        other.team1Ids.every(team1Ids.contains) &&
        other.team2Ids.length == team2Ids.length &&
        other.team2Ids.every(team2Ids.contains) &&
        other.womenOnly == womenOnly &&
        other.winnerTeam == winnerTeam;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        courtId.hashCode ^
        clubId.hashCode ^
        userId.hashCode ^
        Object.hashAll(participantIds) ^
        reservedDate.hashCode ^
        startTime.hashCode ^
        durationMinutes.hashCode ^
        createdAt.hashCode ^
        status.hashCode ^
        paymentStatus.hashCode ^
        cancellationReason.hashCode ^
        price.hashCode ^
        paidAmount.hashCode ^
        type.hashCode ^
        Object.hashAll(team1Ids) ^
        Object.hashAll(team2Ids) ^
        womenOnly.hashCode ^
        winnerTeam.hashCode;
  }

  @override
  String toString() {
    return 'ReservationModel(id: $id, courtId: $courtId, clubId: $clubId, userId: $userId, participantIds: $participantIds, reservedDate: $reservedDate, startTime: $startTime, durationMinutes: $durationMinutes, createdAt: $createdAt, status: $status, paymentStatus: $paymentStatus, cancellationReason: $cancellationReason, price: $price, paidAmount: $paidAmount, type: $type, team1Ids: $team1Ids, team2Ids: $team2Ids, womenOnly: $womenOnly, winnerTeam: $winnerTeam)';
  }
}
