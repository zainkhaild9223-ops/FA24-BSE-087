import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';

class AddRecordScreen extends StatelessWidget {
  const AddRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const steps = ['Doctor', 'Location', 'Visit Info', 'Rx & Tests', 'Review'];
    return Scaffold(
      appBar: topBar(context, 'Add Record', 'My Medical History'),
      body: Column(children: [
        Expanded(
          child: ListView(padding: const EdgeInsets.all(12), children: [
            Row(children: [
              for (int i = 0; i < 5; i++) ...[
                Container(
                  width: 28, height: 28, alignment: Alignment.center,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: i < 4 ? C.primary : C.lav2, border: i == 3 ? Border.all(color: C.blueChip, width: 3) : null),
                  child: i < 3 ? const Icon(Icons.check, size: 15, color: Colors.white) : Text('${i + 1}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: i == 3 ? Colors.white : C.muted)),
                ),
                if (i < 4) Expanded(child: Container(height: 2, color: i < 3 ? C.primary : C.lav2)),
              ],
            ]),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              for (int i = 0; i < 5; i++) Text(steps[i], style: TextStyle(fontSize: 10, fontWeight: i == 3 ? FontWeight.w800 : FontWeight.w500, color: i == 3 ? C.primary : C.muted)),
            ]),
            const SizedBox(height: 14),
            Card2(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('VISIT SELECTED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: C.muted)),
                  Text('06 Oct 2026', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                ]),
                const Text('Dr. Ahmed Khan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const Text('City Medical Hospital', style: TextStyle(fontSize: 12, color: C.muted)),
                const SizedBox(height: 6),
                const Pill('Reason: Persistent Cough & Fever', C.lav2, C.ink, icon: Icons.favorite_border),
              ]),
            ),
            const SizedBox(height: 16),
            const Row(children: [Expanded(child: H('Prescribed Medicines')), Pill('2 Added', C.lav2, C.ink)]),
            const SizedBox(height: 4),
            const Text('Add each medicine prescribed during this visit', style: TextStyle(fontSize: 12, color: C.muted)),
            const SizedBox(height: 10),
            const _MedCard('Panadol (Paracetamol) 500mg', '1 Tablet • 2 times daily (every 8 hrs)', '5 Days', 'After Meal', 'Take with plenty of water. Stop if fever subsides.'),
            const SizedBox(height: 8),
            const _MedCard('Amoxicillin 250mg', '1 Capsule • 2 times daily', '7 Days', 'Before Meal', 'Complete the entire course without interruption.'),
            const SizedBox(height: 10),
            _Dashed('Add Another Medicine', Icons.add_circle_outline),
            const SizedBox(height: 16),
            const Row(children: [Expanded(child: H('Medical Tests & Labs')), Pill('1 Test', C.lav2, C.ink)]),
            const SizedBox(height: 4),
            const Text('Investigations required by the doctor', style: TextStyle(fontSize: 12, color: C.muted)),
            const SizedBox(height: 10),
            Card2(
              child: Row(children: [
                const IconBadge(Icons.science_outlined, C.lav2, C.primary, 34),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Complete Blood Count', style: TextStyle(fontWeight: FontWeight.w700)),
                    Text('06 Oct 2026 • Lab Panel', style: TextStyle(fontSize: 11, color: C.muted)),
                  ]),
                ),
                const Pill('Pending review', Color(0xFFFFE9C7), Color(0xFF8A5A00)),
              ]),
            ),
            const SizedBox(height: 10),
            _Dashed('Add Medical Test', Icons.add_circle_outline),
            const SizedBox(height: 16),
            const H('Prescription Document'),
            const SizedBox(height: 4),
            const Text('Attach scan, phone camera photo, or digital note', style: TextStyle(fontSize: 12, color: C.muted)),
            const SizedBox(height: 10),
            const Row(children: [
              Expanded(child: _Upload(Icons.photo_camera_outlined, 'Take Photo')),
              SizedBox(width: 8),
              Expanded(child: _Upload(Icons.photo_library_outlined, 'Gallery')),
              SizedBox(width: 8),
              Expanded(child: _Upload(Icons.upload_file, 'Upload PDF')),
            ]),
            const SizedBox(height: 10),
            Card2(
              child: Row(children: [
                Container(width: 44, height: 52, decoration: BoxDecoration(color: C.lav, borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.receipt_long, color: C.muted)),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Rx_Khan_060ct2026.pdf', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    Text('1.2 MB • Scanned & text indexed', style: TextStyle(fontSize: 11, color: C.muted)),
                    Text('☁ Uploaded & scanned', style: TextStyle(fontSize: 11, color: C.green, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 8),
            const Row(children: [
              Icon(Icons.visibility_outlined, size: 14, color: C.primary), SizedBox(width: 4),
              Text('View Preview', style: TextStyle(fontSize: 12, color: C.primary, fontWeight: FontWeight.w700)),
              Spacer(),
              Icon(Icons.refresh, size: 14), SizedBox(width: 4), Text('Replace', style: TextStyle(fontSize: 12)),
              SizedBox(width: 16),
              Icon(Icons.delete_outline, size: 14, color: C.red), SizedBox(width: 4), Text('Delete', style: TextStyle(fontSize: 12, color: C.red)),
            ]),
          ]),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
          child: SafeArea(
            top: false,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                Expanded(child: Btn('‹ Back', filled: false, onTap: () => Navigator.pop(context))),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: Btn('Save & Review Visit  →', onTap: () {})),
              ]),
              const SizedBox(height: 6),
              const Text('☁ Automatically backed up to Google Drive when saved', style: TextStyle(fontSize: 10, color: C.muted)),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _MedCard extends StatelessWidget {
  final String name, dose, days, when, note;
  const _MedCard(this.name, this.dose, this.days, this.when, this.note);
  @override
  Widget build(BuildContext context) => Card2(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const IconBadge(Icons.medication_outlined, C.lav2, C.primary, 32),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                Text(dose, style: const TextStyle(fontSize: 11, color: C.muted)),
              ]),
            ),
            const Icon(Icons.edit_outlined, size: 16), const SizedBox(width: 8),
            const Icon(Icons.delete_outline, size: 16, color: C.red),
          ]),
          const SizedBox(height: 8),
          Wrap(spacing: 6, children: [Pill(days, C.lav2, C.ink), Pill(when, C.mint, C.green)]),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: C.lav, borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              const Icon(Icons.info_outline, size: 14, color: C.primary), const SizedBox(width: 6),
              Expanded(child: Text(note, style: const TextStyle(fontSize: 11))),
            ]),
          ),
        ]),
      );
}

class _Dashed extends StatelessWidget {
  final String t;
  final IconData i;
  const _Dashed(this.t, this.i);
  @override
  Widget build(BuildContext context) => Container(
        height: 48,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: C.primary.withOpacity(.4), width: 1.5), color: C.lav),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(i, size: 18, color: C.primary), const SizedBox(width: 8),
          Text(t, style: const TextStyle(color: C.primary, fontWeight: FontWeight.w700)),
        ]),
      );
}

class _Upload extends StatelessWidget {
  final IconData i;
  final String t;
  const _Upload(this.i, this.t);
  @override
  Widget build(BuildContext context) => Card2(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(children: [
          IconBadge(i, C.lav2, C.primary, 34),
          const SizedBox(height: 6),
          Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      );
}
