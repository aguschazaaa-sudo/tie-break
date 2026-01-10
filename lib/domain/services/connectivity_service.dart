import 'package:padel_punilla/domain/enums/connectivity_status.dart';

/// Servicio abstracto para monitorear el estado de conectividad de red.
///
/// Proporciona streams reactivos y métodos para consultar el estado actual.
abstract class ConnectivityService {
  /// Stream que emite cambios en el estado de conectividad.
  Stream<ConnectivityStatus> get statusStream;

  /// Obtiene el estado de conectividad actual.
  Future<ConnectivityStatus> get currentStatus;

  /// Verifica si el dispositivo tiene conexión a internet.
  Future<bool> get isOnline;

  /// Libera recursos del servicio.
  void dispose();
}
