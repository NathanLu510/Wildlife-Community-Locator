
import 'package:flutter/material.dart';

import '../models/species.dart';

class CategoryStyle {
  static IconData icon(AnimalCategory category) {
    switch (category) {
      case AnimalCategory.birds:
        return Icons.flutter_dash;

      case AnimalCategory.mammals:
        return Icons.pets;

      case AnimalCategory.reptiles:
        return Icons.cruelty_free;

      case AnimalCategory.amphibians:
        return Icons.water;

      case AnimalCategory.insects:
        return Icons.bug_report;
    }
  }

  static Color color(AnimalCategory category) {
    switch (category) {
      case AnimalCategory.birds:
        return Colors.blue;

      case AnimalCategory.mammals:
        return Colors.orange;

      case AnimalCategory.reptiles:
        return Colors.green;

      case AnimalCategory.amphibians:
        return Colors.teal;

      case AnimalCategory.insects:
        return Colors.purple;
    }
  }
}
