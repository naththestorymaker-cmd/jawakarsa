import 'package:flutter/material.dart';
import 'package:jawakarsa/core/app_colors.dart';
import 'package:jawakarsa/core/app_text_styles.dart';
import 'package:jawakarsa/data/knowledge_data.dart';
import 'package:jawakarsa/models/knowledge_item.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';

class InstantKnowledgeCardSheet extends StatelessWidget {
  const InstantKnowledgeCardSheet({
    super.key,
    required this.item,
  });

  final KnowledgeItem item;

  static void show(BuildContext context, KnowledgeItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => InstantKnowledgeCardSheet(item: item),
    );
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

  void _navigateToRelatedTopic(BuildContext context, String topicId) {
    final nextItem = KnowledgeData.findById(topicId);
    if (nextItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Topik belum tersedia dalam kurasi lokal.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    Navigator.pop(context);
    Future.microtask(() {
      if (context.mounted) {
        InstantKnowledgeCardSheet.show(context, nextItem);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(item.category);
    final categoryIcon = _getCategoryIcon(item.category);
    final screenH = MediaQuery.sizeOf(context).height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenH * 0.92),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.coastalStorm.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Stack(
                      children: [
                        Container(
                          height: 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                categoryColor,
                                AppColors.potBlack,
                              ],
                            ),
                          ),
                          child: Stack(
                            children: [
                              Image.asset(
                                item.resolvedThumbnailUrl,
                                width: double.infinity,
                                height: 220,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: double.infinity,
                                    height: 220,
                                    color: Colors.grey[850],
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            categoryIcon,
                                            size: 64,
                                            color: Colors.white
                                                .withValues(alpha: 0.8),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            "Aset gambar belum tersedia",
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.2),
                                        Colors.black.withValues(alpha: 0.8),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 20,
                                right: 60,
                                bottom: 16,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: categoryColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(categoryIcon,
                                              size: 13, color: Colors.white),
                                          const SizedBox(width: 5),
                                          Text(
                                            item.category,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item.title,
                                      style: AppTextStyles.headlineMedium(
                                        color: Colors.white,
                                      ).copyWith(fontWeight: FontWeight.w800),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 16,
                          child: Material(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: () => Navigator.pop(context),
                              customBorder: const CircleBorder(),
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on_rounded,
                                  size: 18, color: categoryColor),
                              const SizedBox(width: 6),
                              Text(
                                'Asal Wilayah:',
                                style: AppTextStyles.labelLarge(
                                  color: AppColors.potBlack,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  item.originRegion,
                                  style: AppTextStyles.labelLarge(
                                    color: categoryColor,
                                  ).copyWith(fontWeight: FontWeight.w700),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.coastalStorm
                                    .withValues(alpha: 0.2),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.potBlack
                                      .withValues(alpha: 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.lightbulb_rounded,
                                        size: 18, color: categoryColor),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Wawasan Utama',
                                      style: AppTextStyles.titleSmall().copyWith(
                                        color: AppColors.potBlack,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  item.overview,
                                  style: AppTextStyles.bodyMedium().copyWith(
                                    height: 1.6,
                                    color: const Color(0xFF2B2B2B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Icon(Icons.format_list_bulleted_rounded,
                                  size: 18, color: categoryColor),
                              const SizedBox(width: 8),
                              Text(
                                'Poin-Poin Penting & Filosofi',
                                style: AppTextStyles.titleSmall().copyWith(
                                  color: AppColors.potBlack,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...item.keyFacts.map((fact) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: categoryColor.withValues(alpha: 0.25),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: categoryColor
                                          .withValues(alpha: 0.15),
                                    ),
                                    child: Icon(
                                      Icons.check_rounded,
                                      size: 14,
                                      color: categoryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          fact.key,
                                          style: AppTextStyles.labelLarge(
                                            color: AppColors.potBlack,
                                          ).copyWith(fontWeight: FontWeight.w800),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          fact.value,
                                          style: AppTextStyles.bodyMedium()
                                              .copyWith(
                                            height: 1.45,
                                            color: const Color(0xFF4A4A4A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          if (item.media.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(Icons.perm_media_rounded,
                                    size: 18, color: categoryColor),
                                const SizedBox(width: 8),
                                Text(
                                  'Media Interaktif Lokal',
                                  style: AppTextStyles.titleSmall().copyWith(
                                    color: AppColors.potBlack,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ...item.media.map((m) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _MediaContainerItem(
                                  media: m,
                                  accentColor: categoryColor,
                                ),
                              );
                            }),
                          ],
                          if (item.relatedTopics.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Icon(Icons.explore_rounded,
                                    size: 18, color: categoryColor),
                                const SizedBox(width: 8),
                                Text(
                                  'Jalur Eksplorasi Terkait',
                                  style: AppTextStyles.titleSmall().copyWith(
                                    color: AppColors.potBlack,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...item.relatedTopics.map((rel) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: InkWell(
                                  onTap: () => _navigateToRelatedTopic(
                                      context, rel.id),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.coastalStorm
                                            .withValues(alpha: 0.25),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: categoryColor
                                                .withValues(alpha: 0.12),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 14,
                                            color: categoryColor,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            rel.title,
                                            style: AppTextStyles.bodyMedium(
                                              color: AppColors.potBlack,
                                            ).copyWith(
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        Icon(
                                          Icons.chevron_right_rounded,
                                          size: 18,
                                          color: AppColors.coastalStorm,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaContainerItem extends StatefulWidget {
  final KnowledgeMedia media;
  final Color accentColor;

  const _MediaContainerItem({
    required this.media,
    required this.accentColor,
  });

  @override
  State<_MediaContainerItem> createState() => _MediaContainerItemState();
}

class _MediaContainerItemState extends State<_MediaContainerItem> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.media.type == 'video') {
      _initVideoPlayer();
    }
  }

  void _initVideoPlayer() {
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.media.url),
    )..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
        }
      }).catchError((error) {
        debugPrint("Error loading video: $error");
      });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.media.type == 'video') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 200,
          color: Colors.black,
          child: _isVideoInitialized && _videoController != null
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    ),
                    IconButton(
                      icon: Icon(
                        _videoController!.value.isPlaying
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_fill_rounded,
                        size: 54,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      onPressed: () {
                        setState(() {
                          if (_videoController!.value.isPlaying) {
                            _videoController!.pause();
                          } else {
                            _videoController!.play();
                          }
                        });
                      },
                    ),
                  ],
                )
              : const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
        ),
      );
    }

    if (widget.media.type == 'sound' || widget.media.url.endsWith('.mp3')) {
      return Mp3AudioContainer(
        audioUrl: widget.media.url,
        accentColor: widget.accentColor,
      );
    }

    if (widget.media.type == 'image' || widget.media.url.endsWith('.webp')) {
      return WebpImageContainer(
        imageUrl: widget.media.url,
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: widget.accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.accentColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.perm_media_rounded, color: widget.accentColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.media.url,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class Mp3AudioContainer extends StatefulWidget {
  final String audioUrl;
  final Color accentColor;

  const Mp3AudioContainer({
    super.key,
    required this.audioUrl,
    required this.accentColor,
  });

  @override
  State<Mp3AudioContainer> createState() => _Mp3AudioContainerState();
}

class _Mp3AudioContainerState extends State<Mp3AudioContainer> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Listener status pemutaran untuk just_audio
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          _isLoading = state.processingState == ProcessingState.loading ||
              state.processingState == ProcessingState.buffering;
          if (state.processingState == ProcessingState.completed) {
            _isPlaying = false;
            _audioPlayer.seek(Duration.zero);
            _audioPlayer.pause();
          }
        });
      }
    });

    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _audioPlayer.setUrl(widget.audioUrl);
    } catch (e) {
      debugPrint("Error setting audio source: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileName = Uri.decodeComponent(widget.audioUrl.split('/').last);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: widget.accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.accentColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: _isLoading ? null : _togglePlayPause,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.accentColor,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isPlaying ? 'Memutar Audio Tradisional...' : 'Putar Rekaman Audio',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.accentColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  fileName,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WebpImageContainer extends StatelessWidget {
  final String imageUrl;
  final double height;

  const WebpImageContainer({
    super.key,
    required this.imageUrl,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    final cleanUrl = Uri.decodeComponent(imageUrl);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: height,
        width: double.infinity,
        color: Colors.grey[200],
        child: Image.network(
          cleanUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        (loadingProgress.expectedTotalBytes ?? 1)
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.broken_image_rounded, size: 40, color: Colors.grey),
                  const SizedBox(height: 4),
                  const Text('Gagal memuat gambar', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      cleanUrl,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 9),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}