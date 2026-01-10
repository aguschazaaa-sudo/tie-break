import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:padel_punilla/config/theme/app_theme.dart';
import 'package:padel_punilla/data/repositories/auth_repository_impl.dart';
import 'package:padel_punilla/data/repositories/club_repository_impl.dart';
import 'package:padel_punilla/data/repositories/court_repository_impl.dart';
import 'package:padel_punilla/data/repositories/reservation_repository_impl.dart';
import 'package:padel_punilla/data/repositories/season_repository_impl.dart';
import 'package:padel_punilla/domain/repositories/auth_repository.dart';
import 'package:padel_punilla/domain/repositories/club_repository.dart';
import 'package:padel_punilla/domain/repositories/court_repository.dart';
import 'package:padel_punilla/domain/repositories/reservation_repository.dart';
import 'package:padel_punilla/domain/repositories/season_repository.dart';
import 'package:padel_punilla/domain/repositories/storage_repository.dart';
import 'package:padel_punilla/domain/services/reservation_service.dart';
import 'package:padel_punilla/firebase_options.dart';
import 'package:padel_punilla/presentation/widgets/auth_wrapper.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>(create: (_) => AuthRepositoryImpl()),
        Provider<ClubRepository>(create: (_) => ClubRepositoryImpl()),
        Provider<CourtRepository>(create: (_) => CourtRepositoryImpl()),
        Provider<ReservationRepository>(
          create: (_) => ReservationRepositoryImpl(),
        ),
        ProxyProvider<ReservationRepository, ReservationService>(
          update:
              (_, repo, __) => ReservationService(reservationRepository: repo),
        ),
        Provider<SeasonRepository>(create: (_) => SeasonRepositoryImpl()),
        Provider<StorageRepository>(create: (_) => StorageRepository()),
      ],
      child: MaterialApp(
        title: 'Padel Punilla',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode,
        // Usamos AuthWrapper para decidir qué pantalla mostrar
        home: AuthWrapper(onToggleTheme: _toggleTheme),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
