import 'package:flutter/material.dart';
import '../data.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';
import 'add_record_screen.dart';
import 'backup_sync_screen.dart';
import 'doctor_profile_screen.dart';
import 'record_details_screen.dart';

void _go(BuildContext c, Widget w) => Navigator.push(c, MaterialPageRoute(builder: (_) => w));

const _sheetShape = RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24)));

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String msg;
  final String? btn;
  final VoidCallback? onTap;
  const EmptyState(this.icon, this.msg, {super.key, this.btn, this.onTap});
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            IconBadge(icon, C.lav2, C.primary, 88),
            const SizedBox(height: 16),
            Text(msg, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            if (btn != null) ...[const SizedBox(height: 16), SizedBox(width: 200, child: Btn(btn!, onTap: onTap))],
          ]),
        ),
      );
}

class _TopSearch extends StatelessWidget {
  final String title, hint;
  const _TopSearch(this.title, this.hint);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: Card2(
                onTap: () => _go(context, const SearchScreen()),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Row(children: [
                  const Icon(Icons.search, color: C.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(hint, style: const TextStyle(color: C.muted, fontSize: 14))),
                ]),
              ),
            ),
            const SizedBox(width: 10),
            Card2(onTap: () => showFilterSheet(context), padding: const EdgeInsets.all(14), child: const Icon(Icons.tune)),
          ]),
        ]),
      );
}

// ---------------- Doctors ----------------
class DoctorsScreen extends StatelessWidget {
  const DoctorsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _go(context, const AddRecordScreen()),
          backgroundColor: C.primary, foregroundColor: Colors.white,
          icon: const Icon(Icons.add), label: const Text('Add Doctor'),
        ),
        body: SafeArea(
          child: Column(children: [
            const _TopSearch('Doctors', 'Search doctors...'),
            Expanded(
              child: Store.instance.docs.isEmpty
                  ? EmptyState(Icons.medical_services_outlined, 'No doctors added yet.', btn: 'Add Doctor', onTap: () => _go(context, const AddRecordScreen()))
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                itemCount: Store.instance.docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (c, i) {
                  final d = Store.instance.docs[i];
                  return Card2(
                    onTap: () => _go(c, const DoctorProfileScreen()),
                    child: Row(children: [
                      Avatar(d.name.substring(4), 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(d.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          Text(d.spec, style: const TextStyle(fontSize: 13, color: C.primary, fontWeight: FontWeight.w600)),
                          Text(d.hospital, style: const TextStyle(fontSize: 12, color: C.muted)),
                          const SizedBox(height: 6),
                          Row(children: [
                            const Icon(Icons.call, size: 13, color: C.muted),
                            const SizedBox(width: 4),
                            Text(d.phone, style: const TextStyle(fontSize: 12)),
                            const Spacer(),
                            Pill('${d.visits} Visits', C.lav2, C.ink),
                          ]),
                        ]),
                      ),
                      const Icon(Icons.chevron_right, color: C.muted),
                    ]),
                  );
                },
              ),
            ),
          ]),
        ),
      );
}

// ---------------- History + Medicines ----------------
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryState();
}

class _HistoryState extends State<HistoryScreen> {
  int tab = 0;

  Widget _seg(String t, int i) => GestureDetector(
        onTap: () => setState(() => tab = i),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(color: tab == i ? C.primary : C.lav2, borderRadius: BorderRadius.circular(20)),
          child: Text(t, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: tab == i ? Colors.white : C.ink)),
        ),
      );

  Widget _timeline() => Store.instance.visits.isEmpty
      ? EmptyState(Icons.history, 'Your medical history will appear here.', btn: 'Add Medical Visit', onTap: () => _go(context, const AddRecordScreen()))
      : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: Store.instance.visits.length,
        itemBuilder: (c, i) {
          final v = Store.instance.visits[i];
          return IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              SizedBox(
                width: 26,
                child: Column(children: [
                  Container(width: 12, height: 12, margin: const EdgeInsets.only(top: 4), decoration: BoxDecoration(shape: BoxShape.circle, color: i == 0 ? C.primary : C.muted)),
                  if (i < Store.instance.visits.length - 1) Expanded(child: Container(width: 2, color: C.lav2)),
                ]),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(v.date, style: const TextStyle(fontWeight: FontWeight.w700, color: C.primary, fontSize: 13)),
                    const SizedBox(height: 6),
                    Card2(
                      onTap: () => _go(c, const RecordDetailsScreen()),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(v.doctor, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        Text(v.hospital, style: const TextStyle(fontSize: 12, color: C.muted)),
                        const SizedBox(height: 8),
                        Text('Diagnosis: ${v.dx}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 10),
                        Wrap(spacing: 8, runSpacing: 6, children: [
                          Meta('💊 ${v.meds} Medicines'),
                          Meta('🧪 ${v.tests} Tests'),
                          if (v.files > 0) Meta('📎 ${v.files} Prescription'),
                        ]),
                      ]),
                    ),
                  ]),
                ),
              ),
            ]),
          );
        },
      );

  void _medSheet(Med m) => showModalBottomSheet(
        context: context, backgroundColor: Colors.white, shape: _sheetShape,
        builder: (_) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(m.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            Text('Prescribed ${m.times} times', style: const TextStyle(color: C.muted)),
            const SizedBox(height: 8),
            for (final u in Store.instance.usage.where((u) => u.$3.startsWith(m.name)))
              ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: const Icon(Icons.history, color: C.primary), title: Text(u.$3), subtitle: Text('${u.$1} • ${u.$2}')),
          ]),
        ),
      );

  Widget _medicines() => Store.instance.meds.isEmpty
      ? const EmptyState(Icons.medication_outlined, 'No medicines recorded yet.')
      : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: Store.instance.meds.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (c, i) {
          final m = Store.instance.meds[i];
          return Card2(
            onTap: () => _medSheet(m),
            child: Row(children: [
              const IconBadge(Icons.medication_outlined, C.mint, C.green, 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(m.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  Text(m.dose, style: const TextStyle(fontSize: 13, color: C.primary, fontWeight: FontWeight.w600)),
                  Text('Last prescribed: ${m.last}', style: const TextStyle(fontSize: 12, color: C.muted)),
                  Text(m.doctor, style: const TextStyle(fontSize: 12, color: C.muted)),
                ]),
              ),
              Pill('${m.times}x', C.lav2, C.ink),
            ]),
          );
        },
      );

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Column(children: [
          _TopSearch('Medical History', 'Search your medical history...'),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [_seg('Timeline', 0), const SizedBox(width: 8), _seg('Medicines', 1)])),
          Expanded(child: tab == 0 ? _timeline() : _medicines()),
        ]),
      );
}

// ---------------- Reports ----------------
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsState();
}

class _ReportsState extends State<ReportsScreen> {
  static const cats = ['All', 'Blood Tests', 'X-Ray', 'MRI', 'CT Scan', 'Ultrasound', 'Other'];
  String cat = 'All';

  void _preview(Rep r) => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(r.name),
          content: Container(height: 180, decoration: BoxDecoration(color: C.lav, borderRadius: BorderRadius.circular(12)), child: Center(child: Icon(r.file == 'PDF' ? Icons.picture_as_pdf_outlined : Icons.image_outlined, size: 56, color: C.primary))),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final list = Store.instance.reps.where((r) => cat == 'All' || r.type == cat).toList();
    return SafeArea(
      child: Column(children: [
        const _TopSearch('Reports', 'Search reports...'),
        SizedBox(
          height: 38,
          child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children: [
            for (final c in cats)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(c), selected: cat == c, onSelected: (_) => setState(() => cat = c),
                  selectedColor: C.primary, backgroundColor: C.lav2, showCheckmark: false,
                  labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: cat == c ? Colors.white : C.ink),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: list.isEmpty
              ? EmptyState(Icons.description_outlined, 'No medical reports uploaded yet.', btn: 'Upload Report', onTap: () => _go(context, const AddRecordScreen()))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (c, i) {
                    final r = list[i];
                    return Card2(
                      child: Row(children: [
                        IconBadge(r.file == 'PDF' ? Icons.picture_as_pdf_outlined : Icons.image_outlined, C.lav2, C.primary, 44),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(r.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text('${r.date} • ${r.doctor}', style: const TextStyle(fontSize: 12, color: C.muted)),
                            Text(r.hospital, style: const TextStyle(fontSize: 12, color: C.muted)),
                          ]),
                        ),
                        Column(children: [
                          Pill(r.file, C.lav, C.ink),
                          TextButton(onPressed: () => _preview(r), child: const Text('Preview', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                        ]),
                      ]),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}

// ---------------- Search ----------------
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchState();
}

class _SearchState extends State<SearchScreen> {
  final ctrl = TextEditingController();
  String q = '';

  @override
  Widget build(BuildContext context) {
    final res = Store.instance.usage.where((u) => q.isNotEmpty && '${u.$1} ${u.$2} ${u.$3}'.toLowerCase().contains(q.toLowerCase())).toList();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, surfaceTintColor: Colors.transparent,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: TextField(
          controller: ctrl, autofocus: true, onChanged: (v) => setState(() => q = v),
          decoration: const InputDecoration(border: InputBorder.none, hintText: 'Search doctors, medicines, diagnosis, tests...', hintStyle: TextStyle(fontSize: 14, color: C.muted)),
        ),
      ),
      body: q.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Suggestions', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final s in ['Doctors', 'Medicines', 'Diagnoses', 'Hospitals', 'Tests']) Chip(label: Text(s), backgroundColor: C.lav2, side: BorderSide.none),
                ]),
                const SizedBox(height: 16),
                const Text('Try searching', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ActionChip(label: const Text('Panadol'), avatar: const Icon(Icons.history, size: 16), onPressed: () => setState(() { ctrl.text = 'Panadol'; q = 'Panadol'; })),
              ]),
            )
          : res.isEmpty
              ? const EmptyState(Icons.search_off, 'No results found.')
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: res.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (c, i) => Card2(
                    onTap: () => _go(c, const RecordDetailsScreen()),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(res[i].$1, style: const TextStyle(color: C.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                      Text(res[i].$2, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      Text(res[i].$3, style: const TextStyle(color: C.muted)),
                    ]),
                  ),
                ),
    );
  }
}

// ---------------- Filters ----------------
void showFilterSheet(BuildContext c) => showModalBottomSheet(context: c, isScrollControlled: true, backgroundColor: Colors.white, shape: _sheetShape, builder: (_) => const _FilterSheet());

class _FilterSheet extends StatefulWidget {
  const _FilterSheet();
  @override
  State<_FilterSheet> createState() => _FilterState();
}

class _FilterState extends State<_FilterSheet> {
  static const opts = {
    'Date Range': ['Last 30 days', '6 months', '1 year'],
    'Doctor': ['Dr. Ahmed Khan', 'Dr. Elena Rostova', 'Dr. Marcus Lee'],
    'Hospital': ['City Medical Hospital', 'Metro Skin Clinic'],
    'Diagnosis': ['Viral Infection', 'Hypertension'],
    'Medicine': ['Panadol', 'Amoxicillin'],
    'Medical Test': ['CBC', 'Chest X-Ray'],
  };
  final sel = <String>{};

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(child: Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
          ]),
          if (sel.isNotEmpty)
            Wrap(spacing: 6, children: [for (final s in sel) InputChip(label: Text(s), onDeleted: () => setState(() => sel.remove(s)), backgroundColor: C.blueChip, side: BorderSide.none)]),
          Flexible(
            child: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                for (final e in opts.entries) ...[
                  Padding(padding: const EdgeInsets.only(top: 14, bottom: 6), child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w700))),
                  Wrap(spacing: 8, runSpacing: 4, children: [
                    for (final o in e.value)
                      FilterChip(label: Text(o), selected: sel.contains(o), showCheckmark: false, selectedColor: C.blueChip, backgroundColor: C.lav, side: BorderSide.none,
                          onSelected: (v) => setState(() => v ? sel.add(o) : sel.remove(o))),
                  ]),
                ],
              ]),
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: Btn('Clear All', filled: false, onTap: () => setState(sel.clear))),
            const SizedBox(width: 10),
            Expanded(child: Btn('Apply Filters', onTap: () => Navigator.pop(context))),
          ]),
        ]),
      );
}

// ---------------- Settings ----------------
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsScreen> {
  bool auto = true, lock = false, bio = true;

  void _msg(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _sync() async {
    _msg('Syncing...');
    final r = await Store.instance.syncNow();
    if (mounted) _msg(r);
  }

  Future<void> _restore() async {
    try {
      final n = await Store.instance.restore();
      if (mounted) _msg(n < 0 ? 'No backup found in your Google Drive' : 'Restored $n visits from Google Drive');
    } catch (e) {
      if (mounted) _msg('Restore failed: $e');
    }
  }

  Widget _sw(bool v, ValueChanged<bool> f) => Switch(value: v, onChanged: f, activeColor: Colors.white, activeTrackColor: C.primary);

  Widget _tile(IconData i, String t, {String? sub, Widget? trailing, VoidCallback? onTap}) => ListTile(
        leading: IconBadge(i, C.lav2, C.primary, 36),
        title: Text(t, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: sub == null ? null : Text(sub, style: const TextStyle(fontSize: 12)),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: C.muted),
        onTap: onTap ?? () {},
      );

  Widget _group(String t, List<Widget> kids) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.only(top: 18, bottom: 8, left: 4), child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: C.muted, letterSpacing: 1))),
        Card2(padding: EdgeInsets.zero, child: Column(children: [for (int i = 0; i < kids.length; i++) ...[if (i > 0) const Divider(height: 1, indent: 60), kids[i]]])),
      ]);

  @override
  Widget build(BuildContext context) => SafeArea(
        child: ListView(padding: const EdgeInsets.all(16), children: [
          const Text('Settings', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
          _group('ACCOUNT', [_tile(Icons.person_outline, 'Profile', sub: 'Sarah Jenkins'), _tile(Icons.account_circle_outlined, 'Google Account', sub: 'sarah.jenkins@gmail.com')]),
          _group('BACKUP & SYNC', [
            _tile(Icons.cloud_outlined, 'Google Drive', sub: 'Connected', onTap: () => _go(context, Scaffold(appBar: topBar(context, 'Backup & Sync', 'My Medical History'), body: const BackupSyncScreen()))),
            _tile(Icons.sync, 'Sync Now', onTap: _sync),
            _tile(Icons.autorenew, 'Auto Sync', trailing: _sw(auto, (v) => setState(() => auto = v))),
            _tile(Icons.schedule, 'Last Synced', sub: Store.instance.lastSyncedText, trailing: const SizedBox()),
          ]),
          _group('SECURITY', [
            _tile(Icons.lock_outline, 'App Lock', trailing: _sw(lock, (v) => setState(() => lock = v))),
            _tile(Icons.pin_outlined, 'PIN'),
            _tile(Icons.fingerprint, 'Fingerprint / Biometric', trailing: _sw(bio, (v) => setState(() => bio = v))),
          ]),
          _group('DATA', [_tile(Icons.ios_share, 'Export Medical History'), _tile(Icons.restore, 'Restore Backup', sub: 'Replaces data on this phone', onTap: _restore)]),
          _group('APP', [_tile(Icons.notifications_none, 'Notifications'), _tile(Icons.privacy_tip_outlined, 'Privacy'), _tile(Icons.info_outline, 'About')]),
          const SizedBox(height: 16),
        ]),
      );
}
