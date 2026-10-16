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
      version: 1,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, v) async {
        await db.execute('''CREATE TABLE animals(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          tag_no TEXT UNIQUE NOT NULL,
          name TEXT, type TEXT, breed TEXT, dob TEXT,
          status TEXT DEFAULT 'Active')''');
        await db.execute('''CREATE TABLE milk_records(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          animal_id INTEGER NOT NULL,
          date TEXT NOT NULL,
          morning REAL DEFAULT 0,
          evening REAL DEFAULT 0,
          FOREIGN KEY(animal_id) REFERENCES animals(id) ON DELETE CASCADE)''');
        await db.execute('''CREATE TABLE expenses(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL, category TEXT, amount REAL, note TEXT)''');
        await db.execute('''CREATE TABLE sales(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL, liters REAL, rate REAL, total REAL, buyer TEXT)''');
      },
    );
  }

  /// Backup/restore se pehle DB band karna zaroori hai.
  /// Agli query par database dobara khud khul jata hai.
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  // ---------------- Animals ----------------
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

  Future<int> deleteAnimal(int id) async {
    final db = await database;
    await db.delete('milk_records', where: 'animal_id = ?', whereArgs: [id]);
    return db.delete('animals', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- Milk ----------------
  Future<List<MilkRecord>> getMilkByDate(String date) async {
    final rows = await (await database).rawQuery('''
      SELECT m.*, a.name AS animal_name, a.tag_no AS tag_no
      FROM milk_records m JOIN animals a ON a.id = m.animal_id
      WHERE m.date = ? ORDER BY a.name COLLATE NOCASE''', [date]);
    return rows.map(MilkRecord.fromMap).toList();
  }

  Future<int> insertMilk(MilkRecord r) async =>
      (await database).insert('milk_records', r.toMap()..remove('id'));

  Future<int> updateMilk(MilkRecord r) async => (await database)
      .update('milk_records', r.toMap()..remove('id'), where: 'id = ?', whereArgs: [r.id]);

  Future<int> deleteMilk(int id) async =>
      (await database).delete('milk_records', where: 'id = ?', whereArgs: [id]);

  // ---------------- Expenses ----------------
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
    final todayMilk = await _sum(
        'SELECT SUM(morning + evening) FROM milk_records WHERE date = ?', [today]);
    final monthMilk = await _sum(
        'SELECT SUM(morning + evening) FROM milk_records WHERE date LIKE ?', ['$ym%']);
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
