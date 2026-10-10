import 'package:flutter/material.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';
import 'add_record_screen.dart';
import 'doctor_profile_screen.dart';
import 'main_tabs.dart' show SearchScreen;
import 'record_details_screen.dart';

String _greet() {
  final h = DateTime.now().hour;
  return h < 12 ? 'Good Morning' : h < 17 ? 'Good Afternoon' : 'Good Evening';
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _syncPill() {
    switch (Store.instance.status) {
      case 'syncing':
        return const Pill('Syncing...', C.lav2, C.ink);
      case 'done':
        return const Pill('● Synced', C.mint, C.green);
      case 'failed':
        return const Pill('Sync failed', Color(0xFFFFE3E0), C.red);
      default:
        return const Pill('Not synced', C.lav2, C.ink);
    }
  }

  @override
  Widget build(BuildContext context) {
    void go(Widget w) => Navigator.push(context, MaterialPageRoute(builder: (_) => w));
    final st = Store.instance;
    final up = st.upcoming;
    final recent = st.visits.take(2).toList();
    final team = st.docs.take(3).toList();
    final n = st.firstName;
    return SafeArea(
      child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
        const Row(children: [
          IconBadge(Icons.medical_services, C.primary, Colors.white, 34),
          SizedBox(width: 8),
          Expanded(child: Text('My Medical History', style: TextStyle(fontWeight: FontWeight.w800, color: C.primary, fontSize: 16))),
          Icon(Icons.notifications_none),
          SizedBox(width: 12),
          MeAvatar(18),
        ]),
        const SizedBox(height: 20),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${_greet()}${n.isEmpty ? '' : ', $n'} 👋', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              const Text('Manage your personal health journey', style: TextStyle(color: C.muted)),
            ]),
          ),
          _syncPill(),
        ]),
        const SizedBox(height: 16),
        Card2(
          onTap: () => go(const SearchScreen()),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          child: const Row(children: [
            Icon(Icons.search, color: C.primary),
            SizedBox(width: 8),
            Expanded(child: Text('Search doctors, medicines, diagnosis...', style: TextStyle(color: C.muted, fontSize: 14))),
          ]),
        ),
        const SizedBox(height: 16),
        Btn('+ Add Medical Visit', icon: Icons.add_circle_outline, onTap: () => go(const AddRecordScreen())),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _Stat(Icons.medical_services_outlined, C.blueChip, C.primary, '${st.docs.length}', 'Doctors', 'Specialists consulted')),
          const SizedBox(width: 12),
          Expanded(child: _Stat(Icons.calendar_month_outlined, C.lav2, const Color(0xFF4A56C4), '${st.visits.length}', 'Visits', 'Recorded history')),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _Stat(Icons.medication_outlined, C.mint, C.green, '${st.meds.length}', 'Medicines', 'Active & past')),
          const SizedBox(width: 12),
          Expanded(child: _Stat(Icons.biotech_outlined, const Color(0xFF9CF0E0), const Color(0xFF006A60), '${st.reps.length}', 'Reports', 'Files in Drive')),
        ]),
        if (up != null) ...[
          const SizedBox(height: 20),
          Card2(
            bar: C.green,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.notifications_active_outlined, size: 18, color: C.green),
                const SizedBox(width: 8),
                const Expanded(child: Text('UPCOMING FOLLOW-UP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: C.green, letterSpacing: .5))),
                Pill(up['in']!, C.lav, C.ink),
              ]),
              const SizedBox(height: 8),
              Text(up['doctor']!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              Text('${up['spec']}${up['spec']!.isEmpty || up['hospital']!.isEmpty ? '' : ' • '}${up['hospital']}', style: const TextStyle(color: C.primary, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              Row(children: [const Icon(Icons.event, size: 16), const SizedBox(width: 6), Text(up['date']!, style: const TextStyle(fontSize: 13))]),
            ]),
          ),
        ],
        const SizedBox(height: 24),
        const H('Recent Visits'),
        const SizedBox(height: 12),
        if (recent.isEmpty)
          const Card2(child: Center(child: Text('Your medical history will appear here.', style: TextStyle(color: C.muted))))
        else
          for (var i = 0; i < recent.length; i++) ...[
            _Visit(
              name: recent[i].doctor, spec: '', hospital: recent[i].hospital, date: recent[i].date,
              tags: [Pill(recent[i].dx, C.blueChip, C.primary)], meds: recent[i].meds, tests: recent[i].tests,
              onTap: () => go(RecordDetailsScreen(visit: st.raw[i])), onName: () => go(DoctorProfileScreen(name: recent[i].doctor)),
            ),
            const SizedBox(height: 12),
          ],
        const SizedBox(height: 12),
        const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [H('Your Care Team'), Text('Frequent contacts', style: TextStyle(fontSize: 12))]),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            for (final d in team) _Team(d.name, d.spec, false, () => go(DoctorProfileScreen(name: d.name))),
            _Team('Add Doctor', 'New profile', true, () => go(const AddRecordScreen())),
          ]),
        ),
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
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [IconBadge(icon, bg, fg, 44), const Icon(Icons.chevron_right, color: C.muted)]),
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
            Expanded(child: GestureDetector(onTap: onName, child: Text(spec.isEmpty ? name : '$name  •  $spec', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)))),
            Text(date, style: const TextStyle(fontSize: 12, color: C.muted)),
            const Icon(Icons.chevron_right, size: 18, color: C.muted),
          ]),
          const SizedBox(height: 2),
          Text(hospital, style: const TextStyle(fontSize: 13, color: C.muted)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 6, children: tags),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [Meta('💊 $meds Medicines'), Meta('🧪 $tests Tests')]),
        ]),
      );
}

class _Team extends StatelessWidget {
  final String name, sub;
  final bool add;
  final VoidCallback onTap;
  const _Team(this.name, this.sub, this.add, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: SizedBox(
            width: 78,
            child: Column(children: [
              add ? const IconBadge(Icons.person_add_alt_1_outlined, C.lav2, C.primary, 60) : Avatar(bare(name), 30),
              const SizedBox(height: 6),
              Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: add ? C.primary : C.ink)),
              Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: C.muted)),
            ]),
          ),
        ),
      );
}
