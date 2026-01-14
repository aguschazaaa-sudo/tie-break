import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/models/club_model.dart';
import 'package:padel_punilla/domain/models/court_model.dart';
import 'package:padel_punilla/domain/models/reservation_model.dart';
import 'package:padel_punilla/domain/repositories/court_repository.dart';
import 'package:padel_punilla/domain/repositories/reservation_repository.dart';
import 'package:padel_punilla/presentation/screens/reservation/reservation_screen.dart';
import 'package:padel_punilla/presentation/widgets/timeline/court_timeline_row.dart';
import 'package:padel_punilla/presentation/widgets/timeline/timeline_config.dart';
import 'package:padel_punilla/presentation/widgets/timeline/timeline_court_header.dart';
import 'package:padel_punilla/presentation/widgets/timeline/timeline_current_time_indicator.dart';
import 'package:padel_punilla/presentation/widgets/timeline/timeline_time_header.dart';
import 'package:provider/provider.dart';

class ClubDetailsScreen extends StatefulWidget {
  const ClubDetailsScreen({required this.club, super.key});
  final ClubModel club;

  @override
  State<ClubDetailsScreen> createState() => _ClubDetailsScreenState();
}

class _ClubDetailsScreenState extends State<ClubDetailsScreen> {
  DateTime _selectedDate = DateTime.now();
  final double _widthPerMinute = 2;
  final int _startHour = 8;
  final int _endHour = 23;
  final double _rowHeight = 80;

  late Stream<List<CourtModel>> _courtsStream;
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  Map<String, List<ReservationModel>> _reservationsByCourtId = {};
  bool _isLoadingReservations = false;

  @override
  void initState() {
    super.initState();
    _courtsStream = context.read<CourtRepository>().getCourtsStream(
      widget.club.id,
    );
    _loadReservations();
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  Future<void> _loadReservations() async {
    setState(() => _isLoadingReservations = true);
    try {
      final reservationRepo = context.read<ReservationRepository>();
      final reservations = await reservationRepo.getReservationsByClubAndDate(
        widget.club.id,
        _selectedDate,
      );

      // Group by court
      final grouped = <String, List<ReservationModel>>{};
      for (final res in reservations) {
        grouped.putIfAbsent(res.courtId, () => []).add(res);
      }
      setState(() => _reservationsByCourtId = grouped);
    } catch (e) {
      debugPrint('Error loading reservations: $e');
    } finally {
      setState(() => _isLoadingReservations = false);
    }
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
    _loadReservations();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.club.name)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compact Club Info Header
          _buildClubHeader(context),

          // Date Selector
          _buildDateSelector(context, colorScheme),

          // Timeline
          Expanded(
            child: StreamBuilder<List<CourtModel>>(
              stream: _courtsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final courts = snapshot.data ?? [];
                if (courts.isEmpty) {
                  return const Center(
                    child: Text('No hay canchas registradas'),
                  );
                }

                return _buildTimeline(context, courts);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClubHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          if (widget.club.logoUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.club.logoUrl!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.sports_tennis),
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.club.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${widget.club.address}, ${widget.club.locality.displayName}',
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeDate(-1),
          ),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
                _loadReservations();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeDate(1),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, List<CourtModel> courts) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final headerWidth = isMobile ? 100.0 : 140.0;

    if (_isLoadingReservations) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scrollbar(
      controller: _verticalController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _verticalController,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Court Headers
            SizedBox(
              width: headerWidth,
              child: Column(
                children: [
                  const SizedBox(height: 40), // Space for time header
                  ...courts.map(
                    (court) => SizedBox(
                      height: _rowHeight,
                      child: GestureDetector(
                        onTap: () => _navigateToReservation(court),
                        child: TimelineCourtHeader(
                          court: court,
                          width: headerWidth,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Right Column: Timeline
            Expanded(
              child: Scrollbar(
                controller: _horizontalController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _horizontalController,
                  scrollDirection: Axis.horizontal,
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TimelineTimeHeader(
                            widthPerMinute: _widthPerMinute,
                            startHour: _startHour,
                            endHour: _endHour,
                          ),
                          ...courts.map((court) {
                            final reservations =
                                _reservationsByCourtId[court.id] ?? [];
                            return CourtTimelineRow(
                              reservations: reservations,
                              widthPerMinute: _widthPerMinute,
                              totalWidth:
                                  _widthPerMinute *
                                  60 *
                                  (_endHour - _startHour + 1),
                              startHour: _startHour,
                              endHour: _endHour,
                              height: _rowHeight,
                              slotDurationMinutes: court.slotDurationMinutes,
                              config: TimelineConfig.userView,
                              clubSchedules: widget.club.availableSchedules,
                              onReservationTap: (res) {
                                // If reservation is incomplete, show join option
                                if (!res.isComplete) {
                                  _showJoinDialog(res, court);
                                }
                              },
                              onAvailableSlotTap: (slotTime) {
                                _showReservationModal(court, slotTime);
                              },
                            );
                          }),
                        ],
                      ),
                      // Current time indicator
                      TimelineCurrentTimeIndicator(
                        startHour: _startHour,
                        widthPerMinute: _widthPerMinute,
                        height: double.infinity,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReservationModal(CourtModel court, DateTime slotTime) {
    final colorScheme = Theme.of(context).colorScheme;
    final hour = slotTime.hour.toString().padLeft(2, '0');
    final minute = slotTime.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$minute';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Text(
                  'Nueva Reserva',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  context,
                  Icons.sports_tennis,
                  'Cancha',
                  court.name,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  context,
                  Icons.calendar_today,
                  'Fecha',
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(context, Icons.access_time, 'Hora', timeStr),
                const SizedBox(height: 12),
                _buildInfoRow(
                  context,
                  Icons.attach_money,
                  'Precio',
                  '\$${court.reservationPrice.toStringAsFixed(0)}',
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.onSurface,
                          side: BorderSide(color: colorScheme.outline),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _navigateToReservation(court);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                        ),
                        child: const Text('Reservar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
        ),
        const SizedBox(width: 8),
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

  void _navigateToReservation(CourtModel court) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => ReservationScreen(court: court),
      ),
    );
  }

  void _showJoinDialog(ReservationModel reservation, CourtModel court) {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Unirse al Partido'),
            content: Text(
              'Hay un ${reservation.type.displayName} disponible en ${court.name}. ¿Deseas unirte?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToReservation(court);
                },
                child: const Text('Unirse'),
              ),
            ],
          ),
    );
  }
}
