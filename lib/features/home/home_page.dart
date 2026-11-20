import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jawakarsa/core/app_colors.dart';
import 'package:jawakarsa/core/app_text_styles.dart';
import 'package:jawakarsa/features/dolan/dolan_page.dart';
import 'package:jawakarsa/features/kawruh/kawruh_page.dart';
import 'package:jawakarsa/features/home/widgets/home_header.dart';
import 'package:jawakarsa/features/home/widgets/home_search_bar.dart';
import 'package:jawakarsa/features/home/widgets/trending_carousel.dart';
import 'package:jawakarsa/features/home/widgets/tahukah_kamu_section.dart';
import 'package:jawakarsa/features/home/widgets/home_bottom_nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _navIndex = 0;

  Widget _buildBody() {
    switch (_navIndex) {
      case 0:
        return const _HomeView();
      case 1:
        return const KawruhPage();
      case 2:
        return const DolanPage();
      case 3:
        return _PlaceholderView(
          title: 'Dolanan Tradisional',
          subtitle:
              'Wahana permainan interaktif, tebak aksara Jawa, dan kuis gamifikasi budaya sedang disiapkan.',
          mascotPath: 'assets/gendhis/gendhis_bangga.svg',
          actionLabel: 'Kembali ke Beranda',
          onAction: () => setState(() => _navIndex = 0),
        );
      default:
        return const _HomeView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: KeyedSubtree(
            key: ValueKey<int>(_navIndex),
            child: _buildBody(),
          ),
        ),
      ),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOME VIEW (Main Dashboard Slivers)
// ─────────────────────────────────────────────────────────────────────────────
class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: HomeHeader(
              userName: 'Penjelajah',
              badgeLabel: 'Pemula',
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: HomeSearchBar(
              onTap: () {
                // Navigate to search or topic
              },
            ),
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

        // Bottom clearance for floating bottom navigation dock
        const SliverToBoxAdapter(child: SizedBox(height: 110)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PLACEHOLDER VIEW FOR UNIMPLEMENTED TABS
// ─────────────────────────────────────────────────────────────────────────────
class _PlaceholderView extends StatelessWidget {
  const _PlaceholderView({
    required this.title,
    required this.subtitle,
    required this.mascotPath,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String subtitle;
  final String mascotPath;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(
                  color: AppColors.goldVarnishBrown,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.potBlack.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: SvgPicture.asset(
                mascotPath,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTextStyles.headlineMedium(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTextStyles.bodyMedium(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.potBlack,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(
                actionLabel,
                style: AppTextStyles.labelLarge(color: Colors.white),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
