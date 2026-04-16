import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NetworkOrBase64Image extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? errorWidget;

  const NetworkOrBase64Image({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    Widget buildError(BuildContext ctx, Object err, StackTrace? st) {
      return errorWidget ?? _defaultErrorWidget();
    }

    if (imageUrl.startsWith('data:image')) {
      try {
        final parts = imageUrl.split(',');
        if (parts.length > 1) {
          final imageBytes = base64Decode(parts[1].replaceAll(RegExp(r'\s+'), ''));
          return Image.memory(
            imageBytes,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: buildError,
          );
        }
      } catch (e) {
        // Fall through to error
      }
    }

    return CachedNetworkImage(
      imageUrl: imageUrl.isNotEmpty ? imageUrl : 'https://via.placeholder.com/150',
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (context, url, error) => buildError(context, error, null),
    );
  }

  Widget _defaultErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported,
        color: Colors.grey,
      ),
    );
  }
}
