import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  final Widget child;
  const HomeScreen({super.key, required this.child});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/scanner');
        break;
      case 2:
        context.go('/records'); // Placeholder
        break;
      case 3:
        context.go('/map'); // Placeholder
        break;
      case 4:
        context.go('/shop'); // Placeholder (Paywall for now)
        break;
    }
  }

  // Helper to sync index with route
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/scanner')) return 1;
    if (location.startsWith('/records')) return 2;
    if (location.startsWith('/map')) return 3;
    if (location.startsWith('/shop')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.health_and_safety_outlined), selectedIcon: Icon(Icons.health_and_safety), label: 'Scanner'),
          NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'Records'),
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Map'),
          NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), selectedIcon: Icon(Icons.shopping_bag), label: 'Shop'),
        ],
      ),
    );
  }
}
