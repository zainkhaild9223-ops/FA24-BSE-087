import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../common.dart';
import '../db/database_helper.dart';
import 'animals_screen.dart';
import 'finance_screen.dart';
import 'milk_screen.dart';

class DashboardScreen extends StatefulWidget {
  final void Function(int tab) onGoTo;
  const DashboardScreen({super.key, required this.onGoTo});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<DashboardStats> _future;

  @override
  void initState() {
    super.initState();
    _future = DatabaseHelper.instance.dashboard();
  }

  void _reload() => setState(() => _future = DatabaseHelper.instance.dashboard());

  Future<void> _push(Widget w) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => w));
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dairy Farm')),
      body: RefreshIndicator(
        onRefresh: () async => _reload(),
        child: FutureBuilder<DashboardStats>(
          future: _future,
          builder: (c, snap) {
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final s = snap.data!;
            return ListView(padding: const EdgeInsets.all(16), children: [
              Text('Assalam-o-Alaikum, Farmer',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(DateFormat('EEEE, dd MMM yyyy').format(DateTime.now()),
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _stat('Today\'s Milk', liters(s.todayMilk), Icons.water_drop)),
                const SizedBox(width: 10),
                Expanded(child: _stat('This Month', liters(s.monthMilk), Icons.calendar_month)),
              ]),
              Row(children: [
                Expanded(child: _stat('Livestock', '${s.animals} head', Icons.pets)),
                const SizedBox(width: 10),
                Expanded(
                    child: _stat('Net Profit', pkr(s.netProfit), Icons.trending_up,
                        valueColor: s.netProfit >= 0 ? kGreen : kRed)),
              ]),
              AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Quick Actions',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    _action('Add Milk', Icons.water_drop, () => _push(const MilkFormScreen())),
                    _action('+ Animal', Icons.add, () => _push(const AnimalFormScreen())),
                    _action('Expense', Icons.receipt_long, () => _push(const ExpenseFormScreen())),
                    _action('Add Sale', Icons.attach_money, () => _push(const SaleFormScreen())),
                  ]),
                ]),
              ),
              AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Expanded(
                        child: Text('Income vs Expense',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                    _legend(kGreen, 'Sales'),
                    const SizedBox(width: 8),
                    _legend(kAmber, 'Expenses'),
                  ]),
                  const Text('Last 7 days', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 12),
                  _chart(s.last7),
                ]),
              ),
              AppCard(
                color: kLightGreen,
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Monthly Net Balance'),
                  Text(pkr(s.netProfit),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: s.netProfit >= 0 ? kGreen : kRed)),
                ]),
              ),
            ]);
          },
        ),
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon, {Color? valueColor}) => AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Flexible(
                child: Text(label,
                    style: const TextStyle(color: Colors.grey, fontSize: 13))),
            Icon(icon, size: 18, color: kGreen),
          ]),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: valueColor)),
          ),
        ]),
      );

  Widget _action(String label, IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(children: [
            CircleAvatar(
                radius: 24,
                backgroundColor: kLightGreen,
                child: Icon(icon, color: kGreen)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ]),
        ),
      );

  Widget _legend(Color c, String t) => Row(children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(t, style: const TextStyle(fontSize: 12)),
      ]);

  Widget _chart(List<DayFlow> days) {
    double maxV = 1;
    for (final d in days) {
      if (d.sales > maxV) maxV = d.sales;
      if (d.expenses > maxV) maxV = d.expenses;
    }
    const h = 110.0;
    return SizedBox(
      height: h + 24,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days
            .map((d) => Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    _bar(d.sales / maxV * h, kGreen),
                    const SizedBox(width: 2),
                    _bar(d.expenses / maxV * h, kAmber),
                  ]),
                  const SizedBox(height: 4),
                  Text(DateFormat('E').format(d.day).substring(0, 1),
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ]))
            .toList(),
      ),
    );
  }

  Widget _bar(double height, Color c) => Container(
        width: 12,
        height: height < 2 ? 2 : height,
        decoration: BoxDecoration(
            color: c, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
      );
}
