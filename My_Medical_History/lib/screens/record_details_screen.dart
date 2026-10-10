import 'package:flutter/material.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';

class RecordDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> visit;
  const RecordDetailsScreen({super.key, required this.visit});

  String _s(String k) => '${visit[k] ?? ''}';
  List _l(String k) => (visit[k] as List?) ?? const [];

  Future<void> _delete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete this visit?'),
        content: const Text('It will be removed from this phone and from your Google Drive backup.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete', style: TextStyle(color: C.red))),
        ],
      ),
    );
    if (ok != true) return;
    await Store.instance.deleteVisit(_s('id'));
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final symptoms = _s('symptoms').split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    return Scaffold(
      appBar: topBar(context, 'Record Details', 'My Medical History'),
      body: ListView(padding: const EdgeInsets.all(12), children: [
        Card2(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Pill('Saved record', C.mint, C.green, icon: Icons.check_circle_outline),
            const SizedBox(height: 10),
            Text(_s('date'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: C.lav, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Avatar(bare(_s('doctor')), 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_s('doctor'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    if (_s('spec').isNotEmpty) Text(_s('spec'), style: const TextStyle(fontSize: 12, color: C.muted)),
                    if (_s('hospital').isNotEmpty) Text(_s('hospital'), style: const TextStyle(fontSize: 12, color: C.muted)),
                    if (_s('phone').isNotEmpty) Text(_s('phone'), style: const TextStyle(fontSize: 12, color: C.muted)),
                  ]),
                ),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        _Section(Icons.medical_information_outlined, 'Diagnosis & Symptoms', [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: C.lav, borderRadius: BorderRadius.circular(10)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('PRIMARY DIAGNOSIS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: C.muted)),
              const SizedBox(height: 2),
              Text(_s('dx'), style: const TextStyle(color: C.primary, fontWeight: FontWeight.w700)),
            ]),
          ),
          if (symptoms.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(spacing: 6, runSpacing: 6, children: [for (final s in symptoms) Pill(s, C.lav, C.ink)]),
          ],
        ]),
        if (_l('meds').isNotEmpty)
          _Section(Icons.medication_outlined, 'Prescribed Medicines', [
            for (final m in _l('meds'))
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: C.lav, borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('• ${m['name']} ${m['dose']}'.trim(), style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text([m['freq'], m['days']].where((e) => '${e ?? ''}'.isNotEmpty).join(' • '), style: const TextStyle(fontSize: 12, color: C.muted)),
                      if ('${m['note'] ?? ''}'.isNotEmpty) Text('${m['note']}', style: const TextStyle(fontSize: 12)),
                    ]),
                  ),
                  Pill('${m['meal'] ?? ''}', C.mint, C.green),
                ]),
              ),
          ]),
        if (_l('tests').isNotEmpty)
          _Section(Icons.science_outlined, 'Medical Tests & Labs', [
            for (final t in _l('tests'))
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: C.lav, borderRadius: BorderRadius.circular(10)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${t['name']}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  if ('${t['result'] ?? ''}'.isNotEmpty) Text('Result: ${t['result']}', style: const TextStyle(fontSize: 12, color: C.muted)),
                ]),
              ),
          ]),
        if (_l('files').isNotEmpty)
          _Section(Icons.description_outlined, 'Prescription & Reports', [
            for (final f in _l('files'))
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: C.lav, borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  const Icon(Icons.insert_drive_file_outlined, color: C.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${f['name']}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      const Text('☁ Stored in your Google Drive › My Medical History', style: TextStyle(fontSize: 11, color: C.green)),
                    ]),
                  ),
                ]),
              ),
          ]),
        if (_s('notes').isNotEmpty) _Section(Icons.sticky_note_2_outlined, 'Doctor Notes', [Text(_s('notes'), style: const TextStyle(fontSize: 13, height: 1.4))]),
        if (_s('followUp').isNotEmpty) _Section(Icons.event_repeat, 'Follow-up', [Text(_s('followUp'), style: const TextStyle(fontWeight: FontWeight.w700, color: C.primary))]),
        const SizedBox(height: 4),
        SizedBox(
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () => _delete(context),
            icon: const Icon(Icons.delete_outline, color: C.red),
            label: const Text('Delete Visit', style: TextStyle(color: C.red, fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: C.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ),
        const SizedBox(height: 16),
      ]),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;
  const _Section(this.icon, this.title, this.children);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Card2(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              IconBadge(icon, C.lav2, C.primary, 28),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
            ]),
            const SizedBox(height: 12),
            ...children,
          ]),
        ),
      );
}
