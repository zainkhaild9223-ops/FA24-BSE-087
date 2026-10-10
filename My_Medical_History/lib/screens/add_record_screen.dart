import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../drive_service.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
String _fmt(DateTime d) => '${d.day.toString().padLeft(2, '0')} ${_months[d.month - 1]} ${d.year}';

class _MedForm {
  final name = TextEditingController(), dose = TextEditingController(), freq = TextEditingController(), days = TextEditingController(), note = TextEditingController();
  String meal = 'After Meal';
  Map<String, dynamic> toMap() => {'name': name.text.trim(), 'dose': dose.text.trim(), 'freq': freq.text.trim(), 'days': days.text.trim(), 'meal': meal, 'note': note.text.trim()};
}

class AddRecordScreen extends StatefulWidget {
  final String? doctorName;
  const AddRecordScreen({super.key, this.doctorName});
  @override
  State<AddRecordScreen> createState() => _AddRecordState();
}

class _AddRecordState extends State<AddRecordScreen> {
  final doctor = TextEditingController(), spec = TextEditingController(), phone = TextEditingController(), hospital = TextEditingController();
  final dx = TextEditingController(), symptoms = TextEditingController(), notes = TextEditingController();
  DateTime date = DateTime.now();
  DateTime? followUp;
  final meds = <_MedForm>[_MedForm()];
  final tests = <List<TextEditingController>>[];
  final files = <Map<String, dynamic>>[];
  bool saving = false;

  @override
  void initState() {
    super.initState();
    final n = widget.doctorName;
    if (n == null) return;
    for (final d in Store.instance.docs) {
      if (d.name == n) {
        doctor.text = d.name;
        spec.text = d.spec;
        phone.text = d.phone;
        hospital.text = d.hospital;
      }
    }
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Widget _field(String label, TextEditingController c, {int lines = 1, TextInputType? kb}) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          controller: c, maxLines: lines, keyboardType: kb,
          decoration: InputDecoration(
            labelText: label, filled: true, fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.border)),
          ),
        ),
      );

  Widget _dateField(String label, DateTime? d, ValueChanged<DateTime> onPick) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          onTap: () async {
            final p = await showDatePicker(context: context, initialDate: d ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
            if (p != null) setState(() => onPick(p));
          },
          child: InputDecorator(
            decoration: InputDecoration(labelText: label, filled: true, fillColor: Colors.white, suffixIcon: const Icon(Icons.calendar_today, size: 18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(d == null ? 'Not set' : _fmt(d)),
          ),
        ),
      );

  Future<void> _pick(String kind) async {
    File? picked;
    if (kind == 'pdf') {
      final r = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
      final p = r?.files.single.path;
      if (p != null) picked = File(p);
    } else {
      final x = await ImagePicker().pickImage(source: kind == 'camera' ? ImageSource.camera : ImageSource.gallery);
      if (x != null) picked = File(x.path);
    }
    if (picked == null) return;
    final file = picked;
    final entry = <String, dynamic>{'name': file.path.split(Platform.pathSeparator).last, 'status': 'uploading'};
    setState(() => files.add(entry));
    try {
      final up = await DriveService.instance.upload(file); // -> user's own Google Drive
      entry['driveId'] = up.id;
      entry['status'] = 'done';
    } catch (e) {
      entry['status'] = 'failed';
      if (mounted) _snack('Drive upload failed: $e');
    }
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    if (doctor.text.trim().isEmpty || dx.text.trim().isEmpty) return _snack('Doctor name and diagnosis are required');
    if (files.any((f) => f['status'] == 'uploading')) return _snack('Please wait for the upload to finish');
    setState(() => saving = true);
    await Store.instance.addVisit({
      'date': _fmt(date), 'doctor': doctor.text.trim(), 'spec': spec.text.trim(), 'phone': phone.text.trim(), 'hospital': hospital.text.trim(),
      'dx': dx.text.trim(), 'symptoms': symptoms.text.trim(), 'notes': notes.text.trim(), 'followUp': followUp == null ? '' : _fmt(followUp!),
      'meds': [for (final m in meds) if (m.name.text.trim().isNotEmpty) m.toMap()],
      'tests': [for (final t in tests) if (t[0].text.trim().isNotEmpty) {'name': t[0].text.trim(), 'result': t[1].text.trim()}],
      'files': [for (final f in files) if (f['status'] == 'done') {'name': f['name'], 'driveId': f['driveId']}],
    });
    if (!mounted) return;
    final m = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    m.showSnackBar(const SnackBar(content: Text('Visit saved. Syncing to your Google Drive...')));
  }

  @override
  Widget build(BuildContext context) {
    final known = Store.instance.docs;
    return Scaffold(
      appBar: topBar(context, 'Add Record', 'My Medical History'),
      body: Column(children: [
        Expanded(
          child: ListView(padding: const EdgeInsets.all(14), children: [
            const H('Doctor'),
            const SizedBox(height: 8),
            if (known.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Wrap(spacing: 8, children: [
                  for (final d in known)
                    ActionChip(
                      label: Text(d.name), backgroundColor: C.lav2, side: BorderSide.none,
                      onPressed: () => setState(() { doctor.text = d.name; spec.text = d.spec; phone.text = d.phone; hospital.text = d.hospital; }),
                    ),
                ]),
              ),
            _field('Doctor name *', doctor),
            _field('Specialization', spec),
            _field('Phone', phone, kb: TextInputType.phone),
            _field('Hospital / Clinic', hospital),
            const SizedBox(height: 8),
            const H('Visit Information'),
            const SizedBox(height: 8),
            _dateField('Visit date', date, (d) => date = d),
            _field('Diagnosis *', dx),
            _field('Symptoms', symptoms, lines: 2),
            _field("Doctor's notes", notes, lines: 2),
            _dateField('Follow-up date', followUp, (d) => followUp = d),
            const SizedBox(height: 8),
            const H('Prescribed Medicines'),
            const SizedBox(height: 8),
            for (int i = 0; i < meds.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card2(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text('Medicine ${i + 1}', style: const TextStyle(fontWeight: FontWeight.w700))),
                      if (meds.length > 1) IconButton(icon: const Icon(Icons.delete_outline, color: C.red), onPressed: () => setState(() => meds.removeAt(i))),
                    ]),
                    _field('Medicine name', meds[i].name),
                    Row(children: [
                      Expanded(child: _field('Dose (500mg)', meds[i].dose)),
                      const SizedBox(width: 8),
                      Expanded(child: _field('Frequency', meds[i].freq)),
                      const SizedBox(width: 8),
                      Expanded(child: _field('Duration', meds[i].days)),
                    ]),
                    Wrap(spacing: 8, children: [
                      for (final o in ['Before Meal', 'After Meal', 'With Meal', 'Night'])
                        ChoiceChip(label: Text(o), selected: meds[i].meal == o, showCheckmark: false, selectedColor: C.blueChip, onSelected: (_) => setState(() => meds[i].meal = o)),
                    ]),
                    const SizedBox(height: 10),
                    _field('Instructions', meds[i].note),
                  ]),
                ),
              ),
            _Dashed('Add Medicine', () => setState(() => meds.add(_MedForm()))),
            const SizedBox(height: 20),
            const H('Medical Tests & Labs'),
            const SizedBox(height: 8),
            for (final t in tests) Card2(child: Column(children: [_field('Test name', t[0]), _field('Result', t[1])])),
            if (tests.isNotEmpty) const SizedBox(height: 10),
            _Dashed('Add Medical Test', () => setState(() => tests.add([TextEditingController(), TextEditingController()]))),
            const SizedBox(height: 20),
            const H('Prescription & Reports'),
            const SizedBox(height: 4),
            const Text('Files are uploaded to your own Google Drive', style: TextStyle(fontSize: 12, color: C.muted)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _Upload(Icons.photo_camera_outlined, 'Take Photo', () => _pick('camera'))),
              const SizedBox(width: 8),
              Expanded(child: _Upload(Icons.photo_library_outlined, 'Gallery', () => _pick('gallery'))),
              const SizedBox(width: 8),
              Expanded(child: _Upload(Icons.upload_file, 'Upload PDF', () => _pick('pdf'))),
            ]),
            const SizedBox(height: 10),
            for (final f in files) Padding(padding: const EdgeInsets.only(bottom: 8), child: _FileCard('${f['name']}', '${f['status']}')),
            const SizedBox(height: 12),
          ]),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
          child: SafeArea(
            top: false,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Btn(saving ? 'Saving...' : 'Save Medical Visit', onTap: saving ? null : _save),
              const SizedBox(height: 6),
              const Text('☁ Saved on this phone and auto-synced to your Google Drive', style: TextStyle(fontSize: 10, color: C.muted)),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _Dashed extends StatelessWidget {
  final String t;
  final VoidCallback onTap;
  const _Dashed(this.t, this.onTap);
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: C.primary.withOpacity(.4), width: 1.5), color: C.lav),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.add_circle_outline, size: 18, color: C.primary), const SizedBox(width: 8),
            Text('+ $t', style: const TextStyle(color: C.primary, fontWeight: FontWeight.w700)),
          ]),
        ),
      );
}

class _Upload extends StatelessWidget {
  final IconData i;
  final String t;
  final VoidCallback onTap;
  const _Upload(this.i, this.t, this.onTap);
  @override
  Widget build(BuildContext context) => Card2(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(children: [
          IconBadge(i, C.lav2, C.primary, 34),
          const SizedBox(height: 6),
          Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      );
}

class _FileCard extends StatelessWidget {
  final String name, status;
  const _FileCard(this.name, this.status);
  @override
  Widget build(BuildContext context) => Card2(
        child: Row(children: [
          Container(width: 44, height: 52, decoration: BoxDecoration(color: C.lav, borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.receipt_long, color: C.muted)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              Text(
                status == 'uploading' ? 'Uploading to your Google Drive...' : status == 'done' ? '☁ Saved to your Google Drive' : 'Upload failed',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: status == 'failed' ? C.red : status == 'done' ? C.green : C.muted),
              ),
            ]),
          ),
          if (status == 'uploading') const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
        ]),
      );
}
