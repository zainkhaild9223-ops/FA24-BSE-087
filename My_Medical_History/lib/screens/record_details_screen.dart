import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';

class RecordDetailsScreen extends StatelessWidget {
  const RecordDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        titleSpacing: 0,
        title: const Row(children: [
          IconBadge(Icons.add, C.primary, Colors.white, 28),
          SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Record Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text('My Medical History', style: TextStyle(fontSize: 10, color: C.primary, fontWeight: FontWeight.w600)),
          ]),
        ]),
        actions: const [Padding(padding: EdgeInsets.only(right: 16), child: Avatar('Sarah', 14))],
      ),
      body: ListView(padding: const EdgeInsets.all(12), children: [
        const Row(children: [
          Icon(Icons.local_hospital_outlined, size: 14, color: C.primary),
          SizedBox(width: 6),
          Expanded(child: Text('Outpatient Consultation #MED-8842', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
          Icon(Icons.share_outlined, size: 18),
          SizedBox(width: 12),
          Icon(Icons.edit_outlined, size: 18),
        ]),
        const SizedBox(height: 10),
        Card2(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Pill('Verified Record', C.mint, C.green, icon: Icons.verified_outlined),
              Row(children: [Icon(Icons.access_time, size: 14, color: C.muted), SizedBox(width: 4), Text('10:30 AM', style: TextStyle(fontSize: 12, color: C.muted))]),
            ]),
            const SizedBox(height: 10),
            const Text('06 October 2026', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: C.lav, borderRadius: BorderRadius.circular(12)),
              child: const Row(children: [
                Avatar('A', 20),
                SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Dr. Ahmed Khan', style: TextStyle(fontWeight: FontWeight.w700)),
                    Text('Cardiology & General Medicine', style: TextStyle(fontSize: 12, color: C.muted)),
                    Text('City Medical Hospital (Downtown Branch)', style: TextStyle(fontSize: 11, color: C.muted)),
                  ]),
                ),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        _Section(Icons.medical_information_outlined, 'Diagnosis & Symptoms', const Pill('Moderate', C.lav2, C.ink), [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: C.lav, borderRadius: BorderRadius.circular(10)),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('PRIMARY DIAGNOSIS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: C.muted)),
              SizedBox(height: 2),
              Text('Viral Upper Respiratory Infection & Mild Bronchitis', style: TextStyle(color: C.primary, fontWeight: FontWeight.w700)),
            ]),
          ),
          const SizedBox(height: 10),
          const Text('SYMPTOMS REPORTED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: C.muted)),
          const SizedBox(height: 6),
          const Wrap(spacing: 6, runSpacing: 6, children: [
            Pill('High-grade fever (101.4°F)', Color(0xFFFFE3E0), C.red, icon: Icons.thermostat),
            Pill('Dry persistent cough (4 days)', C.lav, C.ink),
            Pill('Mild fatigue', C.lav, C.ink),
            Pill('Throat congestion', C.lav, C.ink),
          ]),
        ]),
        _Section(Icons.medication_outlined, 'Prescribed Medicines', const Pill('3 Items', C.lav2, C.ink), const [
          _Med('Panadol 500mg', 'Dosage: 1 Tablet • 3x per day', 'After Meal', '5 Days', C.mint, C.green),
          _Med('Amoxicillin 250mg', 'Dosage: 1 Capsule • 2x per day', 'Before Meal', '7 Days', C.blueChip, C.primary),
          _Med('Cetirizine 10mg', 'Dosage: 1 Tablet at bedtime', 'Night', '3 Days', C.blueChip, C.primary),
        ]),
        _Section(Icons.science_outlined, 'Medical Tests & Labs', const Pill('2 Ordered', C.lav2, C.ink), [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: C.lav, borderRadius: BorderRadius.circular(10)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Expanded(child: Text('Complete Blood Count (CBC)', style: TextStyle(fontWeight: FontWeight.w700))),
                Icon(Icons.check_circle_outline, color: C.green, size: 18),
              ]),
              const Text('Result: Normal leukocytes, mild viral profile', style: TextStyle(fontSize: 12, color: C.muted)),
              const SizedBox(height: 8),
              Align(alignment: Alignment.centerRight, child: Pill('View Lab Report (PDF)', Colors.white, C.primary, icon: Icons.picture_as_pdf_outlined)),
            ]),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: C.lav, borderRadius: BorderRadius.circular(10)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Expanded(child: Text('Chest X-Ray (PA View)', style: TextStyle(fontWeight: FontWeight.w700))),
                Icon(Icons.check_circle_outline, color: C.green, size: 18),
              ]),
              const Text('Result: Clear lung fields, no infiltrates', style: TextStyle(fontSize: 12, color: C.muted)),
              const SizedBox(height: 8),
              Align(alignment: Alignment.centerRight, child: Pill('View Imaging', Colors.white, C.primary, icon: Icons.image_outlined)),
            ]),
          ),
        ]),
        _Section(Icons.description_outlined, 'Prescription Document', null, [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: C.lav, borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              Container(width: 56, height: 64, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.receipt_long, color: C.muted)),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Official Rx Slip - Dr. Ahmed Khan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  Text('JPEG • 3.4 MB • Scanned on 06 Oct 2026', style: TextStyle(fontSize: 11, color: C.muted)),
                  SizedBox(height: 4),
                  Text('Expand Full Screen', style: TextStyle(fontSize: 11, color: C.primary, fontWeight: FontWeight.w700)),
                ]),
              ),
            ]),
          ),
        ]),
        _Section(Icons.sticky_note_2_outlined, 'Doctor Notes & Instructions', null, const [
          Text('"Patient advised strict bed rest for 48 hours. Hydrate adequately (minimum 2.5L daily). If fever persists above 102°F after 3 days, report back."', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13, height: 1.4)),
          SizedBox(height: 8),
          Pill('Hydration monitoring enabled', C.mint, C.green, icon: Icons.water_drop_outlined),
        ]),
        _Section(Icons.event_repeat, 'Follow-up & Next Steps', const Pill('In 6 days', C.mint, C.green), [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: C.lav, borderRadius: BorderRadius.circular(10)),
            child: const Row(children: [
              Column(children: [Text('OCT', style: TextStyle(fontSize: 10, color: C.primary, fontWeight: FontWeight.w700)), Text('12', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: C.primary))]),
              SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Scheduled Follow-up', style: TextStyle(fontWeight: FontWeight.w700)),
                  Text('12 October 2026 • 11:00 AM with Dr. Khan', style: TextStyle(fontSize: 11, color: C.muted)),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 8),
          Btn('Add Follow-up Reminder to Calendar', icon: Icons.event, filled: false, onTap: () {}),
        ]),
        const SizedBox(height: 4),
        const Center(child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.edit_outlined, size: 16), SizedBox(width: 6), Text('Edit Visit', style: TextStyle(fontWeight: FontWeight.w700))])),
        const SizedBox(height: 12),
        Btn('Export / Share PDF', icon: Icons.ios_share, onTap: () {}),
        const SizedBox(height: 16),
      ]),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final List<Widget> children;
  const _Section(this.icon, this.title, this.trailing, this.children);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Card2(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              IconBadge(icon, C.lav2, C.primary, 28),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
              if (trailing != null) trailing!,
            ]),
            const SizedBox(height: 12),
            ...children,
          ]),
        ),
      );
}

class _Med extends StatelessWidget {
  final String name, dose, tag, days;
  final Color tagBg, tagFg;
  const _Med(this.name, this.dose, this.tag, this.days, this.tagBg, this.tagFg);
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: C.lav, borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('• $name', style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(dose, style: const TextStyle(fontSize: 12, color: C.muted)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Pill(tag, tagBg, tagFg),
            const SizedBox(height: 6),
            Text(days, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
        ]),
      );
}
