import 'package:flutter/material.dart';
import 'package:jawakarsa/core/app_colors.dart';
import 'package:jawakarsa/core/app_transitions.dart';
import 'package:jawakarsa/features/dolan/dolan_page.dart';
import 'package:jawakarsa/features/dolanan/dolanan_page.dart';
import 'package:jawakarsa/features/home/widgets/home_bottom_nav.dart';
import 'package:jawakarsa/features/home/widgets/home_header.dart';
import 'package:jawakarsa/features/home/widgets/home_search_bar.dart';
import 'package:jawakarsa/features/home/widgets/tahukah_kamu_section.dart';
import 'package:jawakarsa/features/home/widgets/trending_carousel.dart';
import 'package:jawakarsa/features/kawruh/kawruh_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.userName = 'Penjelajah'});

  final String userName;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _navIndex = 0;

  void _onNavTap(int nextIndex) {
    if (nextIndex == _navIndex) return;
    setState(() => _navIndex = nextIndex);
  }

  Widget _buildTab(BuildContext context, int index) {
    switch (index) {
      case 0:
        return _HomeView(userName: widget.userName);
      case 1:
        return const KawruhPage();
      case 2:
        return const DolanPage();
      case 3:
        return const DolananPage();
      default:
        return _HomeView(userName: widget.userName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOME VIEW (Main Dashboard Slivers)
// ─────────────────────────────────────────────────────────────────────────────
class _HomeView extends StatelessWidget {
  const _HomeView({required this.userName});

  final String userName;

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

        // Bottom clearance for floating bottom navigation dock
        const SliverToBoxAdapter(child: SizedBox(height: 110)),
      ],
    );
  }
}
