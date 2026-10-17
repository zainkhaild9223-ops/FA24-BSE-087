import 'package:flutter/material.dart';

import '../common.dart';
import '../db/database_helper.dart';
import '../models.dart';
import 'milk_plan_screen.dart';

class MilkScreen extends StatefulWidget {
  const MilkScreen({super.key});
  @override
  State<MilkScreen> createState() => _MilkScreenState();
}

class _MilkScreenState extends State<MilkScreen> {
  DateTime _date = DateTime.now();
  late Future<List<MilkRecord>> _future;

  @override
  void initState() {
    super.initState();
    _future = DatabaseHelper.instance.getMilkByDate(fmtDate(_date));
  }

  void _reload() => setState(
      () => _future = DatabaseHelper.instance.getMilkByDate(fmtDate(_date)));

  void _shift(int days) {
    _date = _date.add(Duration(days: days));
    _reload();
  }

  Future<void> _openForm([MilkRecord? r]) async {
    final saved = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
            builder: (_) => MilkFormScreen(record: r, date: fmtDate(_date))));
    if (saved == true) _reload();
  }

  Future<void> _delete(MilkRecord r) async {
    final ok = await confirmDialog(
        context, 'Delete record?', 'Delete milk record of ${r.animalName}?');
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
        onPressed: () => _openForm(),
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
          child: FutureBuilder<List<MilkRecord>>(
            future: _future,
            builder: (c, snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              final list = snap.data!;
              final m = list.fold<double>(0, (s, r) => s + r.morning);
              final e = list.fold<double>(0, (s, r) => s + r.evening);
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                children: [
                  AppCard(
                    color: kLightGreen,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Daily Total Yield', style: TextStyle(color: kGreen)),
                      Text(liters(m + e),
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Morning: ${liters(m)}   •   Evening: ${liters(e)}'),
                    ]),
                  ),
                  const SizedBox(height: 6),
                  const Text('Individual Records',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  if (list.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: EmptyState(
                          icon: Icons.water_drop_outlined,
                          text: 'No milk records for this day.'),
                    ),
                  ...list.map(_tile),
                ],
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _tile(MilkRecord r) => AppCard(
        onTap: () => _openForm(r),
        child: Row(children: [
          const CircleAvatar(backgroundColor: kLightGreen, child: Icon(Icons.pets, color: kGreen)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(
                  child: Text(r.animalName ?? '-',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
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
              Text('Tag: ${r.tagNo ?? '-'}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 4),
              Text('M: ${liters(r.morning)}   E: ${liters(r.evening)}'),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            const Text('Total', style: TextStyle(color: Colors.grey, fontSize: 11)),
            Text(liters(r.total),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16, color: kGreen)),
          ]),
          if (!r.auto)
            IconButton(
                onPressed: () => _delete(r),
                icon: const Icon(Icons.delete_outline, color: kRed))
          else
            const SizedBox(width: 8),
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
  List<Animal> _animals = [];
  int? _animalId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    _date = TextEditingController(text: r?.date ?? widget.date ?? todayStr());
    if (r != null) {
      _animalId = r.animalId;
      _morning.text = r.morning.toString();
      _evening.text = r.evening.toString();
    } else {
      _morning.text = '0';
      _evening.text = '0';
    }
    DatabaseHelper.instance.getAnimals(filter: 'Active').then((l) {
      if (!mounted) return;
      setState(() {
        _animals = l;
        _loading = false;
      });
    });
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
    final r = MilkRecord(
      id: widget.record?.id,
      animalId: _animalId!,
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
          title: Text(widget.record == null ? 'Add Milk Record' : 'Edit Milk Record')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _animals.isEmpty && widget.record == null
              ? const EmptyState(
                  icon: Icons.pets, text: 'Please add an animal first.')
              : Form(
                  key: _form,
                  child: ListView(padding: const EdgeInsets.all(16), children: [
                    DropdownButtonFormField<int>(
                      value: _animalId,
                      decoration: const InputDecoration(
                          labelText: 'Animal *', prefixIcon: Icon(Icons.pets)),
                      items: [
                        // edit mode mein agar animal "Sold" ho chuka ho tab bhi dikhe
                        ..._animals.map((a) => DropdownMenuItem(
                            value: a.id, child: Text('${a.name} (${a.tagNo})'))),
                        if (widget.record != null &&
                            !_animals.any((a) => a.id == widget.record!.animalId))
                          DropdownMenuItem(
                              value: widget.record!.animalId,
                              child: Text(widget.record!.animalName ?? 'Animal')),
                      ],
                      validator: (v) => v == null ? 'Select an animal' : null,
                      onChanged: (v) => setState(() => _animalId = v),
                    ),
                    const SizedBox(height: 14),
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
                          labelText: 'Morning (liters)',
                          prefixIcon: Icon(Icons.wb_sunny_outlined)),
                      validator: _num,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _evening,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                          labelText: 'Evening (liters)',
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
