// Data model for representing animal species
enum AnimalCategory {
  birds,
  mammals,
  reptiles,
  amphibians,
  insects,
}

extension AnimalCategoryName on AnimalCategory {
  String get label {
    switch (this) {
      case AnimalCategory.birds:
        return 'Birds';
      case AnimalCategory.mammals:
        return 'Mammals';
      case AnimalCategory.reptiles:
        return 'Reptiles';
      case AnimalCategory.amphibians:
        return 'Amphibians';
      case AnimalCategory.insects:
        return 'Insects';
    }
  }
}

class Species {
  final String id;
  final String commonName;
  final String scientificName;
  final AnimalCategory category;

  const Species({
    required this.id,
    required this.commonName,
    required this.scientificName,
    required this.category,
  });
}
