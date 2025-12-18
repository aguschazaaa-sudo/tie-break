import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/models/court_model.dart';

class TimelineCourtHeader extends StatelessWidget {
  final CourtModel court;
  final double width;

  const TimelineCourtHeader({
    super.key,
    required this.court,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            court.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          const SizedBox(height: 4),
          Text(
            court.surfaceType.displayName,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (court.isCovered)
                Icon(
                  Icons.roofing,
                  size: 16,
                  color: Theme.of(context).colorScheme.outline,
                ),
              if (court.isCovered) const SizedBox(width: 4),
              if (court.hasLighting)
                Icon(
                  Icons.lightbulb_outline,
                  size: 16,
                  color: Theme.of(context).colorScheme.outline,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
