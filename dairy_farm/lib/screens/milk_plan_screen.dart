import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../common.dart';
import '../db/database_helper.dart';
import '../models.dart';

/// Har animal ka mahine ka fixed daily milk set karne ki screen.
class MilkPlanScreen extends StatefulWidget {
  const MilkPlanScreen({super.key});
  @override
  State<MilkPlanScreen> createState() => _MilkPlanScreenState();
}

class _MilkPlanScreenState extends State<MilkPlanScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  late Future<(List<Animal>, List<MilkPlan>)> _future;

  String get _ym => monthPrefix(_month);

  Future<(List<Animal>, List<MilkPlan>)> _load() async {
    final db = DatabaseHelper.instance;
    return (await db.getAnimals(filter: 'Active'), await db.getPlans(_ym));
  }

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  void _reload() => setState(() => _future = _load());

  void _shift(int months) {
    _month = DateTime(_month.year, _month.month + months);
    _reload();
  }

  Future<void> _edit(Animal a, MilkPlan? current) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _PlanSheet(animal: a, month: _month, current: current),
    );
    if (changed == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Milk Plan')),
      body: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(onPressed: () => _shift(-1), icon: const Icon(Icons.chevron_left)),
          Text(DateFormat('MMMM yyyy').format(_month),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(onPressed: () => _shift(1), icon: const Icon(Icons.chevron_right)),
        ]),
        Expanded(
          child: FutureBuilder<(List<Animal>, List<MilkPlan>)>(
            future: _future,
            builder: (c, snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              final (animals, plans) = snap.data!;
              if (animals.isEmpty) {
                return const EmptyState(icon: Icons.pets, text: 'Add an animal first.');
              }
              return ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 24), children: [
                AppCard(
                  color: kLightGreen,
                  child: const Text(
                    'Set a fixed daily milk for each animal for this month. '
                    'It is counted automatically every day, so you do not need to '
                    'enter it daily. If you enter a record for a day, it replaces the plan for that day.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                ...animals.map((a) {
                  // is animal ka sab se naya plan (from_date barhte order mein aate hain)
                  final mine = plans.where((p) => p.animalId == a.id).toList();
                  final cur = mine.isEmpty ? null : mine.last;
                  return AppCard(
                    onTap: () => _edit(a, cur),
                    child: Row(children: [
                      CircleAvatar(
                        backgroundColor: kLightGreen,
                        backgroundImage: a.photo != null ? MemoryImage(a.photo!) : null,
                        child: a.photo != null
                            ? null
                            : const Icon(Icons.pets, color: kGreen),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${a.name} (${a.tagNo})',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(
                            cur == null
                                ? 'No plan set'
                                : 'M ${cur.morning} + E ${cur.evening}  •  from ${cur.fromDate}',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ]),
                      ),
                      Text(cur == null ? '-' : '${liters(cur.total)}/day',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: cur == null ? Colors.grey : kGreen)),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ]),
                  );
                }),
              ]);
            },
          ),
        ),
      ]),
    );
  }
}

class _PlanSheet extends StatefulWidget {
  final Animal animal;
  final DateTime month;
  final MilkPlan? current;
  const _PlanSheet({required this.animal, required this.month, this.current});
  @override
  State<_PlanSheet> createState() => _PlanSheetState();
}

class _PlanSheetState extends State<_PlanSheet> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _morning;
  late final TextEditingController _evening;
  late String _from;

  DateTime get _first => DateTime(widget.month.year, widget.month.month, 1);
  DateTime get _last => DateTime(widget.month.year, widget.month.month + 1, 0);

  @override
  void initState() {
    super.initState();
    final c = widget.current;
    _morning = TextEditingController(text: c == null ? '' : c.morning.toString());
    _evening = TextEditingController(text: c == null ? '' : c.evening.toString());
    final now = DateTime.now();
    final isCurrentMonth =
        now.year == widget.month.year && now.month == widget.month.month;
    // Pehli baar: poora mahina (1 tareekh se). Pehle se plan ho to aaj se badlo,
    // taake guzre hue dinon ka purana milk na badle.
    _from = fmtDate(c != null && isCurrentMonth ? now : _first);
  }

  double get _total =>
      (double.tryParse(_morning.text) ?? 0) + (double.tryParse(_evening.text) ?? 0);

  String? _num(String? v) {
    final n = double.tryParse(v ?? '');
    return n == null || n < 0 ? 'Enter a valid number' : null;
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    await DatabaseHelper.instance.savePlan(MilkPlan(
      animalId: widget.animal.id!,
      month: monthPrefix(widget.month),
      fromDate: _from,
      morning: double.parse(_morning.text),
      evening: double.parse(_evening.text),
    ));
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _remove() async {
    final ok = await confirmDialog(context, 'Remove plan?',
        'Remove the monthly plan of ${widget.animal.name} for this month?',
        yes: 'Remove');
    if (!ok) return;
    await DatabaseHelper.instance
        .deletePlansFor(widget.animal.id!, monthPrefix(widget.month));
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('${widget.animal.name} - ${DateFormat('MMMM yyyy').format(widget.month)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _morning,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Morning (L)'),
                  validator: _num,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _evening,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Evening (L)'),
                  validator: _num,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ]),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Daily total: ${liters(_total)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: kGreen)),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: DateTime.parse(_from),
                  firstDate: _first,
                  lastDate: _last,
                );
                if (d != null) setState(() => _from = fmtDate(d));
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Applies from (till end of month)',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(_from),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _save, child: const Text('Save Plan')),
            if (widget.current != null)
              TextButton(
                onPressed: _remove,
                child: const Text('Remove plan for this month',
                    style: TextStyle(color: kRed)),
              ),
          ]),
        ),
      ),
    );
  }
}
