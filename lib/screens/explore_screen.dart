import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../services/taiwan_regions.dart';

import '../models/sighting.dart';
import '../data/sample_sightings.dart';

import '../widgets/regional_sightings_panel.dart';

import '../widgets/sighting_marker.dart';
import '../widgets/sighting_details.dart';

import '../models/discovery_filter.dart';
import '../data/sample_species.dart';


class ExploreScreen extends StatefulWidget {

  // Recieve filters from discovery
  final DiscoveryFilter filter; 
  final VoidCallback? onClearFilter;

  const ExploreScreen({
    super.key,
    this.filter = const DiscoveryFilter(),
    this.onClearFilter,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {

  static const taiwanCenter = LatLng(23.7, 120.96);

  static const cartoKey = String.fromEnvironment('CARTO_API_KEY');
  // Initialising with Future handles asynchronisation
  // If assets are loading or when they can't be loaded
  late final Future<List<Polygon<String>>> regionsFuture;

  // Stores information hit by pointer interactions
  final LayerHitNotifier<String> hitNotifier = ValueNotifier(null);

  final MapController mapController = MapController();

  // Selectable variables
  String? selectedRegion;
  Sighting? selectedSighting;

  List<Sighting> get filteredSightings {
    return sampleSightings.where((sighting) {
      return widget.filter.matches(sighting, sampleSpecies);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    regionsFuture = TaiwanRegions.load(); // From taiwan_regions.dart
  }

  @override
  void dispose() {
    hitNotifier.dispose();
    mapController.dispose();
    super.dispose();
  }

  // Function that filters sightings relative to region
  List<Sighting> getSightingsForRegion(String region) {
    return filteredSightings.where((sighting) {
      return sighting.regionId == region;
    }).toList();
  }

  List<Polygon<String>> _getDisplayedPolygons(
    List<Polygon<String>> polygons,
  ) {
    return polygons.map((polygon) {
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
  }

  // Moves map to centre selected observation
  void _focusOnSighting(Sighting sighting) {
    _selectSighting(sighting);

    mapController.move(
      LatLng(sighting.latitude, sighting.longitude),
      10.0,
    );
  }
  // --------------------------------------------------
  // USER INTERACTION METHODS
  // --------------------------------------------------

  // Region Selection
  void _selectRegion() {
    final hits = hitNotifier.value?.hitValues;

    if (hits == null || hits.isEmpty) return;

    setState(() {
      selectedRegion = hits.first;
      selectedSighting = null;
    });
  }

  // Sighting Selection
  void _selectSighting(Sighting sighting) {
    setState(() {
      selectedSighting = sighting;
      selectedRegion = null;
    });
  }

  // Clearing Selection
  void _clearSelection() {
    setState(() {
      selectedRegion = null;
      selectedSighting = null;
    });
  }

  // --------------------------------------------------
  // MAP BUILDING METHODS
  // --------------------------------------------------

  Widget _buildTileLayer() {
    return TileLayer(
      urlTemplate:
          'https://basemaps.cartocdn.com/rastertiles/'
          'voyager_nolabels/{z}/{x}/{y}.png?key=$cartoKey',
      userAgentPackageName:
          'com.nathanlu.wildlifecommunitylocator',
    );
  }

  Widget _buildPolygonLayer(
    List<Polygon<String>> polygons,
  ) {
    return GestureDetector(
      onTap: _selectRegion,
      child: PolygonLayer<String>(
        polygons: _getDisplayedPolygons(polygons),
        hitNotifier: hitNotifier,
        simplificationTolerance: 0.5,
      ),
    );
  }

  Widget _buildMarkerLayer() {
    return MarkerLayer(
      markers: filteredSightings.map((sighting) {
        return Marker(
          point: LatLng(
            sighting.latitude,
            sighting.longitude,
          ),
          width: 42,
          height: 42,
          child: SightingMarker(
            isSelected: selectedSighting?.id == sighting.id,
            onTap: () => _selectSighting(sighting),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMap(List<Polygon<String>> polygons) {
    return FlutterMap(
      mapController: mapController,

      options: const MapOptions(
        initialCenter: taiwanCenter,
        initialZoom: 7.5,
        minZoom: 5,
        maxZoom: 13,
      ),
      children: [
        _buildTileLayer(),
        _buildPolygonLayer(polygons),
        _buildMarkerLayer(),
        const SimpleAttributionWidget(
          source: Text(
            '© OpenStreetMap contributors, © CARTO',
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // BUILD INFORMATION PANEL
  // --------------------------------------------------

  Widget _buildInformationPanel() {
    if (selectedSighting != null) {
      return Positioned(
        left: 12,
        right: 12,
        bottom: 12,
        child: SightingDetailsCard(
          sighting: selectedSighting!,
          onClose: _clearSelection,
        ),
      );
    }

    if (selectedRegion != null) {
      return Positioned(
        left: 12,
        right: 12,
        bottom: 12,
        child: RegionalSightingsPanel(
          regionName: selectedRegion!,
          sightings: getSightingsForRegion(selectedRegion!),
          onClose: _clearSelection,
          onSightSelected: _focusOnSighting,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // --------------------------------------------------
  // MAIN BUILD METHOD
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Polygon<String>>>(
      future: regionsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Failed to load regions: ${snapshot.error}',
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        return Stack(
          children: [
            _buildMap(snapshot.data!), // Builds tile layer, polygon layer, and marker layer first
            _buildInformationPanel(), // Manages panel display
                // Display clear button when a filter is active
            if (widget.filter.category != null ||
                widget.filter.speciesId != null)
              Positioned(
                top: 12,
                left: 12,
                child: ActionChip(
                  avatar: const Icon(Icons.close, size: 18),
                  label: const Text('Clear filter'),
                  onPressed: widget.onClearFilter,
                ),
              ),
          ],
        );
      },
    );
  }
}