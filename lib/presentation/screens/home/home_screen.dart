import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/enums/locality.dart';
import 'package:padel_punilla/domain/models/club_model.dart';
import 'package:padel_punilla/domain/models/reservation_model.dart';
import 'package:padel_punilla/domain/models/user_model.dart';
import 'package:padel_punilla/domain/repositories/auth_repository.dart';
import 'package:padel_punilla/domain/repositories/club_repository.dart';
import 'package:padel_punilla/domain/repositories/reservation_repository.dart';
import 'package:padel_punilla/presentation/screens/club/club_details_screen.dart';
import 'package:padel_punilla/presentation/screens/home/widgets/active_search_section.dart';
import 'package:padel_punilla/presentation/screens/home/widgets/club_search_section.dart';
import 'package:padel_punilla/presentation/screens/home/widgets/favorite_clubs_section.dart';
import 'package:padel_punilla/presentation/screens/my_reservations/my_reservations_screen.dart';
import 'package:padel_punilla/presentation/screens/profile/profile_screen.dart';
import 'package:padel_punilla/presentation/screens/season/leaderboard_screen.dart';

/// Pantalla principal de la aplicación (Home).
///
/// Muestra:
/// - Clubes favoritos del usuario (acceso rápido)
/// - Búsquedas activas (partidos 2v2 y falta1) en su zona
/// - Buscador de clubes con opción de guardar favoritos
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Repositorios
  final _authRepository = AuthRepository();
  final _clubRepository = ClubRepository();
  final _reservationRepository = ReservationRepository();

  // Estado del usuario
  UserModel? _currentUser;

  // Estado de favoritos
  List<ClubModel> _favoriteClubs = [];
  bool _isLoadingFavorites = true;

  // Estado de búsquedas activas
  List<ReservationModel> _localReservations = [];
  List<ReservationModel> _nearbyReservations = [];
  Map<String, ClubModel> _clubsMap = {};
  bool _isLoadingSearches = true;

  // Estado de búsqueda de clubes
  String _searchQuery = '';
  List<ClubModel> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  /// Carga inicial de todos los datos
  Future<void> _loadInitialData() async {
    await _loadUserData();
    await Future.wait([_loadFavoriteClubs(), _loadActiveSearches()]);
  }

  /// Refresca todos los datos (pull-to-refresh)
  Future<void> _refreshData() async {
    await _loadUserData();
    await Future.wait([_loadFavoriteClubs(), _loadActiveSearches()]);
  }

  /// Carga datos del usuario actual
  Future<void> _loadUserData() async {
    final user = _authRepository.currentUser;
    if (user == null) return;

    try {
      final userData = await _authRepository.getUserData(user.uid);
      if (mounted) {
        setState(() {
          _currentUser = userData;
        });
      }
    } catch (e) {
      // Error cargando usuario - continuamos sin datos
    }
  }

  /// Carga clubes favoritos del usuario
  Future<void> _loadFavoriteClubs() async {
    if (_currentUser == null) {
      setState(() => _isLoadingFavorites = false);
      return;
    }

    setState(() => _isLoadingFavorites = true);

    try {
      final clubs = await _clubRepository.getClubsByIds(
        _currentUser!.favoriteClubIds,
      );
      if (mounted) {
        setState(() {
          _favoriteClubs = clubs;
          _isLoadingFavorites = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingFavorites = false);
      }
    }
  }

  /// Carga búsquedas activas de la zona del usuario
  Future<void> _loadActiveSearches() async {
    final userLocality = _currentUser?.locality;
    if (userLocality == null) {
      setState(() => _isLoadingSearches = false);
      return;
    }

    setState(() => _isLoadingSearches = true);

    try {
      // Obtener clubes de la localidad del usuario
      final localClubs = await _clubRepository.getClubsByLocality(userLocality);

      // Obtener clubes de localidades cercanas
      final nearbyLocalities = userLocality.nearbyLocalities;
      final nearbyClubsFutures = nearbyLocalities.map(
        (locality) => _clubRepository.getClubsByLocality(locality),
      );
      final nearbyClubsLists = await Future.wait(nearbyClubsFutures);
      final nearbyClubs = nearbyClubsLists.expand((list) => list).toList();

      // Crear mapa de clubes para referencia rápida
      final allClubs = [...localClubs, ...nearbyClubs];
      final clubsMap = <String, ClubModel>{};
      for (final club in allClubs) {
        clubsMap[club.id] = club;
      }

      // Obtener IDs de clubes locales y cercanos
      final localClubIds = localClubs.map((c) => c.id).toList();
      final nearbyClubIds = nearbyClubs.map((c) => c.id).toList();

      // Obtener reservas activas de todos los clubes
      final allClubIds = [...localClubIds, ...nearbyClubIds];
      final allReservations = await _reservationRepository
          .getActiveSearchReservations(allClubIds);

      // Separar reservas en locales y cercanas
      final localReservations =
          allReservations
              .where((r) => localClubIds.contains(r.clubId))
              .toList();
      final nearbyReservations =
          allReservations
              .where((r) => nearbyClubIds.contains(r.clubId))
              .toList();

      if (mounted) {
        setState(() {
          _localReservations = localReservations;
          _nearbyReservations = nearbyReservations;
          _clubsMap = clubsMap;
          _isLoadingSearches = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSearches = false);
      }
    }
  }

  /// Busca clubes por nombre
  Future<void> _searchClubs(String query) async {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _searchResults = [];
        _isSearching = false;
        return;
      }
      _isSearching = true;
    });

    if (query.isEmpty) return;

    try {
      final results = await _clubRepository.searchClubsByName(query);
      if (mounted && _searchQuery == query) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  /// Toggle favorito de un club
  Future<void> _toggleFavorite(String clubId) async {
    final user = _currentUser;
    if (user == null) return;

    final isFavorite = user.favoriteClubIds.contains(clubId);

    try {
      if (isFavorite) {
        await _authRepository.removeFavoriteClub(user.id, clubId);
        // Actualizar estado local
        setState(() {
          _currentUser = user.copyWith(
            favoriteClubIds:
                user.favoriteClubIds.where((id) => id != clubId).toList(),
          );
          _favoriteClubs.removeWhere((club) => club.id == clubId);
        });
      } else {
        await _authRepository.addFavoriteClub(user.id, clubId);
        // Buscar el club en resultados de búsqueda o cargar
        ClubModel? club = _searchResults.firstWhere(
          (c) => c.id == clubId,
          orElse:
              () =>
                  _clubsMap[clubId] ??
                  ClubModel(
                    id: clubId,
                    name: '',
                    description: '',
                    adminId: '',
                    address: '',
                    locality: Locality.villaCarlosPaz,
                    createdAt: DateTime.now(),
                    expiresAt: DateTime.now(),
                  ),
        );

        // Si no lo encontramos, cargarlo
        if (club.name.isEmpty) {
          club = await _clubRepository.getClub(clubId);
        }

        if (club != null && mounted) {
          setState(() {
            _currentUser = user.copyWith(
              favoriteClubIds: [...user.favoriteClubIds, clubId],
            );
            _favoriteClubs.add(club!);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  /// Navega al detalle de un club
  void _navigateToClub(ClubModel club) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ClubDetailsScreen(club: club),
      ),
    );
  }

  /// Navega al detalle de una reserva (por ahora al club)
  void _navigateToReservation(ReservationModel reservation) {
    final club = _clubsMap[reservation.clubId];
    if (club != null) {
      _navigateToClub(club);
    }
  }

  /// Cierra sesión
  Future<void> _signOut() async {
    try {
      await _authRepository.signOut();
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cerrar sesión: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = _authRepository.currentUser;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Padel Punilla'),
        actions: [
          // Botón de mis reservas
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            tooltip: 'Mis Reservas',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const MyReservationsScreen(),
                ),
              );
            },
          ),
          // Botón de ranking
          IconButton(
            icon: const Icon(Icons.leaderboard_rounded),
            tooltip: 'Ranking',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const LeaderboardScreen(),
                ),
              );
            },
          ),
          // Botón de perfil
          IconButton(
            icon: const Icon(Icons.person_rounded),
            tooltip: 'Perfil',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
          // Botón de logout
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Cerrar sesión',
            onPressed: _signOut,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          slivers: [
            // Saludo al usuario
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Row(
                  children: [
                    // Avatar
                    if (user?.photoURL != null)
                      CircleAvatar(
                        radius: 28,
                        backgroundImage: NetworkImage(user!.photoURL!),
                      )
                    else
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: colorScheme.primaryContainer,
                        child: Icon(
                          Icons.person_rounded,
                          size: 28,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    const SizedBox(width: 16),
                    // Texto de bienvenida
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¡Hola, ${_currentUser?.displayName ?? user?.displayName ?? 'Jugador'}!',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_currentUser?.locality != null)
                            Text(
                              _currentUser!.locality!.displayName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Sección de favoritos
            SliverToBoxAdapter(
              child: FavoriteClubsSection(
                favoriteClubs: _favoriteClubs,
                onClubTap: _navigateToClub,
                isLoading: _isLoadingFavorites,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Sección de búsquedas activas
            SliverToBoxAdapter(
              child: ActiveSearchSection(
                localReservations: _localReservations,
                nearbyReservations: _nearbyReservations,
                clubs: _clubsMap,
                userLocality: _currentUser?.locality,
                onReservationTap: _navigateToReservation,
                isLoading: _isLoadingSearches,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Sección de búsqueda de clubes
            SliverToBoxAdapter(
              child: ClubSearchSection(
                searchResults: _searchResults,
                favoriteClubIds: _currentUser?.favoriteClubIds.toSet() ?? {},
                onSearch: _searchClubs,
                onClubTap: _navigateToClub,
                onFavoriteToggle: _toggleFavorite,
                searchQuery: _searchQuery,
                isSearching: _isSearching,
              ),
            ),

            // Espacio inferior
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
