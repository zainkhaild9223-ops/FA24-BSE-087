import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const kGreen = Color(0xFF2E7D32);
const kLightGreen = Color(0xFFE8F5E9);
const kAmber = Color(0xFFFFB300);
const kBg = Color(0xFFFAFAFA);
const kRed = Color(0xFFD32F2F);

final _df = DateFormat('yyyy-MM-dd');
String fmtDate(DateTime d) => _df.format(d);
String todayStr() => fmtDate(DateTime.now());
String monthPrefix(DateTime d) => DateFormat('yyyy-MM').format(d);
String pkr(num v) => 'PKR ${NumberFormat('#,##0').format(v)}';
String liters(num v) => '${v.toStringAsFixed(1)} L';

String ageText(String? dob) {
  if (dob == null || dob.isEmpty) return '-';
  final d = DateTime.tryParse(dob);
  if (d == null) return '-';
  final months = (DateTime.now().year - d.year) * 12 + DateTime.now().month - d.month;
  if (months < 12) return '$months mo';
  return '${(months / 12).toStringAsFixed(1)} yrs';
}

ThemeData buildTheme() {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide.none,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: kGreen, primary: kGreen),
    scaffoldBackgroundColor: kBg,
    appBarTheme: const AppBarTheme(
      backgroundColor: kGreen,
      foregroundColor: Colors.white,
      centerTitle: false,
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade200,
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kRed),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kGreen,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: kAmber,
      foregroundColor: Colors.black,
    ),
    navigationBarTheme: const NavigationBarThemeData(
      indicatorColor: kLightGreen,
      backgroundColor: Colors.white,
    ),
  );
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? color;
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      color: color ?? Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;
  const EmptyState({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 72, color: Colors.green.shade200),
            const SizedBox(height: 12),
            Text(text, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          ]),
        ),
      );
}

void snack(BuildContext c, String m, {bool error = false}) {
  ScaffoldMessenger.of(c)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(m),
      backgroundColor: error ? kRed : kGreen,
      behavior: SnackBarBehavior.floating,
    ));
}

Future<bool> confirmDialog(BuildContext c, String title, String msg,
    {String yes = 'Delete', Color color = kRed}) async {
  final r = await showDialog<bool>(
    context: c,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(msg),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: color),
          onPressed: () => Navigator.pop(c, true),
          child: Text(yes),
        ),
      ],
    ),
  );
  return r ?? false;
}

Future<String?> pickDate(BuildContext c, String? initial) async {
  final init = DateTime.tryParse(initial ?? '') ?? DateTime.now();
  final d = await showDatePicker(
    context: c,
    initialDate: init,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );
  return d == null ? null : fmtDate(d);
}
