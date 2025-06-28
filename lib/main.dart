import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'auth_services.dart';
import 'flutter_flow/flutter_flow_util.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //await AppStateNotifier.instance.checkAdminStatus(); // 👈 FETCH isAdmin early
  // Enable offline persistence for Firebase Realtime DB
  FirebaseDatabase.instance.setPersistenceEnabled(true);

  // Initialize AppStateNotifier (manages splash + router refresh)
  final appStateNotifier = AppStateNotifier.instance;

  // Wait for Firebase to restore auth state before showing UI
  final initialUser = await FirebaseAuth.instance.authStateChanges().first;

  // Listen for future changes to auth state and notify router
  FirebaseAuth.instance.authStateChanges().listen((user) {
    appStateNotifier.stopShowingSplashImage(); // Ends splash & refreshes GoRouter
  });

  runApp(
    MultiProvider(
      providers: [
        StreamProvider<User?>.value(
          value: FirebaseAuth.instance.authStateChanges(),
          initialData: initialUser,
        ),
        Provider<AuthService>(create: (_) => AuthService()),
      ],
      child: MyApp(appStateNotifier: appStateNotifier),
    ),
  );
}

class MyApp extends StatefulWidget {
  final AppStateNotifier appStateNotifier;
  const MyApp({super.key, required this.appStateNotifier});

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  late GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createRouter(widget.appStateNotifier);
  }

  void setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'John',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', '')],
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: false,
      ),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}
