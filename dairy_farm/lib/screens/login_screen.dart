import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common.dart';
import 'home_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  SharedPreferences? _prefs;
  String _pin = '';
  String? _firstPin; // set-PIN mode mein pehla PIN
  String? _error;

  bool get _hasPin => _prefs?.getString('pin') != null;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) => setState(() => _prefs = p));
  }

  String get _title {
    if (!_hasPin) return _firstPin == null ? 'Set your PIN' : 'Confirm your PIN';
    return 'Welcome to Dairy Farm';
  }

  String get _subtitle {
    if (!_hasPin) {
      return _firstPin == null
          ? 'Choose a 4-digit PIN to protect your data'
          : 'Enter the same PIN again';
    }
    return 'Enter your 4-digit security PIN to unlock';
  }

  void _press(String d) {
    if (_pin.length >= 4) return;
    setState(() {
      _pin += d;
      _error = null;
    });
    if (_pin.length == 4) Future.delayed(const Duration(milliseconds: 150), _submit);
  }

  void _back() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _submit() async {
    final prefs = _prefs!;
    if (_hasPin) {
      if (prefs.getString('pin') == _pin) {
        _enter();
      } else {
        setState(() {
          _pin = '';
          _error = 'Wrong PIN, try again';
        });
      }
      return;
    }
    if (_firstPin == null) {
      setState(() {
        _firstPin = _pin;
        _pin = '';
      });
    } else if (_firstPin == _pin) {
      await prefs.setString('pin', _pin);
      _enter();
    } else {
      setState(() {
        _firstPin = null;
        _pin = '';
        _error = 'PINs did not match, start again';
      });
    }
  }

  void _enter() {
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const HomeShell()));
  }

  @override
  Widget build(BuildContext context) {
    if (_prefs == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF7),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration:
                    const BoxDecoration(color: kLightGreen, shape: BoxShape.circle),
                child: const Icon(Icons.agriculture, size: 56, color: kGreen),
              ),
              const SizedBox(height: 16),
              Text(_title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(_subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Chip(
                avatar: const Icon(Icons.cloud_off, size: 16, color: kGreen),
                label: const Text('Offline Mode Active • Local DB'),
                backgroundColor: kLightGreen,
                side: BorderSide.none,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (i) => Container(
                    margin: const EdgeInsets.all(8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < _pin.length ? kGreen : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 24,
                child: _error == null
                    ? null
                    : Text(_error!, style: const TextStyle(color: kRed)),
              ),
              const SizedBox(height: 8),
              _keypad(),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _keypad() {
    Widget key(String label, {VoidCallback? onTap, IconData? icon}) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Material(
          color: Colors.grey.shade100,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 68,
              height: 68,
              child: Center(
                child: icon != null
                    ? Icon(icon, color: kGreen)
                    : Text(label,
                        style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ),
      );
    }

    Widget row(List<String> d) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: d.map((x) => key(x, onTap: () => _press(x))).toList(),
        );

    return Column(children: [
      row(['1', '2', '3']),
      row(['4', '5', '6']),
      row(['7', '8', '9']),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const SizedBox(width: 84, height: 84),
        key('0', onTap: () => _press('0')),
        key('', icon: Icons.backspace_outlined, onTap: _back),
      ]),
    ]);
  }
}
