import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/enums/reservation_enums.dart';
import 'package:padel_punilla/domain/models/reservation_model.dart';
import 'package:padel_punilla/domain/models/user_model.dart';
import 'package:padel_punilla/domain/repositories/auth_repository.dart';
import 'package:padel_punilla/domain/repositories/reservation_repository.dart';
import 'package:padel_punilla/domain/services/join_match_service.dart';
import 'package:padel_punilla/presentation/widgets/join_match/partner_selector.dart';
import 'package:provider/provider.dart';

/// Bottom sheet para unirse a un partido incompleto (2vs2 o Falta1).
///
/// Muestra:
/// - Información del partido
/// - Selector de compañero (solo para 2vs2)
/// - Botón para unirse
class JoinMatchSheet extends StatefulWidget {
  const JoinMatchSheet({
    required this.reservation,
    required this.onJoined,
    super.key,
    this.courtName,
  });

  /// La reserva a la que se quiere unir
  final ReservationModel reservation;

  /// Nombre de la cancha (opcional, para mostrar en UI)
  final String? courtName;

  /// Callback cuando el usuario se une exitosamente
  final VoidCallback onJoined;

  /// Muestra el bottom sheet. Método estático de conveniencia.
  static Future<void> show(
    BuildContext context, {
    required ReservationModel reservation,
    required VoidCallback onJoined,
    String? courtName,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => JoinMatchSheet(
            reservation: reservation,
            courtName: courtName,
            onJoined: onJoined,
          ),
    );
  }

  @override
  State<JoinMatchSheet> createState() => _JoinMatchSheetState();
}

class _JoinMatchSheetState extends State<JoinMatchSheet> {
  final _joinService = JoinMatchService();

  // Estado del widget
  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _selectedPartner;
  UserModel? _currentUser;

  // Para validación de solapamiento
  List<ReservationModel> _userReservations = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Carga datos del usuario actual y sus reservas
  Future<void> _loadUserData() async {
    final authRepo = context.read<AuthRepository>();
    final firebaseUser = authRepo.currentUser;
    if (firebaseUser == null) return;

    try {
      // Obtener modelo de usuario completo
      final userData = await authRepo.getUserData(firebaseUser.uid);
      if (userData != null && mounted) {
        setState(() => _currentUser = userData);
      }

      // Cargar reservas para validar solapamiento
      final reservationRepo = context.read<ReservationRepository>();
      final reservations = await reservationRepo.getReservationsByUser(
        firebaseUser.uid,
      );
      if (mounted) {
        setState(() => _userReservations = reservations);
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final is2vs2 = widget.reservation.type == ReservationType.match2vs2;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.outline.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Título
            Text(
              'Unirse al Partido',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 16),

            // Info del partido
            _buildMatchInfo(colorScheme, textTheme),

            const SizedBox(height: 16),

            // Selector de compañero (solo para 2vs2)
            if (is2vs2) ...[
              Text(
                'Selecciona tu compañero',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              PartnerSelector(
                excludeUserIds: [
                  ...widget.reservation.team1Ids,
                  ...widget.reservation.team2Ids,
                ],
                womenOnly: widget.reservation.womenOnly,
                onPartnerSelected: (partner) {
                  setState(() {
                    _selectedPartner = partner;
                    _errorMessage = null;
                  });
                },
              ),
              const SizedBox(height: 16),
            ],

            // Mensaje de error
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: colorScheme.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),

            // Botón de unirse
            FilledButton.icon(
              onPressed: _isLoading ? null : _handleJoin,
              icon:
                  _isLoading
                      ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                      : const Icon(Icons.group_add),
              label: Text(_isLoading ? 'Uniéndose...' : 'Unirse al Partido'),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Construye la información del partido
  Widget _buildMatchInfo(ColorScheme colorScheme, TextTheme textTheme) {
    final reservation = widget.reservation;
    final timeString =
        '${reservation.startTime.hour.toString().padLeft(2, '0')}:'
        '${reservation.startTime.minute.toString().padLeft(2, '0')}';
    final endTime = reservation.endTime;
    final endTimeString =
        '${endTime.hour.toString().padLeft(2, '0')}:'
        '${endTime.minute.toString().padLeft(2, '0')}';

    // Color según tipo de reserva
    final typeColor =
        reservation.type == ReservationType.match2vs2
            ? colorScheme.tertiaryContainer
            : colorScheme.secondaryContainer;
    final onTypeColor =
        reservation.type == ReservationType.match2vs2
            ? colorScheme.onTertiaryContainer
            : colorScheme.onSecondaryContainer;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: typeColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tipo de reserva badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: typeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  reservation.type.displayName,
                  style: TextStyle(
                    color: onTypeColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              if (reservation.womenOnly) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.female,
                        size: 14,
                        color: colorScheme.onTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Solo Mujeres',
                        style: TextStyle(
                          color: colorScheme.onTertiary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),

          // Hora
          Row(
            children: [
              Icon(Icons.access_time, size: 18, color: colorScheme.onSurface),
              const SizedBox(width: 8),
              Text(
                '$timeString - $endTimeString',
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),

          // Cancha (si está disponible)
          if (widget.courtName != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.sports_tennis,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.courtName!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],

          // Jugadores actuales
          const SizedBox(height: 12),
          Text(
            'Jugadores: ${reservation.team1Ids.length + reservation.team2Ids.length}/4',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Maneja el proceso de unirse al partido
  Future<void> _handleJoin() async {
    if (_currentUser == null) {
      setState(() => _errorMessage = 'Debes iniciar sesión para unirte');
      return;
    }

    final is2vs2 = widget.reservation.type == ReservationType.match2vs2;

    // Validar con el servicio
    final validationError = _joinService.validateJoin(
      reservation: widget.reservation,
      currentUser: _currentUser!,
      partnerId: _selectedPartner?.id,
      userReservations: _userReservations,
    );

    if (validationError != null) {
      setState(() => _errorMessage = validationError);
      return;
    }

    // Validar que se haya seleccionado partner para 2vs2
    if (is2vs2 && _selectedPartner == null) {
      setState(() => _errorMessage = 'Debes seleccionar un compañero');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final reservationRepo = context.read<ReservationRepository>();
      await reservationRepo.joinMatch(
        reservationId: widget.reservation.id,
        userId: _currentUser!.id,
        partnerId: _selectedPartner?.id,
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onJoined();

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('¡Te has unido al partido exitosamente!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al unirse: $e';
      });
    }
  }
}
