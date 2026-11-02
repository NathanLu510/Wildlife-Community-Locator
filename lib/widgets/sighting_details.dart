// Displays sighting model information as a card

import 'package:flutter/material.dart';
import '../models/sighting.dart';
import '../services/navigation_service.dart';

import 'sighting_image.dart';


class SightingDetailsCard extends StatelessWidget {
  final Sighting sighting;
  final VoidCallback onClose;

  const SightingDetailsCard({
    super.key,
    required this.sighting,
    required this.onClose,
  });
  
  
  @override
  Widget build(BuildContext context) {
    final date = sighting.observedAt;

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pets, color: Colors.green),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    sighting.speciesName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SightingImage(
                sighting: sighting,
                width: double.infinity,
                height: 180,
              ),
            ),

            const SizedBox(height: 4),

            if (sighting.imageAsset != null)
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Illustrative species photograph',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ),

            const SizedBox(height: 12),
            const SizedBox(height: 8),

            Text('Region: ${sighting.regionId}'),

            Text(
              'Observed: ${date.day}/${date.month}/${date.year}',
            ),

            const SizedBox(height: 8),

            Text(sighting.description),

            
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  final launched = await NavigationService.navigateTo(
                    latitude: sighting.latitude,
                    longitude: sighting.longitude,
                  );

                  if (!launched && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Unable to open Google Maps.'),
                      ),
                    );
                  }
                } catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Unable to open navigation.'),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.directions),
              label: const Text('Locate'),
            )

          ],
        ),
      ),
    );
  }
}
