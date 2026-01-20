import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:padel_punilla/domain/enums/club_amenity.dart';
import 'package:padel_punilla/domain/enums/paddle_category.dart';
import 'package:padel_punilla/domain/enums/reservation_enums.dart';
import 'package:padel_punilla/domain/models/club_dashboard_stats.dart';
import 'package:padel_punilla/domain/models/club_model.dart';
import 'package:padel_punilla/domain/models/reservation_model.dart';
import 'package:padel_punilla/domain/repositories/auth_repository.dart';
import 'package:padel_punilla/domain/repositories/club_repository.dart';
import 'package:padel_punilla/domain/repositories/reservation_repository.dart';
import 'package:padel_punilla/domain/repositories/season_repository.dart';
import 'package:padel_punilla/domain/repositories/storage_repository.dart';
import 'package:padel_punilla/domain/services/match_scoring_service.dart';

/// Provider para gestionar el club y sus reservas.
///
/// Incluye funcionalidades de admin como aprobar/rechazar/cancelar reservas,
/// definir ganadores de partidos 2vs2, y gestionar pagos.
class ClubManagementProvider extends ChangeNotifier {
  ClubManagementProvider({
    required AuthRepository authRepository,
    required ClubRepository clubRepository,
    required ReservationRepository reservationRepository,
    SeasonRepository? seasonRepository,
    required StorageRepository storageRepository,
  }) : _authRepository = authRepository,
       _clubRepository = clubRepository,
       _reservationRepository = reservationRepository,
       _seasonRepository = seasonRepository,
       _storageRepository = storageRepository {
    _loadClub();
  }
  final AuthRepository _authRepository;
  final ClubRepository _clubRepository;
  final ReservationRepository _reservationRepository;
  final SeasonRepository? _seasonRepository;
  final StorageRepository _storageRepository;

  /// Define el ganador de un partido 2vs2 y actualiza puntuaciones.
  ///
  /// Los puntos se calculan dinámicamente según el nivel (PaddleCategory)
  /// de los jugadores de cada equipo:
  /// - Si un equipo más débil gana, recibe más puntos (upset bonus)
  /// - Si un equipo más fuerte gana, recibe menos puntos
  /// - Todos reciben puntos para premiar la ocupación de canchas
  ///
  /// [winningTeam] es 1 para team1, 2 para team2
  Future<void> setMatchWinner(String reservationId, int winningTeam) async {
    final reservation = _reservations.firstWhere((r) => r.id == reservationId);

    // 1. Actualizar la reserva con el ganador
    final updatedReservation = reservation.copyWith(winnerTeam: winningTeam);
    await _reservationRepository.updateReservation(updatedReservation);

    // 2. Actualizar puntuaciones si hay temporada activa
    try {
      if (_club == null || _seasonRepository == null) return;
      final activeSeason = await _seasonRepository!.getActiveSeasonByClub(
        _club!.id,
      );
      if (activeSeason != null) {
        // Obtener los IDs de ganadores y perdedores
        final winnerIds =
            winningTeam == 1 ? reservation.team1Ids : reservation.team2Ids;
        final loserIds =
            winningTeam == 1 ? reservation.team2Ids : reservation.team1Ids;

        // Obtener datos de todos los jugadores para calcular niveles
        final allPlayerIds = [...winnerIds, ...loserIds];
        final players = await _authRepository.getUsersByIds(allPlayerIds);

        // Crear mapa de userId -> category para acceso rápido
        final categoryMap = <String, PaddleCategory?>{};
        for (final player in players) {
          categoryMap[player.id] = player.category;
        }

        // Calcular niveles de equipo (promedio ponderado)
        final winnerTeamLevel = MatchScoringService.calculateTeamLevel(
          categoryMap[winnerIds[0]],
          categoryMap[winnerIds.length > 1 ? winnerIds[1] : winnerIds[0]],
        );
        final loserTeamLevel = MatchScoringService.calculateTeamLevel(
          categoryMap[loserIds[0]],
          categoryMap[loserIds.length > 1 ? loserIds[1] : loserIds[0]],
        );

        // Calcular puntos según diferencia de niveles
        final points = MatchScoringService.calculateMatchPoints(
          winnerTeamLevel: winnerTeamLevel,
          loserTeamLevel: loserTeamLevel,
        );

        // Actualizar puntos de cada jugador con estadísticas
        await _updatePlayersScoreWithStats(
          activeSeason.id,
          winnerIds,
          points.winnerPoints,
          isWinner: true,
        );
        await _updatePlayersScoreWithStats(
          activeSeason.id,
          loserIds,
          points.loserPoints,
          isWinner: false,
        );
      }
    } catch (e) {
      debugPrint('Error updating scores: $e');
    }

    await _loadReservations();
  }

  /// Actualiza puntos y estadísticas de un grupo de jugadores.
  ///
  /// Usa operaciones atómicas para evitar race conditions.
  Future<void> _updatePlayersScoreWithStats(
    String seasonId,
    List<String> userIds,
    double pointsToAdd, {
    required bool isWinner,
  }) async {
    if (_seasonRepository == null) return;
    for (final userId in userIds) {
      await _seasonRepository!.updateUserScoreWithStats(
        seasonId,
        userId,
        pointsToAdd,
        isWinner,
      );
    }
  }

  ClubModel? _club;
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  List<ReservationModel> _reservations = [];
  ClubDashboardStats _dashboardStats = const ClubDashboardStats();

  /// Mapa de userId -> displayName para mostrar en el timeline
  final Map<String, String> _userNames = {};

  ClubModel? get club => _club;
  bool get isLoading => _isLoading;
  DateTime get selectedDate => _selectedDate;
  List<ReservationModel> get reservations => _reservations;
  ClubDashboardStats get dashboardStats => _dashboardStats;
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

      // Calcular estadisticas
      _calculateDailyStats();

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
    await _reservationRepository.updateReservation(updated);
    await _loadReservations();
  }

  /// Bloquea una cancha creando una reserva especial (Mantenimiento/Clase)
  Future<void> blockCourt({
    required String courtId,
    required DateTime date,
    required int durationMinutes,
    required ReservationType type,
    String? description,
  }) async {
    if (_club == null) return;

    final reservation = ReservationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // ID temporal único
      courtId: courtId,
      clubId: _club!.id,
      userId: 'BLOCK', // ID especial para bloqueos
      reservedDate: date,
      startTime: date,
      durationMinutes: durationMinutes,
      createdAt: DateTime.now(),
      price: 0,
      status: ReservationStatus.approved,
      type: type,
      // Usamos el campo participantIds para guardar la descripción si es necesario??
      // No, mejor no abusar de campos. Por ahora sin descripción en el modelo
      // o podríamos usar un campo 'note' si existiera.
    );

    await _reservationRepository.createReservation(reservation);
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

  Future<void> updateClubLogo(XFile image) async {
    if (_club == null) return;

    try {
      final logoUrl = await _storageRepository.uploadClubLogo(image, _club!.id);

      final updatedClub = _club!.copyWith(logoUrl: logoUrl);
      await _clubRepository.updateClub(updatedClub);
      _club = updatedClub;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating club logo: $e');
      rethrow;
    }
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

  Future<void> toggleAmenity(ClubAmenity amenity) async {
    if (_club == null) return;

    final currentAmenities = List<ClubAmenity>.from(_club!.amenities);
    if (currentAmenities.contains(amenity)) {
      currentAmenities.remove(amenity);
    } else {
      currentAmenities.add(amenity);
    }

    final updatedClub = _club!.copyWith(amenities: currentAmenities);
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

  // ============================================================
  // Estadísticas (Dashboard)
  // ============================================================

  Future<void> loadDailyStats() async {
    // Si ya estan cargadas las reservas, solo recálculo.
    // O recargamos explicitamente?
    // Para simplificar y cumplir test, recalculamos basándonos en _reservations.
    // Si el test llama a loadDailyStats, asumimos que _reservations ya tiene la data o deberia cargarla?
    // En el test, se moquea el repo.
    // Si loadDailyStats llama a _loadReservations, cumplimos ciclo complete.
    await _loadReservations();
  }

  void _calculateDailyStats() {
    final total = _reservations.length;
    double revenue = 0;
    var pending = 0;
    final activeCourtsSet = <String>{};

    for (final r in _reservations) {
      if (r.status == ReservationStatus.approved) {
        revenue += r.price;
      }
      if (r.status == ReservationStatus.pending) {
        pending++;
      }
      activeCourtsSet.add(r.courtId);
    }

    _dashboardStats = ClubDashboardStats(
      totalReservations: total,
      totalRevenue: revenue,
      activeCourts: activeCourtsSet.length,
      pendingReservations: pending,
    );
  }
}
