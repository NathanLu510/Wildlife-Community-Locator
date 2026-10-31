// Filter observations by either an animal category or one species
import 'species.dart';
import 'sighting.dart';

class DiscoveryFilter {
  final AnimalCategory? category;
  final String? speciesId;

  const DiscoveryFilter({
    this.category,
    this.speciesId,
  });

  bool matches(Sighting sighting, List<Species> catalogue) {
    if (category == null && speciesId == null) {
      return true;
    }

    for (final species in catalogue) {
      if (species.commonName != sighting.speciesName) {
        continue;
      }

      if (speciesId != null && species.id != speciesId) {
        return false;
      }

      if (category != null && species.category != category) {
        return false;
      }

      return true;
    }

    return false;
  }
}
