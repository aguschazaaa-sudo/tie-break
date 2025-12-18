import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/models/club_model.dart';
import 'package:padel_punilla/presentation/screens/reservation/reservation_screen.dart';
import 'package:padel_punilla/presentation/widgets/court_list_widget.dart';

class ClubDetailsScreen extends StatelessWidget {
  const ClubDetailsScreen({required this.club, super.key});
  final ClubModel club;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(club.name)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (club.logoUrl != null)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(club.logoUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  club.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${club.address}, ${club.locality.displayName}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                if (club.description.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    club.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  'Canchas Disponibles',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          Expanded(
            child: CourtListWidget(
              clubId: club.id,
              canManage: false,
              onCourtTap: (court) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReservationScreen(court: court),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
