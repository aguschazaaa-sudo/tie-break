@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:padel_punilla/config/theme/app_theme.dart';
import 'package:padel_punilla/presentation/widgets/ambient_glow.dart';
import 'package:padel_punilla/presentation/widgets/auth_card.dart';
import 'package:padel_punilla/presentation/widgets/custom_text_field.dart';
import 'package:padel_punilla/presentation/widgets/primary_button.dart';
import 'package:padel_punilla/presentation/widgets/secondary_button.dart';

void main() {
  testGoldens('Auth widgets golden test', (tester) async {
    final builder =
        GoldenBuilder.column()
          ..addScenario(
            'AuthCard light',
            Theme(
              data: AppTheme.lightTheme,
              child: const AuthCard(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Auth Card Content'),
                ),
              ),
            ),
          )
          ..addScenario(
            'AuthCard dark',
            Theme(
              data: AppTheme.darkTheme,
              child: const AuthCard(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Auth Card Content'),
                ),
              ),
            ),
          )
          ..addScenario(
            'CustomTextField light',
            Theme(
              data: AppTheme.lightTheme,
              child: SizedBox(
                width: 300,
                child: CustomTextField(
                  controller: TextEditingController(),
                  label: 'Email',
                  prefixIcon: Icons.email,
                  hint: 'Enter your email',
                ),
              ),
            ),
          )
          ..addScenario(
            'CustomTextField dark',
            Theme(
              data: AppTheme.darkTheme,
              child: SizedBox(
                width: 300,
                child: CustomTextField(
                  controller: TextEditingController(),
                  label: 'Password',
                  prefixIcon: Icons.lock,
                  obscureText: true,
                ),
              ),
            ),
          )
          ..addScenario(
            'PrimaryButton',
            Theme(
              data: AppTheme.lightTheme,
              child: PrimaryButton(text: 'Login', onPressed: () {}),
            ),
          )
          ..addScenario(
            'PrimaryButton loading',
            Theme(
              data: AppTheme.lightTheme,
              child: PrimaryButton(
                text: 'Loading',
                onPressed: () {},
                isLoading: true,
              ),
            ),
          )
          ..addScenario(
            'SecondaryButton',
            Theme(
              data: AppTheme.lightTheme,
              child: SecondaryButton(
                text: 'Google Sign In',
                icon: Icons.g_mobiledata,
                onPressed: () {},
              ),
            ),
          )
          ..addScenario(
            'AmbientGlow',
            Theme(
              data: AppTheme.lightTheme,
              child: const SizedBox(
                width: 200,
                height: 200,
                child: AmbientGlow(color: Colors.blue),
              ),
            ),
          );

    await tester.pumpWidgetBuilder(
      builder.build(),
      surfaceSize: const Size(400, 1200),
    );

    await screenMatchesGolden(
      tester,
      'auth_widgets',
      customPump: (tester) async {
        await tester.pump(const Duration(milliseconds: 500));
      },
    );
  });
}
