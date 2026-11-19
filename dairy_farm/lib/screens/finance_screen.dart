import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common.dart';
import '../db/database_helper.dart';
import '../models.dart';

/// Milk sale ka saved rate (PKR per liter) — aik baar save ho to har sale
/// mein yehi rate aata hai, jab tak naya save na karo.
const _rateKey = 'milk_rate';

const _categories = ['Feed', 'Medicine', 'Labor', 'Other'];

IconData _catIcon(String c) {
  switch (c) {
    case 'Feed':
      return Icons.grass;
    case 'Medicine':
      return Icons.medical_services_outlined;
    case 'Labor':
      return Icons.engineering_outlined;
    default:
      return Icons.receipt_long_outlined;
  }
}

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Finance'),
          bottom: const TabBar(
            indicatorColor: kAmber,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.receipt_long), text: 'Expenses'),
              Tab(icon: Icon(Icons.attach_money), text: 'Milk Sales'),
            ],
          ),
        ),
        body: const TabBarView(children: [_ExpensesTab(), _SalesTab()]),
      ),
    );
  }
}

// ---------------------------- Expenses tab ----------------------------
class _ExpensesTab extends StatefulWidget {
  const _ExpensesTab();
  @override
  State<_ExpensesTab> createState() => _ExpensesTabState();
}

class _ExpensesTabState extends State<_ExpensesTab> {
  late Future<(List<Expense>, double, List<DayTotal>)> _future;

  Future<(List<Expense>, double, List<DayTotal>)> _load() async {
    final db = DatabaseHelper.instance;
    final ym = monthPrefix(DateTime.now());
    return (
      await db.getExpenses(),
      await db.expenseTotalForMonth(ym),
      await db.feedDailyTotals(ym),
    );
  }

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _open([Expense? e]) async {
    final ok = await Navigator.push<bool>(
        context, MaterialPageRoute(builder: (_) => ExpenseFormScreen(expense: e)));
    if (ok == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
          FloatingActionButton(heroTag: 'exp', onPressed: () => _open(), child: const Icon(Icons.add)),
      body: FutureBuilder<(List<Expense>, double, List<DayTotal>)>(
        future: _future,
        builder: (c, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final (list, total, feedDays) = snap.data!;
          // Feed running total — feedDays date ke hisab se barhte order mein hai
          var run = 0.0;
          final feedRun = <double>[];
          for (final d in feedDays) {
            run += d.total;
            feedRun.add(run);
          }
          final feedMonth = run;
          final feedRows = feedDays.reversed.toList();
          final feedRunReversed = feedRun.reversed.toList();
          return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 90), children: [
            AppCard(
              color: kLightGreen,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('TOTAL EXPENSES (THIS MONTH)', style: TextStyle(color: kGreen, fontSize: 12)),
                Text(pkr(total),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              ]),
            ),
            // ---- Feed, day-wise: har din ka total Feed kharcha ----
            AppCard(
              color: kLightGreen,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('FEED — DAY WISE (THIS MONTH)',
                      style: TextStyle(color: kGreen, fontSize: 12)),
                  Text(pkr(feedMonth),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 8),
                if (feedDays.isEmpty)
                  const Text('No feed expense this month.',
                      style: TextStyle(color: Colors.grey)),
                ...feedRows.asMap().entries.map((en) {
                  final d = en.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(children: [
                      Expanded(
                        child: Text(d.date,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Text('Total so far: ${pkr(feedRunReversed[en.key])}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(width: 10),
                      Text(pkr(d.total),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ]),
                  );
                }),
              ]),
            ),
            const Text('Recent Expenses',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            if (list.isEmpty)
              const Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: EmptyState(icon: Icons.receipt_long, text: 'No expenses yet.')),
            ...list.map((e) => AppCard(
                  onTap: () => _open(e),
                  child: Row(children: [
                    CircleAvatar(
                        backgroundColor: const Color(0xFFFFF3E0),
                        child: Icon(_catIcon(e.category), color: Colors.orange.shade800)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(e.note.isEmpty ? e.category : e.note,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('${e.date} • ${e.category}',
                            style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ]),
                    ),
                    Text(pkr(e.amount),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: kRed)),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: kRed),
                      onPressed: () async {
                        if (await confirmDialog(context, 'Delete expense?', pkr(e.amount))) {
                          await DatabaseHelper.instance.deleteExpense(e.id!);
                          _reload();
                        }
                      },
                    ),
                  ]),
                )),
          ]);
        },
      ),
    );
  }
}

class ExpenseFormScreen extends StatefulWidget {
  final Expense? expense;
  const ExpenseFormScreen({super.key, this.expense});
  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _date;
  late final TextEditingController _amount;
  late final TextEditingController _note;
  String _cat = 'Feed';

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _date = TextEditingController(text: e?.date ?? todayStr());
    _amount = TextEditingController(text: e == null ? '' : e.amount.toString());
    _note = TextEditingController(text: e?.note ?? '');
    _cat = e?.category ?? 'Feed';
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final e = Expense(
      id: widget.expense?.id,
      date: _date.text,
      category: _cat,
      amount: double.parse(_amount.text),
      note: _note.text.trim(),
    );
    if (e.id == null) {
      await DatabaseHelper.instance.insertExpense(e);
    } else {
      await DatabaseHelper.instance.updateExpense(e);
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.expense == null ? 'Add Expense' : 'Edit Expense')),
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
          DropdownButtonFormField<String>(
            value: _cat,
            decoration: const InputDecoration(
                labelText: 'Category', prefixIcon: Icon(Icons.category_outlined)),
            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _cat = v!),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
                labelText: 'Amount (PKR) *', prefixIcon: Icon(Icons.payments_outlined)),
            validator: (v) {
              final n = double.tryParse(v ?? '');
              return n == null || n <= 0 ? 'Enter a valid amount' : null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _note,
            decoration: const InputDecoration(
                labelText: 'Note', prefixIcon: Icon(Icons.notes)),
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _save, child: const Text('Save Expense')),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ]),
      ),
    );
  }
}

// ----------------------------- Sales tab -----------------------------
class _SalesTab extends StatefulWidget {
  const _SalesTab();
  @override
  State<_SalesTab> createState() => _SalesTabState();
}

class _SalesTabState extends State<_SalesTab> {
  late Future<(List<Sale>, double)> _future;

  Future<(List<Sale>, double)> _load() async {
    final db = DatabaseHelper.instance;
    return (await db.getSales(), await db.salesTotalForMonth(monthPrefix(DateTime.now())));
  }

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _open([Sale? s]) async {
    final ok = await Navigator.push<bool>(
        context, MaterialPageRoute(builder: (_) => SaleFormScreen(sale: s)));
    if (ok == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
          FloatingActionButton(heroTag: 'sale', onPressed: () => _open(), child: const Icon(Icons.add)),
      body: FutureBuilder<(List<Sale>, double)>(
        future: _future,
        builder: (c, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final (list, total) = snap.data!;
          return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 90), children: [
            AppCard(
              color: kLightGreen,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('MILK SALES (THIS MONTH)', style: TextStyle(color: kGreen, fontSize: 12)),
                Text(pkr(total),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              ]),
            ),
            const Text('Recent Sales',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            if (list.isEmpty)
              const Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: EmptyState(icon: Icons.attach_money, text: 'No sales yet.')),
            ...list.map((s) => AppCard(
                  onTap: () => _open(s),
                  child: Row(children: [
                    const CircleAvatar(
                        backgroundColor: kLightGreen,
                        child: Icon(Icons.local_drink_outlined, color: kGreen)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(s.buyer.isEmpty ? 'Milk sale' : s.buyer,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('${s.date} • ${liters(s.liters)} @ ${pkr(s.rate)}',
                            style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ]),
                    ),
                    Text(pkr(s.total),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: kGreen)),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: kRed),
                      onPressed: () async {
                        if (await confirmDialog(context, 'Delete sale?', pkr(s.total))) {
                          await DatabaseHelper.instance.deleteSale(s.id!);
                          _reload();
                        }
                      },
                    ),
                  ]),
                )),
          ]);
        },
      ),
    );
  }
}

class SaleFormScreen extends StatefulWidget {
  final Sale? sale;
  const SaleFormScreen({super.key, this.sale});
  @override
  State<SaleFormScreen> createState() => _SaleFormScreenState();
}

class _SaleFormScreenState extends State<SaleFormScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _date;
  late final TextEditingController _liters;
  late final TextEditingController _rate;
  late final TextEditingController _buyer;
  double? _dayMilk; // us din ka total doodh (milk record se)
  bool _litersEdited = false; // user ne liters khud badla ho to auto-fill na karo

  @override
  void initState() {
    super.initState();
    final s = widget.sale;
    _date = TextEditingController(text: s?.date ?? todayStr());
    _liters = TextEditingController(text: s == null ? '' : s.liters.toString());
    _rate = TextEditingController(text: s == null ? '' : s.rate.toString());
    _buyer = TextEditingController(text: s?.buyer ?? '');
    // Nayi sale: liters us din ke milk record se, rate saved rate se
    if (s == null) _autoFill();
  }

  /// Nayi sale ke liye: rate saved rate se (na ho to 180), aur liters
  /// us din ke total milk se (milk record ho to).
  Future<void> _autoFill() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRate = prefs.getDouble(_rateKey);
    final milk = await DatabaseHelper.instance.getMilkByDate(_date.text);
    if (!mounted) return;
    setState(() {
      if (_rate.text.isEmpty) _rate.text = (savedRate ?? 180).toString();
      if (milk != null) {
        _dayMilk = milk.total;
        if (!_litersEdited) _liters.text = milk.total.toString();
      }
    });
  }

  double get _total =>
      (double.tryParse(_liters.text) ?? 0) * (double.tryParse(_rate.text) ?? 0);

  String? _pos(String? v) {
    final n = double.tryParse(v ?? '');
    return n == null || n <= 0 ? 'Enter a valid number' : null;
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final s = Sale(
      id: widget.sale?.id,
      date: _date.text,
      liters: double.parse(_liters.text),
      rate: double.parse(_rate.text),
      buyer: _buyer.text.trim(),
    );
    if (s.id == null) {
      await DatabaseHelper.instance.insertSale(s);
    } else {
      await DatabaseHelper.instance.updateSale(s);
    }
    // Ye rate ab default ban gaya — agli sale mein yehi rate aayega.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_rateKey, s.rate);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.sale == null ? 'Add Sale' : 'Edit Sale')),
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
              if (d != null) {
                setState(() => _date.text = d);
                // Nayi sale ho aur liters khud na badla ho to us din ka doodh le aao
                if (widget.sale == null && !_litersEdited) _autoFill();
              }
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _liters,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
                labelText: 'Liters *', prefixIcon: Icon(Icons.water_drop_outlined)),
            validator: _pos,
            onChanged: (_) => setState(() => _litersEdited = true),
          ),
          if (_dayMilk != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Is din ka doodh: ${liters(_dayMilk!)} (milk record se)',
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _rate,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
                labelText: 'Rate per liter (PKR) *', prefixIcon: Icon(Icons.sell_outlined)),
            validator: _pos,
            onChanged: (_) => setState(() {}),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
                'Save karne par ye rate default ban jayega — agli sale mein yehi rate aayega. Rate badalna ho to yahan naya likh kar save kar do.',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _buyer,
            decoration: const InputDecoration(
                labelText: 'Buyer name', prefixIcon: Icon(Icons.person_outline)),
          ),
          const SizedBox(height: 14),
          AppCard(
            color: kLightGreen,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Total'),
              Text(pkr(_total),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: kGreen)),
            ]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _save, child: const Text('Save Sale')),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ]),
      ),
    );
  }
}
