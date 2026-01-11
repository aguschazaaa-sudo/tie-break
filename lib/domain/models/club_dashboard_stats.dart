class ClubDashboardStats {
  const ClubDashboardStats({
    this.totalReservations = 0,
    this.totalRevenue = 0.0,
    this.activeCourts = 0,
    this.pendingReservations = 0,
  });
  final int totalReservations;
  final double totalRevenue;
  final int activeCourts;
  final int pendingReservations;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ClubDashboardStats &&
        other.totalReservations == totalReservations &&
        other.totalRevenue == totalRevenue &&
        other.activeCourts == activeCourts &&
        other.pendingReservations == pendingReservations;
  }

  @override
  int get hashCode {
    return totalReservations.hashCode ^
        totalRevenue.hashCode ^
        activeCourts.hashCode ^
        pendingReservations.hashCode;
  }
}
