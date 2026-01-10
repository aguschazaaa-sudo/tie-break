import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/enums/connectivity_status.dart';
import 'package:padel_punilla/presentation/providers/connectivity_provider.dart';
import 'package:provider/provider.dart';

/// Banner animado que muestra el estado de conectividad.
///
/// Aparece cuando el dispositivo pierde conexión a internet.
class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, provider, child) {
        final isOffline = provider.status == ConnectivityStatus.offline;
        final colorScheme = Theme.of(context).colorScheme;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: isOffline ? 40 : 0,
          child:
              isOffline
                  ? Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.error.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wifi_off,
                          color: colorScheme.onError,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Sin conexión a internet',
                          style: TextStyle(
                            color: colorScheme.onError,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                  : const SizedBox.shrink(),
        );
      },
    );
  }
}
