import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/models/club_model.dart';
import 'package:padel_punilla/domain/repositories/club_repository.dart';
import 'package:padel_punilla/presentation/screens/club/club_details_screen.dart';
import 'package:provider/provider.dart';

class ClubListScreen extends StatelessWidget {
  const ClubListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clubes Disponibles')),
      body: FutureBuilder<List<ClubModel>>(
        future: context.read<ClubRepository>().getAllActiveClubs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final clubs = snapshot.data ?? [];

          if (clubs.isEmpty) {
            return const Center(child: Text('No hay clubes disponibles'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: clubs.length,
            itemBuilder: (context, index) {
              final club = clubs[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  leading:
                      club.logoUrl != null
                          ? CircleAvatar(
                            backgroundImage: NetworkImage(club.logoUrl!),
                          )
                          : const CircleAvatar(child: Icon(Icons.business)),
                  title: Text(club.name),
                  subtitle: Text(club.address),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClubDetailsScreen(club: club),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
