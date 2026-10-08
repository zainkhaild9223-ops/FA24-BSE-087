import 'dart:async';
import 'package:flutter/material.dart';

// ───────── Design tokens ─────────
const kBlue = Color(0xFF2563EB);
const kBg = Color(0xFFF6F8FC);
const kInk = Color(0xFF0F172A);
const kMuted = Color(0xFF64748B);
const kGreen = Color(0xFF10B981);
const kAmber = Color(0xFFF59E0B);
const kRed = Color(0xFFEF4444);

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'My Medical History',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: kBlue, surface: Colors.white),
      scaffoldBackgroundColor: kBg,
      appBarTheme: const AppBarTheme(
          backgroundColor: kBg, elevation: 0, scrolledUnderElevation: 0,
          foregroundColor: kInk, centerTitle: false,
          titleTextStyle: TextStyle(color: kInk, fontSize: 22, fontWeight: FontWeight.w700)),
      navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white, indicatorColor: kBlue.withOpacity(.12), height: 68),
      inputDecorationTheme: const InputDecorationTheme(
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
      visualDensity: VisualDensity.standard,
    ),
    home: const SplashScreen(),
  );
}

// ───────── Mock data ─────────
class Doctor {
  final String name, spec, hospital, phone;
  final int visits;
  const Doctor(this.name, this.spec, this.hospital, this.phone, this.visits);
}

class Visit {
  final String date, doctor, hospital, dx;
  final int meds, tests;
  const Visit(this.date, this.doctor, this.hospital, this.dx, this.meds, this.tests);
}

const doctors = [
  Doctor('Dr. Ahmed Khan', 'Cardiologist', 'City Medical Hospital', '+92 300 1234567', 4),
  Doctor('Dr. Sara Malik', 'Dermatologist', 'Skin Care Clinic', '+92 301 7654321', 2),
  Doctor('Dr. Imran Ali', 'General Physician', 'Allied Hospital', '+92 302 1112233', 6),
];
const visits = [
  Visit('06 Oct 2026', 'Dr. Ahmed Khan', 'City Medical Hospital', 'Viral Infection', 3, 2),
  Visit('15 Sep 2026', 'Dr. Sara Malik', 'Skin Care Clinic', 'Skin Allergy', 2, 1),
  Visit('03 Aug 2026', 'Dr. Imran Ali', 'Allied Hospital', 'Routine Checkup', 1, 0),
];

// ───────── Shared widgets ─────────
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  const AppCard({super.key, required this.child, this.onTap, this.padding = const EdgeInsets.all(16)});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: kInk.withOpacity(.05), blurRadius: 16, offset: const Offset(0, 6))]),
    child: Material(
      color: Colors.transparent,
      child: InkWell(borderRadius: BorderRadius.circular(20), onTap: onTap, child: Padding(padding: padding, child: child)),
    ),
  );
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool outlined;
  const PrimaryButton(this.label, this.onTap, {super.key, this.icon, this.outlined = false});
  @override
  Widget build(BuildContext context) {
    final child = Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
      Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    ]);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
    return SizedBox(
      width: double.infinity, height: 54,
      child: outlined
          ? OutlinedButton(onPressed: onTap, style: OutlinedButton.styleFrom(shape: shape, foregroundColor: kBlue), child: child)
          : FilledButton(onPressed: onTap, style: FilledButton.styleFrom(backgroundColor: kBlue, shape: shape), child: child),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionTitle(this.title, {super.key, this.action, this.onAction});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kInk)),
      if (action != null) TextButton(onPressed: onAction, child: Text(action!)),
    ]),
  );
}

class Pill extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color color;
  const Pill(this.text, {super.key, this.icon, this.color = kBlue});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(right: 8),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      if (icon != null) ...[Icon(icon, size: 14, color: color), const SizedBox(width: 4)],
      Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    ]),
  );
}

class Avatar extends StatelessWidget {
  final String name;
  final double radius;
  const Avatar(this.name, {super.key, this.radius = 26});
  @override
  Widget build(BuildContext context) => CircleAvatar(
      radius: radius,
      backgroundColor: kBlue.withOpacity(.12),
      child: Text(name.replaceAll('Dr. ', '').substring(0, 1),
          style: TextStyle(color: kBlue, fontWeight: FontWeight.w700, fontSize: radius * .8)));
}

class SearchBox extends StatelessWidget {
  final String hint;
  final VoidCallback? onTap;
  final VoidCallback? onFilter;
  const SearchBox(this.hint, {super.key, this.onTap, this.onFilter});
  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52, padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            const Icon(Icons.search, color: kMuted), const SizedBox(width: 10),
            Text(hint, style: const TextStyle(color: kMuted)),
          ]),
        ),
      ),
    ),
    if (onFilter != null) ...[
      const SizedBox(width: 10),
      InkWell(
        onTap: onFilter,
        child: Container(
            height: 52, width: 52,
            decoration: BoxDecoration(color: kBlue, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.tune, color: Colors.white)),
      ),
    ],
  ]);
}

InputDecoration fieldDeco(String label, IconData icon) => InputDecoration(
  labelText: label, prefixIcon: Icon(icon, color: kMuted), filled: true, fillColor: Colors.white,
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
  contentPadding: const EdgeInsets.symmetric(vertical: 18),
);

Widget field(String label, IconData icon, {int lines = 1}) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextField(onChanged: (v) => formData[label] = v, minLines: lines, maxLines: lines, decoration: fieldDeco(label, icon)));

Widget emptyState(IconData icon, String msg, String btn, VoidCallback onTap) => Center(
  child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      CircleAvatar(radius: 48, backgroundColor: kBlue.withOpacity(.1), child: Icon(icon, size: 44, color: kBlue)),
      const SizedBox(height: 20),
      Text(msg, style: const TextStyle(fontSize: 16, color: kMuted)),
      const SizedBox(height: 20),
      SizedBox(width: 220, child: PrimaryButton(btn, onTap, icon: Icons.add)),
    ]),
  ),
);

void showFilters(BuildContext context) => showModalBottomSheet(
  context: context, isScrollControlled: true, backgroundColor: Colors.white,
  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
  builder: (sheetCtx) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
      const SizedBox(height: 16),
      for (final f in ['Date Range', 'Doctor', 'Hospital', 'Diagnosis', 'Medicine', 'Medical Test'])
        ListTile(contentPadding: EdgeInsets.zero, title: Text(f), trailing: const Icon(Icons.chevron_right)),
      const Wrap(children: [Pill('Dr. Ahmed Khan', icon: Icons.close), Pill('Last 3 months', icon: Icons.close)]),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: PrimaryButton('Clear All', () => Navigator.pop(sheetCtx), outlined: true)),
        const SizedBox(width: 12),
        Expanded(child: PrimaryButton('Apply Filters', () => Navigator.pop(sheetCtx))),
      ]),
    ]),
  ),
);

void push(BuildContext c, Widget w) => Navigator.push(c, MaterialPageRoute(builder: (_) => w));

// ───────── Splash ─────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Onboarding()));
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: kBlue,
    body: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
            child: const Icon(Icons.medical_information, size: 64, color: kBlue)),
        const SizedBox(height: 24),
        const Text('My Medical History', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text('Your medical records, organized.', style: TextStyle(color: Colors.white70, fontSize: 16)),
      ]),
    ),
  );
}

// ───────── Onboarding ─────────
class Onboarding extends StatefulWidget {
  const Onboarding({super.key});
  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final _pc = PageController();
  int _i = 0;
  static const pages = [
    (Icons.folder_shared, 'Keep Your Medical History Organized', 'Store visits, diagnoses, medicines and reports in one place.'),
    (Icons.medical_services, 'Remember Every Doctor Visit', 'Doctor, hospital, diagnosis and medicines — all linked together.'),
    (Icons.cloud_done, 'Your Records, Wherever You Need Them', 'Back up securely to your own Google Drive.'),
  ];
  void _done() => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignIn()));

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(children: [
        Align(alignment: Alignment.centerRight, child: TextButton(onPressed: _done, child: const Text('Skip'))),
        Expanded(
          child: PageView(
            controller: _pc,
            onPageChanged: (i) => setState(() => _i = i),
            children: [
              for (final p in pages)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    CircleAvatar(radius: 90, backgroundColor: kBlue.withOpacity(.1), child: Icon(p.$1, size: 90, color: kBlue)),
                    const SizedBox(height: 40),
                    Text(p.$2, textAlign: TextAlign.center, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: kInk)),
                    const SizedBox(height: 12),
                    Text(p.$3, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: kMuted, height: 1.4)),
                  ]),
                ),
            ],
          ),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (int i = 0; i < 3; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250), margin: const EdgeInsets.all(4),
              height: 8, width: i == _i ? 24 : 8,
              decoration: BoxDecoration(color: i == _i ? kBlue : Colors.black12, borderRadius: BorderRadius.circular(8)),
            ),
        ]),
        Padding(
          padding: const EdgeInsets.all(24),
          child: PrimaryButton(_i == 2 ? 'Get Started' : 'Next',
                  () => _i == 2 ? _done() : _pc.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut)),
        ),
      ]),
    ),
  );
}

// ───────── Google Sign-in + Drive setup ─────────
class SignIn extends StatelessWidget {
  const SignIn({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.medical_information, size: 72, color: kBlue),
          const SizedBox(height: 16),
          const Text('My Medical History', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Sign in to securely manage your medical records.', textAlign: TextAlign.center, style: TextStyle(color: kMuted, fontSize: 16)),
          const SizedBox(height: 40),
          PrimaryButton('Continue with Google', () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DriveSetup())), icon: Icons.g_mobiledata),
          const SizedBox(height: 20),
          const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.lock_outline, size: 16, color: kMuted), SizedBox(width: 6),
            Flexible(child: Text('Your data stays private. Only you can access it.', style: TextStyle(color: kMuted, fontSize: 13))),
          ]),
        ]),
      ),
    ),
  );
}

class DriveSetup extends StatefulWidget {
  const DriveSetup({super.key});
  @override
  State<DriveSetup> createState() => _DriveSetupState();
}

class _DriveSetupState extends State<DriveSetup> {
  bool connected = false;
  void _home() => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Shell()));
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const Spacer(),
          CircleAvatar(radius: 56, backgroundColor: (connected ? kGreen : kBlue).withOpacity(.12),
              child: Icon(connected ? Icons.check_circle : Icons.add_to_drive, size: 56, color: connected ? kGreen : kBlue)),
          const SizedBox(height: 24),
          Text(connected ? 'Google Drive Connected' : 'Connect Your Google Drive',
              textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          const Text('Keep a secure backup of your medical records in your Google Drive.', textAlign: TextAlign.center, style: TextStyle(color: kMuted, fontSize: 16)),
          const SizedBox(height: 24),
          AppCard(child: Column(children: [
            const _Row(Icons.account_circle, 'Google account', 'user@gmail.com'),
            _Row(Icons.link, 'Status', connected ? 'Connected' : 'Not connected'),
            if (connected) ...const [
              _Row(Icons.sync, 'Last sync', 'Just now'),
              _Row(Icons.storage, 'Storage used', '12.4 MB'),
            ],
          ])),
          const Spacer(),
          PrimaryButton(connected ? 'Continue' : 'Connect Google Drive', connected ? _home : () => setState(() => connected = true)),
          if (!connected) TextButton(onPressed: _home, child: const Text('Skip for Now')),
        ]),
      ),
    ),
  );
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String k, v;
  const _Row(this.icon, this.k, this.v);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      Icon(icon, color: kBlue, size: 20), const SizedBox(width: 12),
      Text(k, style: const TextStyle(color: kMuted)), const Spacer(),
      Text(v, style: const TextStyle(fontWeight: FontWeight.w600)),
    ]),
  );
}

// ───────── Shell with bottom nav ─────────
class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _i = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: IndexedStack(index: _i, children: const [HomeTab(), DoctorsTab(), HistoryTab(), ReportsTab(), SettingsTab()])),
    floatingActionButton: _i == 1
        ? FloatingActionButton.extended(
        onPressed: () => push(context, const EditScreen('Doctor')),
        backgroundColor: kBlue, foregroundColor: Colors.white,
        icon: const Icon(Icons.add), label: const Text('Add Doctor'))
        : null,
    bottomNavigationBar: NavigationBar(
      selectedIndex: _i,
      onDestinationSelected: (i) => setState(() => _i = i),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: kBlue), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.medical_services_outlined), selectedIcon: Icon(Icons.medical_services, color: kBlue), label: 'Doctors'),
        NavigationDestination(icon: Icon(Icons.history), selectedIcon: Icon(Icons.history, color: kBlue), label: 'History'),
        NavigationDestination(icon: Icon(Icons.description_outlined), selectedIcon: Icon(Icons.description, color: kBlue), label: 'Reports'),
        NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings, color: kBlue), label: 'Settings'),
      ],
    ),
  );
}

// ───────── Home ─────────
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});
  @override
  Widget build(BuildContext context) {
    final stats = [
      (Icons.medical_services, '5', 'Doctors', kBlue, null),
      (Icons.event_note, '17', 'Visits', kGreen, null),
      (Icons.medication, '28', 'Medicines', kAmber, const MedicinesScreen()),
      (Icons.description, '12', 'Reports', kRed, null),
    ];
    return ListView(padding: const EdgeInsets.all(20), children: [
      Row(children: [
        const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Good Morning', style: TextStyle(color: kMuted)),
              Text('Welcome back', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
            ])),
        const Avatar('User'),
      ]),
      const SizedBox(height: 20),
      SearchBox('Search your medical history...', onTap: () => push(context, const SearchScreen())),
      const SizedBox(height: 16),
      PrimaryButton('Add Medical Visit', () => push(context, const AddVisit()), icon: Icons.add),
      const SizedBox(height: 20),
      GridView.count(
        crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.8,
        children: [
          for (final s in stats)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: s.$4.withOpacity(.1), borderRadius: BorderRadius.circular(20)),
              child: InkWell(
                onTap: s.$5 == null ? null : () => push(context, s.$5!),
                child: Row(children: [
                  Icon(s.$1, color: s.$4, size: 28), const SizedBox(width: 12),
                  Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.$2, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                    Text(s.$3, style: const TextStyle(color: kMuted, fontSize: 13)),
                  ]),
                ]),
              ),
            ),
        ],
      ),
      const SizedBox(height: 12),
      SectionTitle('Recent Visits', action: 'View All'),
      for (final v in visits.take(2)) VisitCard(v),
      const SectionTitle('Recent Doctors'),
      SizedBox(
        height: 96,
        child: ListView(scrollDirection: Axis.horizontal, children: [
          for (final d in doctors)
            GestureDetector(
              onTap: () => push(context, DoctorProfile(d)),
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(children: [Avatar(d.name, radius: 30), const SizedBox(height: 6), Text(d.name.split(' ').last, style: const TextStyle(fontSize: 12))]),
              ),
            ),
        ]),
      ),
      const SectionTitle('Upcoming Follow-up'),
      AppCard(child: Row(children: [
        const CircleAvatar(backgroundColor: Color(0x1AF59E0B), child: Icon(Icons.alarm, color: kAmber)),
        const SizedBox(width: 12),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('15 Nov 2026', style: TextStyle(fontWeight: FontWeight.w700)),
          Text('Dr. Ahmed Khan • Follow-up', style: TextStyle(color: kMuted)),
        ])),
      ])),
    ]);
  }
}

class VisitCard extends StatelessWidget {
  final Visit v;
  const VisitCard(this.v, {super.key});
  @override
  Widget build(BuildContext context) => AppCard(
    onTap: () => push(context, VisitDetails(v)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Avatar(v.doctor, radius: 22), const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(v.doctor, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          Text(v.hospital, style: const TextStyle(color: kMuted, fontSize: 13)),
        ])),
        Text(v.date, style: const TextStyle(color: kMuted, fontSize: 12)),
      ]),
      const SizedBox(height: 12),
      Text('Diagnosis: ${v.dx}', style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      Row(children: [
        Pill('${v.meds} Medicines', icon: Icons.medication, color: kAmber),
        Pill('${v.tests} Tests', icon: Icons.science, color: kGreen),
        const Pill('Rx', icon: Icons.attach_file),
      ]),
    ]),
  );
}

// ───────── Doctors ─────────
class DoctorsTab extends StatelessWidget {
  const DoctorsTab({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
    const Text('Doctors', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
    const SizedBox(height: 16),
    SearchBox('Search doctors...', onFilter: () => showFilters(context)),
    const SizedBox(height: 16),
    for (final d in doctors)
      AppCard(
        onTap: () => push(context, DoctorProfile(d)),
        child: Row(children: [
          Avatar(d.name, radius: 30), const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(d.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            Text(d.spec, style: const TextStyle(color: kBlue, fontWeight: FontWeight.w500)),
            Text(d.hospital, style: const TextStyle(color: kMuted, fontSize: 13)),
            Text(d.phone, style: const TextStyle(color: kMuted, fontSize: 13)),
          ])),
          Pill('${d.visits} Visits'),
        ]),
      ),
    const SizedBox(height: 80),
  ]);
}

class MapPreview extends StatelessWidget {
  const MapPreview({super.key});
  @override
  Widget build(BuildContext context) => Container(
    height: 150,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(colors: [Color(0xFFDBEAFE), Color(0xFFE0F2FE)])),
    child: const Center(child: Icon(Icons.location_on, size: 48, color: kRed)),
  );
}

class DoctorProfile extends StatelessWidget {
  final Doctor d;
  const DoctorProfile(this.d, {super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Doctor Profile'), actions: [IconButton(onPressed: () => push(context, const EditScreen('Doctor')), icon: const Icon(Icons.edit_outlined))]),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Center(child: Column(children: [
        Avatar(d.name, radius: 44), const SizedBox(height: 12),
        Text(d.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        Text(d.spec, style: const TextStyle(color: kBlue, fontSize: 16)),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          FilledButton.tonalIcon(onPressed: () {}, icon: const Icon(Icons.call), label: Text(d.phone)),
          const SizedBox(width: 8),
          FilledButton.tonalIcon(onPressed: () {}, icon: const Icon(Icons.photo), label: const Text('Doctor Photo')),
        ]),
      ])),
      const SizedBox(height: 20),
      AppCard(child: Column(children: [_Row(Icons.local_hospital, 'Hospital', d.hospital), const _Row(Icons.place, 'Address', 'Main Blvd, Faisalabad')])),
      const MapPreview(),
      const SizedBox(height: 16),
      Row(children: [
        for (final s in [('${d.visits}', 'Total Visits'), ('06 Oct', 'Last Visit'), ('9', 'Medicines')])
          Expanded(child: AppCard(padding: const EdgeInsets.all(12), child: Column(children: [
            Text(s.$1, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kBlue)),
            Text(s.$2, style: const TextStyle(fontSize: 12, color: kMuted)),
          ]))),
      ]),
      const SectionTitle('Visit History', action: 'All Visits'),
      for (int i = 0; i < visits.length; i++) ...[
        Padding(padding: const EdgeInsets.only(bottom: 6), child: Text('Visit ${visits.length - i}', style: const TextStyle(color: kMuted, fontWeight: FontWeight.w700))),
        Dismissible(
          key: ValueKey(i), direction: DismissDirection.endToStart,
          background: Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.only(right: 20), alignment: Alignment.centerRight,
              decoration: BoxDecoration(color: kRed, borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.delete, color: Colors.white)),
          confirmDismiss: (_) async {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Open the visit to delete it')));
            return false;
          },
          child: VisitCard(Visit(visits[i].date, d.name, d.hospital, visits[i].dx, visits[i].meds, visits[i].tests)),
        ),
      ],
      const SizedBox(height: 8),
      PrimaryButton('Add New Visit', () => push(context, const AddVisit()), icon: Icons.add),
    ]),
  );
}

// ───────── History (timeline) ─────────
class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
    const Text('Medical History', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
    const SizedBox(height: 16),
    SearchBox('Search history...', onFilter: () => showFilters(context)),
    const SizedBox(height: 20),
    for (final v in visits)
      IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Column(children: [
            const CircleAvatar(radius: 6, backgroundColor: kBlue),
            Expanded(child: Container(width: 2, color: kBlue.withOpacity(.2))),
          ]),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(v.date, style: const TextStyle(fontWeight: FontWeight.w700, color: kMuted))),
            VisitCard(v),
          ])),
        ]),
      ),
  ]);
}

// ───────── Visit details ─────────
class VisitDetails extends StatelessWidget {
  final Visit v;
  const VisitDetails(this.v, {super.key});
  Widget sec(String t, IconData i, String body) => AppCard(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(i, color: kBlue), const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 4),
          Text(body, style: const TextStyle(color: kMuted, height: 1.4)),
        ])),
      ]));
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(v.date)),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      AppCard(child: Row(children: [
        Avatar(v.doctor, radius: 28), const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(v.doctor, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          Text(v.hospital, style: const TextStyle(color: kMuted)),
        ]),
      ])),
      sec('Diagnosis', Icons.assignment, v.dx),
      sec('Symptoms', Icons.sick, 'Fever, sore throat, body aches'),
      sec('Medicines', Icons.medication, 'Panadol 500mg • 3x daily • 5 days\nAmoxicillin 250mg • 2x daily • 7 days'),
      sec('Medical Tests', Icons.science, 'CBC — Normal\nCRP — Slightly elevated'),
      sec('Prescription', Icons.receipt_long, 'prescription_06Oct.jpg'),
      sec('Attachments', Icons.attach_file, 'Prescription photo • Lab report PDF'),
      sec('Doctor Notes', Icons.notes, 'Rest, fluids, review if fever persists.'),
      sec('Follow-up', Icons.event, '15 Nov 2026'),
      sec('Location', Icons.location_on, 'City Medical Hospital • Main Blvd'),
      Wrap(spacing: 8, children: [
        for (final t in ['Doctor', 'Hospital', 'Medicine', 'Test', 'Prescription'])
          ActionChip(avatar: const Icon(Icons.edit, size: 16), label: Text('Edit $t'), onPressed: () => push(context, EditScreen(t))),
      ]),
      const SizedBox(height: 12),
      const MapPreview(),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: PrimaryButton('Edit Visit', () => push(context, const EditScreen('Visit')), outlined: true, icon: Icons.edit)),
        const SizedBox(width: 12),
        Expanded(child: PrimaryButton('Delete', () => showDialog(
            context: context,
            builder: (c) => AlertDialog(
              title: const Text('Delete visit?'), content: const Text('This cannot be undone.'),
              actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(c), child: const Text('Delete', style: TextStyle(color: kRed)))],
            )), outlined: true, icon: Icons.delete_outline)),
      ]),
    ]),
  );
}

// ───────── Add visit (multi-step) ─────────
class AddVisit extends StatefulWidget {
  const AddVisit({super.key});
  @override
  State<AddVisit> createState() => _AddVisitState();
}

class _AddVisitState extends State<AddVisit> {
  int step = 0;
  int meds = 1;
  static const titles = ['Doctor', 'Location', 'Visit Info', 'Medicines', 'Review'];

  Widget body() {
    switch (step) {
      case 0:
        return Column(children: [
          Row(children: const [Expanded(child: Pill('Select Existing')), Expanded(child: Pill('Add New Doctor'))]),
          field('Doctor Name', Icons.person), field('Specialization', Icons.badge), field('Phone', Icons.phone),
          field('Hospital / Clinic', Icons.local_hospital),
          field('Hospital Address', Icons.place),
          Row(children: [
            Expanded(child: PrimaryButton('Doctor Photo', () {}, outlined: true, icon: Icons.photo_camera)),
            const SizedBox(width: 12),
            Expanded(child: PrimaryButton('Hospital Photo', () {}, outlined: true, icon: Icons.photo)),
          ]),
        ]);
      case 1:
        return Column(children: [
          const SizedBox(height: 220, child: MapPreview()),
          const SizedBox(height: 12),
          PrimaryButton('Use Current Location', () {}, icon: Icons.my_location),
          const SizedBox(height: 10),
          PrimaryButton('Select on Map', () {}, outlined: true, icon: Icons.map),
          const SizedBox(height: 14),
          field('Hospital Address', Icons.place),
        ]);
      case 2:
        return Column(children: [
          field('Visit Date', Icons.calendar_today), field('Visit Time', Icons.access_time),
          field('Reason for Visit', Icons.help_outline), field('Symptoms', Icons.sick, lines: 2),
          field('Diagnosis', Icons.assignment), field("Doctor's Notes", Icons.notes, lines: 3),
          field('Follow-up Date', Icons.event),
        ]);
      case 3:
        return Column(children: [
          for (int i = 0; i < meds; i++)
            AppCard(child: Column(children: [
              field('Medicine Name', Icons.medication), field('Dose (e.g. 500mg)', Icons.scale),
              field('Frequency', Icons.repeat), field('Duration', Icons.timelapse),
              Wrap(children: const [Pill('Before Meal'), Pill('After Meal')]),
            ])),
          PrimaryButton('Add Medicine', () => setState(() => meds++), outlined: true, icon: Icons.add),
          const SizedBox(height: 16),
          const TestsSection(),
          const PrescriptionSection(),
        ]);
      default:
        return review();
    }
  }

  Widget review() {
    const secs = [
      ('Doctor', ['Doctor Name', 'Specialization', 'Phone'], 0),
      ('Hospital', ['Hospital / Clinic'], 0),
      ('Location', ['Hospital Address'], 1),
      ('Visit Information', ['Visit Date', 'Visit Time', 'Reason for Visit'], 2),
      ('Diagnosis', ['Diagnosis', 'Symptoms'], 2),
      ('Medicines', ['Medicine Name', 'Dose (e.g. 500mg)', 'Frequency', 'Duration'], 3),
      ('Tests', ['Test Name', 'Test Date', 'Result'], 3),
      ('Prescription', <String>[], 3),
      ('Notes', ["Doctor's Notes"], 2),
      ('Follow-up', ['Follow-up Date'], 2),
    ];
    return Column(children: [
      for (final x in secs)
        AppCard(padding: const EdgeInsets.all(14), child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(x.$1, style: const TextStyle(color: kMuted, fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(() {
              final v = x.$2.map((k) => formData[k]).where((e) => e != null && e.isNotEmpty).join(' • ');
              return v.isEmpty ? '—' : v;
            }(), style: const TextStyle(fontWeight: FontWeight.w600)),
          ])),
          TextButton(onPressed: () => setState(() => step = x.$3), child: const Text('Edit')),
        ])),
    ]);
  }

  void save(BuildContext c, String msg) {
    Navigator.pop(c);
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(msg), backgroundColor: kGreen, behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Step ${step + 1}: ${titles[step]}')),
    body: Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: (step + 1) / 5, minHeight: 8, color: kBlue, backgroundColor: Colors.black12)),
      ),
      Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: body())),
      Container(
        padding: const EdgeInsets.all(16), color: Colors.white,
        child: SafeArea(
          top: false,
          child: step < 4
              ? Row(children: [
            if (step > 0) ...[Expanded(child: PrimaryButton('Back', () => setState(() => step--), outlined: true)), const SizedBox(width: 12)],
            Expanded(child: PrimaryButton('Next', () => setState(() => step++))),
          ])
              : Column(mainAxisSize: MainAxisSize.min, children: [
            PrimaryButton('Save Medical Visit', () => save(context, 'Visit saved')),
            const SizedBox(height: 8),
            PrimaryButton('Save & Sync', () => save(context, 'Saved and synced to Drive'), outlined: true, icon: Icons.cloud_upload),
          ]),
        ),
      ),
    ]),
  );
}

// ───────── Medicines ─────────
class MedicinesScreen extends StatelessWidget {
  const MedicinesScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Medicines')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      for (final m in [('Panadol', '500mg', '06 Oct 2026', 'Dr. Ahmed Khan', 5), ('Amoxicillin', '250mg', '15 Sep 2026', 'Dr. Sara Malik', 2)])
        AppCard(
          onTap: () => showModalBottomSheet(
            context: context, backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
            builder: (_) => Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${m.$1} history', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              const ListTile(title: Text('06 Oct 2026 • 500mg'), subtitle: Text('Dr. Ahmed Khan')),
              const ListTile(title: Text('15 Nov 2026 • 500mg'), subtitle: Text('Dr. Ahmed Khan')),
            ])),
          ),
          child: Row(children: [
            const CircleAvatar(backgroundColor: Color(0x1AF59E0B), child: Icon(Icons.medication, color: kAmber)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${m.$1} ${m.$2}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              Text('Last prescribed: ${m.$3}', style: const TextStyle(color: kMuted, fontSize: 13)),
              Text(m.$4, style: const TextStyle(color: kMuted, fontSize: 13)),
            ])),
            Pill('${m.$5}×'),
          ]),
        ),
    ]),
  );
}

// ───────── Reports ─────────
class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
    const Text('Reports', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
    const SizedBox(height: 16),
    PrimaryButton(
      'Upload Medical Report',
          () => showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Upload Report'),
          content: const Text('Choose a PDF or image report to preview it here.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                Navigator.pop(c);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report added successfully'), backgroundColor: kGreen),
                );
              },
              child: const Text('Choose File'),
            ),
          ],
        ),
      ),
      icon: Icons.upload_file,
    ),
    const SizedBox(height: 16),
    SizedBox(height: 40, child: ListView(scrollDirection: Axis.horizontal, children: [
      for (final c in ['Blood Tests', 'X-Ray', 'MRI', 'CT Scan', 'Ultrasound', 'Other'])
        Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(c), selected: c == 'Blood Tests', onSelected: (_) {})),
    ])),
    const SizedBox(height: 16),
    for (final r in [('CBC Blood Test', '06 Oct 2026', 'PDF'), ('Chest X-Ray', '15 Sep 2026', 'Image')])
      AppCard(child: Row(children: [
        CircleAvatar(backgroundColor: kBlue.withOpacity(.1), child: Icon(r.$3 == 'PDF' ? Icons.picture_as_pdf : Icons.image, color: kBlue)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(r.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
          Text('${r.$2} • Dr. Ahmed Khan', style: const TextStyle(color: kMuted, fontSize: 13)),
          const Text('City Medical Hospital', style: TextStyle(color: kMuted, fontSize: 13)),
        ])),
        TextButton(onPressed: () => showDialog(context: context, builder: (c) => AlertDialog(title: Text(r.$1), content: SizedBox(height: 200, child: Center(child: Icon(r.$3 == 'PDF' ? Icons.picture_as_pdf : Icons.image, size: 96, color: kBlue))), actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Close'))])), child: const Text('Preview')),
      ])),
  ]);
}

// ───────── Search ─────────
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = '';
  String category = 'All';

  final data = const [
    ('06 Oct 2026', 'Dr. Ahmed Khan', 'Panadol 500mg', 'Medicine', 'City Medical Hospital'),
    ('15 Nov 2026', 'Dr. Ahmed Khan', 'Panadol 500mg', 'Medicine', 'City Medical Hospital'),
    ('06 Oct 2026', 'Dr. Ahmed Khan', 'Viral Infection', 'Diagnosis', 'City Medical Hospital'),
    ('15 Sep 2026', 'Dr. Sara Malik', 'Skin Care Clinic', 'Hospital', 'Skin Care Clinic'),
    ('03 Aug 2026', 'Dr. Imran Ali', 'CBC', 'Test', 'Allied Hospital'),
  ];

  @override
  Widget build(BuildContext context) {
    final results = data.where((r) {
      final searchText = query.trim().toLowerCase();
      final matchesQuery = searchText.isEmpty ||
          r.$1.toLowerCase().contains(searchText) ||
          r.$2.toLowerCase().contains(searchText) ||
          r.$3.toLowerCase().contains(searchText) ||
          r.$4.toLowerCase().contains(searchText) ||
          r.$5.toLowerCase().contains(searchText);
      final matchesCategory = category == 'All' || r.$4 == category;
      return matchesQuery && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        TextField(
          autofocus: true,
          onChanged: (v) => setState(() => query = v),
          decoration: fieldDeco(
            'Search doctors, medicines, diagnosis, tests...',
            Icons.search,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in ['All', 'Doctor', 'Medicine', 'Diagnosis', 'Hospital', 'Test'])
              ChoiceChip(
                label: Text(c),
                selected: category == c,
                onSelected: (_) => setState(() => category = c),
              ),
          ],
        ),
        const SizedBox(height: 20),
        SectionTitle(
          query.isEmpty ? 'Search Suggestions' : 'Search Results',
          action: 'Filters',
          onAction: () => showFilters(context),
        ),
        if (query.isEmpty)
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Pill('Doctors', icon: Icons.person),
              Pill('Medicines', icon: Icons.medication),
              Pill('Diagnoses', icon: Icons.assignment),
              Pill('Hospitals', icon: Icons.local_hospital),
              Pill('Tests', icon: Icons.science),
            ],
          ),
        if (query.isNotEmpty && results.isEmpty)
          emptyState(Icons.search_off, 'No matching records found.', 'Clear Search', () {
            setState(() {
              query = '';
              category = 'All';
            });
          }),
        for (final r in results)
          AppCard(
            onTap: () => push(
              context,
              VisitDetails(Visit(r.$1, r.$2, r.$5, r.$3, 1, 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.$1, style: const TextStyle(color: kMuted)),
                Text(r.$2, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(r.$3, style: const TextStyle(color: kBlue)),
                const SizedBox(height: 6),
                Row(children: [
                  Pill(r.$4),
                  const SizedBox(width: 4),
                  Text(r.$5, style: const TextStyle(color: kMuted, fontSize: 12)),
                ]),
              ],
            ),
          ),
      ]),
    );
  }
}

// ───────── Settings + Backup ─────────
class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});
  Widget group(String t, List<Widget> kids) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(padding: const EdgeInsets.fromLTRB(4, 16, 0, 8), child: Text(t, style: const TextStyle(color: kMuted, fontWeight: FontWeight.w700, fontSize: 12))),
    AppCard(padding: EdgeInsets.zero, child: Column(children: kids)),
  ]);
  Widget tile(IconData i, String t, {VoidCallback? onTap, Widget? trailing}) =>
      ListTile(leading: Icon(i, color: kBlue), title: Text(t), trailing: trailing ?? const Icon(Icons.chevron_right), onTap: onTap);
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
    const Text('Settings', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
    group('ACCOUNT', [tile(Icons.person, 'Profile', onTap: () => push(context, const ProfileScreen())), tile(Icons.account_circle, 'Google Account')]),
    group('BACKUP & SYNC', [
      tile(Icons.add_to_drive, 'Google Drive', onTap: () => push(context, const BackupScreen())),
      tile(Icons.sync, 'Auto Sync', trailing: Switch(value: true, onChanged: (_) {})),
    ]),
    group('SECURITY', [
      tile(Icons.lock, 'App Lock', trailing: Switch(value: false, onChanged: (_) {})),
      tile(Icons.pin, 'PIN'), tile(Icons.fingerprint, 'Biometric'),
    ]),
    group('DATA', [tile(Icons.ios_share, 'Export Medical History'), tile(Icons.restore, 'Restore Backup')]),
    group('APP', [tile(Icons.notifications, 'Notifications'), tile(Icons.privacy_tip, 'Privacy'), tile(Icons.info, 'About'), tile(Icons.view_carousel, 'Preview UI States', onTap: () => push(context, const StatesScreen()))]),
  ]);
}

enum SyncState { ok, syncing, success, failed, offline }

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});
  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  SyncState s = SyncState.ok;
  void sync() {
    setState(() => s = SyncState.syncing);
    Timer(const Duration(seconds: 2), () { if (mounted) setState(() => s = SyncState.success); });
  }

  @override
  Widget build(BuildContext context) {
    final info = {
      SyncState.ok: (Icons.cloud_done, kGreen, 'Everything is up to date'),
      SyncState.syncing: (Icons.cloud_sync, kBlue, 'Syncing...'),
      SyncState.success: (Icons.check_circle, kGreen, 'Sync Successful'),
      SyncState.failed: (Icons.cloud_off, kRed, 'Sync Failed'),
      SyncState.offline: (Icons.wifi_off, kAmber, 'Offline — will sync when connected'),
    }[s]!;
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Sync')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        AppCard(child: Column(children: [
          s == SyncState.syncing ? const SizedBox(height: 64, width: 64, child: CircularProgressIndicator(strokeWidth: 5)) : Icon(info.$1, size: 64, color: info.$2),
          const SizedBox(height: 12),
          Text(info.$3, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          const _Row(Icons.add_to_drive, 'Google Drive', 'Connected'),
          const _Row(Icons.schedule, 'Last Sync', 'Today, 10:32 AM'),
        ])),
        PrimaryButton('Sync Now', sync, icon: Icons.sync),
        const SizedBox(height: 10),
        AppCard(child: Column(children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Auto Sync', style: TextStyle(fontWeight: FontWeight.w700)),
            subtitle: const Text('Keep your records backed up automatically'),
            value: true,
            onChanged: (_) {},
          ),
          const _Row(Icons.schedule, 'Last Synced', 'Today, 10:32 AM'),
        ])),
        const SizedBox(height: 8),
        const Text('Preview states', style: TextStyle(color: kMuted)),
        Wrap(spacing: 8, children: [
          for (final st in SyncState.values) ActionChip(label: Text(st.name), onPressed: () => setState(() => s = st)),
        ]),
      ]),
    );
  }
}


// ───────── Form store, tests, prescription ─────────
final formData = <String, String>{};

class TestsSection extends StatefulWidget {
  const TestsSection({super.key});
  @override
  State<TestsSection> createState() => _TestsSectionState();
}

class _TestsSectionState extends State<TestsSection> {
  final files = <String>[];
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SectionTitle('Medical Tests'),
    field('Test Name', Icons.science), field('Test Date', Icons.calendar_today),
    field('Result', Icons.fact_check), field('Doctor Notes', Icons.notes, lines: 2),
    PrimaryButton('Upload Report (PDF / Image)', () => setState(() => files.add('report_${files.length + 1}.${files.length.isEven ? 'pdf' : 'jpg'}')), outlined: true, icon: Icons.upload_file),
    const SizedBox(height: 12),
    for (final f in files)
      AppCard(padding: const EdgeInsets.all(12), child: Row(children: [
        Icon(f.endsWith('pdf') ? Icons.picture_as_pdf : Icons.image, color: kBlue), const SizedBox(width: 12),
        Expanded(child: Text(f, style: const TextStyle(fontWeight: FontWeight.w600))),
        IconButton(onPressed: () => setState(() => files.remove(f)), icon: const Icon(Icons.delete_outline, color: kRed)),
      ])),
  ]);
}

class PrescriptionSection extends StatefulWidget {
  const PrescriptionSection({super.key});
  @override
  State<PrescriptionSection> createState() => _PrescriptionSectionState();
}

class _PrescriptionSectionState extends State<PrescriptionSection> {
  String? file;
  void pick(String f) => setState(() => file = f);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SectionTitle('Prescription'),
    if (file == null)
      Wrap(spacing: 8, children: [
        ActionChip(avatar: const Icon(Icons.photo_camera, size: 18), label: const Text('Take Photo'), onPressed: () => pick('prescription.jpg')),
        ActionChip(avatar: const Icon(Icons.photo_library, size: 18), label: const Text('Choose From Gallery'), onPressed: () => pick('gallery_image.jpg')),
        ActionChip(avatar: const Icon(Icons.picture_as_pdf, size: 18), label: const Text('Upload PDF'), onPressed: () => pick('prescription.pdf')),
      ])
    else
      AppCard(child: Column(children: [
        Container(height: 110, decoration: BoxDecoration(color: kBlue.withOpacity(.08), borderRadius: BorderRadius.circular(14)),
            child: const Center(child: Icon(Icons.receipt_long, size: 48, color: kBlue))),
        const SizedBox(height: 10),
        Text(file!, style: const TextStyle(fontWeight: FontWeight.w700)),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          TextButton.icon(onPressed: () {}, icon: const Icon(Icons.visibility), label: const Text('View')),
          TextButton.icon(onPressed: () => pick('replaced_prescription.jpg'), icon: const Icon(Icons.swap_horiz), label: const Text('Replace')),
          TextButton.icon(onPressed: () => setState(() => file = null), icon: const Icon(Icons.delete_outline, color: kRed), label: const Text('Delete', style: TextStyle(color: kRed))),
        ]),
      ])),
    const SizedBox(height: 16),
  ]);
}

// ───────── Edit screens + Profile ─────────
const editFields = {
  'Doctor': ['Doctor Name', 'Specialization', 'Phone'],
  'Hospital': ['Hospital / Clinic', 'Hospital Address', 'Hospital Photo'],
  'Visit': ['Visit Date', 'Diagnosis', 'Symptoms', "Doctor's Notes"],
  'Medicine': ['Medicine Name', 'Dose', 'Frequency', 'Duration'],
  'Test': ['Test Name', 'Test Date', 'Result'],
  'Prescription': ['Prescription Note'],
  'Profile': ['Full Name', 'Email', 'Date of Birth', 'Blood Group'],
};

class EditScreen extends StatelessWidget {
  final String type;
  const EditScreen(this.type, {super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Edit $type')),
    body: ListView(padding: const EdgeInsets.all(20), children: [for (final f in editFields[type]!) field(f, Icons.edit_outlined)]),
    bottomNavigationBar: Container(
      color: Colors.white, padding: const EdgeInsets.all(16),
      child: SafeArea(child: PrimaryButton('Save Changes', () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$type updated'), backgroundColor: kGreen, behavior: SnackBarBehavior.floating));
      }), top: false),
    ),
  );
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Profile')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      const Center(child: Avatar('User', radius: 48)),
      const SizedBox(height: 12),
      const Center(child: Text('Your Name', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800))),
      const Center(child: Text('user@gmail.com', style: TextStyle(color: kMuted))),
      const SizedBox(height: 20),
      Row(children: [
        for (final s in [('5', 'Doctors'), ('17', 'Visits'), ('12', 'Reports')])
          Expanded(child: AppCard(padding: const EdgeInsets.all(12), child: Column(children: [
            Text(s.$1, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kBlue)),
            Text(s.$2, style: const TextStyle(color: kMuted, fontSize: 12)),
          ]))),
      ]),
      const AppCard(child: Column(children: [_Row(Icons.bloodtype, 'Blood Group', 'O+'), _Row(Icons.cake, 'Date of Birth', '01 Jan 1995')])),
      PrimaryButton('Edit Profile', () => push(context, const EditScreen('Profile')), icon: Icons.edit),
    ]),
  );
}

// ───────── UI states: loading / empty / error / offline / success ─────────
class StatesScreen extends StatelessWidget {
  const StatesScreen({super.key});
  Widget bar(double w) => Container(height: 14, width: w, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(8)));
  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 5,
    child: Scaffold(
      appBar: AppBar(title: const Text('UI States'), bottom: const TabBar(isScrollable: true, tabs: [
        Tab(text: 'Loading'), Tab(text: 'Empty'), Tab(text: 'Error'), Tab(text: 'Offline'), Tab(text: 'Success'),
      ])),
      body: TabBarView(children: [
        ListView(padding: const EdgeInsets.all(20), children: [
          for (int i = 0; i < 4; i++)
            AppCard(child: Row(children: [
              const CircleAvatar(radius: 24, backgroundColor: Colors.black12), const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [bar(160), const SizedBox(height: 8), bar(100)]),
            ])),
        ]),
        ListView(children: [
          SizedBox(height: 300, child: emptyState(Icons.medical_services, 'No doctors added yet.', 'Add Doctor', () {})),
          SizedBox(height: 300, child: emptyState(Icons.history, 'Your medical history will appear here.', 'Add Medical Visit', () {})),
          SizedBox(height: 260, child: emptyState(Icons.description, 'No medical reports uploaded yet.', 'Upload Report', () {})),
        ]),
        Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, size: 72, color: kRed), const SizedBox(height: 16),
          const Text('Something went wrong', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8), const Text('We could not load your records.', style: TextStyle(color: kMuted)),
          const SizedBox(height: 20), SizedBox(width: 200, child: PrimaryButton('Try Again', () {}, icon: Icons.refresh)),
        ]))),
        ListView(padding: const EdgeInsets.all(20), children: [
          Container(padding: const EdgeInsets.all(14), margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: kAmber.withOpacity(.15), borderRadius: BorderRadius.circular(14)),
              child: const Row(children: [Icon(Icons.wifi_off, color: kAmber), SizedBox(width: 10), Expanded(child: Text("You're offline. Showing saved records."))])),
          VisitCard(visits[0]),
        ]),
        Center(child: Column(mainAxisSize: MainAxisSize.min, children: const [
          Icon(Icons.check_circle, size: 88, color: kGreen), SizedBox(height: 16),
          Text('Visit saved successfully', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        ])),
      ]),
    ),
  );
}