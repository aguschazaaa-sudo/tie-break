import 'package:flutter/widgets.dart';

/// Utility class to preload critical images at app startup.
/// This prevents image flickering when navigating to screens.
class ImagePreloader {
  /// List of critical image paths that should be preloaded.
  static const List<String> criticalImages = [
    'assets/images/pexels-khezez-34079996.jpg', // Landing
    'assets/images/pexels-anhelina-vasylyk-734724285-35248373.jpg', // Login
    'assets/images/pexels-ivanhdz-32349969.jpg', // Signup
    'assets/icons/imagotipo.png', // Logo
    'assets/icons/PADEL PUNILLA.png', // Branding
  ];

  /// Preloads all critical images into the image cache.
  /// Should be called once when the app starts, ideally in a loading screen
  /// or in the first widget's didChangeDependencies.
  static Future<void> precacheImages(BuildContext context) async {
    await Future.wait(
      criticalImages.map((path) => precacheImage(AssetImage(path), context)),
    );
  }
}
