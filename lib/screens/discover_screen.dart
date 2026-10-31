
import 'package:flutter/material.dart';

import '../models/species.dart';
import '../models/discovery_filter.dart';
import '../data/sample_species.dart';

class DiscoverScreen extends StatefulWidget {
  final ValueChanged<DiscoveryFilter> onExplore;

  const DiscoverScreen({
    super.key,
    required this.onExplore,
  });

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String searchQuery = '';
  AnimalCategory? selectedCategory;

  List<Species> get visibleSpecies {
    return sampleSpecies.where((species) {
      final matchesCategory =
          selectedCategory == null ||
          species.category == selectedCategory;

      final query = searchQuery.toLowerCase();

      final matchesSearch =
          species.commonName.toLowerCase().contains(query) ||
          species.scientificName.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _selectCategory(AnimalCategory? category) {
    setState(() {
      selectedCategory = category;
    });
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          label: const Text('All'),
          selected: selectedCategory == null,
          onSelected: (_) => _selectCategory(null),
        ),
        ...AnimalCategory.values.map((category) {
          return ChoiceChip(
            label: Text(category.label),
            selected: selectedCategory == category,
            onSelected: (_) => _selectCategory(category),
          );
        }),
      ],
    );
  }

  Widget _buildSpeciesList() {
    if (visibleSpecies.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text('No matching species found.'),
        ),
      );
    }

    return Column(
      children: visibleSpecies.map((species) {
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.pets),
            ),
            title: Text(species.commonName),
            subtitle: Text(
              '${species.scientificName}\n'
              '${species.category.label}',
            ),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              widget.onExplore(
                DiscoveryFilter(speciesId: species.id),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Discover Wildlife',
            style: Theme.of(context).textTheme.headlineMedium,
          ),

          const SizedBox(height: 8),

          const Text(
            'Explore wildlife species found across Taiwan.',
          ),

          const SizedBox(height: 20),

          TextField(
            decoration: const InputDecoration(
              hintText: 'Search species...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value.trim();
              });
            },
          ),

          const SizedBox(height: 24),

          Text(
            'Browse by category',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 12),

          _buildCategorySelector(),

          const SizedBox(height: 12),

          if (selectedCategory != null)
            FilledButton.icon(
              onPressed: () {
                widget.onExplore(
                  DiscoveryFilter(category: selectedCategory),
                );
              },
              icon: const Icon(Icons.map),
              label: Text(
                'View ${selectedCategory!.label} on Map',
              ),
            ),

          const SizedBox(height: 24),

          Text(
            'Species',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 12),

          _buildSpeciesList(),
        ],
      ),
    );
  }
}
