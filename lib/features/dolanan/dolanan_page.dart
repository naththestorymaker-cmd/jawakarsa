import 'package:flutter/material.dart';
import 'package:jawakarsa/core/app_colors.dart';
import 'package:jawakarsa/core/app_text_styles.dart';
import 'package:jawakarsa/features/dolanan/widgets/game_list_tab.dart';

class DolananPage extends StatelessWidget {
  const DolananPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text('Dolanan', style: AppTextStyles.titleLarge()),
            ),
            const SizedBox(height: 8),
            const Expanded(child: GameListTab()),
          ],
        ),
      ),
    );
  }
}
