import 'package:padel_punilla/domain/models/notification_model.dart';

abstract class NotificationRepository {
  /// Obtiene un stream de las notificaciones de un usuario
  Stream<List<NotificationModel>> getUserNotifications(String userId);

  /// Marca una notificación como leída
  Future<void> markAsRead(String notificationId);

  /// Marca todas las notificaciones de un usuario como leídas
  Future<void> markAllAsRead(String userId);
}
