@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:padel_punilla/config/theme/app_theme.dart';
import 'package:padel_punilla/presentation/widgets/leaderboard/leaderboard_empty_state.dart';

void main() {
  testGoldens('Leaderboard widgets golden test', (tester) async {
    final builder =
        GoldenBuilder.column()
          ..addScenario(
            'LeaderboardEmptyState light',
            Theme(
              data: AppTheme.lightTheme,
              child: const SizedBox(
                width: 350,
                height: 150,
                child: LeaderboardEmptyState(),
              ),
            ),
          )
          ..addScenario(
            'LeaderboardEmptyState dark',
            Theme(
              data: AppTheme.darkTheme,
              child: const SizedBox(
                width: 350,
                height: 150,
                child: LeaderboardEmptyState(),
              ),
            ),
          );

    await tester.pumpWidgetBuilder(
      builder.build(),
      surfaceSize: const Size(400, 500),
    );

    await screenMatchesGolden(
      tester,
      'leaderboard_widgets',
      customPump: (tester) async {
        await tester.pump(const Duration(milliseconds: 500));
      },
    );
  });
}
