import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:padel_punilla/domain/enums/reservation_enums.dart';
import 'package:padel_punilla/domain/enums/club_amenity.dart';
import 'package:padel_punilla/domain/models/club_dashboard_stats.dart';
import 'package:padel_punilla/domain/models/club_model.dart';
import 'package:padel_punilla/domain/models/reservation_model.dart';
import 'package:padel_punilla/domain/models/season_model.dart';
import 'package:padel_punilla/domain/repositories/auth_repository.dart';
import 'package:padel_punilla/domain/repositories/club_repository.dart';
import 'package:padel_punilla/domain/repositories/reservation_repository.dart';
import 'package:padel_punilla/domain/repositories/season_repository.dart';
import 'package:padel_punilla/domain/repositories/storage_repository.dart';

/// Provider para gestionar el club y sus reservas.
///
/// Incluye funcionalidades de admin como aprobar/rechazar/cancelar reservas,
/// definir ganadores de partidos 2vs2, y gestionar pagos.
class ClubManagementProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final ClubRepository _clubRepository;
  final ReservationRepository _reservationRepository;
  final SeasonRepository _seasonRepository;
  final StorageRepository _storageRepository;

  ClubManagementProvider({
    required AuthRepository authRepository,
    required ClubRepository clubRepository,
    required ReservationRepository reservationRepository,
    required SeasonRepository seasonRepository,
    required StorageRepository storageRepository,
  }) : _authRepository = authRepository,
       _clubRepository = clubRepository,
       _reservationRepository = reservationRepository,
       _seasonRepository = seasonRepository,
       _storageRepository = storageRepository {
    _loadClub();
  }
  // ... (existing code)

  /// Define el ganador de un partido 2vs2
  /// [winningTeam] es 1 para team1, 2 para team2
  Future<void> setMatchWinner(String reservationId, int winningTeam) async {
    final reservation = _reservations.firstWhere((r) => r.id == reservationId);

    // 1. Actualizar la reserva con el ganador
    final updatedReservation = reservation.copyWith(winnerTeam: winningTeam);
    await _reservationRepository.updateReservation(updatedReservation);

    // 2. Actualizar puntuaciones si hay temporada activa
    try {
      if (_club == null) return;
      final activeSeason = await _seasonRepository.getActiveSeasonByClub(
        _club!.id,
      );
      if (activeSeason != null) {
        final winners =
            winningTeam == 1 ? reservation.team1Ids : reservation.team2Ids;
        final losers =
            winningTeam == 1 ? reservation.team2Ids : reservation.team1Ids;

        // Puntos: Ganador +3, Perdedor +1
        await _updatePlayersScore(activeSeason.id, winners, 3.0);
        await _updatePlayersScore(activeSeason.id, losers, 1.0);
      }
    } catch (e) {
      debugPrint('Error updating scores: $e');
    }

    await _loadReservations();
  }

  Future<void> _updatePlayersScore(
    String seasonId,
    List<String> userIds,
    double pointsToAdd,
  ) async {
    for (final userId in userIds) {
      final currentScoreData = await _seasonRepository.getUserScore(
        seasonId,
        userId,
      );
      final currentScore = currentScoreData?.score ?? 0.0;
      await _seasonRepository.updateUserScore(
        seasonId,
        userId,
        currentScore + pointsToAdd,
      );
    }
  }

  ClubModel? _club;
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  List<ReservationModel> _reservations = [];
  List<SeasonModel> _seasons = [];
  ClubDashboardStats _dashboardStats = const ClubDashboardStats();

  /// Mapa de userId -> displayName para mostrar en el timeline
  Map<String, String> _userNames = {};

  ClubModel? get club => _club;
  bool get isLoading => _isLoading;
  DateTime get selectedDate => _selectedDate;
  List<ReservationModel> get reservations => _reservations;
  List<SeasonModel> get seasons => _seasons;
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
          await Future.wait([_loadReservations(), _loadSeasons()]);
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
  // Métodos de gestión de Temporadas (Ligas)
  // ============================================================

  Future<void> _loadSeasons() async {
    if (_club == null) return;
    try {
      _seasons = await _seasonRepository.getSeasonsByClub(_club!.id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading seasons: $e');
    }
  }

  Future<void> createSeason({
    required String name,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (_club == null) return;

    final newSeason = SeasonModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      clubId: _club!.id,
      number: (_seasons.length) + 1,
      startDate: startDate,
      endDate: endDate,
      isActive: true, // Por defecto activa
    );

    // Desactivar otras temporadas activas si se crea una nueva activa?
    // Por simplicidad, dejamos que el backend o lógica de negocio maneje esto,
    // o simplemente desactivamos las demás aquí.
    for (final s in _seasons) {
      if (s.isActive) {
        await _seasonRepository.createSeason(s.copyWith(isActive: false));
      }
    }

    await _seasonRepository.createSeason(newSeason);
    await _loadSeasons();
  }

  Future<void> toggleSeasonStatus(String seasonId) async {
    final season = _seasons.firstWhere((s) => s.id == seasonId);
    final newStatus = !season.isActive;

    // Si activamos esta, desactivamos las demas
    if (newStatus) {
      for (final s in _seasons) {
        if (s.id != seasonId && s.isActive) {
          await _seasonRepository.createSeason(s.copyWith(isActive: false));
        }
      }
    }

    await _seasonRepository.createSeason(season.copyWith(isActive: newStatus));
    await _loadSeasons();
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
    int total = _reservations.length;
    double revenue = 0;
    int pending = 0;
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
