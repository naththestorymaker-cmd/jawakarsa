import 'package:flutter/material.dart';
import 'package:jawakarsa/core/app_colors.dart';
import 'package:jawakarsa/core/app_text_styles.dart';
import 'package:jawakarsa/features/dolanan/widgets/game_list_tab.dart';
import 'package:jawakarsa/features/dolanan/widgets/leaderboard_tab.dart';

class DolananPage extends StatefulWidget {
  const DolananPage({super.key});

  @override
  State<DolananPage> createState() => _DolananPageState();
}

class _DolananPageState extends State<DolananPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text('Dolanan & Papan Peringkat',
                  style: AppTextStyles.titleLarge()),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SegmentedTab(controller: _tab),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: const [
                  GameListTab(),
                  LeaderboardTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentedTab extends StatelessWidget {
  const _SegmentedTab({required this.controller});
  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.coastalStorm.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _Segment(
            label: 'Mini Games',
            selected: controller.index == 0,
            onTap: () => controller.animateTo(0),
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(10),
              right: Radius.circular(10),
            ),
          ),
          _Segment(
            label: 'Papan Peringkat',
            selected: controller.index == 1,
            onTap: () => controller.animateTo(1),
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(10),
              right: Radius.circular(10),
            ),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.borderRadius,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.surface : Colors.transparent,
            borderRadius: borderRadius,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.potBlack.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            style: selected
                ? AppTextStyles.labelLarge(color: AppColors.potBlack)
                : AppTextStyles.labelLarge(color: AppColors.coastalStorm),
          ),
        ),
      ),
    );
  }
}
