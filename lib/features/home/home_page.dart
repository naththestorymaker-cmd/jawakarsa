import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jawakarsa/core/app_colors.dart';
import 'package:jawakarsa/core/app_text_styles.dart';
import 'package:jawakarsa/core/app_transitions.dart';
import 'package:jawakarsa/features/dolan/dolan_page.dart';
import 'package:jawakarsa/features/dolanan/dolanan_page.dart';
import 'package:jawakarsa/features/home/widgets/home_bottom_nav.dart';
import 'package:jawakarsa/features/home/widgets/home_header.dart';
import 'package:jawakarsa/features/home/widgets/home_search_bar.dart';
import 'package:jawakarsa/features/home/widgets/tahukah_kamu_section.dart';
import 'package:jawakarsa/features/home/widgets/trending_carousel.dart';
import 'package:jawakarsa/features/home/widgets/gendhis_tour_overlay.dart';
import 'package:jawakarsa/features/kawruh/kawruh_page.dart';
import 'package:jawakarsa/features/personalization/personalization_screen.dart';
import 'package:jawakarsa/services/auth_service.dart';
import 'package:jawakarsa/services/gendhis_voice_service.dart';
import 'package:jawakarsa/services/network_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.userName = 'Penjelajah'});

  final String userName;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _kHasSeenTourKey = 'has_seen_gendhis_tour';

  int _navIndex = 0;
  late String _userName;
  UserProfile? _profile;
  bool _showTour = false;
  bool _tourStartsWithPrompt = true;
  Timer? _tourStartTimer;

  @override
  void initState() {
    super.initState();
    _userName = widget.userName;
    _loadProfile();
    _initTourGuide();
  }

  @override
  void dispose() {
    _tourStartTimer?.cancel();
    super.dispose();
  }

  Future<void> _initTourGuide() async {
    await GendhisVoiceService.instance.loadPreferences();
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool(_kHasSeenTourKey) ?? false;
    if (!hasSeen && mounted) {
      _tourStartTimer = Timer(const Duration(milliseconds: 450), () {
        if (mounted) {
          setState(() {
            _tourStartsWithPrompt = true;
            _showTour = true;
          });
        }
      });
    }
  }

  Future<void> _finishTour() async {
    setState(() {
      _showTour = false;
      _navIndex = 0;
    });
    await GendhisVoiceService.instance.stop();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kHasSeenTourKey, true);
    } catch (_) {}
  }

  void _replayTour() {
    _tourStartTimer?.cancel();
    setState(() {
      _navIndex = 0;
      _tourStartsWithPrompt = false;
      _showTour = true;
    });
  }

  Future<void> _loadProfile() async {
    final profile = await AuthService.instance.getUserProfile();
    if (!mounted || profile == null) return;
    setState(() {
      _profile = profile;
      _userName = profile.name;
    });
  }

  void _onNavTap(int nextIndex) {
    if (nextIndex == _navIndex) return;
    setState(() => _navIndex = nextIndex);
  }

  void _openProfileSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => _AccountProfileSheet(
        userName: _userName,
        profile: _profile,
        onEditNickname: () {
          Navigator.pop(sheetCtx);
          _showEditNicknameDialog();
        },
        onReplayTour: () {
          Navigator.pop(sheetCtx);
          _replayTour();
        },
        onLinkGoogle: () async {
          Navigator.pop(sheetCtx);
          await _linkGoogleAccount();
        },
        onSignOut: () async {
          Navigator.pop(sheetCtx);
          await AuthService.instance.clearUser();
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            AppTransitions.fadeScaleRoute(page: const PersonalizationScreen()),
            (route) => false,
          );
        },
      ),
    );
  }

  Future<void> _showEditNicknameDialog() async {
    final ctrl = TextEditingController(text: _userName);
    final newName = await showDialog<String>(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Ubah Nama Panggilan', style: AppTextStyles.titleLarge()),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          inputFormatters: [LengthLimitingTextInputFormatter(24)],
          decoration: InputDecoration(
            hintText: 'Masukkan nama baru',
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx),
            child: Text(
              'Batal',
              style: AppTextStyles.labelLarge(color: AppColors.coastalStorm),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.rubyRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final clean = ctrl.text.trim();
              if (clean.isNotEmpty) Navigator.pop(dlgCtx, clean);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    ctrl.dispose();

    if (newName == null || newName.isEmpty || newName == _userName) return;
    await AuthService.instance.updateNickname(newName);
    await _loadProfile();
    if (!mounted) return;
    setState(() => _userName = newName);
  }

  Future<void> _linkGoogleAccount() async {
    try {
      final result = await AuthService.instance.signInWithGoogle();
      if (!mounted) return;
      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.potBlack,
            content: Text(
              'Login Google dibatalkan.',
              style: AppTextStyles.bodyMedium(color: Colors.white),
            ),
          ),
        );
        return;
      }
      final linked = await AuthService.instance.linkGoogleToCurrentProfile(
        result,
      );
      if (!mounted) return;
      setState(() {
        _profile = linked;
        _userName = linked.name;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.mallardish,
          content: Text(
            'Terhubung ke Google (${linked.email ?? linked.name})',
            style: AppTextStyles.bodyMedium(color: Colors.white),
          ),
        ),
      );
    } on NoInternetException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.rubyRed,
          content: Text(
            'Tidak ada koneksi internet. Aktifkan WiFi atau data seluler terlebih dahulu.',
            style: AppTextStyles.bodyMedium(color: Colors.white),
          ),
        ),
      );
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.rubyRed,
          content: Text(
            'Waktu login Google habis. Coba lagi nanti.',
            style: AppTextStyles.bodyMedium(color: Colors.white),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().contains('ApiException: 10')
          ? 'SHA-1 Android belum didaftarkan di Firebase Console.'
          : 'Gagal menghubungkan akun Google.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.rubyRed,
          content: Text(
            msg,
            style: AppTextStyles.bodyMedium(color: Colors.white),
          ),
        ),
      );
    }
  }

  Widget _buildTab(BuildContext context, int index) {
    switch (index) {
      case 0:
        return _HomeView(
          userName: _userName,
          isGoogleUser: _profile?.isGoogleUser ?? false,
          onProfileTap: _openProfileSheet,
        );
      case 1:
        return const KawruhPage();
      case 2:
        return const DolanPage();
      case 3:
        return const DolananPage();
      default:
        return _HomeView(
          userName: _userName,
          isGoogleUser: _profile?.isGoogleUser ?? false,
          onProfileTap: _openProfileSheet,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.background,
          extendBody: true,
          body: SafeArea(
            bottom: false,
            child: KeepAliveTabSwitcher(
              currentIndex: _navIndex,
              itemCount: 4,
              itemBuilder: _buildTab,
            ),
          ),
          bottomNavigationBar: HomeBottomNav(
            currentIndex: _navIndex,
            onTap: _onNavTap,
          ),
        ),
        if (_showTour)
          Positioned.fill(
            child: GendhisTourOverlay(
              startWithPrompt: _tourStartsWithPrompt,
              onSwitchTab: (tabIdx) {
                if (_navIndex != tabIdx && mounted) {
                  setState(() => _navIndex = tabIdx);
                }
              },
              onFinish: _finishTour,
            ),
          ),
      ],
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView({
    required this.userName,
    required this.isGoogleUser,
    required this.onProfileTap,
  });

  final String userName;
  final bool isGoogleUser;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: HomeHeader(
              userName: userName,
              badgeLabel: 'Pemula',
              isGoogleUser: isGoogleUser,
              onProfileTap: onProfileTap,
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const HomeSearchBar(),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const TrendingCarousel(),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 28)),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: const TahukahKamuSection(),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 110)),
      ],
    );
  }
}

class _AccountProfileSheet extends StatelessWidget {
  const _AccountProfileSheet({
    required this.userName,
    required this.profile,
    required this.onEditNickname,
    required this.onReplayTour,
    required this.onLinkGoogle,
    required this.onSignOut,
  });

  final String userName;
  final UserProfile? profile;
  final VoidCallback onEditNickname;
  final VoidCallback onReplayTour;
  final VoidCallback onLinkGoogle;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final isGoogle = profile?.isGoogleUser ?? false;
    final email = profile?.email;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.coastalStorm.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.background,
                    border: Border.all(
                      color: AppColors.goldVarnishBrown,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: SvgPicture.asset(
                      'assets/gendhis/gendhis_ramah.svg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName, style: AppTextStyles.titleLarge()),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isGoogle
                                ? AppColors.mallardish.withValues(alpha: 0.14)
                                : AppColors.coastalStorm.withValues(
                                    alpha: 0.14,
                                  ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isGoogle ? 'Akun Google' : 'Mode Tamu',
                            style: AppTextStyles.labelSmall(
                              color: isGoogle
                                  ? AppColors.mallardish
                                  : AppColors.coastalStorm,
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (isGoogle && email != null && email.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              email,
                              style: AppTextStyles.labelSmall(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          ListTile(
            onTap: onEditNickname,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            tileColor: AppColors.background,
            leading: const Icon(
              Icons.edit_rounded,
              color: AppColors.goldVarnishBrown,
            ),
            title: Text(
              'Ubah Nama Panggilan',
              style: AppTextStyles.titleSmall(),
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
          const SizedBox(height: 10),
          ListTile(
            onTap: onReplayTour,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            tileColor: AppColors.goldVarnishBrown.withValues(alpha: 0.10),
            leading: const Icon(
              Icons.record_voice_over_rounded,
              color: AppColors.goldVarnishBrown,
            ),
            title: Text(
              'Ulangi Tur Panduan Gendhis',
              style: AppTextStyles.titleSmall(),
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
          if (!isGoogle) ...[
            const SizedBox(height: 10),
            ListTile(
              onTap: onLinkGoogle,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              tileColor: AppColors.mallardish.withValues(alpha: 0.08),
              leading: const Icon(
                Icons.login_rounded,
                color: AppColors.mallardish,
              ),
              title: Text(
                'Hubungkan Akun Google',
                style: AppTextStyles.titleSmall(color: AppColors.mallardish),
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.mallardish,
              ),
            ),
          ],
          const SizedBox(height: 10),
          ListTile(
            onTap: onSignOut,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            tileColor: AppColors.rubyRed.withValues(alpha: 0.08),
            leading: const Icon(Icons.logout_rounded, color: AppColors.rubyRed),
            title: Text(
              'Keluar / Ganti Akun',
              style: AppTextStyles.titleSmall(color: AppColors.rubyRed),
            ),
          ),
        ],
      ),
    );
  }
}
