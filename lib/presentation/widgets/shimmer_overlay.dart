import 'package:flutter/material.dart';

class ShimmerOverlay extends StatefulWidget {
  const ShimmerOverlay({required this.child, super.key, this.enabled = true});
  final Widget child;
  final bool enabled;

  @override
  State<ShimmerOverlay> createState() => _ShimmerOverlayState();
}

class _ShimmerOverlayState extends State<ShimmerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FractionallySizedBox(
                  widthFactor: 1.5, // Wider than container for smooth passage
                  alignment:
                      AlignmentGeometry.lerp(
                        Alignment.centerLeft,
                        Alignment.centerRight,
                        _controller.value,
                      )!,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0),
                          Colors.white.withValues(alpha: 0.2), // The shine
                          Colors.white.withValues(alpha: 0),
                        ],
                        stops: const [0.35, 0.5, 0.65],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        transform: const GradientRotation(0.5),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
