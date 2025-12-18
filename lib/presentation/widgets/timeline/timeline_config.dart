/// Configuración para personalizar el comportamiento del timeline.
///
/// Permite reutilizar el timeline en diferentes contextos (admin vs usuario)
/// controlando qué información y acciones se muestran.
class TimelineConfig {
  /// Si es true, muestra el nombre del usuario que hizo la reserva
  final bool showUserName;

  /// Si es true, muestra acciones de admin (aprobar, rechazar, cancelar, etc)
  final bool showAdminActions;

  /// Si es true, muestra el tipo de reserva (Normal, 2vs2, Falta1)
  final bool showReservationType;

  /// Si es true, muestra indicador de estado de pago
  final bool showPaymentStatus;

  const TimelineConfig({
    this.showUserName = false,
    this.showAdminActions = false,
    this.showReservationType = true,
    this.showPaymentStatus = false,
  });

  /// Configuración por defecto para vista de usuario normal
  static const TimelineConfig userView = TimelineConfig(
    showUserName: false,
    showAdminActions: false,
    showReservationType: true,
    showPaymentStatus: false,
  );

  /// Configuración para vista de administrador del club
  static const TimelineConfig adminView = TimelineConfig(
    showUserName: true,
    showAdminActions: true,
    showReservationType: true,
    showPaymentStatus: true,
  );
}
