// Icon for wildlife sighting marker appearance
// Green paw marker, gesture detector tells screen when marker is 'ontap'

import 'package:flutter/material.dart';

import '../models/sighting.dart';
import '../utils/category_style.dart';
import '../utils/sighting_category.dart';

class SightingMarker extends StatelessWidget {
  final Sighting sighting;
  final bool isSelected;
  final VoidCallback onTap;

  const SightingMarker({
    super.key,
    required this.sighting,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final category = getSightingCategory(sighting);
    
    final color = category != null
        ? CategoryStyle.color(category)
        : Colors.grey;

    final icon = category != null
        ? CategoryStyle.icon(category)
        : Icons.location_on;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isSelected ? 48 : 40,
        height: isSelected ? 48 : 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: isSelected ? 26 : 22,
        ),
      ),
    );
  }
}
