import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/enums/player_gender.dart';
import 'package:padel_punilla/domain/enums/reservation_enums.dart';
import 'package:padel_punilla/domain/models/club_model.dart';
import 'package:padel_punilla/domain/models/court_model.dart';
import 'package:padel_punilla/domain/models/reservation_model.dart';
import 'package:padel_punilla/domain/models/user_model.dart';
import 'package:padel_punilla/domain/repositories/auth_repository.dart';
import 'package:padel_punilla/domain/repositories/club_repository.dart';
import 'package:padel_punilla/domain/repositories/reservation_repository.dart';
import 'package:padel_punilla/domain/services/reservation_service.dart';
import 'package:padel_punilla/presentation/widgets/primary_button.dart';
import 'package:padel_punilla/presentation/widgets/skeleton_loader.dart';
import 'package:padel_punilla/presentation/widgets/user_selection_dialog.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({required this.court, super.key});
  final CourtModel court;

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime? _selectedTime;
  ReservationType _selectedType = ReservationType.normal;
  UserModel? _partner;
  bool _isLoading = false;

  /// Si es true, la reserva es solo para mujeres (disponible solo para usuarios femeninos)
  bool _womenOnly = false;

  /// Datos del usuario actual (para verificar género)
  UserModel? _currentUserModel;

  late Future<Map<String, dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _fetchData();
  }

  Future<Map<String, dynamic>> _fetchData() async {
    final clubRepo = context.read<ClubRepository>();
    final reservationRepo = context.read<ReservationRepository>();
    final authRepo = context.read<AuthRepository>();

    final club = await clubRepo.getClub(widget.court.clubId);
    final reservations = await reservationRepo.getReservationsByCourtAndDate(
      widget.court.id,
      _selectedDate,
    );

    // Cargar datos del usuario actual para verificar género
    final currentUser = authRepo.currentUser;
    if (currentUser != null && _currentUserModel == null) {
      _currentUserModel = await authRepo.getUserData(currentUser.uid);
    }

    return {'club': club, 'reservations': reservations};
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTime = null; // Reset time when date changes
        _selectedType = ReservationType.normal;
        _partner = null;
        _womenOnly = false; // Reset womenOnly al cambiar fecha
        _dataFuture = _fetchData(); // Refresh data for new date
      });
    }
  }

  Future<void> _createReservation() async {
    if (_selectedTime == null) return;
    if (_selectedType == ReservationType.match2vs2 && _partner == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar una pareja para 2 vs 2'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authRepo = context.read<AuthRepository>();
      final reservationService = context.read<ReservationService>();
      final currentUser = authRepo.currentUser;

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes iniciar sesión para reservar')),
        );
        return;
      }

      final reservation = ReservationModel(
        id: const Uuid().v4(),
        courtId: widget.court.id,
        clubId: widget.court.clubId,
        userId: currentUser.uid,
        reservedDate: _selectedDate,
        startTime: _selectedTime!,
        durationMinutes: widget.court.slotDurationMinutes,
        createdAt: DateTime.now(),
        price: widget.court.reservationPrice,
        type: _selectedType,
        team1Ids:
            _selectedType == ReservationType.match2vs2
                ? [currentUser.uid, _partner!.id]
                : [],
        team2Ids: [],
        womenOnly: _womenOnly,
      );

      await reservationService.createReservation(reservation);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reserva creada con éxito!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _overwriteReservation(
    ReservationModel existingReservation,
    User currentUser,
  ) async {
    setState(() => _isLoading = true);
    try {
      final reservationRepo = context.read<ReservationRepository>();

      // Transform existing Pre-Reservation into Normal Reservation
      // We reuse the ID to maintain the slot, avoiding delete/create race conditions.
      final updatedReservation = existingReservation.copyWith(
        userId: currentUser.uid,
        type: ReservationType.normal,
        status:
            ReservationStatus.pending, // Or approved/confirmed based on logic
        team1Ids: [], // Clear teams
        team2Ids: [],
        participantIds: [],
        price: widget.court.reservationPrice,
      );

      await reservationRepo.updateReservation(updatedReservation);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reserva normal creada con éxito!')),
        );
        // Refresh grid to show new status
        await _fetchData().then((data) {
          if (mounted) {
            // Force UI rebuild if needed, though FutureBuilder should handle it if we trigger it
            // Actually, _dataFuture is a future, we need to reset it to trigger builder
            setState(() {
              _dataFuture = Future.value(data);
            });
          }
        });
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectPartner() async {
    // Si es solo mujeres, filtrar por género femenino
    final genderFilter = _womenOnly ? PlayerGender.female : null;

    final user = await showDialog<UserModel>(
      context: context,
      builder: (context) => UserSelectionDialog(genderFilter: genderFilter),
    );
    if (user != null) {
      setState(() => _partner = user);
    }
  }

  Future<void> _handleSlotTap(
    ReservationModel? existingReservation,
    DateTime slotTime,
  ) async {
    // 1. If no reservation, just select logic
    if (existingReservation == null) {
      setState(() {
        _selectedTime = slotTime;
        _selectedType = ReservationType.normal;
        _partner = null;
      });
      return;
    }

    // 2. If existing reservation is INCOMPLETE (Pre-Reservation), show options
    if (!existingReservation.isComplete) {
      // Set time so logic works
      setState(() {
        _selectedTime = slotTime;
      });

      await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Horario con Pre-Reserva'),
              content: Text(
                'Hay una búsqueda de ${existingReservation.type.displayName} activa. \n\n¿Qué deseas hacer?',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _joinReservation(existingReservation);
                  },
                  child: const Text('Unirse al Partido'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    // Confirm Overwrite
                    final confirm =
                        await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Confirmar Reserva'),
                                content: const Text(
                                  'Reservar este horario cancelará la búsqueda de partido existente y creará una Reserva Normal para ti. ¿Estás seguro?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    child: const Text(
                                      'Confirmar Reserva Normal',
                                    ),
                                  ),
                                ],
                              ),
                        ) ??
                        false;

                    if (confirm) {
                      final authRepo = context.read<AuthRepository>();
                      final user = authRepo.currentUser;
                      if (user != null) {
                        _overwriteReservation(existingReservation, user);
                      }
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: const Text('Reservar Cancha (Prioridad)'),
                ),
              ],
            ),
      );
    }
  }

  Future<void> _joinReservation(ReservationModel reservation) async {
    final authRepo = context.read<AuthRepository>();
    final currentUser = authRepo.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para unirte')),
      );
      return;
    }

    if (reservation.userId == currentUser.uid ||
        reservation.team1Ids.contains(currentUser.uid)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ya eres parte de esta reserva')),
      );
      return;
    }

    // Validar género para reservas solo mujeres
    if (reservation.womenOnly) {
      // Necesitamos verificar el género del usuario actual
      if (_currentUserModel?.gender != PlayerGender.female) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Esta reserva es exclusiva para mujeres'),
          ),
        );
        return;
      }
    }

    var confirm = false;
    UserModel? partner;

    if (reservation.type == ReservationType.falta1) {
      confirm =
          await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Unirse a partido'),
                  content: const Text('¿Deseas cubrir la vacante (Falta 1)?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Unirse'),
                    ),
                  ],
                ),
          ) ??
          false;
    } else if (reservation.type == ReservationType.match2vs2) {
      // First confirm intention
      final wantToJoin =
          await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Desafiar Equipo'),
                  content: const Text(
                    '¿Deseas jugar contra este equipo? Necesitarás seleccionar tu pareja.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Continuar'),
                    ),
                  ],
                ),
          ) ??
          false;

      if (!wantToJoin) return;

      // Select partner - con filtro de género si es solo mujeres
      if (mounted) {
        final genderFilter = reservation.womenOnly ? PlayerGender.female : null;
        partner = await showDialog<UserModel>(
          context: context,
          builder: (context) => UserSelectionDialog(genderFilter: genderFilter),
        );
        if (partner == null) return; // Cancelled selection
        confirm = true;
      }
    }

    if (!confirm) return;

    setState(() => _isLoading = true);

    try {
      final reservationService = context.read<ReservationRepository>();

      var updatedReservation = reservation;

      if (reservation.type == ReservationType.falta1) {
        updatedReservation = reservation.copyWith(
          status: ReservationStatus.approved,
          participantIds: [...reservation.participantIds, currentUser.uid],
          isOpenMatch: false, // Cerrar búsqueda al unirse
        );
      } else if (reservation.type == ReservationType.match2vs2 &&
          partner != null) {
        updatedReservation = reservation.copyWith(
          status: ReservationStatus.approved,
          team2Ids: [currentUser.uid, partner.id],
        );
      }

      await reservationService.updateReservation(updatedReservation);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Te has unido al partido!')),
        );
        _dataFuture = _fetchData(); // Refresh grid
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reservar ${widget.court.name}')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Selection
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      'Fecha: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _selectDate(context),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Horarios Disponibles',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildLegendItem(
                      context,
                      'Disponible',
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    _buildLegendItem(
                      context,
                      'Seleccionado',
                      Theme.of(context).colorScheme.primary,
                    ),
                    _buildLegendItem(
                      context,
                      'Reservado',
                      Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    ),
                    _buildLegendItem(
                      context,
                      '2 vs 2',
                      Theme.of(context).colorScheme.tertiary,
                    ),
                    _buildLegendItem(
                      context,
                      'Falta 1',
                      Theme.of(context).colorScheme.secondary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Time Slots Grid
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount =
                          constraints.maxWidth < 600
                              ? 3
                              : (constraints.maxWidth / 150).floor();

                      return FutureBuilder<Map<String, dynamic>>(
                        future: _dataFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    childAspectRatio: 2.2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                              itemCount: 12,
                              itemBuilder:
                                  (context, index) => SkeletonLoader(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }

                          final club = snapshot.data!['club'] as ClubModel?;
                          final reservations =
                              snapshot.data!['reservations']
                                  as List<ReservationModel>;
                          final schedules = club?.availableSchedules ?? [];

                          if (schedules.isEmpty) {
                            return const Center(
                              child: Text(
                                'No hay horarios configurados para este club',
                              ),
                            );
                          }

                          return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  childAspectRatio: 2.2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                            itemCount: schedules.length,
                            itemBuilder: (context, index) {
                              final timeString = schedules[index];
                              final parts = timeString.split(':');
                              final hour = int.parse(parts[0]);
                              final minute = int.parse(parts[1]);

                              final slotTime = DateTime(
                                _selectedDate.year,
                                _selectedDate.month,
                                _selectedDate.day,
                                hour,
                                minute,
                              );

                              // Check availability
                              ReservationModel? existingReservation;
                              for (final res in reservations) {
                                if (res.status == ReservationStatus.cancelled) {
                                  continue;
                                }

                                final resEnd = res.startTime.add(
                                  Duration(minutes: res.durationMinutes),
                                );
                                final slotEnd = slotTime.add(
                                  Duration(
                                    minutes: widget.court.slotDurationMinutes,
                                  ),
                                );

                                if (slotTime.isBefore(resEnd) &&
                                    slotEnd.isAfter(res.startTime)) {
                                  existingReservation = res;
                                  break;
                                }
                              }

                              final isSelected = _selectedTime == slotTime;
                              final colorScheme = Theme.of(context).colorScheme;

                              Color slotColor;
                              Color textColor;
                              VoidCallback? onTap;
                              Widget? badge;

                              if (existingReservation != null) {
                                if (existingReservation.isComplete) {
                                  // Fully booked (or Normal Pending)
                                  slotColor = colorScheme
                                      .surfaceContainerHighest
                                      .withOpacity(0.3);
                                  textColor = colorScheme.onSurface.withOpacity(
                                    0.3,
                                  );
                                  onTap = null;
                                } else {
                                  // Incomplete (Pre-Reservation 2vs2 or Falta1)
                                  // Show as available but with data
                                  slotColor =
                                      colorScheme.surfaceContainerHighest;
                                  textColor = colorScheme.onSurface;

                                  // Determine badge color/text
                                  final is2vs2 =
                                      existingReservation.type ==
                                      ReservationType.match2vs2;
                                  final badgeColor =
                                      is2vs2
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.tertiary
                                          : Theme.of(
                                            context,
                                          ).colorScheme.secondary;
                                  final badgeTextColor =
                                      is2vs2
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.onTertiary
                                          : Theme.of(
                                            context,
                                          ).colorScheme.onSecondary;
                                  final badgeLabel = is2vs2 ? '2vs2' : 'F1';

                                  badge = Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: badgeColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        badgeLabel,
                                        style: TextStyle(
                                          color: badgeTextColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );

                                  onTap =
                                      () => _handleSlotTap(
                                        existingReservation,
                                        slotTime,
                                      );
                                }
                              } else if (isSelected) {
                                slotColor = colorScheme.primary;
                                textColor = colorScheme.onPrimary;
                                onTap = () => _handleSlotTap(null, slotTime);
                              } else {
                                slotColor = colorScheme.surfaceContainerHighest;
                                textColor = colorScheme.onSurface;
                                onTap = () => _handleSlotTap(null, slotTime);
                              }

                              return InkWell(
                                onTap: onTap,
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: slotColor,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color:
                                              isSelected
                                                  ? colorScheme.primary
                                                  : Colors.transparent,
                                          width: 2,
                                        ),
                                        boxShadow:
                                            isSelected
                                                ? [
                                                  BoxShadow(
                                                    color: colorScheme.primary
                                                        .withOpacity(0.4),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ]
                                                : [],
                                      ),
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            timeString,
                                            style: TextStyle(
                                              color: textColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          if (existingReservation != null &&
                                              existingReservation.isComplete)
                                            Text(
                                              'Reservado',
                                              style: TextStyle(
                                                color: textColor,
                                                fontSize: 10,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    if (badge != null) badge,
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Price and Action
                if (_selectedTime != null) ...[
                  const SizedBox(height: 24),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Tipo de Reserva',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          SegmentedButton<ReservationType>(
                            segments: const [
                              ButtonSegment(
                                value: ReservationType.normal,
                                label: Text('Normal'),
                              ),
                              ButtonSegment(
                                value: ReservationType.match2vs2,
                                label: Text('2 vs 2'),
                              ),
                              ButtonSegment(
                                value: ReservationType.falta1,
                                label: Text('Falta 1'),
                              ),
                            ],
                            selected: {_selectedType},
                            onSelectionChanged: (
                              Set<ReservationType> newSelection,
                            ) {
                              setState(() {
                                _selectedType = newSelection.first;
                                // Reset womenOnly y partner al cambiar tipo
                                if (_selectedType == ReservationType.normal) {
                                  _womenOnly = false;
                                }
                                _partner = null;
                              });
                            },
                          ),
                          // Switch "Solo Mujeres" - solo visible para usuarias femeninas
                          // y cuando el tipo es 2vs2 o falta1
                          if (_currentUserModel?.gender ==
                                  PlayerGender.female &&
                              (_selectedType == ReservationType.match2vs2 ||
                                  _selectedType == ReservationType.falta1)) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.female,
                                  color: Theme.of(context).colorScheme.tertiary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Solo Mujeres',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const Spacer(),
                                Switch(
                                  value: _womenOnly,
                                  onChanged: (value) {
                                    setState(() {
                                      _womenOnly = value;
                                      // Si activa womenOnly, resetear pareja para re-validar
                                      if (value) _partner = null;
                                    });
                                  },
                                  activeColor:
                                      Theme.of(context).colorScheme.tertiary,
                                ),
                              ],
                            ),
                          ],
                          if (_selectedType == ReservationType.match2vs2) ...[
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: _selectPartner,
                              icon: const Icon(Icons.person_add),
                              label: Text(
                                _partner == null
                                    ? 'Seleccionar Pareja'
                                    : 'Pareja: ${_partner!.displayName}',
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          PrimaryButton(
                            text: 'CONFIRMAR RESERVA',
                            onPressed: _createReservation,
                            isLoading: _isLoading,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
