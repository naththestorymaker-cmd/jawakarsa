import 'package:flutter/material.dart';
import 'package:jawakarsa/core/app_colors.dart';
import 'package:jawakarsa/features/home/widgets/home_header.dart';
import 'package:jawakarsa/features/home/widgets/home_search_bar.dart';
import 'package:jawakarsa/features/home/widgets/trending_carousel.dart';
import 'package:jawakarsa/features/home/widgets/tahukah_kamu_section.dart';
import 'package:jawakarsa/features/home/widgets/home_bottom_nav.dart';
import 'package:jawakarsa/features/dolanan/dolanan_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.userName = 'Penjelajah'});

  final String userName;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _navIndex = 0;

  static const _kawruhPlaceholder = _PlaceholderPage(
    icon: Icons.menu_book_rounded,
    title: 'Kawruh',
    subtitle: 'Halaman ini sedang dalam pengembangan',
  );

  static const _dolanPlaceholder = _PlaceholderPage(
    icon: Icons.explore_rounded,
    title: 'Dolan',
    subtitle: 'Halaman ini sedang dalam pengembangan',
  );

  Widget get _currentPage {
    switch (_navIndex) {
      case 1:
        return _kawruhPlaceholder;
      case 2:
        return _dolanPlaceholder;
      case 3:
        return const DolananPage();
      default:
        return _HomeBody(userName: widget.userName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: KeyedSubtree(
          key: ValueKey(_navIndex),
          child: _currentPage,
        ),
      ),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.userName});
  final String userName;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: HomeHeader(userName: userName, badgeLabel: 'Pemula'),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: HomeSearchBar(
                onTap: () {
                  // TODO: navigasi ke halaman pencarian
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
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.coastalStorm),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.potBlack,
                )),
            const SizedBox(height: 8),
            Text(subtitle,
                style: TextStyle(fontSize: 13, color: AppColors.coastalStorm),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
