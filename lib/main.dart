
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:medminder/providers/theme_provider.dart';
import 'package:medminder/screens/onboarding/onboarding_screen.dart';
import 'package:medminder/services/fcm_service.dart';
import 'package:medminder/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'screens/app_shell.dart';
import 'screens/auth_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  await FirebaseAppCheck.instance.activate();

  // Notifications
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const App(),
    ),
  );
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late Future<bool> _onboardingSeen;

  @override
  void initState() {
    super.initState();
    _onboardingSeen = _checkOnboardingStatus();
  }

  Future<bool> _checkOnboardingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_seen') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _onboardingSeen,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else {
          final onboardingSeen = snapshot.data ?? false;
          return MedMinderApp(onboardingSeen: onboardingSeen);
        }
      },
    );
  }
}

class MedMinderApp extends StatelessWidget {
  final bool onboardingSeen;
  const MedMinderApp({super.key, required this.onboardingSeen});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'MedMinder',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          debugShowCheckedModeBanner: false,
          home: onboardingSeen ? const AuthWrapper() : const OnboardingScreen(),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasData) {
          return const AppShellWrapper();
        }
        return const AuthScreen();
      },
    );
  }
}

class AppShellWrapper extends StatefulWidget {
  const AppShellWrapper({super.key});

  @override
  State<AppShellWrapper> createState() => _AppShellWrapperState();
}

class _AppShellWrapperState extends State<AppShellWrapper> {
  @override
  void initState() {
    super.initState();
    FcmService().init();
  }

  @override
  Widget build(BuildContext context) {
    return const AppShell();
  }
}
