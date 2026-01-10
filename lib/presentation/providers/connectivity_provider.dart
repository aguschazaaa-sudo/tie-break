import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:padel_punilla/domain/enums/connectivity_status.dart';
import 'package:padel_punilla/domain/services/connectivity_service.dart';

/// Provider que gestiona el estado de conectividad de red.
///
/// Escucha cambios en la conectividad y notifica a los widgets consumidores.
class ConnectivityProvider extends ChangeNotifier {
  ConnectivityProvider({required ConnectivityService service})
    : _service = service {
    _init();
  }

  final ConnectivityService _service;
  StreamSubscription<ConnectivityStatus>? _subscription;
  ConnectivityStatus _status = ConnectivityStatus.unknown;

  /// Estado actual de conectividad.
  ConnectivityStatus get status => _status;

  /// Indica si el dispositivo está sin conexión.
  bool get isOffline => _status == ConnectivityStatus.offline;

  /// Indica si el dispositivo está conectado.
  bool get isOnline => _status == ConnectivityStatus.online;

  void _init() {
    // Obtener estado actual
    _service.currentStatus.then((status) {
      _status = status;
      notifyListeners();
    });

    // Escuchar cambios
    _subscription = _service.statusStream.listen((status) {
      if (_status != status) {
        _status = status;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
