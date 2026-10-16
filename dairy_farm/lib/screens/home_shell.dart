import 'package:flutter/material.dart';

import 'animals_screen.dart';
import 'backup_screen.dart';
import 'dashboard_screen.dart';
import 'finance_screen.dart';
import 'milk_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  // Har tab badalne par screen dobara bunti hai, is liye data hamesha fresh hota hai
  Widget _page() {
    switch (_index) {
      case 0:
        return DashboardScreen(onGoTo: (i) => setState(() => _index = i));
      case 1:
        return const AnimalsScreen();
      case 2:
        return const MilkScreen();
      case 3:
        return const FinanceScreen();
      default:
        return const BackupScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _page(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.pets_outlined), selectedIcon: Icon(Icons.pets), label: 'Animals'),
          NavigationDestination(icon: Icon(Icons.water_drop_outlined), selectedIcon: Icon(Icons.water_drop), label: 'Milk'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Finance'),
          NavigationDestination(icon: Icon(Icons.cloud_outlined), selectedIcon: Icon(Icons.cloud), label: 'Backup'),
        ],
      ),
    );
  }
}
