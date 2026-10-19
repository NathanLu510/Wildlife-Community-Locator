import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../services/taiwan_regions.dart';

import '../data/sample_sightings.dart';
import '../models/sighting.dart';

import '../widgets/regional_sightings_panel.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  static const taiwanCenter = LatLng(23.7, 120.96);

  // Initialising with Future handles asynchronisation
  // If assets are loading or when they can't be loaded
  late final Future<List<Polygon<String>>> regionsFuture;

  // Stores information hit by pointer interactions
  final LayerHitNotifier<String> hitNotifier = ValueNotifier(null);

  String? selectedRegion;

  @override
  void initState() {
    super.initState();
    regionsFuture = TaiwanRegions.load(); // From taiwan_regions.dart
  }

  @override
  void dispose() {
    hitNotifier.dispose();
    super.dispose();
  }

  // Function that filters sightings relative to region
  List<Sighting> getSightingsForRegion(String region) {
    return sampleSightings.where((sighting) {
      return sighting.regionId == region;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    const cartoKey = String.fromEnvironment('CARTO_API_KEY');

    return FutureBuilder<List<Polygon<String>>>(
      future: regionsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Failed to load regions: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final polygons = snapshot.data!;

        final displayedPolygons = polygons.map((polygon) {
          final isSelected = polygon.hitValue == selectedRegion; // check if selected polygon name matches region

          // Highlight selected country
          return Polygon<String>(
            points: polygon.points,
            holePointsList: polygon.holePointsList,
            color: isSelected
                ? Colors.green.withValues(alpha: 0.25)
                : Colors.transparent,
            borderColor: isSelected
                ? Colors.green.shade900
                : const Color(0xFF315C46),
            borderStrokeWidth: isSelected ? 2.5 : 1.3,
            hitValue: polygon.hitValue,
          );
        }).toList();

        return Stack(
          children: [
            FlutterMap(
              options: const MapOptions(
                initialCenter: taiwanCenter,
                initialZoom: 7.5,
                minZoom: 5,
                maxZoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://basemaps.cartocdn.com/rastertiles/'
                      'voyager_nolabels/{z}/{x}/{y}.png?key=$cartoKey',
                  userAgentPackageName:
                      'com.nathanlu.wildlifecommunitylocator',
                ),

                GestureDetector( // Detect pointer hits 
                  onTap: () {
                    final hits = hitNotifier.value?.hitValues;

                    if (hits == null || hits.isEmpty) return;

                    setState(() {
                      selectedRegion = hits.first;
                    });
                  },
                  child: PolygonLayer<String>( // Render Geographic Polygons
                    polygons: displayedPolygons,
                    hitNotifier: hitNotifier,
                    simplificationTolerance: 0.5,
                  ),
                ),

                const SimpleAttributionWidget(
                  source: Text(
                    '© OpenStreetMap contributors, © CARTO',
                  ),
                ),
              ],
            ),

            // Display selected county region
            if (selectedRegion != null)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: RegionalSightingsPanel(
                  regionName: selectedRegion!,
                  sightings: getSightingsForRegion(selectedRegion!),
                  onClose: () {
                    setState(() {
                      selectedRegion = null;
                    });
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}