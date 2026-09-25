// tasbeeh.dart
// Digital Tasbeeh Counter Engine — OOP Backend Logic
// CSC303 - Mobile Application Development | Unit 2 / Week 5

// -----------------------------------------------------------
// 4. MIXIN — reusable behaviour that can be "mixed in" to any class
// -----------------------------------------------------------
mixin NotificationMixin {
  void triggerVibration() {
    print("📳 [VIBRATION]: Target Completed!");
  }
}

// -----------------------------------------------------------
// 1. CLASS & ENCAPSULATION
// -----------------------------------------------------------
class Tasbeeh with NotificationMixin {
  // Private fields — cannot be modified directly from outside the class
  String _dhikrName;
  int _counter;
  int _target;

  // ---------------------------------------------------------
  // 2. CONSTRUCTORS
  // ---------------------------------------------------------

  // Default constructor — name is required, target defaults to 33
  Tasbeeh({required String name, int target = 33})
      : _dhikrName = name,
        _counter = 0,
        _target = target;

  // Named constructors — quick presets for common adhkar
  Tasbeeh.subhanAllah()
      : _dhikrName = "SubhanAllah",
        _counter = 0,
        _target = 33;

  Tasbeeh.alhamdulillah()
      : _dhikrName = "Alhamdulillah",
        _counter = 0,
        _target = 33;

  Tasbeeh.allahAkbar()
      : _dhikrName = "Allahu Akbar",
        _counter = 0,
        _target = 33;

  // ---------------------------------------------------------
  // Getters — read-only access to private fields
  // ---------------------------------------------------------
  String get dhikrName => _dhikrName;
  int get counter => _counter;
  int get target => _target;

  // Boolean getter — checks completion state
  bool get isCompleted => _counter >= _target;

  // ---------------------------------------------------------
  // 3. METHODS & LOGIC
  // ---------------------------------------------------------

  /// Increments the counter by 1. Prevents overflow past target and
  /// fires a notification + vibration once the target is reached.
  void increment() {
    if (_counter < _target) {
      _counter++;
    }
    if (_counter == _target) {
      print("Target Reached for $_dhikrName!");
      triggerVibration(); // from NotificationMixin
    }
  }

  /// Resets the counter back to zero (e.g. starting a new set).
  void reset() {
    _counter = 0;
  }

  @override
  String toString() =>
      "Tasbeeh($_dhikrName: $_counter / $_target)";
}