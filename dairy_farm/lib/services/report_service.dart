import '../common.dart';
import '../db/database_helper.dart';

String _cell(Object? v) {
  final s = v == null ? '' : '$v';
  if (s.contains(',') || s.contains('"') || s.contains('\n')) {
    return '"${s.replaceAll('"', '""')}"';
  }
  return s;
}

String _line(List<Object?> c) => c.map(_cell).join(',');
String _l(double v) => v.toStringAsFixed(1);

/// Google Sheet ke liye CSV text banata hai (Drive upload par Sheet mein convert hota hai).
class ReportService {
  /// Animals sheet: tag, naam, photo link, status, aaj/is mahine ka milk, monthly plan.
  static Future<String> animalsCsv(Map<int, String> photoLinks) async {
    final db = DatabaseHelper.instance;
    final now = DateTime.now();
    final today = fmtDate(now);
    final ym = monthPrefix(now);

    final animals = await db.getAnimals();

    final todayMap = <int, double>{};
    for (final r in await db.getMilkByDate(today)) {
      todayMap[r.animalId] = (todayMap[r.animalId] ?? 0) + r.total;
    }
    final monthMap = await db.monthMilkByAnimal(ym);

    // Plans from_date barhte order mein aate hain, aaj tak ka aakhri plan jeetta hai
    final plan = <int, double>{};
    for (final p in await db.getPlans(ym)) {
      if (p.fromDate.compareTo(today) <= 0) plan[p.animalId] = p.total;
    }

    final out = <String>[
      _line([
        'Tag No',
        'Name',
        'Type',
        'Breed',
        'Date of Birth',
        'Age',
        'Status',
        'Photo',
        "Today's Milk (L)",
        'This Month Milk (L)',
        'Monthly Plan (L/day)',
      ]),
    ];
    for (final a in animals) {
      final link = photoLinks[a.id];
      out.add(_line([
        a.tagNo,
        a.name,
        a.type,
        a.breed,
        a.dob,
        ageText(a.dob),
        a.status,
        link == null ? '' : '=HYPERLINK("$link","View photo")',
        _l(todayMap[a.id] ?? 0),
        _l(monthMap[a.id] ?? 0),
        a.status == 'Active' && plan[a.id] != null ? _l(plan[a.id]!) : '',
      ]));
    }
    return out.join('\n');
  }

  /// Milk records sheet: pichhle [days] dinon ki date-wise entries (plan wale bhi).
  static Future<String> milkCsv({int days = 60}) async {
    final db = DatabaseHelper.instance;
    final out = <String>[
      _line(['Date', 'Tag No', 'Animal', 'Morning (L)', 'Evening (L)', 'Total (L)', 'Source']),
    ];
    final now = DateTime.now();
    for (var i = 0; i < days; i++) {
      final ds = fmtDate(now.subtract(Duration(days: i)));
      for (final r in await db.getMilkByDate(ds)) {
        out.add(_line([
          ds,
          r.tagNo,
          r.animalName,
          _l(r.morning),
          _l(r.evening),
          _l(r.total),
          r.auto ? 'Monthly plan' : 'Daily entry',
        ]));
      }
    }
    return out.join('\n');
  }
}
