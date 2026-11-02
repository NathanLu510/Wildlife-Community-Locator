// Data model for describing the structure of a wildlife sighting
// 'final' prevents the reassignment of values 
// 'required' caller must provide value when constructing variable

class Sighting {
  final String id;
  final String speciesName;
  final double latitude;
  final double longitude;
  final String regionId;
  final DateTime observedAt;
  final String description;
  final String? imageUrl;
  final String? imageAsset;
  final String? userId;

  const Sighting({
    required this.id,
    required this.speciesName,
    required this.latitude,
    required this.longitude,
    required this.regionId,
    required this.observedAt,
    required this.description,
    this.imageUrl,
    this.imageAsset,
    this.userId,
  });
}
