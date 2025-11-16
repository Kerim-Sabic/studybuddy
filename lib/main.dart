import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (gracefully handle missing .env for tests)
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('⚠️ .env file not found - using default values for testing');
  }

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize Firebase (gracefully handle missing config for tests)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint(
        '⚠️ Firebase initialization failed - running without Firebase features');
  }

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(
      child: StudyBuddyApp(),
    ),
  );
}

class StudyBuddyApp extends ConsumerWidget {
  const StudyBuddyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Future: Make this dynamic based on user preference
      routerConfig: router,
    );
  }
}
