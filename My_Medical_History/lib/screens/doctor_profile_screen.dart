import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import 'add_record_screen.dart';
import 'record_details_screen.dart';

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: topBar(context, 'Doctor Profile', 'My Medical History'),
      body: ListView(padding: const EdgeInsets.all(12), children: [
        Card2(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Stack(children: [
                ClipRRect(borderRadius: BorderRadius.circular(10), child: Container(width: 76, height: 76, color: C.blueChip, child: const Icon(Icons.person, size: 44, color: C.primary))),
                const Positioned(right: 0, bottom: 0, child: IconBadge(Icons.check, C.green, Colors.white, 20)),
              ]),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Pill('Cardiology & Medicine', C.blueChip, C.primary, icon: Icons.favorite_border),
                  SizedBox(height: 6),
                  Text('Dr. Ahmed Khan', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                  Text('Consultant Cardiologist & Internal Medi...', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: C.muted)),
                  SizedBox(height: 2),
                  Row(children: [
                    Icon(Icons.local_hospital_outlined, size: 14, color: C.primary),
                    SizedBox(width: 4),
                    Text('City Medical Hospital', style: TextStyle(fontSize: 12, color: C.primary, fontWeight: FontWeight.w600)),
                  ]),
                ]),
              ),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(flex: 3, child: Btn('Call Doctor', icon: Icons.call, onTap: () {})),
              const SizedBox(width: 8),
              Expanded(flex: 2, child: Btn('Share', icon: Icons.share_outlined, filled: false, onTap: () {})),
            ]),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: C.lav, borderRadius: BorderRadius.circular(12)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [
                  IconBadge(Icons.location_on_outlined, C.lav2, C.primary, 34),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Clinic Address', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: C.muted)),
                      Text('450 Wellness Blvd, Suite 300, Medical City', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ]),
                const SizedBox(height: 10),
                Container(
                  height: 110,
                  decoration: BoxDecoration(color: const Color(0xFFC5C6EA), borderRadius: BorderRadius.circular(10)),
                  child: Stack(children: [
                    const Center(child: Pill('Suite 300 Floor 3', Colors.white, C.ink, icon: Icons.location_on)),
                    Positioned(
                      right: 8, bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: C.primary, borderRadius: BorderRadius.circular(6)),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.map_outlined, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text('Open Maps', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                        ]),
                      ),
                    ),
                  ]),
                ),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        const Row(children: [
          Expanded(child: _Mini(Icons.calendar_month_outlined, C.blueChip, C.primary, '4', 'Total Visits')),
          SizedBox(width: 8),
          Expanded(child: _Mini(Icons.event_available, C.mint, C.green, '06 Oct 2026', 'Last Visit')),
          SizedBox(width: 8),
          Expanded(child: _Mini(Icons.medication_outlined, Color(0xFF9CF0E0), Color(0xFF006A60), '8', 'Medicines')),
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
                Text('The same doctor can have multiple visits over time. All clinical encounters, prescriptions, and lab tests are chronologically tracked below.', style: TextStyle(fontSize: 13, color: C.muted)),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        Btn('+ Add New Visit with Dr. Ahmed Khan', icon: Icons.add_circle_outline, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddRecordScreen()))),
        const SizedBox(height: 20),
        const Row(children: [
          H('Visit History'),
          SizedBox(width: 8),
          Pill('3 recorded', C.lav2, C.ink),
          Spacer(),
          Text('Filter Timeline ', style: TextStyle(color: C.primary, fontWeight: FontWeight.w700, fontSize: 12)),
          Icon(Icons.tune, size: 16, color: C.primary),
        ]),
        const SizedBox(height: 12),
        _Timeline(first: true, date: '06 Oct 2026', badge: const Pill('Follow-up completed', C.mint, C.green, icon: Icons.check_circle_outline), title: 'Viral Infection',
            body: 'Patient presented with seasonal cough, elevated temperature (38.4°C), and fatigue. Advised...',
            rows: const [(Icons.medication_outlined, '3 Prescriptions: Panadol 500mg, Amoxicillin 625mg, Cetirizine'), (Icons.biotech_outlined, '2 Clinical Tests: CBC, Chest X-Ray (Normal)')],
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecordDetailsScreen()))),
        const _Timeline(date: '15 Nov 2025', badge: Pill('Routine Review', C.lav2, C.ink), title: 'Hypertension Follow-up',
            body: 'Blood pressure logged at 134/86 mmHg. Moderate improvement noted with current lifestyle modifications and diet adjustments.',
            rows: [(Icons.medication_outlined, '2 Prescriptions: Amlodipine 5mg, Low-dose Aspirin'), (Icons.monitor_heart_outlined, '1 Diagnostic: Resting 12-Lead ECG')]),
        const _Timeline(last: true, date: '03 Jan 2025', badge: Pill('Preventative', C.lav2, C.ink), title: 'Annual Cardiac Checkup',
            body: 'Initial baseline assessment. Cardiac rhythms steady, clear valve sounds, no reported chest pressure during normal exercise.',
            rows: [(Icons.medication_outlined, '1 Prescription: Daily Cardiac Multivitamin'), (Icons.science_outlined, '0 Tests: No invasive procedures required')]),
        const SizedBox(height: 12),
        const Center(child: Pill('Start of medical records with Dr. Khan (Jan 2025)', C.lav, C.muted, icon: Icons.history)),
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
          Text(v, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          Text(l, style: const TextStyle(fontSize: 11, color: C.muted)),
        ]),
      );
}

class _Timeline extends StatelessWidget {
  final bool first, last;
  final String date, title, body;
  final Widget badge;
  final List<(IconData, String)> rows;
  final VoidCallback? onTap;
  const _Timeline({this.first = false, this.last = false, required this.date, required this.badge, required this.title, required this.body, required this.rows, this.onTap});

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SizedBox(
            width: 28,
            child: Column(children: [
              Container(
                width: 14, height: 14, margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(shape: BoxShape.circle, color: first ? C.primary : C.muted.withOpacity(.5), border: Border.all(color: first ? C.lav2 : Colors.transparent, width: 3)),
              ),
              if (!last) Expanded(child: Container(width: 2, color: C.lav2)),
            ]),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(date, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: first ? C.primary : C.muted)),
                  badge,
                ]),
                const SizedBox(height: 8),
                Card2(
                  onTap: onTap,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('PRIMARY DIAGNOSIS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: C.muted, letterSpacing: .8)),
                          const SizedBox(height: 4),
                          Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
                        ]),
                      ),
                      const IconBadge(Icons.chevron_right, C.lav, C.ink, 32),
                    ]),
                    const SizedBox(height: 8),
                    Text(body, style: const TextStyle(fontSize: 13, color: C.muted, height: 1.4)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: C.lav, borderRadius: BorderRadius.circular(10)),
                      child: Column(children: [
                        for (final r in rows)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Icon(r.$1, size: 18, color: C.primary),
                              const SizedBox(width: 8),
                              Expanded(child: Text(r.$2, style: const TextStyle(fontSize: 12.5))),
                            ]),
                          ),
                      ]),
                    ),
                  ]),
                ),
              ]),
            ),
          ),
        ]),
      );
}
