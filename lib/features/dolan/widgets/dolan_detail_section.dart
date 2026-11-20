import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jawakarsa/core/app_colors.dart';
import 'package:jawakarsa/core/app_text_styles.dart';
import '../models/dolan_region.dart';

class DolanDetailSection extends StatelessWidget {
  const DolanDetailSection({
    super.key,
    required this.region,
  });

  final DolanRegion region;

  Future<void> _openGoogleMaps(BuildContext context, DolanPlace place) async {
    final uri = Uri.parse(place.googleMapsUrl);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak dapat membuka peta untuk ${place.name}'),
            backgroundColor: AppColors.potBlack,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Membuka query peta: ${place.mapsQuery}'),
            backgroundColor: AppColors.potBlack,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.potBlack.withValues(alpha: 0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.potBlack.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Province Header matching Wireframe: "JAWA TENGAH"
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(
                bottom: BorderSide(
                  color: AppColors.potBlack.withValues(alpha: 0.1),
                  width: 1.2,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
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
                              color: AppColors.potBlack,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'WILAYAH #${region.id}',
                              style: AppTextStyles.labelSmall(
                                color: Colors.white,
                              ).copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            region.capital,
                            style: AppTextStyles.labelSmall(
                              color: AppColors.coastalStorm,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        region.name.toUpperCase(),
                        style: AppTextStyles.headlineMedium().copyWith(
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        region.nickname,
                        style: AppTextStyles.bodyMedium(
                          color: AppColors.coastalStorm,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.rubyRed.withValues(alpha: 0.1),
                    border: Border.all(
                      color: AppColors.rubyRed.withValues(alpha: 0.25),
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.place_rounded,
                      color: AppColors.rubyRed,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3 Categories: Sejarah, Kuliner, Wisata
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Cagar Sejarah & Museum
                _CategoryBlock(
                  category: DolanCategory.sejarah,
                  accentColor: AppColors.mallardish,
                  places: region.getPlacesByCategory(DolanCategory.sejarah),
                  onPlaceTap: (place) => _openGoogleMaps(context, place),
                ),

                const SizedBox(height: 20),

                // 2. Kuliner Tradisional Khas
                _CategoryBlock(
                  category: DolanCategory.kuliner,
                  accentColor: AppColors.rubyRed,
                  places: region.getPlacesByCategory(DolanCategory.kuliner),
                  onPlaceTap: (place) => _openGoogleMaps(context, place),
                ),

                const SizedBox(height: 20),

                // 3. Destinasi Wisata Populer
                _CategoryBlock(
                  category: DolanCategory.wisata,
                  accentColor: AppColors.goldVarnishBrown,
                  places: region.getPlacesByCategory(DolanCategory.wisata),
                  onPlaceTap: (place) => _openGoogleMaps(context, place),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CATEGORY BLOCK (Title + Place Cards)
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryBlock extends StatelessWidget {
  const _CategoryBlock({
    required this.category,
    required this.accentColor,
    required this.places,
    required this.onPlaceTap,
  });

  final DolanCategory category;
  final Color accentColor;
  final List<DolanPlace> places;
  final ValueChanged<DolanPlace> onPlaceTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                category.icon,
                color: accentColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              category.label,
              style: AppTextStyles.titleSmall().copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Places in this category
        ...places.map((place) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PlaceCard(
                place: place,
                accentColor: accentColor,
                onTap: () => onPlaceTap(place),
              ),
            )),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PLACE CARD (Tap to Google Maps)
// ─────────────────────────────────────────────────────────────────────────────
class _PlaceCard extends StatelessWidget {
  const _PlaceCard({
    required this.place,
    required this.accentColor,
    required this.onTap,
  });

  final DolanPlace place;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: accentColor.withValues(alpha: 0.1),
        highlightColor: accentColor.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.potBlack.withValues(alpha: 0.08),
              width: 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      place.name,
                      style: AppTextStyles.titleSmall().copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.goldVarnishBrown.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.goldVarnishBrown,
                          size: 14,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          place.rating.toString(),
                          style: AppTextStyles.labelSmall(
                            color: AppColors.potBlack,
                          ).copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Location snippet
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: accentColor,
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

              // Description
              Text(
                place.description,
                style: AppTextStyles.bodyMedium(
                  color: AppColors.potBlack.withValues(alpha: 0.8),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 10),

              // "Buka di Google Maps" CTA badge
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.directions_outlined,
                          size: 14,
                          color: accentColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Buka di Google Maps',
                          style: AppTextStyles.labelSmall(
                            color: accentColor,
                          ).copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.arrow_outward_rounded,
                          size: 12,
                          color: accentColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
