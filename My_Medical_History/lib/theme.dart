import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class C {
  static const primary = Color(0xFF005A92);
  static const bg = Color(0xFFF8F9FF);
  static const ink = Color(0xFF0B1C30);
  static const muted = Color(0xFF5B6B7F);
  static const lav = Color(0xFFEAF0FF);
  static const lav2 = Color(0xFFDCE5FF);
  static const blueChip = Color(0xFFCFE5FF);
  static const mint = Color(0xFF6FFBBE);
  static const green = Color(0xFF006C4A);
  static const red = Color(0xFFBA1A1A);
  static const border = Color(0xFFE1E8F5);
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: C.primary),
    scaffoldBackgroundColor: C.bg,
  );
  return base.copyWith(
    textTheme: GoogleFonts.interTextTheme(base.textTheme)
        .apply(bodyColor: C.ink, displayColor: C.ink),
  );
}
