import 'package:flutter/material.dart';
import 'package:jawakarsa/core/app_colors.dart';
import 'package:jawakarsa/core/app_text_styles.dart';
import 'widgets/aksara_converter_section.dart';
import 'widgets/aksara_grid_section.dart';

class KawruhPage extends StatelessWidget {
  const KawruhPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.mallardish,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.menu_book_rounded,
                              color: Colors.white,
                              size: 13,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'PUSTAKA & LITERASI',
                              style:
                                  AppTextStyles.labelSmall(
                                    color: Colors.white,
                                  ).copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.potBlack,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '20 Hanacaraka',
                          style: AppTextStyles.labelSmall(
                            color: Colors.white,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text('Kawruh Aksara Jawa', style: AppTextStyles.displayLarge()),
                const SizedBox(height: 4),
                Text(
                  'Pelajari 20 aksara dasar Carakan beserta Pasangannya, lalu buat Kartu Nama Aksara Jawa milikmu secara otomatis.',
                  style: AppTextStyles.bodyMedium(),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 18)),

        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: AksaraGridSection(),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              color: AppColors.potBlack.withValues(alpha: 0.1),
              thickness: 1.2,
              height: 1,
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: AksaraConverterSection(),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 115)),
      ],
    );
  }
}
