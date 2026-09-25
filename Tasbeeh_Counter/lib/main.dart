// main.dart
// Flutter UI wrapper around the Tasbeeh OOP engine (tasbeeh.dart)

import 'package:flutter/material.dart';
import 'tasbeeh.dart';

void main() {
  runApp(const TasbeehApp());
}

class TasbeehApp extends StatelessWidget {
  const TasbeehApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Tasbeeh Counter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF3F6F5),
      ),
      home: const TasbeehHomePage(),
    );
  }
}

class TasbeehHomePage extends StatefulWidget {
  const TasbeehHomePage({super.key});

  @override
  State<TasbeehHomePage> createState() => _TasbeehHomePageState();
}

class _TasbeehHomePageState extends State<TasbeehHomePage> {
  // Preset engines built with the named constructors
  final List<Tasbeeh> _presets = [
    Tasbeeh.subhanAllah(),
    Tasbeeh.alhamdulillah(),
    Tasbeeh.allahAkbar(),
    Tasbeeh(name: "Astaghfirullah", target: 33), // default constructor
  ];

  int _selectedIndex = 0;

  Tasbeeh get _active => _presets[_selectedIndex];

  void _onIncrement() {
    setState(() {
      _active.increment();
    });

    if (_active.isCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Target Reached for ${_active.dhikrName}!"),
          backgroundColor: Colors.teal,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _onReset() {
    setState(() {
      _active.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress =
    _active.target == 0 ? 0.0 : _active.counter / _active.target;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Digital Tasbeeh Counter"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Dhikr selector chips
            Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: List.generate(_presets.length, (i) {
                  final t = _presets[i];
                  final selected = i == _selectedIndex;
                  return ChoiceChip(
                    label: Text(t.dhikrName),
                    selected: selected,
                    selectedColor: Colors.teal,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                    ),
                    onSelected: (_) => setState(() => _selectedIndex = i),
                  );
                }),
              ),
            ),

            const Spacer(),

            // Counter circle — tap anywhere on the circle to increment
            GestureDetector(
              onTap: _onIncrement,
              behavior: HitTestBehavior.opaque,
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: _onIncrement,
                  customBorder: const CircleBorder(),
                  splashColor: Colors.teal.withOpacity(0.3),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 220,
                        height: 220,
                        child: CircularProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          strokeWidth: 10,
                          backgroundColor: Colors.teal.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _active.isCompleted ? Colors.green : Colors.teal,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${_active.counter}",
                            style: const TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          Text(
                            "/ ${_active.target}",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "tap circle",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Text(
              _active.dhikrName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (_active.isCompleted)
              const Text(
                "🎉 Target Completed",
                style: TextStyle(color: Colors.green, fontSize: 16),
              ),

            const Spacer(),

            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _onReset,
                      icon: const Icon(Icons.refresh),
                      label: const Text("Reset"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _onIncrement,
                      icon: const Icon(Icons.touch_app),
                      label: const Text("Tap to Count"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}