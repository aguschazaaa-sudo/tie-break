import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/models/reservation_model.dart';
import 'package:padel_punilla/domain/repositories/auth_repository.dart';
import 'package:padel_punilla/domain/repositories/club_repository.dart';
import 'package:padel_punilla/domain/repositories/court_repository.dart';
import 'package:padel_punilla/domain/repositories/reservation_repository.dart';
import 'package:padel_punilla/presentation/screens/my_reservations/widgets/widgets.dart';
import 'package:padel_punilla/presentation/widgets/skeleton_loader.dart';
import 'package:provider/provider.dart';

/// Pantalla principal de "Mis Reservas".
///
/// Muestra todas las reservas del usuario actual ordenadas por fecha,
/// agrupadas en categorías temporales (Hoy, Mañana, Próximas, Pasadas).
/// Cada reserva muestra su estado con colores distintivos.
class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  /// Indica si estamos cargando datos
  bool _isLoading = true;

  /// Lista de reservas del usuario
  List<ReservationModel> _reservations = [];

  /// Mapa de clubId -> nombre del club
  final Map<String, String> _clubNames = {};

  /// Mapa de courtId -> nombre de la cancha
  final Map<String, String> _courtNames = {};

  /// Mensaje de error si ocurre algún problema
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  /// Carga las reservas del usuario actual
  Future<void> _loadReservations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authRepo = context.read<AuthRepository>();
      final reservationRepo = context.read<ReservationRepository>();
      final clubRepo = context.read<ClubRepository>();
      final courtRepo = context.read<CourtRepository>();

      final currentUser = authRepo.currentUser;
      if (currentUser == null) {
        throw Exception('No hay usuario logueado');
      }

      // Cargar reservas del usuario
      final reservations = await reservationRepo.getReservationsByUser(
        currentUser.uid,
      );

      // Recolectar IDs únicos de clubs y canchas
      final clubIds = <String>{};
      final courtIds = <String>{};
      for (final reservation in reservations) {
        clubIds.add(reservation.clubId);
        courtIds.add(reservation.courtId);
      }

      // Cargar nombres de clubs y canchas
      for (final clubId in clubIds) {
        final club = await clubRepo.getClub(clubId);
        if (club != null) {
          _clubNames[clubId] = club.name;
          // Cargar canchas de este club
          final courts = await courtRepo.getCourts(clubId);
          for (final court in courts) {
            if (courtIds.contains(court.id)) {
              _courtNames[court.id] = court.name;
            }
          }
        }
      }

      // Actualizar estado
      if (mounted) {
        setState(() {
          _reservations = reservations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // AppBar con estilo premium
      appBar: AppBar(
        title: const Text('Mis Reservas'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        actions: [
          // Botón de refrescar
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadReservations,
            tooltip: 'Actualizar',
          ),
        ],
      ),

      // Contenido
      body: _buildBody(),
    );
  }

  /// Construye el cuerpo de la pantalla según el estado
  Widget _buildBody() {
    // Estado de carga
    if (_isLoading) {
      return _buildLoadingState();
    }

    // Estado de error
    if (_errorMessage != null) {
      return _buildErrorState();
    }

    // Estado vacío
    if (_reservations.isEmpty) {
      return ReservationListEmpty(
        onActionPressed: () {
          // Volver atrás (a home) para buscar canchas
          Navigator.of(context).pop();
        },
      );
    }

    // Lista de reservas
    return ReservationListContent(
      reservations: _reservations,
      clubNames: _clubNames,
      courtNames: _courtNames,
      onReservationTap: _onReservationTap,
    );
  }

  /// Construye el estado de carga con skeleton
  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SkeletonLoader(
            height: 140,
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  /// Construye el estado de error
  Widget _buildErrorState() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 64, color: colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Error al cargar reservas',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: colorScheme.error),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Error desconocido',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colorScheme.outline),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _loadReservations,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  /// Callback al hacer tap en una reserva
  void _onReservationTap(ReservationModel reservation) {
    // Por ahora solo muestra un snackbar con info
    // En el futuro podría navegar a una pantalla de detalle
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Reserva: ${reservation.type.displayName} - ${reservation.status.displayName}',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
