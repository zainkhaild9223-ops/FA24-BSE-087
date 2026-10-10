import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';
import 'add_record_screen.dart';
import 'record_details_screen.dart';

class DoctorProfileScreen extends StatelessWidget {
  final String name;
  const DoctorProfileScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final all = Store.instance.raw;
    final idx = [for (var i = 0; i < all.length; i++) if ('${all[i]['doctor']}' == name) i];
    if (idx.isEmpty) {
      return Scaffold(appBar: topBar(context, 'Doctor Profile', 'My Medical History'), body: const Center(child: Text('No visits found')));
    }
    String f(Map v, String k) => '${v[k] ?? ''}';
    final last = all[idx.first]; // newest visit
    final spec = f(last, 'spec'), hospital = f(last, 'hospital'), phone = f(last, 'phone');
    final medNames = <String>{
      for (final i in idx)
        for (final m in ((all[i]['meds'] as List?) ?? const [])) if (m is Map && '${m['name']}'.isNotEmpty) '${m['name']}'
    };
    return Scaffold(
      appBar: topBar(context, 'Doctor Profile', 'My Medical History'),
      body: ListView(padding: const EdgeInsets.all(12), children: [
        Card2(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Avatar(bare(name), 38),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (spec.isNotEmpty) Pill(spec, C.blueChip, C.primary, icon: Icons.favorite_border),
                  const SizedBox(height: 6),
                  Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                  if (hospital.isNotEmpty)
                    Row(children: [
                      const Icon(Icons.local_hospital_outlined, size: 14, color: C.primary),
                      const SizedBox(width: 4),
                      Expanded(child: Text(hospital, style: const TextStyle(fontSize: 12, color: C.primary, fontWeight: FontWeight.w600))),
                    ]),
                ]),
              ),
            ]),
            if (phone.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: C.lav, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Icon(Icons.call, size: 18, color: C.primary),
                  const SizedBox(width: 10),
                  Expanded(child: Text(phone, style: const TextStyle(fontWeight: FontWeight.w600))),
                  TextButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: phone));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone number copied')));
                    },
                    child: const Text('Copy'),
                  ),
                ]),
              ),
            ],
          ]),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _Mini(Icons.calendar_month_outlined, C.blueChip, C.primary, '${idx.length}', 'Total Visits')),
          const SizedBox(width: 8),
          Expanded(child: _Mini(Icons.event_available, C.mint, C.green, f(last, 'date'), 'Last Visit')),
          const SizedBox(width: 8),
          Expanded(child: _Mini(Icons.medication_outlined, const Color(0xFF9CF0E0), const Color(0xFF006A60), '${medNames.length}', 'Medicines')),
        ]),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: C.lav, borderRadius: BorderRadius.circular(14)),
          child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.info_outline, color: C.primary),
            SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Continuous Longitudinal Care', style: TextStyle(fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text('The same doctor can have multiple visits over time. All encounters, prescriptions and tests are tracked below.', style: TextStyle(fontSize: 13, color: C.muted)),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        Btn('+ Add New Visit with $name', icon: Icons.add_circle_outline, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddRecordScreen(doctorName: name)))),
        const SizedBox(height: 20),
        Row(children: [const H('Visit History'), const SizedBox(width: 8), Pill('${idx.length} recorded', C.lav2, C.ink)]),
        const SizedBox(height: 12),
        for (var k = 0; k < idx.length; k++)
          IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              SizedBox(
                width: 26,
                child: Column(children: [
                  Container(width: 12, height: 12, margin: const EdgeInsets.only(top: 4), decoration: BoxDecoration(shape: BoxShape.circle, color: k == 0 ? C.primary : C.muted)),
                  if (k < idx.length - 1) Expanded(child: Container(width: 2, color: C.lav2)),
                ]),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(f(all[idx[k]], 'date'), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: k == 0 ? C.primary : C.muted)),
                    const SizedBox(height: 6),
                    Card2(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecordDetailsScreen(visit: all[idx[k]]))),
                      child: Row(children: [
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('PRIMARY DIAGNOSIS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: C.muted, letterSpacing: .8)),
                            const SizedBox(height: 4),
                            Text(f(all[idx[k]], 'dx'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            Text('${((all[idx[k]]['meds'] as List?) ?? const []).length} Medicines • ${((all[idx[k]]['tests'] as List?) ?? const []).length} Tests', style: const TextStyle(fontSize: 12, color: C.muted)),
                          ]),
                        ),
                        const IconBadge(Icons.chevron_right, C.lav, C.ink, 32),
                      ]),
                    ),
                  ]),
                ),
              ),
            ]),
          ),
        const SizedBox(height: 24),
      ]),
    );
  }
}

class _Mini extends StatelessWidget {
  final IconData icon;
  final Color bg, fg;
  final String v, l;
  const _Mini(this.icon, this.bg, this.fg, this.v, this.l);
  @override
  Widget build(BuildContext context) => Card2(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        child: Column(children: [
          IconBadge(icon, bg, fg, 30),
          const SizedBox(height: 6),
          Text(v, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          Text(l, style: const TextStyle(fontSize: 11, color: C.muted)),
        ]),
      );
}
