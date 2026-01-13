import 'dart:ui';

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
import 'package:padel_punilla/presentation/widgets/ambient_glow.dart';
import 'package:padel_punilla/presentation/widgets/gradient_logo.dart';
import 'package:provider/provider.dart';

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
    final authRepo = context.read<AuthRepository>();
    final user = authRepo.currentUser;
    if (user == null) return;

    try {
      final userData = await authRepo.getUserData(user.uid);
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
      final clubs = await context.read<ClubRepository>().getClubsByIds(
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
    debugPrint('[HomeScreen] userLocality: $userLocality');
    if (userLocality == null) {
      debugPrint('[HomeScreen] userLocality is null, skipping search');
      setState(() => _isLoadingSearches = false);
      return;
    }

    setState(() => _isLoadingSearches = true);

    try {
      final clubRepo = context.read<ClubRepository>();
      final reservationRepo = context.read<ReservationRepository>();

      // Obtener clubes de la localidad del usuario
      final localClubs = await clubRepo.getClubsByLocality(userLocality);
      debugPrint('[HomeScreen] localClubs found: ${localClubs.length}');

      // Obtener clubes de localidades cercanas
      final nearbyLocalities = userLocality.nearbyLocalities;
      debugPrint('[HomeScreen] nearbyLocalities: $nearbyLocalities');
      final nearbyClubsFutures = nearbyLocalities.map(
        clubRepo.getClubsByLocality,
      );
      final nearbyClubsLists = await Future.wait(nearbyClubsFutures);
      final nearbyClubs = nearbyClubsLists.expand((list) => list).toList();
      debugPrint('[HomeScreen] nearbyClubs found: ${nearbyClubs.length}');

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
      debugPrint(
        '[HomeScreen] searching reservations for ${allClubIds.length} clubs',
      );
      final allReservations = await reservationRepo.getActiveSearchReservations(
        allClubIds,
      );
      debugPrint('[HomeScreen] reservations found: ${allReservations.length}');

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
      debugPrint('[HomeScreen] Error loading active searches: $e');
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
      final results = await context.read<ClubRepository>().searchClubsByName(
        query,
      );
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
      final authRepo = context.read<AuthRepository>();
      if (isFavorite) {
        await authRepo.removeFavoriteClub(user.id, clubId);
        // Actualizar estado local
        setState(() {
          _currentUser = user.copyWith(
            favoriteClubIds:
                user.favoriteClubIds.where((id) => id != clubId).toList(),
          );
          _favoriteClubs.removeWhere((club) => club.id == clubId);
        });
      } else {
        await authRepo.addFavoriteClub(user.id, clubId);
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
          club = await context.read<ClubRepository>().getClub(clubId);
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
      await context.read<AuthRepository>().signOut();
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
    final user = context.read<AuthRepository>().currentUser;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
            ),
          ),
        ),
        title: Row(
          children: [
            // Logo con gradiente
            const GradientLogo.medium(),
            const SizedBox(width: 10),
            Text(
              'Padel Punilla',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
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
      body: Stack(
        children: [
          // Ambient Background Glows
          // 1. Primary Glow (Top Right)
          Positioned(
            top: -100,
            right: -100,
            child: AmbientGlow(
              color: colorScheme.primary,
              size: 400,
              opacity: 0.35,
            ),
          ),
          // 2. Secondary Glow (Bottom Left)
          Positioned(
            bottom: -50,
            left: -100,
            child: AmbientGlow(
              color: colorScheme.secondary,
              size: 350,
              opacity: 0.3,
            ),
          ),

          // Main Content
          RefreshIndicator(
            onRefresh: _refreshData,
            edgeOffset:
                100, // Ajuste para que el refresh no quede tapado por AppBar
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1024),
                child: CustomScrollView(
                  slivers: [
                    // Espacio para AppBar transparente
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),

                    // Saludo al usuario
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
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
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
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
                        favoriteClubIds:
                            _currentUser?.favoriteClubIds.toSet() ?? {},
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
            ),
          ),
        ],
      ),
    );
  }
}
