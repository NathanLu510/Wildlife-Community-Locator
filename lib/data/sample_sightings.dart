// Sample sighting data

import '../../models/sighting.dart';

final List<Sighting> sampleSightings = [
  Sighting(
    id: 'sighting_001',
    speciesName: 'Formosan rock macaque',
    latitude: 24.16,
    longitude: 121.62,
    regionId: '花蓮縣',
    observedAt: DateTime(2026, 10, 12, 9, 30),
    description: 'A macaque observed near a forest trail.',
  ),
  Sighting(
    id: 'sighting_002',
    speciesName: 'Taiwan blue magpie',
    latitude: 25.04,
    longitude: 121.58,
    regionId: '臺北市',
    observedAt: DateTime(2026, 10, 13, 8, 15),
    description: 'A blue magpie perched on a tree branch.',
  ),
  Sighting(
    id: 'sighting_003',
    speciesName: 'Formosan sika deer',
    latitude: 21.95,
    longitude: 120.78,
    regionId: '屏東縣',
    observedAt: DateTime(2026, 10, 14, 16, 45),
    description: 'Several deer observed in a grassy clearing.',
  ),
  Sighting(
    id: 'sighting_004',
    speciesName: 'Taiwan barbet',
    latitude: 25.02,
    longitude: 121.55,
    regionId: '臺北市',
    observedAt: DateTime(2026, 10, 15, 10, 20),
    description: 'A Taiwan barbet calling from a tree.',
  ),
  Sighting(
    id: 'sighting_005',
    speciesName: 'Formosan rock macaque',
    latitude: 24.08,
    longitude: 121.59,
    regionId: '花蓮縣',
    observedAt: DateTime(2026, 10, 16, 11, 10),
    description: 'A small group of macaques moving through the forest.',
  ),
  Sighting(
    id: 'sighting_006',
    speciesName: 'Black-faced spoonbill',
    latitude: 23.07,
    longitude: 120.05,
    regionId: '臺南市',
    observedAt: DateTime(2026, 10, 17, 7, 50),
    description: 'A spoonbill feeding in a coastal wetland.',
  ),
];
