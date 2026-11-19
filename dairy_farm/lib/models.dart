import 'dart:typed_data';

class Animal {
  final int? id;
  final String tagNo;
  final String name;
  final String type; // Cow / Buffalo
  final String breed;
  final String dob;
  final String status; // Active / Sold
  final Uint8List? photo; // chhoti compressed image (SQLite BLOB)

  Animal({
    this.id,
    required this.tagNo,
    required this.name,
    required this.type,
    this.breed = '',
    this.dob = '',
    this.status = 'Active',
    this.photo,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'tag_no': tagNo,
        'name': name,
        'type': type,
        'breed': breed,
        'dob': dob,
        'status': status,
        'photo': photo,
      };

  factory Animal.fromMap(Map<String, dynamic> m) => Animal(
        id: m['id'] as int?,
        tagNo: m['tag_no'] as String,
        name: (m['name'] ?? '') as String,
        type: (m['type'] ?? 'Cow') as String,
        breed: (m['breed'] ?? '') as String,
        dob: (m['dob'] ?? '') as String,
        status: (m['status'] ?? 'Active') as String,
        photo: m['photo'] as Uint8List?,
      );
}

/// Aik din ka total milk — poore farm ka, kisi aik cow ka nahi.
/// Har date ki sirf aik entry hoti hai (morning + evening).
class MilkRecord {
  final int? id;
  final String date; // yyyy-MM-dd
  final double morning;
  final double evening;
  final bool auto; // true = monthly plan se khud bana record (database mein nahi)

  MilkRecord({
    this.id,
    required this.date,
    required this.morning,
    required this.evening,
    this.auto = false,
  });

  double get total => morning + evening;

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date,
        'morning': morning,
        'evening': evening,
      };

  factory MilkRecord.fromMap(Map<String, dynamic> m) => MilkRecord(
        id: m['id'] as int?,
        date: m['date'] as String,
        morning: (m['morning'] as num).toDouble(),
        evening: (m['evening'] as num).toDouble(),
      );
}

/// Aik din ka total (date + total) — feed day-wise list ke liye.
class DayTotal {
  final String date;
  final double total;
  DayTotal(this.date, this.total);
}

class Expense {
  final int? id;
  final String date;
  final String category; // Feed / Medicine / Labor / Other
  final double amount;
  final String note;

  Expense({
    this.id,
    required this.date,
    required this.category,
    required this.amount,
    this.note = '',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date,
        'category': category,
        'amount': amount,
        'note': note,
      };

  factory Expense.fromMap(Map<String, dynamic> m) => Expense(
        id: m['id'] as int?,
        date: m['date'] as String,
        category: m['category'] as String,
        amount: (m['amount'] as num).toDouble(),
        note: (m['note'] ?? '') as String,
      );
}

class Sale {
  final int? id;
  final String date;
  final double liters;
  final double rate;
  final String buyer;

  Sale({
    this.id,
    required this.date,
    required this.liters,
    required this.rate,
    this.buyer = '',
  });

  double get total => liters * rate;

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date,
        'liters': liters,
        'rate': rate,
        'total': total,
        'buyer': buyer,
      };

  factory Sale.fromMap(Map<String, dynamic> m) => Sale(
        id: m['id'] as int?,
        date: m['date'] as String,
        liters: (m['liters'] as num).toDouble(),
        rate: (m['rate'] as num).toDouble(),
        buyer: (m['buyer'] ?? '') as String,
      );
}

/// Poore farm ka monthly fixed daily milk. [fromDate] se mahine ke aakhir tak
/// har din itna milk count hota hai (jab tak us din ki apni entry na ho).
class MilkPlan {
  final int? id;
  final String month; // yyyy-MM
  final String fromDate; // yyyy-MM-dd
  final double morning;
  final double evening;

  MilkPlan({
    this.id,
    required this.month,
    required this.fromDate,
    required this.morning,
    required this.evening,
  });

  double get total => morning + evening;

  Map<String, dynamic> toMap() => {
        'month': month,
        'from_date': fromDate,
        'morning': morning,
        'evening': evening,
      };

  factory MilkPlan.fromMap(Map<String, dynamic> m) => MilkPlan(
        id: m['id'] as int?,
        month: m['month'] as String,
        fromDate: m['from_date'] as String,
        morning: (m['morning'] as num).toDouble(),
        evening: (m['evening'] as num).toDouble(),
      );
}
