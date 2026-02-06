import 'package:flutter/material.dart';
import 'package:padel_punilla/presentation/providers/notification_provider.dart';
import 'package:padel_punilla/presentation/screens/notifications/widgets/notification_item.dart';
import 'package:padel_punilla/presentation/widgets/ambient_glow.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Notificaciones',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            tooltip: 'Marcar todas como leídas',
            onPressed:
                provider.unreadCount > 0
                    ? () {
                      context.read<NotificationProvider>().markAllAsRead();
                    }
                    : null,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            right: -100,
            child: AmbientGlow(
              color: colorScheme.primary,
              size: 400,
              opacity: 0.2,
            ),
          ),

          if (provider.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (provider.notifications.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes notificaciones',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          else
            SafeArea(
              child: ListView.separated(
                padding: const EdgeInsets.only(top: 16, bottom: 32),
                itemCount: provider.notifications.length,
                separatorBuilder:
                    (context, index) => Divider(
                      height: 1,
                      color: colorScheme.outlineVariant.withOpacity(0.5),
                    ),
                itemBuilder: (context, index) {
                  final notification = provider.notifications[index];
                  return NotificationItem(
                    notification: notification,
                    onTap: () {
                      if (!notification.isRead) {
                        context.read<NotificationProvider>().markAsRead(
                          notification.id,
                        );
                      }
                      // Aquí podriamos navegar al detalle de la reserva si hay reservationId
                      // Por ahora solo marcamos como leída
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
