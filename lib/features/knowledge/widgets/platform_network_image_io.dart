import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jawakarsa/core/app_colors.dart';
import 'package:jawakarsa/core/app_text_styles.dart';
import 'package:jawakarsa/services/network_service.dart';

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
  bool _checking = true;
  bool _offline = false;
  bool _timedOut = false;
  bool _loaded = false;
  int _retryCount = 0;
  Timer? _loadTimeoutTimer;

  @override
  void initState() {
    super.initState();
    _checkAndLoad(forceRefresh: false);
  }

  @override
  void didUpdateWidget(covariant PlatformNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _checkAndLoad(forceRefresh: false);
    }
  }

  @override
  void dispose() {
    _loadTimeoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkAndLoad({required bool forceRefresh}) async {
    _loadTimeoutTimer?.cancel();
    if (mounted) {
      setState(() {
        _checking = true;
        _offline = false;
        _timedOut = false;
        _loaded = false;
      });
    }

    final online = await NetworkService.instance.hasInternet(
      forceRefresh: forceRefresh,
    );
    if (!mounted) return;

    if (!online) {
      setState(() {
        _checking = false;
        _offline = true;
      });
      return;
    }

    setState(() {
      _checking = false;
      _offline = false;
      _retryCount++;
    });

    _loadTimeoutTimer = Timer(const Duration(seconds: 12), () {
      if (mounted && !_loaded) {
        setState(() => _timedOut = true);
      }
    });
  }

  Widget _buildFallback({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool showBrowserButton,
  }) {
    return ColoredBox(
      color: AppColors.coastalStorm.withValues(alpha: 0.08),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: AppColors.coastalStorm),
              const SizedBox(height: 6),
              Text(
                title,
                style: AppTextStyles.labelLarge(color: AppColors.potBlack),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.labelSmall(color: AppColors.coastalStorm),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _checkAndLoad(forceRefresh: true),
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
                  if (showBrowserButton)
                    TextButton.icon(
                      onPressed: widget.onOpenExternal,
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: const Icon(Icons.open_in_new_rounded, size: 15),
                      label: const Text('Buka di Browser'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: _checking
          ? ColoredBox(
              color: AppColors.coastalStorm.withValues(alpha: 0.08),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.2),
                ),
              ),
            )
          : _offline
          ? _buildFallback(
              icon: Icons.wifi_off_rounded,
              title: 'Tidak ada koneksi internet',
              subtitle: 'Aktifkan WiFi atau data seluler untuk memuat foto.',
              showBrowserButton: false,
            )
          : _timedOut
          ? _buildFallback(
              icon: Icons.signal_wifi_bad_rounded,
              title: 'Koneksi terlalu lambat',
              subtitle: 'Gagal memuat foto. Periksa jaringan lalu coba lagi.',
              showBrowserButton: true,
            )
          : Image.network(
              widget.imageUrl,
              key: ValueKey('${widget.imageUrl}#$_retryCount'),
              fit: BoxFit.cover,
              cacheWidth: 840,
              filterQuality: FilterQuality.medium,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (frame != null || wasSynchronouslyLoaded) {
                  _loaded = true;
                  _loadTimeoutTimer?.cancel();
                }
                return child;
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  _loaded = true;
                  _loadTimeoutTimer?.cancel();
                  return child;
                }
                return ColoredBox(
                  color: AppColors.coastalStorm.withValues(alpha: 0.08),
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                _loadTimeoutTimer?.cancel();
                return _buildFallback(
                  icon: Icons.broken_image_rounded,
                  title: 'Gagal memuat gambar',
                  subtitle: 'Periksa koneksi internet lalu coba lagi.',
                  showBrowserButton: true,
                );
              },
            ),
    );
  }
}
