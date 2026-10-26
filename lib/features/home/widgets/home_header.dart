import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jawakarsa/core/app_colors.dart';
import 'package:jawakarsa/core/app_text_styles.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    this.userName = 'Penjelajah',
    this.badgeLabel = 'Pemula',
  });

  final String userName;
  final String badgeLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.coastalStorm.withValues(alpha: 0.12),
            border: Border.all(color: AppColors.goldVarnishBrown, width: 2),
          ),
          clipBehavior: Clip.antiAlias,
          child: SvgPicture.asset(
            'assets/gendhis/gendhis_ramah.svg',
            fit: BoxFit.cover,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wilujeng Enjing,',
                style: AppTextStyles.bodyMedium(),
              ),
              Text(
                userName,
                style: AppTextStyles.titleLarge(),
              ),
              Text(
                'Siap jelajah budaya Jawa?',
                style: AppTextStyles.bodyMedium(),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.potBlack,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            badgeLabel,
            style: AppTextStyles.labelLarge(color: AppColors.background),
          ),
        ),
      ],
    );
  }
}
