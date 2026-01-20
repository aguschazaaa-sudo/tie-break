import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:padel_punilla/config/theme/app_theme.dart';
import 'package:padel_punilla/data/repositories/auth_repository_impl.dart';
import 'package:padel_punilla/data/repositories/club_repository_impl.dart';
import 'package:padel_punilla/data/repositories/court_repository_impl.dart';
import 'package:padel_punilla/data/repositories/reservation_repository_impl.dart';
import 'package:padel_punilla/data/repositories/season_repository_impl.dart';
import 'package:padel_punilla/data/services/connectivity_service_impl.dart';
import 'package:padel_punilla/domain/repositories/auth_repository.dart';
import 'package:padel_punilla/domain/repositories/club_repository.dart';
import 'package:padel_punilla/domain/repositories/court_repository.dart';
import 'package:padel_punilla/domain/repositories/reservation_repository.dart';
import 'package:padel_punilla/domain/repositories/season_repository.dart';
import 'package:padel_punilla/domain/repositories/storage_repository.dart';
import 'package:padel_punilla/domain/services/connectivity_service.dart';
import 'package:padel_punilla/domain/services/reservation_service.dart';
import 'package:padel_punilla/firebase_options.dart';
import 'package:padel_punilla/presentation/providers/connectivity_provider.dart';
import 'package:padel_punilla/presentation/widgets/auth_wrapper.dart';
import 'package:padel_punilla/presentation/widgets/connectivity_banner.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicializar Firebase Messaging
  final messaging = FirebaseMessaging.instance;

  // Solicitar permisos (especialmente importante en iOS)
  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  // Inicializar datos de formateo de fecha para español
  await initializeDateFormatting('es');

  // Habilitar persistencia offline de Firestore
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Pre-cargar Google Fonts para evitar FOUT (Flash of Unstyled Text)
  await Future.wait([
    GoogleFonts.pendingFonts([
      GoogleFonts.spaceGrotesk(),
      GoogleFonts.roboto(),
    ]),
  ]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  late final ConnectivityServiceImpl _connectivityService;

  @override
  void initState() {
    super.initState();
    _connectivityService = ConnectivityServiceImpl();
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }

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
        // Connectivity
        Provider<ConnectivityService>.value(value: _connectivityService),
        ChangeNotifierProvider<ConnectivityProvider>(
          create: (_) => ConnectivityProvider(service: _connectivityService),
        ),
        // Repositories
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
        debugShowCheckedModeBanner: false,
        home: Column(
          children: [
            const ConnectivityBanner(),
            Expanded(child: AuthWrapper(onToggleTheme: _toggleTheme)),
          ],
        ),
      ),
    );
  }
}
