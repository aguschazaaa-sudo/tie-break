import 'package:flutter/material.dart';

class TimelineBackgroundGrid extends StatelessWidget {
  final double widthPerMinute;
  final int startHour;
  final int endHour;
  final double height;

  const TimelineBackgroundGrid({
    super.key,
    required this.widthPerMinute,
    required this.startHour,
    required this.endHour,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(widthPerMinute * 60 * (endHour - startHour + 1), height),
      painter: _GridPainter(
        widthPerMinute: widthPerMinute,
        startHour: startHour,
        endHour: endHour,
        lineColor: Theme.of(
          context,
        ).colorScheme.outlineVariant.withValues(alpha: 0.3),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final double widthPerMinute;
  final int startHour;
  final int endHour;
  final Color lineColor;

  _GridPainter({
    required this.widthPerMinute,
    required this.startHour,
    required this.endHour,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = lineColor
          ..strokeWidth = 1;

    final hourWidth = widthPerMinute * 60;

    // Draw lines for each hour
    for (int i = 0; i <= endHour - startHour + 1; i++) {
      final x = i * hourWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.widthPerMinute != widthPerMinute ||
        oldDelegate.startHour != startHour ||
        oldDelegate.endHour != endHour ||
        oldDelegate.lineColor != lineColor;
  }
}
