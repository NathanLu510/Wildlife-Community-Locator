import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TaiwanRegions {
  static Future<List<Polygon<String>>> load() async {
    final jsonString = await rootBundle.loadString(
      'assets/geo/taiwan_counties.geojson',
    );

    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final features = data['features'] as List<dynamic>;

    final polygons = <Polygon<String>>[];

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

      final type = geometry['type'] as String;
      final coordinates = geometry['coordinates'] as List<dynamic>;

      if (type == 'Polygon') {
        _addPolygon(polygons, coordinates, name);
      } else if (type == 'MultiPolygon') {
        for (final polygonCoordinates in coordinates) {
          _addPolygon(
            polygons,
            polygonCoordinates as List<dynamic>,
            name,
          );
        }
      }
    }

    return polygons;
  }

  static void _addPolygon(
    List<Polygon<String>> result,
    List<dynamic> rings,
    String name,
  ) {
    List<LatLng> convertRing(dynamic ring) {
      return (ring as List<dynamic>).map((point) {
        final coordinate = point as List<dynamic>;

        return LatLng(
          (coordinate[1] as num).toDouble(),
          (coordinate[0] as num).toDouble(),
        );
      }).toList();
    }

    if (rings.isEmpty) return;

    final outerRing = convertRing(rings.first);

    final holes = rings
        .skip(1)
        .map(convertRing)
        .toList();

    result.add(
      Polygon<String>(
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