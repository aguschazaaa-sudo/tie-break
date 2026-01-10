import 'dart:async';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:padel_punilla/config/theme/app_text_styles.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  AppTextStyles.useGoogleFonts = false;
  return GoldenToolkit.runWithConfiguration(() async {
    await loadAppFonts();
    await testMain();
  }, config: GoldenToolkitConfiguration(enableRealShadows: true));
}
