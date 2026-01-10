import 'package:flutter/material.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:padel_punilla/config/theme/app_theme.dart';
import 'package:padel_punilla/presentation/screens/policies/terms_conditions_screen.dart';

void main() {
  testGoldens('TermsConditionsScreen golden test', (tester) async {
    final builder =
        DeviceBuilder()
          ..overrideDevicesForAllScenarios(
            devices: [Device.phone, Device.iphone11],
          )
          ..addScenario(
            widget: Theme(
              data: AppTheme.lightTheme,
              child: const TermsConditionsScreen(),
            ),
            name: 'light_mode',
          )
          ..addScenario(
            widget: Theme(
              data: AppTheme.darkTheme,
              child: const TermsConditionsScreen(),
            ),
            name: 'dark_mode',
          );

    await tester.pumpDeviceBuilder(builder);

    await screenMatchesGolden(
      tester,
      'terms_conditions_screen',
      customPump: (tester) async {
        await tester.pump(const Duration(milliseconds: 500));
      },
    );
  });
}
