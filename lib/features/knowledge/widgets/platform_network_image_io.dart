import 'package:flutter/material.dart';

class PlatformNetworkImage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        cacheWidth: 840,
        filterQuality: FilterQuality.medium,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return ColoredBox(
            color: Colors.grey[200]!,
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
          return ColoredBox(
            color: Colors.grey[200]!,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.broken_image_rounded,
                      size: 36,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Gagal memuat gambar',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: onOpenExternal,
                      icon: const Icon(Icons.open_in_new_rounded, size: 16),
                      label: const Text('Buka di Browser'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
