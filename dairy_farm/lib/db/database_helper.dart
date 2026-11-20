import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models.dart';

class DashboardStats {
  final double todayMilk;
  final double monthMilk;
  final int animals;
  final double monthIncome;
  final double monthExpense;
  final List<DayFlow> last7;
  DashboardStats(this.todayMilk, this.monthMilk, this.animals, this.monthIncome,
      this.monthExpense, this.last7);
  double get netProfit => monthIncome - monthExpense;
}

class DayFlow {
  final DateTime day;
  final double sales;
  final double expenses;
  DayFlow(this.day, this.sales, this.expenses);
}

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();
  static const dbName = 'dairy.db';


  static const _planTableSql = '''CREATE TABLE IF NOT EXISTS milk_plans(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    month TEXT NOT NULL,
    from_date TEXT NOT NULL,
    morning REAL DEFAULT 0,
    evening REAL DEFAULT 0,
    UNIQUE(month, from_date))''';

  String _todayStr() {
    final n = DateTime.now();
    return '${n.year.toString().padLeft(4, '0')}-'
        '${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }
  Database? _db;

  Future<String> get dbPath async => join(await getDatabasesPath(), dbName);

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final path = await dbPath;
    return openDatabase(
      path,
      version: 4,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, v) async {
        await db.execute('''CREATE TABLE animals(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          tag_no TEXT UNIQUE NOT NULL,
          name TEXT, type TEXT, breed TEXT, dob TEXT,
          status TEXT DEFAULT 'Active',
          photo BLOB)''');

        await db.execute('''CREATE TABLE milk_records(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL UNIQUE,
          morning REAL DEFAULT 0,
          evening REAL DEFAULT 0)''');
        await db.execute('''CREATE TABLE expenses(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL, category TEXT, amount REAL, note TEXT)''');
        await db.execute('''CREATE TABLE sales(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL, liters REAL, rate REAL, total REAL, buyer TEXT)''');
        await db.execute(_planTableSql);
      },

      onUpgrade: (db, oldV, newV) async {
        if (oldV < 2) {
          await db.execute('ALTER TABLE animals ADD COLUMN photo BLOB');
        }
        if (oldV < 3) {
          await db.execute(_planTableSql);
        }
        if (oldV < 4) {

          await db.execute('''CREATE TABLE milk_records_new(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL UNIQUE,
            morning REAL DEFAULT 0,
            evening REAL DEFAULT 0)''');
          await db.execute('''INSERT INTO milk_records_new(date, morning, evening)
            SELECT date, SUM(morning), SUM(evening)
            FROM milk_records GROUP BY date''');
          await db.execute('DROP TABLE milk_records');
          await db.execute('ALTER TABLE milk_records_new RENAME TO milk_records');

          await db.execute('''CREATE TABLE milk_plans_new(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            month TEXT NOT NULL,
            from_date TEXT NOT NULL,
            morning REAL DEFAULT 0,
            evening REAL DEFAULT 0,
            UNIQUE(month, from_date))''');
          await db.execute('''INSERT INTO milk_plans_new(month, from_date, morning, evening)
            SELECT month, from_date, SUM(morning), SUM(evening)
            FROM milk_plans GROUP BY month, from_date''');
          await db.execute('DROP TABLE milk_plans');
          await db.execute('ALTER TABLE milk_plans_new RENAME TO milk_plans');
        }
      },
    );
  }


  Future<void> close() async {
    await _db?.close();
    _db = null;
  }


  Future<List<Animal>> getAnimals({String search = '', String filter = 'All'}) async {
    final db = await database;
    final where = <String>[];
    final args = <Object?>[];
    if (search.isNotEmpty) {
      where.add('(tag_no LIKE ? OR name LIKE ? OR breed LIKE ?)');
      args.addAll(['%$search%', '%$search%', '%$search%']);
    }
    if (filter == 'Cow' || filter == 'Buffalo') {
      where.add('type = ?');
      args.add(filter);
    } else if (filter == 'Sold') {
      where.add("status = 'Sold'");
    } else if (filter == 'Active') {
      where.add("status = 'Active'");
    }
    final rows = await db.query('animals',
        where: where.isEmpty ? null : where.join(' AND '),
        whereArgs: args,
        orderBy: 'name COLLATE NOCASE');
    return rows.map(Animal.fromMap).toList();
  }

  Future<int> insertAnimal(Animal a) async =>
      (await database).insert('animals', a.toMap()..remove('id'));

  Future<int> updateAnimal(Animal a) async => (await database)
      .update('animals', a.toMap()..remove('id'), where: 'id = ?', whereArgs: [a.id]);


  Future<int> deleteAnimal(int id) async =>
      (await database).delete('animals', where: 'id = ?', whereArgs: [id]);


  Future<MilkRecord?> getMilkByDate(String date) async {
    final db = await database;
    final rows =
        await db.query('milk_records', where: 'date = ?', whereArgs: [date]);
    if (rows.isNotEmpty) return MilkRecord.fromMap(rows.first);
    if (date.compareTo(_todayStr()) > 0) return null;
    final plan = await _effectivePlan(date.substring(0, 7), date);
    if (plan == null) return null;
    return MilkRecord(
      date: date,
      morning: plan.morning,
      evening: plan.evening,
      auto: true,
    );
  }


  Future<List<MilkRecord>> getMilkHistory(String ym) async {
    final db = await database;
    final y = int.parse(ym.substring(0, 4));
    final mo = int.parse(ym.substring(5, 7));
    final lastDay = DateTime(y, mo + 1, 0).day;
    final now = DateTime.now();
    final cur = now.year * 12 + now.month;
    final target = y * 12 + mo;
    final cutoff = target < cur ? lastDay : (target == cur ? now.day : 0);
    if (cutoff == 0) return [];

    final rows = await db.query('milk_records',
        where: 'date LIKE ?', whereArgs: ['$ym%']);
    final byDate = {
      for (final r in rows) r['date'] as String: MilkRecord.fromMap(r)
    };
    final plans = await getPlans(ym);

    final list = <MilkRecord>[];
    for (var d = 1; d <= cutoff; d++) {
      final ds = '$ym-${d.toString().padLeft(2, '0')}';
      final own = byDate[ds];
      if (own != null) {
        list.add(own);
        continue;
      }
      MilkPlan? eff;
      for (final p in plans) {
        if (p.fromDate.compareTo(ds) <= 0) eff = p;
      }
      if (eff != null) {
        list.add(MilkRecord(
          date: ds,
          morning: eff.morning,
          evening: eff.evening,
          auto: true,
        ));
      }
    }
    return list;
  }


  Future<double> monthMilkTotal(String ym) async =>
      (await getMilkHistory(ym)).fold<double>(0, (s, r) => s + r.total);


  Future<List<MilkPlan>> getPlans(String ym) async {
    final rows = await (await database).query('milk_plans',
        where: 'month = ?', whereArgs: [ym], orderBy: 'from_date');
    return rows.map(MilkPlan.fromMap).toList();
  }


  Future<MilkPlan?> _effectivePlan(String ym, String date) async {
    MilkPlan? eff;
    for (final p in await getPlans(ym)) {
      if (p.fromDate.compareTo(date) <= 0) eff = p;
    }
    return eff;
  }

  Future<void> savePlan(MilkPlan p) async => (await database).insert(
        'milk_plans',
        p.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

  Future<void> deletePlansFor(String ym) async =>
      (await database).delete('milk_plans', where: 'month = ?', whereArgs: [ym]);

  Future<int> insertMilk(MilkRecord r) async => (await database).insert(
        'milk_records',
        r.toMap()..remove('id'),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

  Future<int> updateMilk(MilkRecord r) async => (await database)
      .update('milk_records', r.toMap()..remove('id'), where: 'id = ?', whereArgs: [r.id]);

  Future<int> deleteMilk(int id) async =>
      (await database).delete('milk_records', where: 'id = ?', whereArgs: [id]);


  Future<List<Expense>> getExpenses() async {
    final rows = await (await database)
        .query('expenses', orderBy: 'date DESC, id DESC', limit: 200);
    return rows.map(Expense.fromMap).toList();
  }

  Future<int> insertExpense(Expense e) async =>
      (await database).insert('expenses', e.toMap()..remove('id'));

  Future<int> updateExpense(Expense e) async => (await database)
      .update('expenses', e.toMap()..remove('id'), where: 'id = ?', whereArgs: [e.id]);

  Future<int> deleteExpense(int id) async =>
      (await database).delete('expenses', where: 'id = ?', whereArgs: [id]);

  // ---------------- Feed (day-wise) ----------------
  /// Har din ka total Feed kharcha (date ke hisab se, barhte order mein).
  Future<List<DayTotal>> feedDailyTotals(String ym) async {
    final rows = await (await database).rawQuery(
        "SELECT date, SUM(amount) AS t FROM expenses "
        "WHERE category = 'Feed' AND date LIKE ? GROUP BY date ORDER BY date",
        ['$ym%']);
    return rows
        .map((r) => DayTotal(r['date'] as String, (r['t'] as num).toDouble()))
        .toList();
  }

  /// [from] se [to] tak har din ka total Feed kharcha (barhte order mein).
  Future<List<DayTotal>> feedDailyTotalsRange(String from, String to) async {
    final rows = await (await database).rawQuery(
        "SELECT date, SUM(amount) AS t FROM expenses "
        "WHERE category = 'Feed' AND date >= ? AND date <= ? GROUP BY date ORDER BY date",
        [from, to]);
    return rows
        .map((r) => DayTotal(r['date'] as String, (r['t'] as num).toDouble()))
        .toList();
  }

  // ---------------- Sales ----------------
  Future<List<Sale>> getSales() async {
    final rows =
        await (await database).query('sales', orderBy: 'date DESC, id DESC', limit: 200);
    return rows.map(Sale.fromMap).toList();
  }

  Future<int> insertSale(Sale s) async =>
      (await database).insert('sales', s.toMap()..remove('id'));

  Future<int> updateSale(Sale s) async => (await database)
      .update('sales', s.toMap()..remove('id'), where: 'id = ?', whereArgs: [s.id]);

  Future<int> deleteSale(int id) async =>
      (await database).delete('sales', where: 'id = ?', whereArgs: [id]);

  // ---------------- Totals ----------------
  Future<double> _sum(String sql, List<Object?> args) async {
    final r = await (await database).rawQuery(sql, args);
    final v = r.first.values.first;
    return v == null ? 0 : (v as num).toDouble();
  }

  Future<double> expenseTotalForMonth(String ym) => _sum(
      'SELECT SUM(amount) FROM expenses WHERE date LIKE ?', ['$ym%']);

  Future<Map<String, double>> expenseByCategory(String ym) async {
    final rows = await (await database).rawQuery(
        'SELECT category, SUM(amount) AS t FROM expenses WHERE date LIKE ? GROUP BY category',
        ['$ym%']);
    return {for (final r in rows) r['category'] as String: (r['t'] as num).toDouble()};
  }

  Future<double> salesTotalForMonth(String ym) =>
      _sum('SELECT SUM(total) FROM sales WHERE date LIKE ?', ['$ym%']);

  Future<DashboardStats> dashboard() async {
    final now = DateTime.now();
    final today = '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final ym = today.substring(0, 7);
    final todayMilk = (await getMilkByDate(today))?.total ?? 0;
    final monthMilk = await monthMilkTotal(ym);
    final animals = (await _sum(
            "SELECT COUNT(*) FROM animals WHERE status = 'Active'", []))
        .toInt();
    final income = await salesTotalForMonth(ym);
    final expense = await expenseTotalForMonth(ym);

    final last7 = <DayFlow>[];
    for (var i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final ds = '${d.year.toString().padLeft(4, '0')}-'
          '${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      final s = await _sum('SELECT SUM(total) FROM sales WHERE date = ?', [ds]);
      final e = await _sum('SELECT SUM(amount) FROM expenses WHERE date = ?', [ds]);
      last7.add(DayFlow(d, s, e));
    }
    return DashboardStats(todayMilk, monthMilk, animals, income, expense, last7);
  }
}
