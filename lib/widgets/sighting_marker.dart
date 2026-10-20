// Icon for wildlife sightings

import 'package:flutter/material.dart';

class SightingMarker extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const SightingMarker({
    super.key,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.orange.shade700
              : Colors.green.shade700,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 2.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.pets,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}
