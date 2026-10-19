import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TaiwanRegions {
  static Future<List<Polygon<String>>> load() async {

    // Access packaged files listed in pubspec.yaml
    // 'await' is used as reading asset is asynchronous
    final jsonString = await rootBundle.loadString(
      'assets/geo/taiwan_counties.geojson',
    );

    final data = jsonDecode(jsonString) as Map<String, dynamic>; // Convert JSON text into Dart objects
    final features = data['features'] as List<dynamic>; // Extract features 

    final polygons = <Polygon<String>>[];

    // Extract each county's name in 'properties' and polygon in 'geometry'
    for (final feature in features) {
      final properties =
          feature['properties'] as Map<String, dynamic>;

      final geometry =
          feature['geometry'] as Map<String, dynamic>;

      // Adjust this field after inspecting your GeoJSON properties.
      final name = (properties['COUNTYNAME'] ??
              properties['name'] ??
              properties['NAME'] ??
              'Unknown region')
          .toString();

      // Extract geometry type and check if its a Polygon or MultiPolygon
      // Polygons are processed once, MultiPolygons are processed separately
      final type = geometry['type'] as String;
      final coordinates = geometry['coordinates'] as List<dynamic>;
      
      if (type == 'Polygon') {
        _addPolygon(polygons, coordinates, name);
      } else if (type == 'MultiPolygon') {
        for (final polygonCoordinates in coordinates) {
          _addPolygon(
            polygons,
            polygonCoordinates as List<dynamic>, // List of Coordinates for polygons (offshore islands) in same county
            name,
          );
        }
      }
    }

    return polygons;
  }
  // Function that converts GeoJSON coordinates into LatLng objects
 // GeoJSON uses [121.5, 25.0] Flutter uses LatLng(25.0, 121.5)
  static void _addPolygon(
    List<Polygon<String>> result,
    List<dynamic> rings,
    String name,
  ) {
    List<LatLng> convertRing(dynamic ring) {
      return (ring as List<dynamic>).map((point) {
        final coordinate = point as List<dynamic>;

        return LatLng( // Reverse to fit GeoJSON to Flutter LatLng
          (coordinate[1] as num).toDouble(),
          (coordinate[0] as num).toDouble(),
        );
      }).toList();
    }
    // Rings are ordered sequence of points
    if (rings.isEmpty) return;

    final outerRing = convertRing(rings.first);

    final holes = rings
        .skip(1)
        .map(convertRing)
        .toList();

    result.add(
      Polygon<String>( // Creating a polygon with the following properties
        points: outerRing,
        holePointsList: holes.isEmpty ? null : holes,
        color: Colors.transparent,
        borderColor: const Color(0xFF315C46),
        borderStrokeWidth: 1.3,
        hitValue: name,
      ),
    );
  }
}