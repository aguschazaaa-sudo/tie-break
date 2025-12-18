import 'package:flutter/material.dart';

class TimelineCurrentTimeIndicator extends StatelessWidget {
  final int startHour;
  final double widthPerMinute;
  final double height;

  const TimelineCurrentTimeIndicator({
    super.key,
    required this.startHour,
    required this.widthPerMinute,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // For debugging/demo, let's assume specific time if needed, but for now real time.
    // If now is before startHour or after endHour?
    // We can just calculate offset.

    final startOfDay = DateTime(now.year, now.month, now.day, startHour);
    final difference = now.difference(startOfDay);
    final offset = difference.inMinutes * widthPerMinute;

    if (offset < 0) return const SizedBox.shrink();

    return Positioned(
      left: offset,
      top: 40,
      bottom: 0,
      child: Container(
        width: 2,
        height: height,
        color: Theme.of(context).colorScheme.primary,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -4,
              left: -4,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
