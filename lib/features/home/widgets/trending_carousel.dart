import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:jawakarsa/core/app_colors.dart';
import 'package:jawakarsa/core/app_text_styles.dart';

class _CarouselItem {
  const _CarouselItem({
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });
  final String imagePath;
  final String title;
  final String subtitle;
}

class TrendingCarousel extends StatefulWidget {
  const TrendingCarousel({super.key});

  @override
  State<TrendingCarousel> createState() => _TrendingCarouselState();
}

class _TrendingCarouselState extends State<TrendingCarousel> {
  static const _items = [
    _CarouselItem(
      imagePath: 'assets/carousel/wayang.webp',
      title: 'Wayang Kulit',
      subtitle: 'Warisan budaya dunia dari Jawa',
    ),
    _CarouselItem(
      imagePath: 'assets/carousel/gedung_sate.webp',
      title: 'Gedung Sate',
      subtitle: 'Ikon arsitektur bersejarah Jawa Barat',
    ),
    _CarouselItem(
      imagePath: 'assets/carousel/little_venice.webp',
      title: 'Little Venice',
      subtitle: 'Pesona kanal di tanah Jawa',
    ),
  ];

  // Gunakan jumlah item besar untuk efek loop seamless
  static const int _multiplier = 500;
  static const int _itemsLength = 3;
  static const int _virtualCount = _itemsLength * _multiplier;
  static const int _initialPage = _itemsLength * (_multiplier ~/ 2);

  late final PageController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: _initialPage);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      if (!_controller.hasClients) return;
      _controller.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Trending Sekarang', style: AppTextStyles.titleMedium()),
        const SizedBox(height: 12),

        SizedBox(
          height: 190,
          child: PageView.builder(
            controller: _controller,
            itemCount: _virtualCount,
            itemBuilder: (context, index) {
              final item = _items[index % _itemsLength];
              return _CarouselCard(item: item);
            },
          ),
        ),

        const SizedBox(height: 10),

        Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final realPage = _controller.hasClients
                  ? (_controller.page?.round() ?? _initialPage) %
                      _itemsLength
                  : 0;
              return SmoothPageIndicator(
                controller: PageController(initialPage: realPage),
                count: _items.length,
                effect: ExpandingDotsEffect(
                  dotHeight: 7,
                  dotWidth: 7,
                  expansionFactor: 2.8,
                  spacing: 5,
                  activeDotColor: AppColors.rubyRed,
                  dotColor: AppColors.coastalStorm.withValues(alpha: 0.3),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CarouselCard extends StatelessWidget {
  const _CarouselCard({required this.item});

  final _CarouselItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.potBlack,
        boxShadow: [
          BoxShadow(
            color: AppColors.potBlack.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              item.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: AppColors.mallardish.withValues(alpha: 0.3),
                child: Center(
                  child: Icon(
                    Icons.image_outlined,
                    color: AppColors.coastalStorm,
                    size: 40,
                  ),
                ),
              ),
            ),

            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.potBlack.withValues(alpha: 0.65),
                    ],
                    stops: const [0.45, 1.0],
                  ),
                ),
              ),
            ),

            // Teks judul & subtitl di bawah
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTextStyles.titleSmall(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: AppTextStyles.labelSmall(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
