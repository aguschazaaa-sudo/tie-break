import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/repositories/auth_repository.dart';
import 'package:padel_punilla/presentation/screens/club/club_list_screen.dart';
import 'package:padel_punilla/presentation/screens/club/create_club_screen.dart';
import 'package:padel_punilla/presentation/screens/my_reservations/my_reservations_screen.dart';
import 'package:padel_punilla/presentation/screens/profile/profile_screen.dart';
import 'package:padel_punilla/presentation/screens/season/leaderboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    final authRepository = AuthRepository();
    try {
      await authRepository.signOut();
      if (context.mounted) {
        // Volver a la pantalla inicial (LandingScreen)
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cerrar sesión: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthRepository().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Padel Punilla'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (user?.photoURL != null)
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(user!.photoURL!),
              )
            else
              const CircleAvatar(
                radius: 40,
                child: Icon(Icons.person, size: 40),
              ),
            const SizedBox(height: 16),
            Text(
              '¡Hola, ${user?.displayName ?? 'Jugador'}!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user?.email ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ClubListScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.search),
              label: const Text('Buscar Canchas'),
            ),
            const SizedBox(height: 16),
            // Botón para ver reservas del usuario
            FilledButton.tonal(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyReservationsScreen(),
                  ),
                );
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_month_rounded),
                  SizedBox(width: 8),
                  Text('Mis Reservas'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LeaderboardScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.leaderboard),
              label: const Text('Ranking de Temporada'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CreateClubScreen()),
          );
        },
        label: const Text('Crear Club'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
