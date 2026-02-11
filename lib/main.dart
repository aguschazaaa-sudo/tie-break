import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
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
import 'package:padel_punilla/domain/repositories/notification_repository.dart';
import 'package:padel_punilla/data/repositories/notification_repository_impl.dart';
import 'package:padel_punilla/presentation/providers/notification_provider.dart';
import 'package:padel_punilla/firebase_options.dart';
import 'package:padel_punilla/presentation/providers/connectivity_provider.dart';
import 'package:padel_punilla/presentation/widgets/auth_wrapper.dart';
import 'package:padel_punilla/presentation/widgets/connectivity_banner.dart';
import 'package:padel_punilla/presentation/screens/my_reservations/my_reservations_screen.dart';
import 'package:provider/provider.dart';

void main() {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // Preserve native splash until we are ready to remove it
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
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
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _connectivityService = ConnectivityServiceImpl();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // 1. Initialize Firebase Core (Critical)
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // 2. Start parallel initialization of non-critical components
      // We don't await these immediately to allow the UI to start handling basic frame
      await Future.wait([
        _initializeLocalization(),
        _initializeFonts(),
        _setupFirebaseMessaging(),
        _configureFirestore(),
      ]);
    } catch (e) {
      debugPrint('Initialization error: $e');
      // Handle critical errors (maybe show an error screen)
    } finally {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        FlutterNativeSplash.remove();
      }
    }
  }

  Future<void> _initializeLocalization() async {
    await initializeDateFormatting('es');
  }

  Future<void> _initializeFonts() async {
    // Pre-load Google Fonts to prevent FOUT
    await Future.wait([
      GoogleFonts.pendingFonts([
        GoogleFonts.spaceGrotesk(),
        GoogleFonts.roboto(),
      ]),
    ]);
  }

  Future<void> _configureFirestore() async {
    // Enable offline persistence
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  Future<void> _setupFirebaseMessaging() async {
    final messaging = FirebaseMessaging.instance;

    // Request permissions (non-blocking if possible, but await to ensure decision)
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final android = message.notification?.android;

      if (notification != null && android != null) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(notification.title ?? 'Nueva notificación'),
            behavior: SnackBarBehavior.floating,
            backgroundColor:
                _themeMode == ThemeMode.dark
                    ? AppTheme.darkTheme.colorScheme.primaryContainer
                    : AppTheme.lightTheme.colorScheme.primaryContainer,
            action: SnackBarAction(
              label: 'VER',
              textColor:
                  _themeMode == ThemeMode.dark
                      ? AppTheme.darkTheme.colorScheme.onPrimaryContainer
                      : AppTheme.lightTheme.colorScheme.onPrimaryContainer,
              onPressed: () {
                _navigatorKey.currentState?.push(
                  MaterialPageRoute<void>(
                    builder: (context) => const MyReservationsScreen(),
                  ),
                );
              },
            ),
          ),
        );
      }
    });
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
    if (!_isInitialized) {
      // Show a loading screen while initializing
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode,
        home: Scaffold(
          backgroundColor:
              _themeMode == ThemeMode.dark
                  ? const Color(0xFF0A1628) // Helper for dark bg match
                  : Colors.white,
          body: Center(
            child: CircularProgressIndicator(
              color:
                  _themeMode == ThemeMode.dark
                      ? const Color(0xFF0D7377)
                      : AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
        ),
      );
    }

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
        Provider<NotificationRepository>(
          create: (_) => NotificationRepositoryImpl(),
        ),
        ChangeNotifierProvider<NotificationProvider>(
          create:
              (context) => NotificationProvider(
                notificationRepository: context.read<NotificationRepository>(),
                authRepository: context.read<AuthRepository>(),
              ),
        ),
      ],
      child: MaterialApp(
        scaffoldMessengerKey: _scaffoldMessengerKey,
        navigatorKey: _navigatorKey,
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
