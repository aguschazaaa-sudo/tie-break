import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/models/court_model.dart';
import 'package:padel_punilla/domain/repositories/court_repository.dart';
import 'package:padel_punilla/presentation/providers/club_management_provider.dart';
import 'package:padel_punilla/presentation/screens/court/court_form_screen.dart';
import 'package:padel_punilla/presentation/widgets/dialogs/block_court_dialog.dart';
import 'package:padel_punilla/presentation/widgets/dialogs/payment_dialog.dart';
import 'package:padel_punilla/presentation/widgets/timeline/court_timeline_row.dart';
import 'package:padel_punilla/presentation/widgets/timeline/reservation_action_sheet.dart';
import 'package:padel_punilla/presentation/widgets/timeline/timeline_config.dart';
import 'package:padel_punilla/presentation/widgets/timeline/timeline_court_header.dart';
import 'package:padel_punilla/presentation/widgets/timeline/timeline_current_time_indicator.dart';
import 'package:padel_punilla/presentation/widgets/timeline/timeline_time_header.dart';
import 'package:provider/provider.dart';

class ClubCourtsTab extends StatefulWidget {
  const ClubCourtsTab({required this.isDesktop, super.key});
  final bool isDesktop;

  @override
  State<ClubCourtsTab> createState() => _ClubCourtsTabState();
}

class _ClubCourtsTabState extends State<ClubCourtsTab> {
  final double _widthPerMinute = 2;
  final int _startHour = 8;
  final int _endHour = 23;
  final double _rowHeight = 80;

  late Stream<List<CourtModel>> _courtsStream;
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  bool _initialScrollDone = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ClubManagementProvider>();
    if (provider.club != null) {
      _courtsStream = context.read<CourtRepository>().getCourtsStream(
        provider.club!.id,
      );
    } else {
      _courtsStream = const Stream.empty();
    }
  }

  void _scrollToCurrentTime() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day, _startHour);

    if (now.isBefore(startOfDay)) return;

    final differenceInMinutes = now.difference(startOfDay).inMinutes;
    final offset = differenceInMinutes * _widthPerMinute;

    // Center the current time if possible (subtracting half viewport width)
    // We don't have viewport width easily here without LayoutBuilder or similar,
    // but typically we just want the time to be visible.
    // Let's just scroll to offset - 100 to show a bit of previous context.

    final targetOffset = (offset - 100).clamp(
      0.0,
      _widthPerMinute * 60 * (_endHour - _startHour + 1),
    );

    if (_horizontalController.hasClients) {
      _horizontalController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClubManagementProvider>();
    final club = provider.club;

    if (club == null) return const SizedBox.shrink();

    return Column(
      children: [
        _buildHeader(context, provider),
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
                return const Center(child: Text('No hay canchas registradas'));
              }

              if (!_initialScrollDone) {
                _initialScrollDone = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToCurrentTime();
                });
              }

              return _buildTimeline(context, courts, provider);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, ClubManagementProvider provider) {
    // Responsive layout for header
    if (!widget.isDesktop) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          children: [
            // Row 1: Date Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    provider.setSelectedDate(
                      provider.selectedDate.subtract(const Duration(days: 1)),
                    );
                  },
                ),
                Text(
                  '${provider.selectedDate.day}/${provider.selectedDate.month}/${provider.selectedDate.year}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    provider.setSelectedDate(
                      provider.selectedDate.add(const Duration(days: 1)),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Row 2: Legend (Scrollable if needed)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildLegend(context),
            ),
          ],
        ),
      );
    }

    // Desktop Layout
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              provider.setSelectedDate(
                provider.selectedDate.subtract(const Duration(days: 1)),
              );
            },
          ),
          Text(
            '${provider.selectedDate.day}/${provider.selectedDate.month}/${provider.selectedDate.year}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              provider.setSelectedDate(
                provider.selectedDate.add(const Duration(days: 1)),
              );
            },
          ),
          const Spacer(),
          _buildLegend(context),
          const SizedBox(width: 16),
          OutlinedButton.icon(
            onPressed: () => _showBlockDialog(context),
            icon: const Icon(Icons.block),
            label: const Text('Bloquear'),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: () {
              if (provider.club != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => CourtFormScreen(clubId: provider.club!.id),
                  ),
                );
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Nueva Cancha'),
          ),
        ],
      ),
    );
  }

  Future<void> _showBlockDialog(BuildContext context) async {
    final provider = context.read<ClubManagementProvider>();
    final clubId = provider.club?.id;
    if (clubId == null) return;

    // Obtener canchas para el diálogo
    final courtRepo = context.read<CourtRepository>();
    final courts = await courtRepo.getCourts(clubId);

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder:
          (context) => BlockCourtDialog(
            initialDate: provider.selectedDate,
            courts: courts,
            onBlock: (courtId, date, duration, type, description) {
              provider.blockCourt(
                courtId: courtId,
                date: date,
                durationMinutes: duration,
                type: type,
                description: description,
              );
            },
          ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      children: [
        _buildLegendItem(
          context,
          'Normal',
          Theme.of(context).colorScheme.primaryContainer,
        ),
        const SizedBox(width: 8),
        _buildLegendItem(
          context,
          '2 vs 2',
          Theme.of(context).colorScheme.tertiaryContainer,
        ),
        const SizedBox(width: 8),
        _buildLegendItem(
          context,
          'Falta 1',
          Theme.of(context).colorScheme.secondaryContainer,
        ),
        const SizedBox(width: 8),
        _buildLegendItem(
          context,
          'Pendiente',
          Colors.grey.withValues(alpha: 0.2),
          isBordered: true,
        ),
        const SizedBox(width: 8),
        // Indicador de solo mujeres
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.pink.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.female, size: 14, color: Colors.pink.shade400),
              const SizedBox(width: 4),
              Text(
                'Solo ♀',
                style: TextStyle(fontSize: 12, color: Colors.pink.shade700),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    Color color, {
    bool isBordered = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: isBordered ? Border.all(color: Colors.grey) : null,
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildTimeline(
    BuildContext context,
    List<CourtModel> courts,
    ClubManagementProvider provider,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final headerWidth = isMobile ? 100.0 : 140.0;

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
                      child: TimelineCourtHeader(
                        court: court,
                        width: headerWidth,
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
                      // Global background grid removed to support per-court slot duration
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TimelineTimeHeader(
                            widthPerMinute: _widthPerMinute,
                            startHour: _startHour,
                            endHour: _endHour,
                          ),
                          ...courts.map((court) {
                            final reservations = provider
                                .getReservationsForCourt(court.id);
                            return CourtTimelineRow(
                              reservations: reservations,
                              widthPerMinute: _widthPerMinute,
                              totalWidth:
                                  _widthPerMinute *
                                  60 *
                                  (_endHour - _startHour + 1),
                              startHour: _startHour,
                              height: _rowHeight,
                              slotDurationMinutes: court.slotDurationMinutes,
                              userNames: provider.userNames,
                              config: TimelineConfig.adminView,
                              onReservationTap: (res) {
                                // Abre el bottom sheet de acciones
                                ReservationActionSheet.show(
                                  context,
                                  reservation: res,
                                  userName: provider.userNames[res.userId],
                                  courtName: court.name,
                                  onApprove:
                                      () => provider.approveReservation(res.id),
                                  onReject:
                                      () => provider.rejectReservation(res.id),
                                  onCancel:
                                      () => provider.cancelReservation(res.id),
                                  onSetWinner:
                                      (team) =>
                                          provider.setMatchWinner(res.id, team),
                                  onManagePayment: () {
                                    showDialog(
                                      context: context,
                                      builder:
                                          (context) => PaymentDialog(
                                            reservation: res,
                                            onUpdate: (amount, status) {
                                              provider.updatePayment(
                                                res.id,
                                                paidAmount: amount,
                                                paymentStatus: status,
                                              );
                                            },
                                          ),
                                    );
                                  },
                                );
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
}
