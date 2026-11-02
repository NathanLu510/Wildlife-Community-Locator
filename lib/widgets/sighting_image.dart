// Displays animal images 

import 'package:flutter/material.dart';

import '../models/sighting.dart';

class SightingImage extends StatelessWidget {
  final Sighting sighting;
  final double? width;
  final double? height;
  final BoxFit fit;

  const SightingImage({
    super.key,
    required this.sighting,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final imageAsset = sighting.imageAsset;
    final imageUrl = sighting.imageUrl;

    // Local sample photograph
    if (imageAsset != null && imageAsset.isNotEmpty) {
      return Image.asset(
        imageAsset,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => _buildPlaceholder(),
      );
    }

    // Remote image (future uploaded sightings)
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => _buildPlaceholder(),
      );
    }

    // No photograph available
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey,
          size: 32,
        ),
      ),
    );
  }
}
