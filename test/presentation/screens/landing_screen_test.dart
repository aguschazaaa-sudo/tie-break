import 'package:flutter/material.dart';

import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:padel_punilla/config/theme/app_theme.dart';
import 'package:padel_punilla/presentation/screens/landing_screen.dart';

void main() {
  testGoldens('LandingScreen golden test', (tester) async {
    final builder =
        DeviceBuilder()
          ..overrideDevicesForAllScenarios(
            devices: [Device.phone, Device.iphone11, Device.tabletLandscape],
          )
          ..addScenario(
            widget: Theme(
              data: AppTheme.lightTheme,
              child: LandingScreen(onToggleTheme: () {}),
            ),
            name: 'default',
          )
          ..addScenario(
            widget: Theme(
              data: AppTheme.darkTheme,
              child: LandingScreen(onToggleTheme: () {}),
            ),
            name: 'dark_mode',
          );

    await tester.pumpDeviceBuilder(builder);

    await screenMatchesGolden(
      tester,
      'landing_screen',
      customPump: (tester) async {
        await tester.pump(const Duration(milliseconds: 500));
      },
    );
  });
}
