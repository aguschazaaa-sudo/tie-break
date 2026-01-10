import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:padel_punilla/domain/repositories/auth_repository.dart';
import 'package:padel_punilla/presentation/screens/home/home_screen.dart';
import 'package:padel_punilla/presentation/screens/landing_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({required this.onToggleTheme, super.key});
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: context.read<AuthRepository>().authStateChanges,
      builder: (context, snapshot) {
        // Si hay datos (usuario logueado), mostramos HomeScreen
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        // Si no hay datos (usuario no logueado), mostramos LandingScreen
        return LandingScreen(onToggleTheme: onToggleTheme);
      },
    );
  }
}
