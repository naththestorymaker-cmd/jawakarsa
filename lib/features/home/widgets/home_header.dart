import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jawakarsa/core/app_colors.dart';

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
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.coastalStorm.withValues(alpha: 0.15),
            border: Border.all(
              color: AppColors.goldVarnishBrown,
              width: 2,
            ),
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
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.coastalStorm,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.potBlack,
                ),
              ),
              Text(
                'Siap jelajah budaya Jawa?',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.coastalStorm,
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.potBlack,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            badgeLabel,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.background,
            ),
          ),
        ),
      ],
    );
  }
}
