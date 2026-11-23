import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jawakarsa/core/app_colors.dart';
import 'package:jawakarsa/core/app_text_styles.dart';
import 'package:jawakarsa/core/app_transitions.dart';
import 'package:jawakarsa/features/home/home_page.dart';
import 'package:jawakarsa/services/auth_service.dart';

enum _OnboardingStep { chooseAuth, setNickname }

class PersonalizationScreen extends StatefulWidget {
  const PersonalizationScreen({super.key});

  @override
  State<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends State<PersonalizationScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _nameCtrl = TextEditingController();
  final _focusNode = FocusNode();

  _OnboardingStep _step = _OnboardingStep.chooseAuth;
  GoogleSignInResult? _googleAccount;
  bool _isGoogleLoading = false;
  bool _isSubmitting = false;
  bool _hasInput = false;
  String? _authError;

  int _googleAuthAttemptId = 0;
  bool _leftAppDuringGoogleAuth = false;
  Timer? _resumeCancelTimer;

  late AnimationController _enterCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _nameCtrl.addListener(() {
      final hasText = _nameCtrl.text.trim().isNotEmpty;
      if (hasText != _hasInput) setState(() => _hasInput = hasText);
    });

    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut));

    _enterCtrl.forward();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _resumeCancelTimer?.cancel();
    _nameCtrl.dispose();
    _focusNode.dispose();
    _enterCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isGoogleLoading) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _leftAppDuringGoogleAuth = true;
      _resumeCancelTimer?.cancel();
    } else if (state == AppLifecycleState.resumed &&
        _leftAppDuringGoogleAuth) {
      _resumeCancelTimer?.cancel();
      _resumeCancelTimer = Timer(const Duration(milliseconds: 3500), () {
        if (!mounted || !_isGoogleLoading) return;
        _googleAuthAttemptId++;
        setState(() {
          _isGoogleLoading = false;
          _leftAppDuringGoogleAuth = false;
          _authError =
              'Jendela login Google ditutup sebelum selesai. Coba lagi atau lanjut sebagai Tamu.';
        });
      });
    }
  }

  void _cancelGoogleSignIn() {
    if (!_isGoogleLoading) return;
    _resumeCancelTimer?.cancel();
    _googleAuthAttemptId++;
    setState(() {
      _isGoogleLoading = false;
      _leftAppDuringGoogleAuth = false;
      _authError =
          'Login Google dibatalkan. Coba lagi atau lanjut sebagai Tamu.';
    });
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isGoogleLoading || _isSubmitting) return;
    final attemptId = ++_googleAuthAttemptId;
    _resumeCancelTimer?.cancel();
    setState(() {
      _isGoogleLoading = true;
      _leftAppDuringGoogleAuth = false;
      _authError = null;
    });

    try {
      final result = await AuthService.instance.signInWithGoogle();
      if (!mounted || attemptId != _googleAuthAttemptId) return;

      _resumeCancelTimer?.cancel();
      _leftAppDuringGoogleAuth = false;

      if (result == null) {
        setState(() {
          _isGoogleLoading = false;
          _authError =
              'Login Google dibatalkan. Silakan coba lagi atau lanjut sebagai Tamu.';
        });
        return;
      }

      final suggested = result.displayName.trim();
      final truncated =
          suggested.length > 24 ? suggested.substring(0, 24).trim() : suggested;

      _nameCtrl.text = truncated;
      setState(() {
        _googleAccount = result;
        _step = _OnboardingStep.setNickname;
        _isGoogleLoading = false;
      });
    } on TimeoutException {
      if (!mounted || attemptId != _googleAuthAttemptId) return;
      _resumeCancelTimer?.cancel();
      _leftAppDuringGoogleAuth = false;
      setState(() {
        _isGoogleLoading = false;
        _authError =
            'Waktu login Google habis. Coba lagi atau lanjut sebagai Tamu.';
      });
    } catch (e) {
      if (!mounted || attemptId != _googleAuthAttemptId) return;
      _resumeCancelTimer?.cancel();
      _leftAppDuringGoogleAuth = false;
      final msg = e.toString();
      final friendly = msg.contains('ApiException: 10')
          ? 'Login Google butuh SHA-1 keystore terdaftar di Firebase Console.'
          : msg.contains('network')
              ? 'Koneksi internet bermasalah. Coba lagi atau lanjut sebagai Tamu.'
              : 'Login Google gagal. Kamu bisa coba lagi atau lanjut sebagai Tamu.';
      setState(() {
        _isGoogleLoading = false;
        _authError = friendly;
      });
    }
  }

  void _continueAsGuest() {
    if (_isGoogleLoading || _isSubmitting) return;
    _nameCtrl.clear();
    setState(() {
      _googleAccount = null;
      _authError = null;
      _step = _OnboardingStep.setNickname;
    });
  }

  Future<void> _backToAuthChoice() async {
    _focusNode.unfocus();
    if (_googleAccount != null) {
      await AuthService.instance.clearUser();
    }
    if (!mounted) return;
    _nameCtrl.clear();
    setState(() {
      _googleAccount = null;
      _authError = null;
      _step = _OnboardingStep.chooseAuth;
    });
  }

  Future<void> _submitNickname() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || _isSubmitting) return;

    _focusNode.unfocus();
    setState(() => _isSubmitting = true);

    try {
      if (_googleAccount != null) {
        await AuthService.instance.completeGoogleOnboarding(
          _googleAccount!,
          name,
        );
      } else {
        await AuthService.instance.signInAndSaveName(name);
      }
    } catch (_) {}

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      AppTransitions.fadeScaleRoute(page: HomePage(userName: name)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: bottomInset > 0 ? 16 : 0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight -
                      MediaQuery.paddingOf(context).top -
                      MediaQuery.paddingOf(context).bottom,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: AnimatedSwitcher(
                      duration: reduceMotion
                          ? Duration.zero
                          : const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: _step == _OnboardingStep.chooseAuth
                          ? _buildChooseAuthStep()
                          : _buildSetNicknameStep(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChooseAuthStep() {
    return Column(
      key: const ValueKey<_OnboardingStep>(_OnboardingStep.chooseAuth),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),
        SizedBox(
          height: 150,
          child: SvgPicture.asset(
            'assets/gendhis/gendhis_ramah.svg',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Sugeng Rawuh di JawaKarsa',
          style: AppTextStyles.headlineMedium(),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Masuk dengan akun Google untuk menyimpan profilmu, atau langsung jelajah sebagai tamu.',
          style: AppTextStyles.bodyMedium(),
          textAlign: TextAlign.center,
        ),
        if (_authError != null) ...[
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.rubyRed.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.rubyRed.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.rubyRed,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _authError!,
                    style: AppTextStyles.labelSmall(color: AppColors.rubyRed),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 28),
        _GoogleSignInButton(
          isLoading: _isGoogleLoading,
          onTap: _handleGoogleSignIn,
        ),
        if (_isGoogleLoading) ...[
          const SizedBox(height: 6),
          TextButton(
            onPressed: _cancelGoogleSignIn,
            child: Text(
              'Batalkan login',
              style: AppTextStyles.labelLarge(color: AppColors.rubyRed),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Divider(
                color: AppColors.coastalStorm.withValues(alpha: 0.25),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'atau',
                style: AppTextStyles.labelSmall(color: AppColors.coastalStorm),
              ),
            ),
            Expanded(
              child: Divider(
                color: AppColors.coastalStorm.withValues(alpha: 0.25),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: _isGoogleLoading ? null : _continueAsGuest,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.potBlack,
              side: BorderSide(
                color: AppColors.potBlack.withValues(alpha: 0.2),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.person_outline_rounded, size: 20),
            label: Text(
              'Lanjut Tanpa Akun (Tamu)',
              style: AppTextStyles.titleSmall(color: AppColors.potBlack),
            ),
          ),
        ),
        const Spacer(flex: 3),
      ],
    );
  }

  Widget _buildSetNicknameStep() {
    final isGoogle = _googleAccount != null;

    return Column(
      key: const ValueKey<_OnboardingStep>(_OnboardingStep.setNickname),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),
        SizedBox(
          height: 145,
          child: SvgPicture.asset(
            isGoogle
                ? 'assets/gendhis/gendhis_bangga.svg'
                : 'assets/gendhis/gendhis_ramah.svg',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 22),
        if (isGoogle) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.mallardish.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.mallardish.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_user_rounded,
                  size: 14,
                  color: AppColors.mallardish,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Google: ${_googleAccount!.email ?? _googleAccount!.displayName}',
                    style: AppTextStyles.labelSmall(color: AppColors.mallardish)
                        .copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        Text(
          isGoogle ? 'Atur nama panggilanmu' : 'Siapa nama panggilan mu?',
          style: AppTextStyles.headlineMedium(),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          isGoogle
              ? 'Kamu bisa pakai nama dari akun Google atau ganti dengan panggilan sesukamu.'
              : 'Gendhis akan menyapamu dengan nama ini.',
          style: AppTextStyles.bodyMedium(),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 26),
        _NameTextField(
          controller: _nameCtrl,
          focusNode: _focusNode,
          onSubmitted: (_) => _submitNickname(),
        ),
        const SizedBox(height: 20),
        _OkButton(
          label: isGoogle ? 'Simpan & Mulai' : 'Oke',
          isEnabled: _hasInput && !_isSubmitting,
          isLoading: _isSubmitting,
          onTap: _submitNickname,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _isSubmitting ? null : _backToAuthChoice,
          child: Text(
            isGoogle ? 'Ganti akun Google' : 'Kembali ke pilihan masuk',
            style: AppTextStyles.labelLarge(color: AppColors.coastalStorm),
          ),
        ),
        const Spacer(flex: 3),
      ],
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({
    required this.isLoading,
    required this.onTap,
  });

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.potBlack.withValues(alpha: 0.16),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.potBlack.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: AppColors.potBlack,
                          strokeWidth: 2.2,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Menunggu login Google...',
                        style: AppTextStyles.titleSmall(
                          color: AppColors.coastalStorm,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _GoogleGLogo(size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Masuk dengan Google',
                        style: AppTextStyles.titleSmall(
                          color: AppColors.potBlack,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _GoogleGLogo extends StatelessWidget {
  const _GoogleGLogo({this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleGLogoPainter()),
    );
  }
}

class _GoogleGLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.45;
    final stroke = size.width * 0.18;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    // Red top arc
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -2.5, 1.85, false, paint);
    // Yellow left arc
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 2.55, 1.23, false, paint);
    // Green bottom arc
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 0.72, 1.83, false, paint);
    // Blue right arc
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.1, 0.85, false, paint);

    // Blue horizontal crossbar
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx, center.dy),
      Offset(center.dx + radius, center.dy),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NameTextField extends StatelessWidget {
  const _NameTextField({
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.done,
      onSubmitted: onSubmitted,
      inputFormatters: [
        LengthLimitingTextInputFormatter(24),
      ],
      style: AppTextStyles.titleMedium(),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: 'nama panggilan',
        hintStyle: AppTextStyles.titleMedium(color: AppColors.coastalStorm),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.coastalStorm.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.goldVarnishBrown,
            width: 2,
          ),
        ),
      ),
    );
  }
}

class _OkButton extends StatelessWidget {
  const _OkButton({
    required this.label,
    required this.isEnabled,
    required this.isLoading,
    required this.onTap,
  });

  final String label;
  final bool isEnabled;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isEnabled ? 1.0 : 0.45,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: isEnabled ? onTap : null,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.rubyRed,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: AppColors.rubyRed.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    label,
                    style: AppTextStyles.titleSmall(color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }
}
