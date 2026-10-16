import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../services/taiwan_regions.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  static const taiwanCenter = LatLng(23.7, 120.96);

  late final Future<List<Polygon<String>>> regionsFuture;

  final LayerHitNotifier<String> hitNotifier = ValueNotifier(null);

  String? selectedRegion;

  @override
  void initState() {
    super.initState();
    regionsFuture = TaiwanRegions.load();
  }

  @override
  void dispose() {
    hitNotifier.dispose();
    super.dispose();
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
          final isSelected = polygon.hitValue == selectedRegion;

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

                GestureDetector(
                  onTap: () {
                    final hits = hitNotifier.value?.hitValues;

                    if (hits == null || hits.isEmpty) return;

                    setState(() {
                      selectedRegion = hits.first;
                    });
                  },
                  child: PolygonLayer<String>(
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

            if (selectedRegion != null)
              Positioned(
                left: 16,
                right: 16,
                bottom: 20,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.place_outlined),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            selectedRegion!,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              selectedRegion = null;
                            });
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}