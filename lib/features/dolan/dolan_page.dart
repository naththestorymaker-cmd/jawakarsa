import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jawakarsa/core/app_colors.dart';
import 'package:jawakarsa/core/app_text_styles.dart';
import 'package:jawakarsa/services/network_service.dart';
import 'models/dolan_region.dart';
import 'widgets/java_island_map.dart';
import 'widgets/dolan_detail_section.dart';

class DolanPage extends StatefulWidget {
  const DolanPage({super.key});

  @override
  State<DolanPage> createState() => _DolanPageState();
}

class _DolanPageState extends State<DolanPage> {
  int _selectedRegionId = 4;

  DolanRegion get _selectedRegion =>
      dolanRegions.firstWhere((r) => r.id == _selectedRegionId);

  void _onRegionSelect(int id) {
    setState(() {
      _selectedRegionId = id;
    });
  }

  void _acakDolan() {
    final random = math.Random();
    final randomRegionIndex = random.nextInt(dolanRegions.length);
    final chosenRegion = dolanRegions[randomRegionIndex];
    final randomPlaceIndex = random.nextInt(chosenRegion.places.length);
    final chosenPlace = chosenRegion.places[randomPlaceIndex];

    setState(() {
      _selectedRegionId = chosenRegion.id;
    });

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _AcakDolanModal(region: chosenRegion, place: chosenPlace);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.rubyRed,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'DESTINASI & BUDAYA',
                        style: AppTextStyles.labelSmall(
                          color: Colors.white,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.potBlack,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '6 Daerah Jawa',
                        style: AppTextStyles.labelSmall(
                          color: AppColors.background,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Jelajah Pulau Jawa',
                  style: AppTextStyles.displayLarge().copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sentuh peta atau nomor daerah untuk mengungkap cagar sejarah, kuliner legendaris, dan wisatanya.',
                  style: AppTextStyles.bodyMedium(),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: JavaIslandMapCard(
              selectedRegionId: _selectedRegionId,
              onRegionSelected: _onRegionSelect,
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: DolanDetailSection(region: _selectedRegion),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _AcakDolanButton(onPressed: _acakDolan),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 110)),
      ],
    );
  }
}

class _AcakDolanButton extends StatelessWidget {
  const _AcakDolanButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.potBlack,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.potBlack.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withValues(alpha: 0.15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.casino_outlined, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Text(
                'Acak Dolan',
                style: AppTextStyles.titleMedium(
                  color: Colors.white,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.rubyRed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Surprise Me!',
                  style: AppTextStyles.labelSmall(
                    color: Colors.white,
                  ).copyWith(fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AcakDolanModal extends StatelessWidget {
  const _AcakDolanModal({required this.region, required this.place});

  final DolanRegion region;
  final DolanPlace place;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
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
          const SizedBox(height: 18),

          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.goldVarnishBrown.withValues(alpha: 0.12),
              border: Border.all(color: AppColors.goldVarnishBrown, width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: SvgPicture.asset(
              'assets/gendhis/gendhis_semangat.svg',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            'Destinasi Pilihan Gendhis!',
            style: AppTextStyles.titleMedium().copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Hari ini kamu ditakdirkan menjelajahi:',
            style: AppTextStyles.bodyMedium(color: AppColors.coastalStorm),
          ),
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.potBlack.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.rubyRed,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        region.name,
                        style: AppTextStyles.labelSmall(
                          color: Colors.white,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      place.category.label,
                      style: AppTextStyles.labelSmall(
                        color: AppColors.coastalStorm,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  place.name,
                  style: AppTextStyles.titleSmall().copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.rubyRed,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        place.location,
                        style: AppTextStyles.labelSmall(
                          color: AppColors.coastalStorm,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(place.description, style: AppTextStyles.bodyMedium()),
              ],
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final online = await NetworkService.instance.hasInternet(
                  forceRefresh: true,
                );
                if (!online) {
                  if (context.mounted) Navigator.pop(context);
                  messenger.showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.rubyRed,
                      content: Text(
                        'Tidak ada koneksi internet. Aktifkan WiFi atau data seluler untuk membuka Google Maps.',
                      ),
                    ),
                  );
                  return;
                }
                if (context.mounted) Navigator.pop(context);
                final uri = Uri.parse(place.googleMapsUrl);
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
              icon: const Icon(Icons.map_rounded, color: Colors.white),
              label: Text(
                'Buka Rute di Google Maps',
                style: AppTextStyles.labelLarge(
                  color: Colors.white,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rubyRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
