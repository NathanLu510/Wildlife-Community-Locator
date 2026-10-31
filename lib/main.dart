import 'package:flutter/material.dart';

import 'screens/explore_screen.dart';
import 'screens/add_sighting_screen.dart';
import 'screens/discover_screen.dart';
import 'screens/profile_screen.dart';

import 'widgets/bottom_navigation.dart';


import 'models/discovery_filter.dart';



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

  DiscoveryFilter activeFilter = const DiscoveryFilter();

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

  @override


  Widget build(BuildContext context) {
// Build screens using the current state
    final List<Widget> screens = [
      ExploreScreen(
        filter: activeFilter,
        onClearFilter: _clearFilter,
      ),

      const AddSightingScreen(),

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