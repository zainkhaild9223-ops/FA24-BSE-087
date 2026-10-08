import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/home_screen.dart';
import 'screens/intro_flow.dart';
import 'screens/main_tabs.dart';

void main() => runApp(const MedicalHistoryApp());

class MedicalHistoryApp extends StatelessWidget {
  const MedicalHistoryApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'My Medical History',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const SplashScreen(),
      );
}

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int i = 0;
  @override
  Widget build(BuildContext context) {
    const pages = <Widget>[HomeScreen(), DoctorsScreen(), HistoryScreen(), ReportsScreen(), SettingsScreen()];
    return Scaffold(
      body: IndexedStack(index: i, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: i,
        onTap: (v) => setState(() => i = v),
        type: BottomNavigationBarType.fixed,
        backgroundColor: C.bg,
        selectedItemColor: C.primary,
        unselectedItemColor: C.ink,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.medical_services_outlined), label: 'Doctors'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}
