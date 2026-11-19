import 'package:flutter/material.dart';

import '../common.dart';
import '../db/database_helper.dart';
import '../models.dart';
import 'milk_plan_screen.dart';

/// Milk ab day-wise hai: har din ka total (poore farm ka), kisi aik cow ka nahi.
class MilkScreen extends StatefulWidget {
  const MilkScreen({super.key});
  @override
  State<MilkScreen> createState() => _MilkScreenState();
}

class _MilkScreenState extends State<MilkScreen> {
  DateTime _date = DateTime.now();
  late Future<(MilkRecord?, List<MilkRecord>)> _future;

  String get _ym => monthPrefix(_date);

  Future<(MilkRecord?, List<MilkRecord>)> _load() async {
    final db = DatabaseHelper.instance;
    return (
      await db.getMilkByDate(fmtDate(_date)),
      await db.getMilkHistory(_ym),
    );
  }

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  void _reload() => setState(() => _future = _load());

  void _shift(int days) {
    _date = _date.add(Duration(days: days));
    _reload();
  }

  Future<void> _openForm() async {
    final record = await DatabaseHelper.instance.getMilkByDate(fmtDate(_date));
    final saved = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
            builder: (_) => MilkFormScreen(record: record, date: fmtDate(_date))));
    if (saved == true) _reload();
  }

  Future<void> _delete(MilkRecord r) async {
    final ok = await confirmDialog(
        context, 'Delete record?', 'Delete milk record of ${r.date}?');
    if (!ok) return;
    await DatabaseHelper.instance.deleteMilk(r.id!);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final isToday = fmtDate(_date) == todayStr();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Milk Records'),
        actions: [
          IconButton(
            tooltip: 'Monthly milk plan',
            icon: const Icon(Icons.event_repeat),
            onPressed: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MilkPlanScreen()));
              _reload();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openForm,
        child: const Icon(Icons.add),
      ),
      body: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(onPressed: () => _shift(-1), icon: const Icon(Icons.chevron_left)),
          TextButton(
            onPressed: () async {
              final d = await pickDate(context, fmtDate(_date));
              if (d != null) {
                _date = DateTime.parse(d);
                _reload();
              }
            },
            child: Text(isToday ? 'Today, ${fmtDate(_date)}' : fmtDate(_date),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          IconButton(onPressed: () => _shift(1), icon: const Icon(Icons.chevron_right)),
        ]),
        Expanded(
          child: FutureBuilder<(MilkRecord?, List<MilkRecord>)>(
            future: _future,
            builder: (c, snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              final (record, history) = snap.data!;
              final m = record?.morning ?? 0;
              final e = record?.evening ?? 0;

              // Running total — history date ke hisab se barhte order mein hai
              var run = 0.0;
              final running = <double>[];
              for (final r in history) {
                run += r.total;
                running.add(run);
              }
              final monthTotal = run;
              // Dikhana naye din pehle hai
              final rows = history.reversed.toList();
              final runReversed = running.reversed.toList();

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                children: [
                  AppCard(
                    color: kLightGreen,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        const Expanded(
                          child: Text('Daily Total Yield',
                              style: TextStyle(color: kGreen)),
                        ),
                        if (record?.auto == true)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                                color: const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(8)),
                            child: const Text('Plan',
                                style: TextStyle(fontSize: 11, color: Color(0xFFE65100))),
                          ),
                        if (record != null && !record.auto)
                          IconButton(
                            onPressed: () => _delete(record),
                            icon: const Icon(Icons.delete_outline, color: kRed),
                            tooltip: 'Delete this day',
                          ),
                      ]),
                      Text(liters(m + e),
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Morning: ${liters(m)}   •   Evening: ${liters(e)}'),
                      if (record == null)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text('No record for this day — tap + to add.',
                              style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ),
                      if (record?.auto == true)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text('Monthly plan se — tap + to enter actual milk.',
                              style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ),
                    ]),
                  ),
                  const SizedBox(height: 6),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Day by Day',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('This month: ${liters(monthTotal)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: kGreen)),
                  ]),
                  if (history.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: EmptyState(
                          icon: Icons.water_drop_outlined,
                          text: 'No milk records for this month.'),
                    ),
                  ...rows.asMap().entries.map((en) {
                    final r = en.value;
                    return _dayTile(r, runReversed[en.key]);
                  }),
                ],
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _dayTile(MilkRecord r, double runningTotal) => AppCard(
        onTap: () {
          _date = DateTime.parse(r.date);
          _reload();
        },
        child: Row(children: [
          const CircleAvatar(
              backgroundColor: kLightGreen,
              child: Icon(Icons.water_drop, color: kGreen)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(r.date,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (r.auto)
                  Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Text('Plan',
                        style: TextStyle(fontSize: 11, color: Color(0xFFE65100))),
                  ),
              ]),
              const SizedBox(height: 2),
              Text('M: ${liters(r.morning)}   E: ${liters(r.evening)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text('Total so far: ${liters(runningTotal)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ]),
          ),
          Text(liters(r.total),
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, color: kGreen)),
        ]),
      );
}

// =====================================================================
class MilkFormScreen extends StatefulWidget {
  final MilkRecord? record;
  final String? date;
  const MilkFormScreen({super.key, this.record, this.date});
  @override
  State<MilkFormScreen> createState() => _MilkFormScreenState();
}

class _MilkFormScreenState extends State<MilkFormScreen> {
  final _form = GlobalKey<FormState>();
  final _morning = TextEditingController();
  final _evening = TextEditingController();
  late final TextEditingController _date;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    _date = TextEditingController(text: r?.date ?? widget.date ?? todayStr());
    _morning.text = r == null ? '0' : r.morning.toString();
    _evening.text = r == null ? '0' : r.evening.toString();
  }

  double get _total =>
      (double.tryParse(_morning.text) ?? 0) + (double.tryParse(_evening.text) ?? 0);

  String? _num(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final n = double.tryParse(v);
    if (n == null || n < 0) return 'Enter a valid number';
    return null;
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final old = widget.record;
    // Date badal di ho to purani entry hata kar nayi daalo (har date UNIQUE hai)
    if (old != null && old.id != null && old.date != _date.text) {
      await DatabaseHelper.instance.deleteMilk(old.id!);
    }
    final r = MilkRecord(
      // Plan wale (auto) record ki id null hoti hai — save karne par
      // us din ki asli entry ban jati hai aur plan replace ho jata hai.
      id: (old != null && old.id != null && old.date == _date.text)
          ? old.id
          : null,
      date: _date.text,
      morning: double.parse(_morning.text),
      evening: double.parse(_evening.text),
    );
    if (r.id == null) {
      await DatabaseHelper.instance.insertMilk(r);
    } else {
      await DatabaseHelper.instance.updateMilk(r);
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.record == null || widget.record!.auto
              ? 'Add Milk Record'
              : 'Edit Milk Record')),
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          TextFormField(
            controller: _date,
            readOnly: true,
            decoration: const InputDecoration(
                labelText: 'Date', prefixIcon: Icon(Icons.calendar_today_outlined)),
            onTap: () async {
              final d = await pickDate(context, _date.text);
              if (d != null) setState(() => _date.text = d);
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _morning,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
                labelText: 'Morning (liters) — whole farm',
                prefixIcon: Icon(Icons.wb_sunny_outlined)),
            validator: _num,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _evening,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
                labelText: 'Evening (liters) — whole farm',
                prefixIcon: Icon(Icons.nightlight_outlined)),
            validator: _num,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          AppCard(
            color: kLightGreen,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total'),
                  Text(liters(_total),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold, color: kGreen)),
                ]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _save, child: const Text('Save Record')),
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
        ]),
      ),
    );
  }
}
