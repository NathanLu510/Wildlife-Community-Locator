// Identify species category
import '../data/sample_species.dart';
import '../models/sighting.dart';
import '../models/species.dart';

AnimalCategory? getSightingCategory(Sighting sighting) {
  for (final species in sampleSpecies) {
    if (species.commonName == sighting.speciesName) {
      return species.category;
    }
  }

  return null;
}
