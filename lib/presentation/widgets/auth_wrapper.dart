import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:padel_punilla/core/utils/image_preloader.dart';
import 'package:padel_punilla/domain/repositories/auth_repository.dart';
import 'package:padel_punilla/presentation/screens/home/home_screen.dart';
import 'package:padel_punilla/presentation/screens/landing_screen.dart';
import 'package:provider/provider.dart';

/// Widget que decide qué pantalla mostrar según el estado de autenticación.
///
/// Maneja 3 estados:
/// - **Waiting**: Muestra loading mientras verifica auth y precarga imágenes
/// - **Authenticated**: Muestra HomeScreen
/// - **Unauthenticated**: Muestra LandingScreen
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({required this.onToggleTheme, super.key});
  final VoidCallback onToggleTheme;

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _imagesPrecached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precarga las imágenes críticas una sola vez
    if (!_imagesPrecached) {
      _imagesPrecached = true;
      ImagePreloader.precacheImages(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: context.read<AuthRepository>().authStateChanges,
      builder: (context, snapshot) {
        // Estado de carga inicial
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Error en el stream - fallback a landing
        if (snapshot.hasError) {
          return LandingScreen(onToggleTheme: widget.onToggleTheme);
        }

        // Usuario autenticado
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // Usuario no autenticado
        return LandingScreen(onToggleTheme: widget.onToggleTheme);
      },
    );
  }
}
