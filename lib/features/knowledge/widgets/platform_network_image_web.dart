import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:jawakarsa/core/app_colors.dart';
import 'package:jawakarsa/core/app_text_styles.dart';
import 'package:jawakarsa/services/network_service.dart';
import 'package:web/web.dart' as web;

class PlatformNetworkImage extends StatefulWidget {
  const PlatformNetworkImage({
    super.key,
    required this.imageUrl,
    required this.height,
    required this.onOpenExternal,
  });

  final String imageUrl;
  final double height;
  final VoidCallback onOpenExternal;

  @override
  State<PlatformNetworkImage> createState() => _PlatformNetworkImageState();
}

class _PlatformNetworkImageState extends State<PlatformNetworkImage> {
  static final Set<String> _registeredViewTypes = <String>{};

  bool _checking = true;
  bool _offline = false;
  int _retryCount = 0;

  @override
  void initState() {
    super.initState();
    _checkConnectivity(forceRefresh: false);
  }

  Future<void> _checkConnectivity({required bool forceRefresh}) async {
    if (mounted) {
      setState(() {
        _checking = true;
        _offline = false;
      });
    }
    final online = await NetworkService.instance.hasInternet(
      forceRefresh: forceRefresh,
    );
    if (!mounted) return;
    setState(() {
      _checking = false;
      _offline = !online;
      if (online) _retryCount++;
    });
  }

  static String _viewTypeFor(String url, int attempt) {
    final viewType =
        'jawakarsa-net-img-${url.hashCode.toUnsigned(32)}-$attempt';
    if (_registeredViewTypes.add(viewType)) {
      ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
        final img = web.HTMLImageElement()
          ..src = url
          ..alt = 'Media Budaya Jawa'
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = 'cover'
          ..style.display = 'block';
        return img;
      });
    }
    return viewType;
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return SizedBox(
        height: widget.height,
        width: double.infinity,
        child: ColoredBox(
          color: AppColors.coastalStorm.withValues(alpha: 0.08),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            ),
          ),
        ),
      );
    }

    if (_offline) {
      return SizedBox(
        height: widget.height,
        width: double.infinity,
        child: ColoredBox(
          color: AppColors.coastalStorm.withValues(alpha: 0.08),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    size: 32,
                    color: AppColors.coastalStorm,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tidak ada koneksi internet',
                    style: AppTextStyles.labelLarge(color: AppColors.potBlack),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Aktifkan WiFi atau data seluler untuk memuat foto.',
                    style: AppTextStyles.labelSmall(
                      color: AppColors.coastalStorm,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _checkConnectivity(forceRefresh: true),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.potBlack,
                      side: BorderSide(
                        color: AppColors.coastalStorm.withValues(alpha: 0.35),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 15),
                    label: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final viewType = _viewTypeFor(widget.imageUrl, _retryCount);
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: Colors.grey[200]!),
          HtmlElementView(viewType: viewType),
          Positioned(
            top: 8,
            right: 8,
            child: Tooltip(
              message: 'Buka media asli di tab baru',
              child: Material(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  onTap: widget.onOpenExternal,
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
    );
  }
}
