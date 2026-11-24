import 'package:flutter/material.dart';
import 'package:jawakarsa/core/app_colors.dart';
import 'package:jawakarsa/core/app_text_styles.dart';
import 'package:jawakarsa/data/knowledge_data.dart';
import 'package:jawakarsa/features/knowledge/widgets/instant_knowledge_card_sheet.dart';
import 'package:jawakarsa/models/knowledge_item.dart';

class KnowledgeSearchResultPage extends StatefulWidget {
  const KnowledgeSearchResultPage({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  State<KnowledgeSearchResultPage> createState() =>
      _KnowledgeSearchResultPageState();
}

class _KnowledgeSearchResultPageState extends State<KnowledgeSearchResultPage> {
  late final TextEditingController _searchCtrl;
  String _selectedCategory = 'Semua';
  List<KnowledgeItem> _results = [];

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.initialQuery);
    _performSearch();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _performSearch() {
    setState(() {
      _results = KnowledgeData.search(
        _searchCtrl.text,
        categoryFilter: _selectedCategory,
      );
    });
  }

  Color _getCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'KRIYA & FILOSOFI':
        return AppColors.goldVarnishBrown;
      case 'SENI PERTUNJUKAN & SASTRA':
        return AppColors.rubyRed;
      case 'MITOLOGI & SPIRITUALITAS':
        return const Color(0xFF6A1B9A);
      case 'ARSITEKTUR & TATA RUANG':
        return AppColors.mallardish;
      case 'RITUAL & UPACARA DAUR HIDUP':
        return const Color(0xFFD84315);
      case 'MUSIK & LARAS TRADISIONAL':
        return const Color(0xFF00838F);
      case 'KULINER & TRADISI RASA':
        return const Color(0xFFE65100);
      case 'BUSANA & SIMBOLOGI':
        return const Color(0xFF4E342E);
      case 'SEJARAH & TOKOH BANGSA':
        return AppColors.potBlack;
      default:
        return AppColors.goldVarnishBrown;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toUpperCase()) {
      case 'KRIYA & FILOSOFI':
        return Icons.handyman_rounded;
      case 'SENI PERTUNJUKAN & SASTRA':
        return Icons.theater_comedy_rounded;
      case 'MITOLOGI & SPIRITUALITAS':
        return Icons.auto_awesome_rounded;
      case 'ARSITEKTUR & TATA RUANG':
        return Icons.temple_buddhist_rounded;
      case 'RITUAL & UPACARA DAUR HIDUP':
        return Icons.celebration_rounded;
      case 'MUSIK & LARAS TRADISIONAL':
        return Icons.music_note_rounded;
      case 'KULINER & TRADISI RASA':
        return Icons.restaurant_rounded;
      case 'BUSANA & SIMBOLOGI':
        return Icons.checkroom_rounded;
      case 'SEJARAH & TOKOH BANGSA':
        return Icons.menu_book_rounded;
      default:
        return Icons.auto_stories_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = KnowledgeData.categories;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.coastalStorm.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.potBlack,
              size: 18,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Pencarian Budaya', style: AppTextStyles.titleSmall()),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: AppColors.goldVarnishBrown.withValues(alpha: 0.5),
                  width: 1.2,
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
                      controller: _searchCtrl,
                      autofocus: widget.initialQuery.isEmpty,
                      textInputAction: TextInputAction.search,
                      onChanged: (_) => _performSearch(),
                      onSubmitted: (_) => _performSearch(),
                      decoration: const InputDecoration(
                        hintText: 'Ketik topik (cth: Keris, Aji Saka)...',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: AppTextStyles.bodyMedium(
                        color: AppColors.potBlack,
                      ),
                    ),
                  ),
                  if (_searchCtrl.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      color: AppColors.coastalStorm,
                      onPressed: () {
                        _searchCtrl.clear();
                        _performSearch();
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final cat = categories[idx];
                final isSelected = cat == _selectedCategory;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) {
                      setState(() => _selectedCategory = cat);
                      _performSearch();
                    }
                  },
                  selectedColor: AppColors.potBlack,
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.potBlack,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.potBlack
                          : AppColors.coastalStorm.withValues(alpha: 0.3),
                    ),
                  ),
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  '${_results.length} entri ditemukan',
                  style: AppTextStyles.labelSmall(
                    color: AppColors.coastalStorm,
                  ),
                ),
                const Spacer(),
                Text(
                  'Pangkalan Data Lokal',
                  style: AppTextStyles.labelSmall(color: AppColors.mallardish),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _results.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_stories_outlined,
                            size: 56,
                            color: AppColors.coastalStorm.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Topik tidak ditemukan',
                            style: AppTextStyles.titleSmall(
                              color: AppColors.potBlack,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Coba kata kunci lain seperti "Keris", "Aji Saka", "Ruwatan", "Gamelan", atau "Joglo".',
                            style: AppTextStyles.bodyMedium(
                              color: AppColors.coastalStorm,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                    itemCount: _results.length,
                    itemBuilder: (context, idx) {
                      final item = _results[idx];
                      final catColor = _getCategoryColor(item.category);
                      final catIcon = _getCategoryIcon(item.category);

                      final synopsis = item.overview.contains('.')
                          ? '${item.overview.split('.').first}.'
                          : item.overview;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          elevation: 1,
                          shadowColor: AppColors.potBlack.withValues(
                            alpha: 0.06,
                          ),
                          child: InkWell(
                            onTap: () =>
                                InstantKnowledgeCardSheet.show(context, item),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: 68,
                                      height: 68,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            catColor,
                                            AppColors.potBlack,
                                          ],
                                        ),
                                      ),
                                      child: Image.asset(
                                        item.resolvedThumbnailUrl,
                                        width: 68,
                                        height: 68,
                                        cacheWidth: 204,
                                        filterQuality: FilterQuality.low,
                                        gaplessPlayback: true,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Center(
                                                child: Icon(
                                                  catIcon,
                                                  color: Colors.white,
                                                  size: 28,
                                                ),
                                              );
                                            },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: catColor.withValues(
                                              alpha: 0.12,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            item.category,
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: catColor,
                                              letterSpacing: 0.4,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          item.title,
                                          style: AppTextStyles.titleSmall()
                                              .copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.potBlack,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          synopsis,
                                          style: AppTextStyles.bodyMedium(
                                            color: const Color(0xFF666666),
                                          ).copyWith(fontSize: 12),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Align(
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 14,
                                      color: AppColors.coastalStorm,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
