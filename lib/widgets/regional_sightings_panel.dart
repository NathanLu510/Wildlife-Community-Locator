
import 'package:flutter/material.dart';

import '../models/sighting.dart';

import 'sighting_image.dart';

import '../utils/category_style.dart';
import '../utils/sighting_category.dart';

class RegionalSightingsPanel extends StatelessWidget {
  final String regionName;
  final List<Sighting> sightings;
  final VoidCallback onClose;
  final ValueChanged<Sighting> onSightSelected;


  const RegionalSightingsPanel({
    super.key,
    required this.regionName,
    required this.sightings,
    required this.onClose,
    required this.onSightSelected
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 4,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 300),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    regionName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
              ],
            ),

            Text('${sightings.length} wildlife sightings'),

            const SizedBox(height: 8),

            if (sightings.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No wildlife sightings recorded in this region.',
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: sightings.length,
                  
                  itemBuilder: (context, index) {
                    final sighting = sightings[index];

                    // Identify the category of this sighting
                    final category = getSightingCategory(sighting);

                    return ListTile(
                      // Sighting photograph
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SightingImage(
                          sighting: sighting,
                          width: 56,
                          height: 56,
                        ),
                      ),

                      // Species name with category icon
                      title: Row(
                        children: [
                          if (category != null) ...[
                            Icon(
                              CategoryStyle.icon(category),
                              color: CategoryStyle.color(category),
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                          ],

                          Expanded(
                            child: Text(
                              sighting.speciesName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      subtitle: Text(
                        '${sighting.observedAt.day}/'
                        '${sighting.observedAt.month}/'
                        '${sighting.observedAt.year}\n'
                        '${sighting.description}',
                      ),

                      isThreeLine: true,

                      trailing: const Icon(Icons.chevron_right),

                      onTap: () {
                        onSightSelected(sighting);
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
