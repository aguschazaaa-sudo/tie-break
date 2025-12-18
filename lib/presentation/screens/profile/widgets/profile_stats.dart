import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/models/user_model.dart';

class ProfileStats extends StatelessWidget {
  const ProfileStats({
    required this.user,
    required this.onFollowersTap,
    required this.onFollowingTap,
    super.key,
  });
  final UserModel user;
  final VoidCallback onFollowersTap;
  final VoidCallback onFollowingTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatColumn(
          'Seguidores',
          user.followers.length.toString(),
          onTap: onFollowersTap,
        ),
        _buildStatColumn(
          'Seguidos',
          user.following.length.toString(),
          onTap: onFollowingTap,
        ),
      ],
    );
  }

  Widget _buildStatColumn(
    String label,
    String count, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Text(
              count,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
