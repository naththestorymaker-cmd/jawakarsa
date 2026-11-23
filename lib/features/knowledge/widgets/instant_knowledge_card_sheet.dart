import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jawakarsa/core/app_colors.dart';
import 'package:jawakarsa/core/app_text_styles.dart';
import 'package:jawakarsa/data/knowledge_data.dart';
import 'package:jawakarsa/features/knowledge/widgets/platform_network_image.dart';
import 'package:jawakarsa/models/knowledge_item.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

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
                                cacheWidth: 840,
                                filterQuality: FilterQuality.medium,
                                gaplessPlayback: true,
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
                                  'Media Interaktif',
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
                                  fallbackThumbnail: item.resolvedThumbnailUrl,
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

Future<void> _openExternalUrl(BuildContext context, String rawUrl) async {
  final uri = Uri.tryParse(rawUrl);
  if (uri == null) return;
  try {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat membuka tautan media di browser.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat membuka tautan media di browser.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

String _formatMediaDuration(Duration d) {
  if (d.isNegative) return '00:00';
  final hours = d.inHours;
  final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (hours > 0) {
    return '$hours:$minutes:$seconds';
  }
  return '$minutes:$seconds';
}

class _MediaContainerItem extends StatefulWidget {
  final KnowledgeMedia media;
  final Color accentColor;
  final String fallbackThumbnail;

  const _MediaContainerItem({
    required this.media,
    required this.accentColor,
    required this.fallbackThumbnail,
  });

  @override
  State<_MediaContainerItem> createState() => _MediaContainerItemState();
}

class _MediaContainerItemState extends State<_MediaContainerItem> {
  VideoPlayerController? _videoController;
  bool _hasStartedVideo = false;
  bool _isLoadingVideo = false;
  bool _isVideoInitialized = false;
  String? _videoError;

  double? _dragPositionMs;
  bool _isMuted = false;
  bool _showCenterOverlay = true;
  Timer? _hideOverlayTimer;

  Future<void> _initAndPlayVideo() async {
    setState(() {
      _hasStartedVideo = true;
      _isLoadingVideo = true;
      _videoError = null;
      _dragPositionMs = null;
    });

    await _videoController?.dispose();
    _videoController = null;

    try {
      final url = widget.media.url.trim();
      final controller = url.startsWith('http')
          ? VideoPlayerController.networkUrl(Uri.parse(url))
          : VideoPlayerController.asset(url);
      _videoController = controller;

      await controller.initialize().timeout(const Duration(seconds: 15));
      if (!mounted) {
        await controller.dispose();
        return;
      }

      if (_isMuted) {
        await controller.setVolume(0.0);
      }

      setState(() {
        _isVideoInitialized = true;
        _isLoadingVideo = false;
        _showCenterOverlay = true;
      });
      await controller.play();
      _scheduleHideOverlay();
    } catch (error) {
      debugPrint('Error loading video: $error');
      await _videoController?.dispose();
      _videoController = null;
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
          _isLoadingVideo = false;
          _videoError = 'Video tidak dapat diputar langsung di perangkat ini';
        });
      }
    }
  }

  void _scheduleHideOverlay() {
    _hideOverlayTimer?.cancel();
    _hideOverlayTimer = Timer(const Duration(seconds: 2), () {
      if (mounted &&
          _videoController != null &&
          _videoController!.value.isPlaying) {
        setState(() => _showCenterOverlay = false);
      }
    });
  }

  Future<void> _toggleVideoPlayPause() async {
    final controller = _videoController;
    if (controller == null || !_isVideoInitialized) return;

    final val = controller.value;
    if (val.isPlaying) {
      _hideOverlayTimer?.cancel();
      await controller.pause();
      if (mounted) setState(() => _showCenterOverlay = true);
    } else {
      if (val.duration > Duration.zero && val.position >= val.duration) {
        await controller.seekTo(Duration.zero);
      }
      await controller.play();
      if (mounted) setState(() => _showCenterOverlay = true);
      _scheduleHideOverlay();
    }
  }

  Future<void> _seekVideoRelative(Duration delta) async {
    final controller = _videoController;
    if (controller == null || !_isVideoInitialized) return;

    final duration = controller.value.duration;
    if (duration <= Duration.zero) return;

    var target = controller.value.position + delta;
    if (target < Duration.zero) target = Duration.zero;
    if (target > duration) target = duration;
    await controller.seekTo(target);
    _scheduleHideOverlay();
  }

  Future<void> _toggleVideoMute() async {
    final controller = _videoController;
    if (controller == null || !_isVideoInitialized) return;
    final nextMuted = !_isMuted;
    await controller.setVolume(nextMuted ? 0.0 : 1.0);
    if (mounted) {
      setState(() => _isMuted = nextMuted);
    }
  }

  @override
  void dispose() {
    _hideOverlayTimer?.cancel();
    _videoController?.dispose();
    super.dispose();
  }

  Widget _buildVideoCard() {
    final fileName = Uri.decodeComponent(widget.media.url.split('/').last);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 224,
        width: double.infinity,
        color: AppColors.potBlack,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (!_hasStartedVideo) ...[
              Image.asset(
                widget.fallbackThumbnail,
                fit: BoxFit.cover,
                cacheWidth: 840,
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, _, _) =>
                    Container(color: AppColors.potBlack),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.72),
                    ],
                  ),
                ),
              ),
              Center(
                child: Material(
                  color: widget.accentColor,
                  borderRadius: BorderRadius.circular(32),
                  child: InkWell(
                    onTap: _initAndPlayVideo,
                    borderRadius: BorderRadius.circular(32),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Putar Video',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 48,
                bottom: 10,
                child: Text(
                  fileName,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ] else if (_isLoadingVideo) ...[
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 10),
                    Text(
                      'Memuat video...',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ] else if (_videoError != null) ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.videocam_off_rounded,
                        color: Colors.white70,
                        size: 36,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _videoError!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _initAndPlayVideo,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white54),
                            ),
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: const Text('Coba Lagi'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () =>
                                _openExternalUrl(context, widget.media.url),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.accentColor,
                              foregroundColor: Colors.white,
                            ),
                            icon:
                                const Icon(Icons.open_in_new_rounded, size: 16),
                            label: const Text('Buka di Browser'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (_isVideoInitialized && _videoController != null) ...[
              Center(
                child: AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio > 0
                      ? _videoController!.value.aspectRatio
                      : 16 / 9,
                  child: VideoPlayer(_videoController!),
                ),
              ),
              Positioned.fill(
                child: ValueListenableBuilder<VideoPlayerValue>(
                  valueListenable: _videoController!,
                  builder: (context, value, _) {
                    final duration = value.duration;
                    final maxMs = duration.inMilliseconds > 0
                        ? duration.inMilliseconds.toDouble()
                        : 0.0;
                    final currentMs = _dragPositionMs ??
                        value.position.inMilliseconds
                            .toDouble()
                            .clamp(0.0, maxMs > 0 ? maxMs : 0.0);
                    final displayPos = Duration(
                      milliseconds: currentMs.round(),
                    );
                    final showCenterBtn = !value.isPlaying || _showCenterOverlay;

                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (value.isPlaying && !_showCenterOverlay) {
                              setState(() => _showCenterOverlay = true);
                              _scheduleHideOverlay();
                            } else {
                              _toggleVideoPlayPause();
                            }
                          },
                          behavior: HitTestBehavior.translucent,
                          child: Center(
                            child: value.isBuffering
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : AnimatedOpacity(
                                    opacity: showCenterBtn ? 0.92 : 0.0,
                                    duration:
                                        const Duration(milliseconds: 180),
                                    child: IgnorePointer(
                                      ignoring: !showCenterBtn,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.black45,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(6),
                                        child: Icon(
                                          value.isPlaying
                                              ? Icons.pause_rounded
                                              : Icons.play_arrow_rounded,
                                          size: 38,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: DecoratedBox(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black54,
                                  Colors.black87,
                                ],
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 12, 10, 4),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      trackHeight: 3.5,
                                      thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 6,
                                      ),
                                      overlayShape:
                                          const RoundSliderOverlayShape(
                                        overlayRadius: 12,
                                      ),
                                      activeTrackColor: widget.accentColor,
                                      inactiveTrackColor: Colors.white24,
                                      thumbColor: Colors.white,
                                      overlayColor: widget.accentColor
                                          .withValues(alpha: 0.25),
                                    ),
                                    child: Slider(
                                      min: 0.0,
                                      max: maxMs > 0 ? maxMs : 1.0,
                                      value: maxMs > 0
                                          ? currentMs.clamp(0.0, maxMs)
                                          : 0.0,
                                      onChangeStart: maxMs > 0
                                          ? (v) {
                                              _hideOverlayTimer?.cancel();
                                              setState(
                                                () => _dragPositionMs = v,
                                              );
                                            }
                                          : null,
                                      onChanged: maxMs > 0
                                          ? (v) => setState(
                                                () => _dragPositionMs = v,
                                              )
                                          : null,
                                      onChangeEnd: maxMs > 0
                                          ? (v) async {
                                              await _videoController!.seekTo(
                                                Duration(
                                                  milliseconds: v.round(),
                                                ),
                                              );
                                              if (mounted) {
                                                setState(
                                                  () => _dragPositionMs = null,
                                                );
                                                _scheduleHideOverlay();
                                              }
                                            }
                                          : null,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        tooltip: value.isPlaying
                                            ? 'Jeda'
                                            : 'Putar',
                                        onPressed: _toggleVideoPlayPause,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 32,
                                          minHeight: 32,
                                        ),
                                        icon: Icon(
                                          value.isPlaying
                                              ? Icons.pause_rounded
                                              : Icons.play_arrow_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Mundur 10 detik',
                                        onPressed: () => _seekVideoRelative(
                                          const Duration(seconds: -10),
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 30,
                                          minHeight: 30,
                                        ),
                                        icon: const Icon(
                                          Icons.replay_10_rounded,
                                          color: Colors.white70,
                                          size: 19,
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Maju 10 detik',
                                        onPressed: () => _seekVideoRelative(
                                          const Duration(seconds: 10),
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 30,
                                          minHeight: 30,
                                        ),
                                        icon: const Icon(
                                          Icons.forward_10_rounded,
                                          color: Colors.white70,
                                          size: 19,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${_formatMediaDuration(displayPos)} / ${_formatMediaDuration(duration)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontFeatures: [
                                            FontFeature.tabularFigures(),
                                          ],
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        tooltip: _isMuted
                                            ? 'Bunyikan'
                                            : 'Bisukan',
                                        onPressed: _toggleVideoMute,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 32,
                                          minHeight: 32,
                                        ),
                                        icon: Icon(
                                          _isMuted
                                              ? Icons.volume_off_rounded
                                              : Icons.volume_up_rounded,
                                          color: Colors.white70,
                                          size: 19,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
            Positioned(
              top: 8,
              right: 8,
              child: Tooltip(
                message: 'Buka di Browser',
                child: Material(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    onTap: () => _openExternalUrl(context, widget.media.url),
                    borderRadius: BorderRadius.circular(18),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.open_in_new_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.media.type == 'video') {
      return _buildVideoCard();
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
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<Duration?>? _durationSub;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isSourceSet = false;
  String? _errorMessage;
  Duration _duration = Duration.zero;
  double? _dragPositionMs;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _playerStateSub = _audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;
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
    });

    _durationSub = _audioPlayer.durationStream.listen((d) {
      if (!mounted || d == null) return;
      setState(() => _duration = d);
    });
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    _durationSub?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _seekAudioRelative(Duration delta) async {
    if (!_isSourceSet || _duration <= Duration.zero) return;
    var target = _audioPlayer.position + delta;
    if (target < Duration.zero) target = Duration.zero;
    if (target > _duration) target = _duration;
    await _audioPlayer.seek(target);
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        return;
      }

      if (!_isSourceSet) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
        final url = widget.audioUrl.trim();
        if (url.startsWith('http')) {
          await _audioPlayer.setUrl(url).timeout(const Duration(seconds: 15));
        } else {
          await _audioPlayer.setAsset(url);
        }
        _isSourceSet = true;
        if (_audioPlayer.duration != null && mounted) {
          setState(() => _duration = _audioPlayer.duration!);
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Error playing audio: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isPlaying = false;
          _errorMessage = 'Gagal memutar audio — ketuk ikon kanan untuk browser';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileName = Uri.decodeComponent(widget.audioUrl.split('/').last);
    final statusTitle = _errorMessage != null
        ? 'Audio tidak tersedia langsung'
        : _isPlaying
            ? 'Memutar Audio Tradisional...'
            : 'Putar Rekaman Audio';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      decoration: BoxDecoration(
        color: widget.accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.accentColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
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
                          _isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
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
                      statusTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _errorMessage != null
                            ? Colors.redAccent
                            : widget.accentColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _errorMessage ?? fileName,
                      style: TextStyle(
                        fontSize: 11,
                        color: _errorMessage != null
                            ? Colors.redAccent
                            : Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Buka di Browser',
                onPressed: () => _openExternalUrl(context, widget.audioUrl),
                icon: Icon(
                  Icons.open_in_new_rounded,
                  size: 18,
                  color: widget.accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          StreamBuilder<Duration>(
            stream: _audioPlayer.positionStream,
            initialData: Duration.zero,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final maxMs = _duration.inMilliseconds > 0
                  ? _duration.inMilliseconds.toDouble()
                  : 0.0;
              final canSeek = _isSourceSet && maxMs > 0;
              final currentMs = _dragPositionMs ??
                  position.inMilliseconds
                      .toDouble()
                      .clamp(0.0, maxMs > 0 ? maxMs : 0.0);
              final displayPos = Duration(milliseconds: currentMs.round());

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3.5,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 12,
                      ),
                      activeTrackColor: widget.accentColor,
                      inactiveTrackColor:
                          widget.accentColor.withValues(alpha: 0.22),
                      disabledActiveTrackColor:
                          widget.accentColor.withValues(alpha: 0.25),
                      disabledInactiveTrackColor:
                          widget.accentColor.withValues(alpha: 0.14),
                      thumbColor: widget.accentColor,
                      disabledThumbColor:
                          widget.accentColor.withValues(alpha: 0.45),
                      overlayColor: widget.accentColor.withValues(alpha: 0.2),
                    ),
                    child: Slider(
                      min: 0.0,
                      max: maxMs > 0 ? maxMs : 1.0,
                      value: canSeek ? currentMs.clamp(0.0, maxMs) : 0.0,
                      onChangeStart: canSeek
                          ? (v) => setState(() => _dragPositionMs = v)
                          : null,
                      onChanged: canSeek
                          ? (v) => setState(() => _dragPositionMs = v)
                          : null,
                      onChangeEnd: canSeek
                          ? (v) async {
                              await _audioPlayer.seek(
                                Duration(milliseconds: v.round()),
                              );
                              if (mounted) {
                                setState(() => _dragPositionMs = null);
                              }
                            }
                          : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        Text(
                          _formatMediaDuration(displayPos),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.coastalStorm,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Mundur 10 detik',
                          onPressed: canSeek
                              ? () => _seekAudioRelative(
                                    const Duration(seconds: -10),
                                  )
                              : null,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 28,
                          ),
                          icon: Icon(
                            Icons.replay_10_rounded,
                            size: 18,
                            color: canSeek
                                ? widget.accentColor
                                : AppColors.coastalStorm.withValues(alpha: 0.4),
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          tooltip: 'Maju 10 detik',
                          onPressed: canSeek
                              ? () => _seekAudioRelative(
                                    const Duration(seconds: 10),
                                  )
                              : null,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 28,
                          ),
                          icon: Icon(
                            Icons.forward_10_rounded,
                            size: 18,
                            color: canSeek
                                ? widget.accentColor
                                : AppColors.coastalStorm.withValues(alpha: 0.4),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatMediaDuration(_duration),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.coastalStorm,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
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
    final cleanUrl = imageUrl.trim();

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: cleanUrl.startsWith('assets/')
          ? SizedBox(
              height: height,
              width: double.infinity,
              child: Image.asset(
                cleanUrl,
                cacheWidth: 840,
                filterQuality: FilterQuality.medium,
                fit: BoxFit.cover,
              ),
            )
          : PlatformNetworkImage(
              imageUrl: cleanUrl,
              height: height,
              onOpenExternal: () => _openExternalUrl(context, cleanUrl),
            ),
    );
  }
}