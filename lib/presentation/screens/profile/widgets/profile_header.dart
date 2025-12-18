import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/models/user_model.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({required this.user, super.key});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage:
              user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
          child:
              user.photoUrl == null
                  ? Text(
                    user.displayName.isNotEmpty
                        ? user.displayName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(fontSize: 40),
                  )
                  : null,
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            Text(
              '@${user.username}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.cyan[300]
                        : Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '#${user.discriminator}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
            ),
          ],
        ),
      ],
    );
  }
}
