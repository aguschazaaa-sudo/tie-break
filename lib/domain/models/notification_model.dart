class NotificationModel {
  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.receiverId,
    required this.createdAt,
    this.reservationId,
    this.type = 'matchJoined',
    this.isRead = false,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      receiverId: map['receiverId'] as String? ?? '',
      createdAt: DateTime.parse(map['createdAt'] as String),
      reservationId: map['reservationId'] as String?,
      type: map['type'] as String? ?? 'matchJoined',
      isRead: map['isRead'] as bool? ?? false,
    );
  }
  final String id;
  final String title;
  final String body;
  final String receiverId;
  final DateTime createdAt;
  final String? reservationId;
  final String type;
  final bool isRead;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'receiverId': receiverId,
      'createdAt': createdAt.toIso8601String(),
      'reservationId': reservationId,
      'type': type,
      'isRead': isRead,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? receiverId,
    DateTime? createdAt,
    String? reservationId,
    String? type,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      receiverId: receiverId ?? this.receiverId,
      createdAt: createdAt ?? this.createdAt,
      reservationId: reservationId ?? this.reservationId,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }
}
