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
  /// Animals sheet: tag, naam, photo link, status.
  /// (Milk ab day-wise hai, is liye animals sheet mein milk columns nahi hain.)
  static Future<String> animalsCsv(Map<int, String> photoLinks) async {
    final animals = await DatabaseHelper.instance.getAnimals();

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
      ]));
    }
    return out.join('\n');
  }

  /// Milk records sheet: pichhle [days] dinon ka day-wise total milk
  /// (plan wale din bhi), running total ke saath.
  static Future<String> milkCsv({int days = 60}) async {
    final db = DatabaseHelper.instance;
    final out = <String>[
      _line(['Date', 'Morning (L)', 'Evening (L)', 'Total (L)', 'Running Total (L)', 'Source']),
    ];
    final now = DateTime.now();
    // Purane din se naye din ki taraf, taake running total sahi bane
    var run = 0.0;
    for (var i = days - 1; i >= 0; i--) {
      final ds = fmtDate(now.subtract(Duration(days: i)));
      final r = await db.getMilkByDate(ds);
      if (r == null) continue;
      run += r.total;
      out.add(_line([
        ds,
        _l(r.morning),
        _l(r.evening),
        _l(r.total),
        _l(run),
        r.auto ? 'Monthly plan' : 'Daily entry',
      ]));
    }
    return out.join('\n');
  }

  /// Feed sheet: pichhle [days] dinon ka day-wise total Feed kharcha,
  /// running total ke saath.
  static Future<String> feedCsv({int days = 60}) async {
    final db = DatabaseHelper.instance;
    final out = <String>[
      _line(['Date', 'Feed Cost (PKR)', 'Running Total (PKR)']),
    ];
    final now = DateTime.now();
    final from = fmtDate(now.subtract(Duration(days: days - 1)));
    final to = fmtDate(now);
    var run = 0.0;
    for (final d in await db.feedDailyTotalsRange(from, to)) {
      run += d.total;
      out.add(_line([d.date, d.total.toStringAsFixed(0), run.toStringAsFixed(0)]));
    }
    return out.join('\n');
  }
}
