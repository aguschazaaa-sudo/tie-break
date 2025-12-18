import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/enums/reservation_enums.dart';
import 'package:padel_punilla/domain/models/club_model.dart';
import 'package:padel_punilla/domain/models/reservation_model.dart';
import 'package:padel_punilla/domain/repositories/auth_repository.dart';
import 'package:padel_punilla/domain/repositories/club_repository.dart';
import 'package:padel_punilla/domain/repositories/reservation_repository.dart';

/// Provider para gestionar el club y sus reservas.
///
/// Incluye funcionalidades de admin como aprobar/rechazar/cancelar reservas,
/// definir ganadores de partidos 2vs2, y gestionar pagos.
class ClubManagementProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final ClubRepository _clubRepository;
  final ReservationRepository _reservationRepository;

  ClubManagementProvider({
    required AuthRepository authRepository,
    required ClubRepository clubRepository,
    required ReservationRepository reservationRepository,
  }) : _authRepository = authRepository,
       _clubRepository = clubRepository,
       _reservationRepository = reservationRepository {
    _loadClub();
  }

  ClubModel? _club;
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  List<ReservationModel> _reservations = [];

  /// Mapa de userId -> displayName para mostrar en el timeline
  Map<String, String> _userNames = {};

  ClubModel? get club => _club;
  bool get isLoading => _isLoading;
  DateTime get selectedDate => _selectedDate;
  List<ReservationModel> get reservations => _reservations;
  Map<String, String> get userNames => _userNames;

  List<ReservationModel> getReservationsForCourt(String courtId) {
    return _reservations.where((r) => r.courtId == courtId).toList();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
    _loadReservations();
  }

  Future<void> _loadClub() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final currentUser = _authRepository.currentUser;

      if (currentUser != null) {
        final club = await _clubRepository.getClubByUserId(currentUser.uid);
        if (club != null) {
          _club = club;
          await _loadReservations();
        }
      }
    } catch (e) {
      debugPrint('Error loading club: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadReservations() async {
    if (_club == null) return;
    try {
      final allReservations = await _reservationRepository
          .getReservationsByClubAndDate(_club!.id, _selectedDate);

      // Filtrar reservas canceladas y rechazadas - no las mostramos en el timeline
      _reservations =
          allReservations
              .where(
                (r) =>
                    r.status != ReservationStatus.cancelled &&
                    r.status != ReservationStatus.rejected,
              )
              .toList();

      // Precargar nombres de usuarios de las reservas
      await _loadUserNames();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading reservations: $e');
    }
  }

  /// Precarga los nombres de usuarios para todas las reservas cargadas
  Future<void> _loadUserNames() async {
    // Recolectar todos los userIds únicos
    final userIds = <String>{};
    for (final reservation in _reservations) {
      userIds.add(reservation.userId);
      userIds.addAll(reservation.participantIds);
      userIds.addAll(reservation.team1Ids);
      userIds.addAll(reservation.team2Ids);
    }

    // No cargar si ya tenemos todos los nombres
    final missingIds =
        userIds.where((id) => !_userNames.containsKey(id)).toList();
    if (missingIds.isEmpty) return;

    try {
      final users = await _authRepository.getUsersByIds(missingIds);
      for (final user in users) {
        _userNames[user.id] = user.displayName;
      }
    } catch (e) {
      debugPrint('Error loading user names: $e');
    }
  }

  // ============================================================
  // Métodos de Admin para gestionar reservas
  // ============================================================

  /// Aprueba una reserva pendiente
  Future<void> approveReservation(String reservationId) async {
    final reservation = _reservations.firstWhere((r) => r.id == reservationId);
    final updated = reservation.copyWith(status: ReservationStatus.approved);

    await _reservationRepository.updateReservation(updated);
    await _loadReservations();
  }

  /// Rechaza una reserva pendiente
  Future<void> rejectReservation(String reservationId) async {
    final reservation = _reservations.firstWhere((r) => r.id == reservationId);
    final updated = reservation.copyWith(status: ReservationStatus.rejected);

    await _reservationRepository.updateReservation(updated);
    await _loadReservations();
  }

  /// Cancela una reserva aprobada
  Future<void> cancelReservation(String reservationId) async {
    final reservation = _reservations.firstWhere((r) => r.id == reservationId);
    final updated = reservation.copyWith(status: ReservationStatus.cancelled);

    await _reservationRepository.updateReservation(updated);
    await _loadReservations();
  }

  /// Define el ganador de un partido 2vs2
  /// [winningTeam] es 1 para team1, 2 para team2
  Future<void> setMatchWinner(String reservationId, int winningTeam) async {
    // TODO: Implementar lógica para guardar resultado y actualizar puntuaciones
    // Por ahora solo notificamos
    debugPrint('Winner set for $reservationId: Team $winningTeam');
    notifyListeners();
  }

  /// Actualiza el pago de una reserva
  Future<void> updatePayment(
    String reservationId, {
    required double paidAmount,
    required PaymentStatus paymentStatus,
  }) async {
    final reservation = _reservations.firstWhere((r) => r.id == reservationId);
    final updated = reservation.copyWith(
      paidAmount: paidAmount,
      paymentStatus: paymentStatus,
    );

    await _reservationRepository.updateReservation(updated);
    await _loadReservations();
  }

  // ============================================================
  // Métodos de gestión del club
  // ============================================================

  Future<void> updateClubDetails({
    required String name,
    required String description,
    required String address,
    required String phone,
  }) async {
    if (_club == null) return;

    final updatedClub = _club!.copyWith(
      name: name,
      description: description,
      address: address,
      contactPhone: phone,
    );

    await _clubRepository.updateClub(updatedClub);
    _club = updatedClub;
    notifyListeners();
  }

  Future<void> addSchedule(String time) async {
    if (_club == null) return;
    if (_club!.availableSchedules.contains(time)) {
      throw Exception('El horario ya existe');
    }

    final updatedSchedules =
        List<String>.from(_club!.availableSchedules)
          ..add(time)
          ..sort();

    final updatedClub = _club!.copyWith(availableSchedules: updatedSchedules);
    await _clubRepository.updateClub(updatedClub);
    _club = updatedClub;
    notifyListeners();
  }

  Future<void> removeSchedule(String schedule) async {
    if (_club == null) return;

    final updatedSchedules = List<String>.from(_club!.availableSchedules)
      ..remove(schedule);

    final updatedClub = _club!.copyWith(availableSchedules: updatedSchedules);
    await _clubRepository.updateClub(updatedClub);
    _club = updatedClub;
    notifyListeners();
  }

  Future<void> addHelper(String userId) async {
    if (_club == null) return;
    if (_club!.helperIds.contains(userId)) {
      throw Exception('Este usuario ya es colaborador');
    }
    if (_club!.adminId == userId) {
      throw Exception('El administrador ya tiene acceso total');
    }

    final updatedHelpers = List<String>.from(_club!.helperIds)..add(userId);

    final updatedClub = _club!.copyWith(helperIds: updatedHelpers);
    await _clubRepository.updateClub(updatedClub);
    _club = updatedClub;
    notifyListeners();
  }

  Future<void> removeHelper(String helperId) async {
    if (_club == null) return;

    final updatedHelpers = List<String>.from(_club!.helperIds)
      ..remove(helperId);

    final updatedClub = _club!.copyWith(helperIds: updatedHelpers);
    await _clubRepository.updateClub(updatedClub);
    _club = updatedClub;
    notifyListeners();
  }
}
