enum ReservationStatus {
  pending,
  approved,
  rejected,
  cancelled;

  String get displayName {
    switch (this) {
      case ReservationStatus.pending:
        return 'Pendiente';
      case ReservationStatus.approved:
        return 'Aprobada';
      case ReservationStatus.rejected:
        return 'Rechazada';
      case ReservationStatus.cancelled:
        return 'Cancelada';
    }
  }
}

enum PaymentStatus {
  pending,
  partial,
  paid,
  refunded;

  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pendiente';
      case PaymentStatus.partial:
        return 'Parcial';
      case PaymentStatus.paid:
        return 'Pagado';
      case PaymentStatus.refunded:
        return 'Reembolsado';
    }
  }
}

enum ReservationType {
  normal,
  match2vs2,
  falta1,
  maintenance,
  coaching;

  String get displayName {
    switch (this) {
      case ReservationType.normal:
        return 'Normal';
      case ReservationType.match2vs2:
        return '2 vs 2';
      case ReservationType.falta1:
        return 'Falta 1';
      case ReservationType.maintenance:
        return 'Mantenimiento';
      case ReservationType.coaching:
        return 'Clase / Entrenamiento';
    }
  }
}
