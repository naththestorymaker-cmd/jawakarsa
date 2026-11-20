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
        SizedBox(
          width: 58,
          height: 58,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.coastalStorm.withValues(alpha: 0.12),
              border: Border.all(color: AppColors.goldVarnishBrown, width: 2),
            ),
            child: ClipOval(
              child: SvgPicture.asset(
                'assets/gendhis/gendhis_ramah.svg',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sugeng Rawuh,',
                style: AppTextStyles.bodyMedium(),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                userName,
                style: AppTextStyles.titleLarge(),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Siap jelajah budaya Jawa?',
                style: AppTextStyles.bodyMedium(),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 90),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.potBlack,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badgeLabel,
              style: AppTextStyles.labelLarge(color: AppColors.background),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
