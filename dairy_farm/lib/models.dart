class Animal {
  final int? id;
  final String tagNo;
  final String name;
  final String type; // Cow / Buffalo
  final String breed;
  final String dob;
  final String status; // Active / Sold

  Animal({
    this.id,
    required this.tagNo,
    required this.name,
    required this.type,
    this.breed = '',
    this.dob = '',
    this.status = 'Active',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'tag_no': tagNo,
        'name': name,
        'type': type,
        'breed': breed,
        'dob': dob,
        'status': status,
      };

  factory Animal.fromMap(Map<String, dynamic> m) => Animal(
        id: m['id'] as int?,
        tagNo: m['tag_no'] as String,
        name: (m['name'] ?? '') as String,
        type: (m['type'] ?? 'Cow') as String,
        breed: (m['breed'] ?? '') as String,
        dob: (m['dob'] ?? '') as String,
        status: (m['status'] ?? 'Active') as String,
      );
}

class MilkRecord {
  final int? id;
  final int animalId;
  final String date;
  final double morning;
  final double evening;
  final String? animalName; // from JOIN
  final String? tagNo; // from JOIN

  MilkRecord({
    this.id,
    required this.animalId,
    required this.date,
    required this.morning,
    required this.evening,
    this.animalName,
    this.tagNo,
  });

  double get total => morning + evening;

  Map<String, dynamic> toMap() => {
        'id': id,
        'animal_id': animalId,
        'date': date,
        'morning': morning,
        'evening': evening,
      };

  factory MilkRecord.fromMap(Map<String, dynamic> m) => MilkRecord(
        id: m['id'] as int?,
        animalId: m['animal_id'] as int,
        date: m['date'] as String,
        morning: (m['morning'] as num).toDouble(),
        evening: (m['evening'] as num).toDouble(),
        animalName: m['animal_name'] as String?,
        tagNo: m['tag_no'] as String?,
      );
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
