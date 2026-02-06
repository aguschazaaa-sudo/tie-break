import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:padel_punilla/domain/models/notification_model.dart';
import 'package:padel_punilla/domain/repositories/auth_repository.dart';
import 'package:padel_punilla/domain/repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider({
    required NotificationRepository notificationRepository,
    required AuthRepository authRepository,
  }) : _notificationRepository = notificationRepository,
       _authRepository = authRepository {
    _init();
  }

  final NotificationRepository _notificationRepository;
  final AuthRepository _authRepository;

  StreamSubscription<List<NotificationModel>>? _subscription;
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void _init() {
    // Escuchar cambios en la autenticación para actualizar las notificaciones
    // Si el usuario cambia (logout/login), reiniciamos el stream
    final user = _authRepository.currentUser;
    if (user != null) {
      _subscribeToNotifications(user.uid);
    }

    // Aquí podríamos escuchar el stream de auth si quisiéramos reactividad total al cambio de usuario
    // pero por simplicidad asumimos que el provider se reconstruye o reinicia en el árbol si cambia el Auth context.
    // Sin embargo, para ser más robustos en un provider global:
    // TODO: Considerar escuchar authRepository.authStateChanges si este provider es singleton/global.
  }

  void _subscribeToNotifications(String userId) {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _notificationRepository
        .getUserNotifications(userId)
        .listen(
          (notifications) {
            _notifications = notifications;
            _isLoading = false;
            notifyListeners();
          },
          onError: (Object error) {
            debugPrint('Error loading notifications: $error');
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationRepository.markAsRead(notificationId);
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    final user = _authRepository.currentUser;
    if (user == null) return;

    try {
      await _notificationRepository.markAllAsRead(user.uid);
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
