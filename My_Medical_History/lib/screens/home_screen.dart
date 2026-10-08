import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import 'add_record_screen.dart';
import 'doctor_profile_screen.dart';
import 'record_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void go(Widget w) => Navigator.push(context, MaterialPageRoute(builder: (_) => w));
    return SafeArea(
      child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
        const Row(children: [
          IconBadge(Icons.medical_services, C.primary, Colors.white, 34),
          SizedBox(width: 8),
          Expanded(child: Text('My Medical History', style: TextStyle(fontWeight: FontWeight.w800, color: C.primary, fontSize: 16))),
          Icon(Icons.notifications_none),
          SizedBox(width: 12),
          Avatar('Sarah', 18),
        ]),
        const SizedBox(height: 20),
        const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Good Morning, Sarah 👋', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              SizedBox(height: 2),
              Text('Manage your personal health journey', style: TextStyle(color: C.muted)),
            ]),
          ),
          Pill('● Up to date', C.mint, C.green),
        ]),
        const SizedBox(height: 16),
        const Card2(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: TextField(
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Search doctors, medicines, diagnosis...',
              hintStyle: TextStyle(color: C.muted, fontSize: 14),
              prefixIcon: Icon(Icons.search, color: C.primary),
              suffixIcon: Icon(Icons.tune),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Btn('+ Add Medical Visit', icon: Icons.add_circle_outline, onTap: () => go(const AddRecordScreen())),
        const SizedBox(height: 16),
        const Row(children: [
          Expanded(child: _Stat(Icons.medical_services_outlined, C.blueChip, C.primary, '5', 'Doctors', 'Specialists consulted')),
          SizedBox(width: 12),
          Expanded(child: _Stat(Icons.calendar_month_outlined, C.lav2, Color(0xFF4A56C4), '17', 'Visits', 'Recorded history')),
        ]),
        const SizedBox(height: 12),
        const Row(children: [
          Expanded(child: _Stat(Icons.medication_outlined, C.mint, C.green, '28', 'Medicines', 'Active & past')),
          SizedBox(width: 12),
          Expanded(child: _Stat(Icons.biotech_outlined, Color(0xFF9CF0E0), Color(0xFF006A60), '12', 'Reports', 'Lab & radiology')),
        ]),
        const SizedBox(height: 20),
        Card2(
          bar: C.green,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [
              Icon(Icons.notifications_active_outlined, size: 18, color: C.green),
              SizedBox(width: 8),
              Expanded(child: Text('UPCOMING FOLLOW-UP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: C.green, letterSpacing: .5))),
              Pill('In 3 days', C.lav, C.ink),
            ]),
            const SizedBox(height: 8),
            const Text('Dr. Ahmed Khan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const Text('Cardiology • City Medical Hospital', style: TextStyle(color: C.primary, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            const Row(children: [
              Icon(Icons.access_time, size: 16),
              SizedBox(width: 6),
              Text('12 Oct 2026, 10:00 AM', style: TextStyle(fontSize: 13)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.check_circle_outline, size: 16, color: C.green),
              const SizedBox(width: 4),
              const Text('Confirmed', style: TextStyle(color: C.green, fontWeight: FontWeight.w700, fontSize: 13)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.event, size: 16),
                label: const Text('Add to Calendar'),
                style: ElevatedButton.styleFrom(backgroundColor: C.blueChip, foregroundColor: C.ink, elevation: 0, textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ]),
          ]),
        ),
        const SizedBox(height: 24),
        const Row(children: [
          Expanded(child: H('Recent Visits')),
          Text('View All', style: TextStyle(color: C.primary, fontWeight: FontWeight.w700, fontSize: 13)),
        ]),
        const SizedBox(height: 12),
        _Visit(
          name: 'Dr. Ahmed Khan', spec: 'Cardiologist', hospital: 'City Medical Hospital', date: '06 Oct 2026',
          tags: const [Pill('Viral Infection', C.blueChip, C.primary), Pill('Routine Checkup', C.mint, C.green)],
          meds: 3, tests: 2, onTap: () => go(const RecordDetailsScreen()), onName: () => go(const DoctorProfileScreen()),
        ),
        const SizedBox(height: 12),
        _Visit(
          name: 'Dr. Elena Rostova', spec: 'Dermatologist', hospital: 'Metro Skin & Wellness Clinic', date: '18 Sep 2026',
          tags: const [Pill('Contact Dermatitis', C.blueChip, C.primary), Pill('Follow-up', C.lav2, C.ink)],
          meds: 2, tests: 0, onTap: () => go(const RecordDetailsScreen()), onName: () {},
        ),
        const SizedBox(height: 24),
        const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          H('Your Care Team'),
          Text('Frequent contacts', style: TextStyle(fontSize: 12)),
        ]),
        const SizedBox(height: 12),
        const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _Team('Dr. Ahmed', 'Cardio', 'A'),
          _Team('Dr. Elena', 'Derma', 'E'),
          _Team('Dr. Marcus', 'General', 'M'),
          _Team('Add Doctor', 'New profile', '+', add: true),
        ]),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final Color bg, fg;
  final String n, title, sub;
  const _Stat(this.icon, this.bg, this.fg, this.n, this.title, this.sub);
  @override
  Widget build(BuildContext context) => Card2(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            IconBadge(icon, bg, fg, 44),
            const Icon(Icons.chevron_right, color: C.muted),
          ]),
          const SizedBox(height: 12),
          Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
            Text(n, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(fontSize: 12, color: C.muted)),
        ]),
      );
}

class _Visit extends StatelessWidget {
  final String name, spec, hospital, date;
  final List<Widget> tags;
  final int meds, tests;
  final VoidCallback onTap, onName;
  const _Visit({required this.name, required this.spec, required this.hospital, required this.date, required this.tags, required this.meds, required this.tests, required this.onTap, required this.onName});
  @override
  Widget build(BuildContext context) => Card2(
        onTap: onTap,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: GestureDetector(
                onTap: onName,
                child: Text('$name  •  $spec', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              ),
            ),
            Text(date, style: const TextStyle(fontSize: 12, color: C.muted)),
            const Icon(Icons.chevron_right, size: 18, color: C.muted),
          ]),
          const SizedBox(height: 2),
          Text(hospital, style: const TextStyle(fontSize: 13, color: C.muted)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 6, children: tags),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            Meta('💊 $meds Medicines'),
            Meta('🧪 $tests Tests'),
            const Meta('📎 1 Prescription'),
          ]),
        ]),
      );
}

class _Team extends StatelessWidget {
  final String name, sub, letter;
  final bool add;
  const _Team(this.name, this.sub, this.letter, {this.add = false});
  @override
  Widget build(BuildContext context) => Column(children: [
        add
            ? const IconBadge(Icons.person_add_alt_1_outlined, C.lav2, C.primary, 60)
            : Avatar(letter, 30),
        const SizedBox(height: 6),
        Text(name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: add ? C.primary : C.ink)),
        Text(sub, style: const TextStyle(fontSize: 12, color: C.muted)),
      ]);
}
