import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:padel_punilla/domain/enums/connectivity_status.dart';
import 'package:padel_punilla/domain/services/connectivity_service.dart';

/// Implementación del servicio de conectividad usando connectivity_plus.
class ConnectivityServiceImpl implements ConnectivityService {
  ConnectivityServiceImpl({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  StreamController<ConnectivityStatus>? _statusController;

  @override
  Stream<ConnectivityStatus> get statusStream {
    _statusController ??= StreamController<ConnectivityStatus>.broadcast();

    _connectivity.onConnectivityChanged.listen((results) {
      final status = _mapResultsToStatus(results);
      _statusController?.add(status);
    });

    return _statusController!.stream;
  }

  @override
  Future<ConnectivityStatus> get currentStatus async {
    final results = await _connectivity.checkConnectivity();
    return _mapResultsToStatus(results);
  }

  @override
  Future<bool> get isOnline async {
    final status = await currentStatus;
    return status == ConnectivityStatus.online;
  }

  ConnectivityStatus _mapResultsToStatus(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return ConnectivityStatus.offline;
    }

    // Si hay cualquier tipo de conexión (wifi, mobile, ethernet, etc.)
    if (results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.ethernet) ||
        results.contains(ConnectivityResult.vpn)) {
      return ConnectivityStatus.online;
    }

    return ConnectivityStatus.unknown;
  }

  @override
  void dispose() {
    _statusController?.close();
  }
}
