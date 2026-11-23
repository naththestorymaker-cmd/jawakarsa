import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

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

  static final Set<String> _registeredViewTypes = <String>{};

  static String _viewTypeFor(String url) {
    final viewType = 'jawakarsa-net-img-${url.hashCode.toUnsigned(32)}';
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
    final viewType = _viewTypeFor(imageUrl);
    return SizedBox(
      height: height,
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
                  onTap: onOpenExternal,
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
