/// Estados posibles de conectividad de red.
enum ConnectivityStatus {
  /// Dispositivo conectado a internet (WiFi o datos móviles)
  online,

  /// Dispositivo sin conexión a internet
  offline,

  /// Estado de conectividad desconocido (inicial o en transición)
  unknown,
}
