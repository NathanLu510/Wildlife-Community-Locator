import 'package:flutter/material.dart';

import 'screens/explore_screen.dart';
import 'screens/add_sighting_screen.dart';
import 'screens/discover_screen.dart';
import 'screens/profile_screen.dart';

import 'widgets/bottom_navigation.dart';


import 'models/discovery_filter.dart';
import 'models/sighting.dart';

import 'data/sample_sightings.dart';


void main() {
  runApp(const WildlifeApp());
}

class WildlifeApp extends StatelessWidget {
  const WildlifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wildlife Community Locator',
      showPerformanceOverlay: false,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}


class _MainScreenState extends State<MainScreen> {

  int selectedIndex = 0;

  // Store currently selected wildlife filter
  DiscoveryFilter activeFilter = const DiscoveryFilter();

  // Shared list of wildlife sightings
  late final List<Sighting> sightings = List<Sighting>.of(sampleSightings);

  // Called when Discover requests a filtered map
  void _exploreWithFilter(DiscoveryFilter filter) {
    setState(() {
      activeFilter = filter;
      selectedIndex = 0;
    });
  }

  // Called when user selects a bottom navigation tab
  void changeScreen(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  // Called when user clears the Explore filter
  void _clearFilter() {
    setState(() {
      activeFilter = const DiscoveryFilter();
    });
  }

  // Add sighting to shared list
  void _addSighting(Sighting sighting) {
    setState(() {
      sightings.add(sighting);

      // Clear filters so the new sighting isn't hidden
      activeFilter = const DiscoveryFilter();

      // Return to Explore
      selectedIndex = 0;
    });
  }

  @override


  Widget build(BuildContext context) {
    // Build screens using the current state
    final List<Widget> screens = [
      ExploreScreen(
        sightings: sightings,
        filter: activeFilter,
        onClearFilter: _clearFilter,
      ),

      AddSightingScreen(
        onSightingAdded: _addSighting,
      ),

      DiscoverScreen(
        onExplore: _exploreWithFilter,
      ),

      const ProfileScreen(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wildlife Community Locator'),
      ),

      body: screens[selectedIndex],

      bottomNavigationBar: BottomNavigation(
        selectedIndex: selectedIndex,
        onDestinationSelected: changeScreen,
      ),
    );
  }
}