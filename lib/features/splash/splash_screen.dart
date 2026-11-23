import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jawakarsa/core/app_colors.dart';
import 'package:jawakarsa/core/app_text_styles.dart';
import 'package:jawakarsa/core/app_transitions.dart';
import 'package:jawakarsa/services/auth_service.dart';
import 'package:jawakarsa/features/home/home_page.dart';
import 'package:jawakarsa/features/personalization/personalization_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );

    _ctrl.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.wait([
      Future<void>.delayed(const Duration(milliseconds: 2000)),
    ]);

    if (!mounted) return;

    final isOnboarded = await AuthService.instance.isOnboarded();
    final savedName = await AuthService.instance.getSavedName();

    if (!mounted) return;

    if (isOnboarded && savedName != null) {
      _goTo(HomePage(userName: savedName));
    } else {
      _goTo(const PersonalizationScreen());
    }
  }

  void _goTo(Widget page) {
    Navigator.of(context).pushReplacement(
      AppTransitions.fadeScaleRoute(page: page),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.potBlack,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: SvgPicture.asset(
                    'assets/gendhis/gendhis_semangat.svg',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'JawaKarsa',
                  style: AppTextStyles.displayLarge(color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  'Jelajah budaya Jawa',
                  style: AppTextStyles.bodyMedium(
                    color: AppColors.coastalStorm,
                  ),
                ),

                const SizedBox(height: 48),

                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.goldVarnishBrown,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
