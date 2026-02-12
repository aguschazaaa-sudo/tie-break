import 'package:flutter/material.dart';
import 'package:padel_punilla/presentation/widgets/skeleton_loader.dart';

class NotificationReservationCardSkeleton extends StatelessWidget {
  const NotificationReservationCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date and Time Row
          Row(
            children: [
              const SkeletonLoader(
                width: 16,
                height: 16,
                shape: BoxShape.circle,
              ),
              const SizedBox(width: 8),
              const SkeletonLoader(width: 80, height: 16),
              const SizedBox(width: 8),
              const SkeletonLoader(
                width: 16,
                height: 16,
                shape: BoxShape.circle,
              ),
              const SizedBox(width: 4),
              const SkeletonLoader(width: 100, height: 16),
            ],
          ),
          const SizedBox(height: 8),
          // Club Row
          Row(
            children: [
              const SkeletonLoader(
                width: 16,
                height: 16,
                shape: BoxShape.circle,
              ),
              const SizedBox(width: 8),
              const Expanded(child: SkeletonLoader(height: 16)),
            ],
          ),
          const SizedBox(height: 4),
          // Court Row (Indented)
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: const SkeletonLoader(width: 120, height: 12),
          ),
        ],
      ),
    );
  }
}
