// Build Discover section UI
import 'package:flutter/material.dart';

import '../models/species.dart';
import '../models/discovery_filter.dart';
import '../data/sample_species.dart';

import '../utils/category_style.dart';

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
        // All categories
        ChoiceChip(
          label: const Text('All'),
          selected: selectedCategory == null,
          onSelected: (_) => _selectCategory(null),
        ),

        // Individual animal categories
        ...AnimalCategory.values.map((category) {
          return ChoiceChip(
            avatar: Icon(
              CategoryStyle.icon(category),
              size: 18,
              color: CategoryStyle.color(category),
            ),
            label: Text(category.label),
            selected: selectedCategory == category,
            selectedColor:
                CategoryStyle.color(category).withValues(alpha: 0.15),
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
            leading: CircleAvatar(
              backgroundColor:
                  CategoryStyle.color(species.category).withValues(alpha: 0.15),
              child: Icon(
                CategoryStyle.icon(species.category),
                color: CategoryStyle.color(species.category),
              ),
            ),
            title: Text(species.commonName),
            subtitle: Text(
              '${species.scientificName}\n'
              '${species.category.label}',
            ),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right),
            onTap: () { // Selecting a species creates the filter for it and passes through onExplore
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

          // Species search field
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
