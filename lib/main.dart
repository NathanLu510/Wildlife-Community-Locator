import 'package:flutter/material.dart';

import 'screens/explore_screen.dart';
import 'screens/add_sighting_screen.dart';
import 'screens/discover_screen.dart';
import 'screens/profile_screen.dart';

import 'widgets/bottom_navigation.dart';

void main() {
  runApp(const WildlifeApp());
}

class WildlifeApp extends StatelessWidget {
  const WildlifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wildlife Community Locator',
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

  final List<Widget> screens = const [
    ExploreScreen(),
    AddSightingScreen(),
    DiscoverScreen(),
    ProfileScreen(),
  ];

  void changeScreen(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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