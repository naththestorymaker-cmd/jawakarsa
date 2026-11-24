import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jawakarsa/core/app_colors.dart';
import 'package:jawakarsa/core/app_text_styles.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    this.userName = 'Penjelajah',
    this.badgeLabel = 'Pemula',
    this.isGoogleUser = false,
    this.onProfileTap,
  });

  final String userName;
  final String badgeLabel;
  final bool isGoogleUser;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Semantics(
            button: onProfileTap != null,
            label: 'Profil dan Pengaturan Akun',
            child: InkWell(
              onTap: onProfileTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        SizedBox(
                          width: 58,
                          height: 58,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.coastalStorm.withValues(
                                alpha: 0.12,
                              ),
                              border: Border.all(
                                color: AppColors.goldVarnishBrown,
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: SvgPicture.asset(
                                'assets/gendhis/gendhis_ramah.svg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        if (isGoogleUser)
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: AppColors.mallardish,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.background,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.verified_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
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
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  userName,
                                  style: AppTextStyles.titleLarge(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (onProfileTap != null) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.expand_more_rounded,
                                  size: 18,
                                  color: AppColors.coastalStorm,
                                ),
                              ],
                            ],
                          ),
                          Text(
                            'Siap jelajah budaya Jawa?',
                            style: AppTextStyles.bodyMedium(),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 90),
          child: GestureDetector(
            onTap: onProfileTap,
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
        ),
      ],
    );
  }
}
