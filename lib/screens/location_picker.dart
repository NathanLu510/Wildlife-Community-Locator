
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const LocationPickerScreen({
    super.key,
    this.initialLocation,
  });

  @override
  State<LocationPickerScreen> createState() =>
      _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final MapController _mapController = MapController();

  LatLng? selectedLocation;
  bool isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    selectedLocation = widget.initialLocation;
  }

  Future<void> _useCurrentLocation() async {
    setState(() => isLoadingLocation = true);

    try {
      final enabled = await Geolocator.isLocationServiceEnabled();

      if (!enabled) {
        throw Exception('Please enable device location services.');
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission is unavailable.');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      final location = LatLng(
        position.latitude,
        position.longitude,
      );

      setState(() => selectedLocation = location);
      _mapController.move(location, 16);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => isLoadingLocation = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Sighting Location'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter:
                  widget.initialLocation ?? const LatLng(23.7, 120.96),
              initialZoom: widget.initialLocation == null ? 7 : 15,
              onTap: (tapPosition, point) {
                setState(() {
                  selectedLocation = point;
                });
              },
            ),
            children: [
              // Replace this with the tile layer used by ExploreScreen.
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.wildlife_locator',
              ),

              if (selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: selectedLocation!,
                      width: 48,
                      height: 48,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 44,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'currentLocation',
              onPressed:
                  isLoadingLocation ? null : _useCurrentLocation,
              child: isLoadingLocation
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.my_location),
            ),
          ),

          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: SafeArea(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedLocation == null
                            ? 'Tap the map to select a location'
                            : 'Location selected',
                      ),

                      const SizedBox(height: 12),

                      FilledButton.icon(
                        onPressed: selectedLocation == null
                            ? null
                            : () {
                                Navigator.pop(
                                  context,
                                  selectedLocation,
                                );
                              },
                        icon: const Icon(Icons.check),
                        label: const Text('Confirm Location'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
