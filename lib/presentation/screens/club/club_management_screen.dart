import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/repositories/auth_repository.dart';
import 'package:padel_punilla/domain/repositories/club_repository.dart';
import 'package:padel_punilla/domain/repositories/reservation_repository.dart';
import 'package:padel_punilla/presentation/providers/club_management_provider.dart';
import 'package:padel_punilla/presentation/screens/club/tabs/club_config_tab.dart';
import 'package:padel_punilla/presentation/screens/club/tabs/club_courts_tab.dart';
import 'package:padel_punilla/presentation/screens/club/tabs/club_team_tab.dart';
import 'package:padel_punilla/presentation/widgets/skeleton_loader.dart';
import 'package:provider/provider.dart';

class ClubManagementScreen extends StatelessWidget {
  const ClubManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (context) => ClubManagementProvider(
            authRepository: context.read<AuthRepository>(),
            clubRepository: context.read<ClubRepository>(),
            reservationRepository: context.read<ReservationRepository>(),
          ),
      child: const _ClubManagementScreenContent(),
    );
  }
}

class _ClubManagementScreenContent extends StatefulWidget {
  const _ClubManagementScreenContent();

  @override
  State<_ClubManagementScreenContent> createState() =>
      _ClubManagementScreenContentState();
}

class _ClubManagementScreenContentState
    extends State<_ClubManagementScreenContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClubManagementProvider>();

    if (provider.isLoading) {
      return _buildSkeletonLoading();
    }

    final club = provider.club;

    if (club == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Gestión de Club')),
        body: const Center(
          child: Text('No tienes permisos para gestionar ningún club.'),
        ),
      );
    }

    final primaryContainer = Theme.of(context).colorScheme.primaryContainer;
    final onPrimaryContainer = Theme.of(context).colorScheme.onPrimaryContainer;

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: primaryContainer,
              iconTheme: IconThemeData(color: onPrimaryContainer),
              expandedHeight: isMobile ? 100 : 160,
              pinned: true,
              centerTitle: true,
              title: Text(
                club.name,
                style: TextStyle(
                  color: onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 18 : 24,
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primaryContainer, primaryContainer],
                    ),
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: onPrimaryContainer,
                labelColor: onPrimaryContainer,
                unselectedLabelColor: onPrimaryContainer.withOpacity(0.7),
                tabs: const [
                  Tab(text: 'Configuración', icon: Icon(Icons.settings)),
                  Tab(text: 'Canchas', icon: Icon(Icons.sports_tennis)),
                  Tab(text: 'Equipo', icon: Icon(Icons.people_outline)),
                ],
              ),
            ),
          ];
        },
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 800;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    ClubConfigTab(isDesktop: isDesktop),
                    ClubCourtsTab(isDesktop: isDesktop),
                    ClubTeamTab(isDesktop: isDesktop),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSkeletonLoading() {
    return Scaffold(
      appBar: AppBar(title: const Text('Cargando Club...')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SkeletonLoader(
              height: 200,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: SkeletonLoader(height: 40)),
                SizedBox(width: 16),
                Expanded(child: SkeletonLoader(height: 40)),
                SizedBox(width: 16),
                Expanded(child: SkeletonLoader(height: 40)),
              ],
            ),
            SizedBox(height: 24),
            Expanded(child: SkeletonLoader(height: double.infinity)),
          ],
        ),
      ),
    );
  }
}
