import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/enums/reservation_enums.dart';
import 'package:padel_punilla/domain/models/court_model.dart';
import 'package:padel_punilla/domain/models/reservation_model.dart';
import 'package:padel_punilla/domain/models/user_model.dart';
import 'package:padel_punilla/domain/repositories/auth_repository.dart';
import 'package:padel_punilla/domain/repositories/reservation_repository.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

/// Modal para crear una nueva reserva directamente desde el timeline
class ReservationModal extends StatefulWidget {
  const ReservationModal({
    required this.court,
    required this.slotTime,
    required this.selectedDate,
    required this.onReservationCreated,
    super.key,
  });

  final CourtModel court;
  final DateTime slotTime;
  final DateTime selectedDate;
  final VoidCallback onReservationCreated;

  @override
  State<ReservationModal> createState() => _ReservationModalState();

  /// Muestra el modal y retorna true si se creó la reserva
  static Future<bool> show(
    BuildContext context, {
    required CourtModel court,
    required DateTime slotTime,
    required DateTime selectedDate,
    required VoidCallback onReservationCreated,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => ReservationModal(
            court: court,
            slotTime: slotTime,
            selectedDate: selectedDate,
            onReservationCreated: onReservationCreated,
          ),
    );
    return result ?? false;
  }
}

class _ReservationModalState extends State<ReservationModal> {
  ReservationType _selectedType = ReservationType.normal;
  bool _isLoading = false;
  bool _isLoadingFollowing = true;
  bool _womenOnly = false;

  List<UserModel> _followingUsers = [];
  UserModel? _selectedPartner; // For 2vs2
  final Set<String> _selectedParticipantIds = {}; // For normal/falta1

  @override
  void initState() {
    super.initState();
    _loadFollowingUsers();
  }

  Future<void> _loadFollowingUsers() async {
    setState(() => _isLoadingFollowing = true);
    try {
      final authRepo = context.read<AuthRepository>();
      final currentUser = authRepo.currentUser;
      if (currentUser == null) return;

      final userData = await authRepo.getUserData(currentUser.uid);
      if (userData != null && userData.following.isNotEmpty) {
        final users = await authRepo.getUsersByIds(userData.following);
        setState(() => _followingUsers = users);
      }
    } catch (e) {
      debugPrint('Error loading following users: $e');
    } finally {
      setState(() => _isLoadingFollowing = false);
    }
  }

  String get _timeStr {
    final hour = widget.slotTime.hour.toString().padLeft(2, '0');
    final minute = widget.slotTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  List<ReservationType> get _availableTypes => [
    ReservationType.normal,
    ReservationType.match2vs2,
    ReservationType.falta1,
  ];

  bool get _canConfirm {
    // For 2vs2, partner is mandatory
    if (_selectedType == ReservationType.match2vs2) {
      return _selectedPartner != null;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Nueva Reserva',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),

            // Info rows
            _buildInfoRow(Icons.sports_tennis, 'Cancha', widget.court.name),
            const SizedBox(height: 10),
            _buildInfoRow(
              Icons.calendar_today,
              'Fecha',
              '${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year}',
            ),
            const SizedBox(height: 10),
            _buildInfoRow(Icons.access_time, 'Hora', _timeStr),
            const SizedBox(height: 10),
            _buildInfoRow(
              Icons.attach_money,
              'Precio',
              '\$${widget.court.reservationPrice.toStringAsFixed(0)}',
            ),
            const SizedBox(height: 20),

            // Type selection
            Text(
              'Tipo de Reserva',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _availableTypes.map((type) {
                    final isSelected = type == _selectedType;
                    return ChoiceChip(
                      label: Text(type.displayName),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedType = type;
                            _selectedPartner = null;
                            _selectedParticipantIds.clear();
                          });
                        }
                      },
                      selectedColor: colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        color:
                            isSelected
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurfaceVariant,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    );
                  }).toList(),
            ),

            // Women only option (for 2vs2 and falta1)
            if (_selectedType != ReservationType.normal) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Switch(
                    value: _womenOnly,
                    onChanged: (value) => setState(() => _womenOnly = value),
                    activeColor: Colors.pink,
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.female, color: Colors.pink.shade300, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    'Solo mujeres',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                ],
              ),
            ],

            // Partner selection for 2vs2 (mandatory)
            if (_selectedType == ReservationType.match2vs2) ...[
              const SizedBox(height: 20),
              _buildPartnerSelection(colorScheme),
            ],

            // Participant selection for normal and falta1 (optional)
            if (_selectedType == ReservationType.normal ||
                _selectedType == ReservationType.falta1) ...[
              const SizedBox(height: 20),
              _buildParticipantSelection(colorScheme),
            ],

            // Help text based on type
            _buildHelpText(colorScheme),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.onSurface,
                      side: BorderSide(color: colorScheme.outline),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed:
                        _isLoading || !_canConfirm ? null : _createReservation,
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      disabledBackgroundColor: colorScheme.primary.withValues(
                        alpha: 0.3,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child:
                        _isLoading
                            ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                            : const Text('Confirmar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerSelection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.people, size: 20, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Seleccionar Pareja *',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(obligatorio)',
              style: TextStyle(color: colorScheme.error, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoadingFollowing)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.primary,
              ),
            ),
          )
        else if (_followingUsers.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber,
                  color: colorScheme.onErrorContainer,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Seguí a otros jugadores para poder agregarlos como pareja',
                    style: TextStyle(
                      color: colorScheme.onErrorContainer,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            constraints: const BoxConstraints(maxHeight: 150),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _followingUsers.length,
              itemBuilder: (context, index) {
                final user = _followingUsers[index];
                final isSelected = _selectedPartner?.id == user.id;
                return ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: colorScheme.primaryContainer,
                    backgroundImage:
                        user.photoUrl != null
                            ? NetworkImage(user.photoUrl!)
                            : null,
                    child:
                        user.photoUrl == null
                            ? Text(
                              user.displayName.isNotEmpty
                                  ? user.displayName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: colorScheme.onPrimaryContainer,
                              ),
                            )
                            : null,
                  ),
                  title: Text(
                    user.displayName,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    '@${user.username}#${user.discriminator}',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  trailing:
                      isSelected
                          ? Icon(Icons.check_circle, color: colorScheme.primary)
                          : Icon(
                            Icons.circle_outlined,
                            color: colorScheme.outlineVariant,
                          ),
                  onTap: () => setState(() => _selectedPartner = user),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildParticipantSelection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.group_add, size: 20, color: colorScheme.secondary),
            const SizedBox(width: 8),
            Text(
              'Agregar Participantes',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(opcional)',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoadingFollowing)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (_followingUsers.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: colorScheme.onSurfaceVariant,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Seguí a otros jugadores para poder agregarlos a tu reserva',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            constraints: const BoxConstraints(maxHeight: 120),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _followingUsers.length,
              itemBuilder: (context, index) {
                final user = _followingUsers[index];
                final isSelected = _selectedParticipantIds.contains(user.id);
                return CheckboxListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedParticipantIds.add(user.id);
                      } else {
                        _selectedParticipantIds.remove(user.id);
                      }
                    });
                  },
                  secondary: CircleAvatar(
                    radius: 16,
                    backgroundColor: colorScheme.secondaryContainer,
                    backgroundImage:
                        user.photoUrl != null
                            ? NetworkImage(user.photoUrl!)
                            : null,
                    child:
                        user.photoUrl == null
                            ? Text(
                              user.displayName.isNotEmpty
                                  ? user.displayName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: colorScheme.onSecondaryContainer,
                              ),
                            )
                            : null,
                  ),
                  title: Text(
                    user.displayName,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    '@${user.username}',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildHelpText(ColorScheme colorScheme) {
    if (_selectedType == ReservationType.match2vs2) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.tertiaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: colorScheme.onTertiaryContainer,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Se buscará automáticamente una pareja rival',
                  style: TextStyle(
                    color: colorScheme.onTertiaryContainer,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_selectedType == ReservationType.falta1) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.person_search,
                color: colorScheme.onSecondaryContainer,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Se buscará un jugador para completar el partido',
                  style: TextStyle(
                    color: colorScheme.onSecondaryContainer,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Future<void> _createReservation() async {
    setState(() => _isLoading = true);

    try {
      final authRepo = context.read<AuthRepository>();
      final reservationRepo = context.read<ReservationRepository>();

      final currentUser = authRepo.currentUser;
      if (currentUser == null) {
        _showError('Debes iniciar sesión para reservar');
        return;
      }

      final reservationId = const Uuid().v4();
      final now = DateTime.now();

      // Build participant list
      final participantIds = <String>[];
      if (_selectedType == ReservationType.normal ||
          _selectedType == ReservationType.falta1) {
        participantIds.addAll(_selectedParticipantIds);
      }

      // Build team1 for 2vs2
      final team1Ids = <String>[];
      if (_selectedType == ReservationType.match2vs2) {
        team1Ids.add(currentUser.uid);
        if (_selectedPartner != null) {
          team1Ids.add(_selectedPartner!.id);
        }
      }

      final reservation = ReservationModel(
        id: reservationId,
        courtId: widget.court.id,
        clubId: widget.court.clubId,
        userId: currentUser.uid,
        participantIds: participantIds,
        reservedDate: widget.selectedDate,
        startTime: DateTime(
          widget.selectedDate.year,
          widget.selectedDate.month,
          widget.selectedDate.day,
          widget.slotTime.hour,
          widget.slotTime.minute,
        ),
        durationMinutes: widget.court.slotDurationMinutes,
        createdAt: now,
        price: widget.court.reservationPrice,
        type: _selectedType,
        womenOnly: _womenOnly,
        team1Ids: team1Ids,
      );

      await reservationRepo.createReservation(reservation);

      if (!mounted) return;

      Navigator.pop(context, true);
      widget.onReservationCreated();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reserva creada: ${_selectedType.displayName}'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      _showError('Error al crear reserva: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
    setState(() => _isLoading = false);
  }
}
