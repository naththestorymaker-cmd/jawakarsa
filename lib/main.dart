import 'package:flutter/material.dart';
import 'package:jawakarsa/core/app_colors.dart';
import 'package:jawakarsa/core/app_text_styles.dart';
import 'package:jawakarsa/features/home/home_page.dart';

void main() {
  runApp(const JawaKarsaApp());
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
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
