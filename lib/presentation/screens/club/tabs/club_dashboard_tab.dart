import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:padel_punilla/presentation/providers/club_management_provider.dart';
import 'package:provider/provider.dart';

class ClubDashboardTab extends StatefulWidget {
  const ClubDashboardTab({required this.isDesktop, super.key});
  final bool isDesktop;

  @override
  State<ClubDashboardTab> createState() => _ClubDashboardTabState();
}

class _ClubDashboardTabState extends State<ClubDashboardTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClubManagementProvider>().loadDailyStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClubManagementProvider>();
    final stats = provider.dashboardStats;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen del Día',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('EEEE d, MMMM yyyy', 'es').format(DateTime.now()),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Grid of Cards
            GridView.count(
              crossAxisCount: widget.isDesktop ? 4 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStatCard(
                  context,
                  title: 'Reservas',
                  value: stats.totalReservations.toString(),
                  icon: Icons.calendar_today,
                  color: Colors.blue,
                ),
                _buildStatCard(
                  context,
                  title: 'Ingresos Est.',
                  value: NumberFormat.currency(
                    symbol: r'$',
                    decimalDigits: 0,
                  ).format(stats.totalRevenue),
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
                _buildStatCard(
                  context,
                  title: 'Canchas Activas',
                  value: stats.activeCourts.toString(),
                  icon: Icons.sports_tennis,
                  color: Colors.orange,
                ),
                _buildStatCard(
                  context,
                  title: 'Pendientes',
                  value: stats.pendingReservations.toString(),
                  icon: Icons.pending_actions,
                  color: Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
