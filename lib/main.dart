import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:jawakarsa/core/app_colors.dart';
import 'package:jawakarsa/core/app_text_styles.dart';
import 'package:jawakarsa/core/app_transitions.dart';
import 'package:jawakarsa/features/splash/splash_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PaintingBinding.instance.imageCache.maximumSize = 80;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 60 << 20;
  await _tryInitFirebase();
  runApp(const JawaKarsaApp());
}

Future<void> _tryInitFirebase() async {
  try {
    final opts = DefaultFirebaseOptions.currentPlatform;
    if (opts.projectId.startsWith('REPLACE_ME')) return;
    await Firebase.initializeApp(options: opts);
  } catch (_) {}
}

class JawaKarsaApp extends StatelessWidget {
  const JawaKarsaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JawaKarsa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.rubyRed,
          primary: AppColors.rubyRed,
          secondary: AppColors.goldVarnishBrown,
          surface: AppColors.surface,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: AppTextStyles.textTheme,
        pageTransitionsTheme: AppTransitions.pageTransitionsTheme,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
