import 'package:flutter/material.dart';

import '../common.dart';
import '../db/database_helper.dart';
import '../models.dart';

class AnimalsScreen extends StatefulWidget {
  const AnimalsScreen({super.key});
  @override
  State<AnimalsScreen> createState() => _AnimalsScreenState();
}

class _AnimalsScreenState extends State<AnimalsScreen> {
  final _search = TextEditingController();
  String _filter = 'All';
  late Future<List<Animal>> _future;

  @override
  void initState() {
    super.initState();
    _future = _query();
  }

  Future<List<Animal>> _query() => DatabaseHelper.instance
      .getAnimals(search: _search.text.trim(), filter: _filter);

  void _reload() => setState(() => _future = _query());

  Future<void> _openForm([Animal? a]) async {
    final saved = await Navigator.push<bool>(
        context, MaterialPageRoute(builder: (_) => AnimalFormScreen(animal: a)));
    if (saved == true) _reload();
  }

  Future<void> _delete(Animal a) async {
    final ok = await confirmDialog(context, 'Delete Animal Record?',
        'Delete ${a.name} (${a.tagNo})? All its milk records will also be deleted.');
    if (!ok) return;
    await DatabaseHelper.instance.deleteAnimal(a.id!);
    if (mounted) snack(context, '${a.name} deleted');
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animals')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            controller: _search,
            onChanged: (_) => _reload(),
            decoration: const InputDecoration(
              hintText: 'Search by Tag No, Name or Breed...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: ['All', 'Cow', 'Buffalo', 'Sold']
                .map((f) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                      child: ChoiceChip(
                        label: Text(f),
                        selected: _filter == f,
                        selectedColor: kLightGreen,
                        onSelected: (_) {
                          _filter = f;
                          _reload();
                        },
                      ),
                    ))
                .toList(),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Animal>>(
            future: _future,
            builder: (c, snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              final list = snap.data!;
              if (list.isEmpty) {
                return const EmptyState(icon: Icons.pets, text: 'No animals yet.\nTap + to add one.');
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                itemCount: list.length,
                itemBuilder: (_, i) => _tile(list[i]),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _tile(Animal a) {
    final sold = a.status == 'Sold';
    return AppCard(
      onTap: () => _openForm(a),
      child: Row(children: [
        CircleAvatar(
          backgroundColor: sold ? Colors.grey.shade200 : kLightGreen,
          child: Icon(a.type == 'Cow' ? Icons.pets : Icons.cruelty_free,
              color: sold ? Colors.grey : kGreen),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.grey.shade200, borderRadius: BorderRadius.circular(6)),
                child: Text(a.tagNo, style: const TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(a.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ]),
            const SizedBox(height: 4),
            Text('${a.type} • ${a.breed.isEmpty ? '-' : a.breed} • ${ageText(a.dob)}',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: sold ? Colors.grey.shade200 : kLightGreen,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(a.status,
              style: TextStyle(
                  fontSize: 12, color: sold ? Colors.grey.shade700 : kGreen)),
        ),
        PopupMenuButton<String>(
          onSelected: (v) => v == 'edit' ? _openForm(a) : _delete(a),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ]),
    );
  }
}

// =====================================================================
// Add / Edit form
// =====================================================================
class AnimalFormScreen extends StatefulWidget {
  final Animal? animal;
  const AnimalFormScreen({super.key, this.animal});
  @override
  State<AnimalFormScreen> createState() => _AnimalFormScreenState();
}

class _AnimalFormScreenState extends State<AnimalFormScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _tag;
  late final TextEditingController _name;
  late final TextEditingController _breed;
  late final TextEditingController _dob;
  String _type = 'Cow';
  String _status = 'Active';
  String? _tagError;

  @override
  void initState() {
    super.initState();
    final a = widget.animal;
    _tag = TextEditingController(text: a?.tagNo ?? '');
    _name = TextEditingController(text: a?.name ?? '');
    _breed = TextEditingController(text: a?.breed ?? '');
    _dob = TextEditingController(text: a?.dob ?? '');
    _type = a?.type ?? 'Cow';
    _status = a?.status ?? 'Active';
  }

  Future<void> _save() async {
    setState(() => _tagError = null);
    if (!_form.currentState!.validate()) return;
    final a = Animal(
      id: widget.animal?.id,
      tagNo: _tag.text.trim(),
      name: _name.text.trim(),
      type: _type,
      breed: _breed.text.trim(),
      dob: _dob.text.trim(),
      status: _status,
    );
    try {
      if (a.id == null) {
        await DatabaseHelper.instance.insertAnimal(a);
      } else {
        await DatabaseHelper.instance.updateAnimal(a);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      // UNIQUE constraint: same tag pehle se maujood hai
      setState(() => _tagError = 'Tag number already exists');
      _form.currentState!.validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.animal != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Edit Animal' : 'Add Animal')),
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          TextFormField(
            controller: _tag,
            decoration: const InputDecoration(
                labelText: 'Tag Number *', prefixIcon: Icon(Icons.sell_outlined)),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Tag number is required';
              return _tagError;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(
                labelText: 'Animal Name', prefixIcon: Icon(Icons.badge_outlined)),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Name is required' : null,
          ),
          const SizedBox(height: 14),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Cow', label: Text('Cow'), icon: Icon(Icons.pets)),
              ButtonSegment(value: 'Buffalo', label: Text('Buffalo'), icon: Icon(Icons.cruelty_free)),
            ],
            selected: {_type},
            onSelectionChanged: (s) => setState(() => _type = s.first),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _breed,
            decoration: const InputDecoration(
                labelText: 'Breed (e.g. Sahiwal, Nili Ravi)',
                prefixIcon: Icon(Icons.category_outlined)),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _dob,
            readOnly: true,
            decoration: const InputDecoration(
                labelText: 'Date of Birth',
                prefixIcon: Icon(Icons.calendar_today_outlined)),
            onTap: () async {
              final d = await pickDate(context, _dob.text);
              if (d != null) setState(() => _dob.text = d);
            },
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _status,
            decoration: const InputDecoration(
                labelText: 'Current Status', prefixIcon: Icon(Icons.monitor_heart_outlined)),
            items: const ['Active', 'Sold']
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _status = v!),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Save Animal Record'),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ]),
      ),
    );
  }
}
