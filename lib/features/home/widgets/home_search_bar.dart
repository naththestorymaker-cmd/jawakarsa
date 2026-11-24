import 'package:flutter/material.dart';
import 'package:jawakarsa/core/app_colors.dart';
import 'package:jawakarsa/core/app_text_styles.dart';
import 'package:jawakarsa/features/knowledge/knowledge_search_result_page.dart';

class HomeSearchBar extends StatefulWidget {
  const HomeSearchBar({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitSearch(String query) {
    final q = query.trim();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KnowledgeSearchResultPage(initialQuery: q),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.coastalStorm.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.potBlack.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            color: AppColors.goldVarnishBrown,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (val) {
                if (val.trim().isNotEmpty) {
                  _submitSearch(val);
                }
              },
              decoration: const InputDecoration(
                hintText: 'Cari budaya Jawa',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF888888),
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: AppTextStyles.bodyMedium(color: AppColors.potBlack),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.goldVarnishBrown,
              size: 20,
            ),
            onPressed: () => _submitSearch(_controller.text),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Cari Budaya',
          ),
        ],
      ),
    );
  }
}
