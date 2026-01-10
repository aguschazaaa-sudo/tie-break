import 'package:flutter/material.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:padel_punilla/config/theme/app_theme.dart';
import 'package:padel_punilla/presentation/widgets/skeleton_loader.dart';
import 'package:padel_punilla/presentation/widgets/shimmer_overlay.dart';
import 'package:padel_punilla/presentation/widgets/gradient_background.dart';

void main() {
  testGoldens('UI widgets golden test', (tester) async {
    final builder =
        GoldenBuilder.column()
          ..addScenario(
            'SkeletonLoader light',
            Theme(
              data: AppTheme.lightTheme,
              child: const SizedBox(
                width: 300,
                height: 100,
                child: SkeletonLoader(width: 280, height: 80),
              ),
            ),
          )
          ..addScenario(
            'SkeletonLoader dark',
            Theme(
              data: AppTheme.darkTheme,
              child: const SizedBox(
                width: 300,
                height: 100,
                child: SkeletonLoader(width: 280, height: 80),
              ),
            ),
          )
          ..addScenario(
            'ShimmerOverlay',
            Theme(
              data: AppTheme.lightTheme,
              child: SizedBox(
                width: 300,
                height: 100,
                child: ShimmerOverlay(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          )
          ..addScenario(
            'GradientBackground',
            Theme(
              data: AppTheme.lightTheme,
              child: const SizedBox(
                width: 300,
                height: 150,
                child: GradientBackground(
                  child: Center(child: Text('Gradient Background')),
                ),
              ),
            ),
          );

    await tester.pumpWidgetBuilder(
      builder.build(),
      surfaceSize: const Size(400, 800),
    );

    await screenMatchesGolden(
      tester,
      'ui_widgets',
      customPump: (tester) async {
        await tester.pump(const Duration(milliseconds: 500));
      },
    );
  });
}
