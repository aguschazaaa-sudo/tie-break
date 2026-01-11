import 'package:flutter/material.dart';

class TimelineTimeHeader extends StatelessWidget {
  const TimelineTimeHeader({
    required this.widthPerMinute,
    this.startHour = 8,
    this.endHour = 23,
    super.key,
  });

  final double widthPerMinute;
  final int startHour;
  final int endHour;

  @override
  Widget build(BuildContext context) {
    final totalWidth = widthPerMinute * 60 * (endHour - startHour + 1);

    return Container(
      height: 40,
      width: totalWidth,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: List.generate(endHour - startHour + 1, (index) {
          final hour = startHour + index;
          return SizedBox(
            width: widthPerMinute * 60,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${hour.toString().padLeft(2, '0')}:00',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
