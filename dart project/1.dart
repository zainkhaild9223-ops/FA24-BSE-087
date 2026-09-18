import 'dart:io';


String readString(String message) {
  stdout.write(message);
  return stdin.readLineSync()?.trim() ?? '';
}

int readInt(String message) {
  while (true) {
    stdout.write(message);
    final input = stdin.readLineSync()?.trim() ?? '';
    final value = int.tryParse(input);
    if (value != null) return value;
    print('Invalid input. Please enter a whole number.');
  }
}

double readDouble(String message) {
  while (true) {
    stdout.write(message);
    final input = stdin.readLineSync()?.trim() ?? '';
    final value = double.tryParse(input);
    if (value != null) return value;
    print('Invalid input. Please enter a valid amount.');
  }
}

bool readBool(String message) {
  while (true) {
    stdout.write(message);
    final input = stdin.readLineSync()?.trim().toLowerCase() ?? '';
    if (input == 'yes' || input == 'y' || input == 'true') return true;
    if (input == 'no' || input == 'n' || input == 'false') return false;
    print('Please answer Yes or No.');
  }
}


double calculateTotal(
  List<String> orderItems,
  Map<String, double> menuPrices,
) {
  double subtotal = 0.0;
  for (final item in orderItems) {
    subtotal += menuPrices[item] ?? 0.0;
  }
  return subtotal;
}

double applyDiscount(
  double subtotal,
  bool isHostelite,
  int loyaltyPoints,
) {
  double discount = 0.0;

  if (isHostelite && subtotal > 500) {
    discount += subtotal * 0.15; 
  } else if (!isHostelite && subtotal > 700) {
    discount += subtotal * 0.10; 
  }

  if (loyaltyPoints > 100) {
    discount += 50; 
  }

  final netPrice = subtotal - discount;
  return netPrice < 0 ? 0 : netPrice;
}

Map<String, double> discountBreakdown(
  double subtotal,
  bool isHostelite,
  int loyaltyPoints,
) {
  double tierDiscount = 0.0;
  if (isHostelite && subtotal > 500) {
    tierDiscount = subtotal * 0.15;
  } else if (!isHostelite && subtotal > 700) {
    tierDiscount = subtotal * 0.10;
  }
  final loyaltyDiscount = loyaltyPoints > 100 ? 50.0 : 0.0;
  return {'tierDiscount': tierDiscount, 'loyaltyDiscount': loyaltyDiscount};
}

double voucherValue(String voucher, double amount) {
  switch (voucher) {
    case 'WELCOME10':
      return amount * 0.10;
    case 'CAMPUS50':
      return 50.0;
    case 'EXAMBOOST':
      return 100.0;
    default:
      return 0.0;
  }
}

void logTransaction(String id, double amount) => print(
      'Transaction $id confirmed at ${DateTime.now()} '
      '-> Rs. ${amount.toStringAsFixed(2)} charged.',
    );


void displayStudentProfile(Map<String, dynamic> profile) {
  print('\n================ STUDENT PROFILE ================');
  print('Name           : ${profile['studentName']}');
  print('Student ID     : ${profile['studentId']}');
  print('Wallet Balance : Rs. ${(profile['walletBalance'] as double).toStringAsFixed(2)}');
  print('Hostelite      : ${profile['isHostelite'] ? 'Yes' : 'No'}');
  print('Loyalty Points : ${profile['loyaltyPoints']}');
  print('Account Active : ${profile['isAccountActive'] ? 'Yes' : 'No'}');
  print('===================================================');
}

void displayMenu(Map<String, double> menuPrices) {
  print('\n================== CANTEEN MENU ==================');
  int n = 1;
  menuPrices.forEach((item, price) {
    print('$n. ${item.padRight(20)} Rs. ${price.toStringAsFixed(2)}');
    n++;
  });
  print('0. Finish / Back');
  print('===================================================');
}

void displayVouchers(Set<String> vouchers) {
  print('\n================= VALID VOUCHERS =================');
  if (vouchers.isEmpty) {
    print('No vouchers available.');
  } else {
    for (final v in vouchers) {
      print('- $v');
    }
  }
  print('===================================================');
}

Map<String, int> _quantities(List<String> orderItems) {
  final q = <String, int>{};
  for (final item in orderItems) {
    q[item] = (q[item] ?? 0) + 1;
  }
  return q;
}

void displayCurrentOrder(
  List<String> orderItems,
  Map<String, double> menuPrices,
) {
  if (orderItems.isEmpty) {
    print('\nYour order is currently empty.');
    return;
  }
  print('\n================== CURRENT ORDER =================');
  _quantities(orderItems).forEach((item, qty) {
    final lineTotal = (menuPrices[item] ?? 0.0) * qty;
    print('${item.padRight(20)} x${qty.toString().padLeft(2)}  '
        'Rs. ${lineTotal.toStringAsFixed(2)}');
  });
  final subtotal = calculateTotal(orderItems, menuPrices);
  print('---------------------------------------------------');
  print('${'Subtotal'.padRight(28)}Rs. ${subtotal.toStringAsFixed(2)}');
  print('===================================================');
}


void placeOrder(List<String> orderItems, Map<String, double> menuPrices) {
  while (true) {
    displayMenu(menuPrices);
    final choice = readInt('Select item number: ');
    if (choice == 0) break;
    if (choice < 1 || choice > menuPrices.length) {
      print('Invalid menu choice.');
      continue;
    }

    final selectedItem = menuPrices.keys.elementAt(choice - 1);
    final quantity = readInt('Enter quantity for $selectedItem: ');
    if (quantity <= 0) {
      print('Quantity must be greater than 0.');
      continue;
    }

    for (int i = 0; i < quantity; i++) {
      orderItems.add(selectedItem);
    }
    print('$quantity x $selectedItem added to your order.');
    displayCurrentOrder(orderItems, menuPrices);

    final more = readString('Add another item? (yes/no): ').toLowerCase();
    if (more == 'no' || more == 'n') break;
  }
}


void checkout(
  List<String> orderItems,
  Map<String, double> menuPrices,
  Map<String, dynamic> profile,
  Set<String> validVouchers,
) {
  if (orderItems.isEmpty) {
    print('\nERROR: Your order is empty. Add items before checkout.');
    return;
  }

  final isAccountActive = profile['isAccountActive'] as bool;
  double walletBalance = profile['walletBalance'] as double;
  final isHostelite = profile['isHostelite'] as bool;
  final loyaltyPoints = profile['loyaltyPoints'] as int;

  if (!isAccountActive) {
    print('\nERROR: Account is inactive. Transaction denied.');
    return;
  }
  if (walletBalance <= 0) {
    print('\nERROR: Wallet balance is zero or negative. Transaction denied.');
    return;
  }

  final subtotal = calculateTotal(orderItems, menuPrices);
  final breakdown = discountBreakdown(subtotal, isHostelite, loyaltyPoints);
  final tierDiscount = breakdown['tierDiscount']!;
  final loyaltyDiscount = breakdown['loyaltyDiscount']!;
  final afterDiscount = applyDiscount(subtotal, isHostelite, loyaltyPoints);

  double voucherDiscount = 0.0;
  String appliedVoucher = 'None';
  final voucherInput =
      readString('\nEnter voucher code (Enter to skip): ').toUpperCase();

  if (voucherInput.isNotEmpty) {
    if (validVouchers.contains(voucherInput)) {
      voucherDiscount = voucherValue(voucherInput, afterDiscount);
      validVouchers.remove(voucherInput); // one-time use
      appliedVoucher = voucherInput;
      print('Voucher $voucherInput applied.');
    } else {
      print('Invalid or already-used voucher. No voucher discount applied.');
    }
  }

  double afterVoucher = afterDiscount - voucherDiscount;
  if (afterVoucher < 0) afterVoucher = 0;

  const taxRate = 0.05;
  final tax = afterVoucher * taxRate;
  final finalAmount = afterVoucher + tax;

  if (finalAmount > walletBalance) {
    print('\n================ TRANSACTION FAILED ================');
    print('Insufficient wallet balance.');
    print('Required : Rs. ${finalAmount.toStringAsFixed(2)}');
    print('Available: Rs. ${walletBalance.toStringAsFixed(2)}');
    print('No amount has been deducted.');
    print('======================================================');
    return;
  }

  final previousBalance = walletBalance;
  walletBalance -= finalAmount;
  profile['walletBalance'] = walletBalance;

  final transactionId = 'TXN-${DateTime.now().millisecondsSinceEpoch}';

  print('\n===================================================');
  print('           SMART CAMPUS CANTEEN - RECEIPT');
  print('===================================================');
  print('Student : ${profile['studentName']} (${profile['studentId']})');
  print('Hostelite: ${isHostelite ? 'Yes' : 'No'}   Loyalty: $loyaltyPoints pts');
  print('---------------------------------------------------');
  print('${'Item'.padRight(20)}${'Qty'.padRight(6)}Amount');
  print('---------------------------------------------------');
  _quantities(orderItems).forEach((item, qty) {
    final lineTotal = (menuPrices[item] ?? 0.0) * qty;
    print('${item.padRight(20)}${qty.toString().padRight(6)}'
        'Rs. ${lineTotal.toStringAsFixed(2)}');
  });
  print('---------------------------------------------------');
  print('${'Subtotal'.padRight(28)}Rs. ${subtotal.toStringAsFixed(2)}');
  print('${'Tier Discount'.padRight(28)}-Rs. ${tierDiscount.toStringAsFixed(2)}');
  print('${'Loyalty Discount'.padRight(28)}-Rs. ${loyaltyDiscount.toStringAsFixed(2)}');
  print('${'Voucher ($appliedVoucher)'.padRight(28)}-Rs. ${voucherDiscount.toStringAsFixed(2)}');
  print('---------------------------------------------------');
  print('${'Amount after discounts'.padRight(28)}Rs. ${afterVoucher.toStringAsFixed(2)}');
  print('${'Tax (5%)'.padRight(28)}Rs. ${tax.toStringAsFixed(2)}');
  print('---------------------------------------------------');
  print('${'FINAL PAYABLE'.padRight(28)}Rs. ${finalAmount.toStringAsFixed(2)}');
  print('---------------------------------------------------');
  print('${'Previous Balance'.padRight(28)}Rs. ${previousBalance.toStringAsFixed(2)}');
  print('${'Remaining Balance'.padRight(28)}Rs. ${walletBalance.toStringAsFixed(2)}');
  print('===================================================');

  logTransaction(transactionId, finalAmount); // arrow function call

  orderItems.clear();
  print('\nThank you for using Smart Campus Canteen!');
}

void main() {
  print('===================================================');
  print('        SMART CAMPUS CANTEEN ENGINE - CSC303');
  print('===================================================');

  print('\nEnter Student Profile Information\n');

  final String studentName = readString('Student Name: ');
  final String studentId = readString('Registration / Roll No: ');
  final double walletBalance = readDouble('Wallet Balance (Rs.): ');
  final bool isHostelite = readBool('Are you a hostelite? (yes/no): ');
  final int loyaltyPoints = readInt('Loyalty Points: ');
  final bool isAccountActive = readBool('Is your account active? (yes/no): ');

  final Map<String, dynamic> studentProfile = {
    'studentName': studentName,
    'studentId': studentId,
    'walletBalance': walletBalance,
    'isHostelite': isHostelite,
    'loyaltyPoints': loyaltyPoints,
    'isAccountActive': isAccountActive,
  };

  displayStudentProfile(studentProfile);

  final Map<String, double> menuPrices = {
    'Chicken Roll': 250.0,
    'Zinger Burger': 450.0,
    'Fries': 180.0,
    'Coffee': 150.0,
    'Fresh Juice': 200.0,
  };

  final List<String> orderItems = [];

  final Set<String> validVouchers = {
    'WELCOME10',
    'CAMPUS50',
    'EXAMBOOST',
  };

  bool running = true;

  while (running) {
    print('\n===================================================');
    print('               SMART CAMPUS CANTEEN');
    print('===================================================');
    print('1. View Student Profile');
    print('2. View Menu');
    print('3. Place Order');
    print('4. View Current Order');
    print('5. View Valid Vouchers');
    print('6. Checkout');
    print('7. Exit');
    print('===================================================');

    final choice = readInt('Enter your choice: ');

    switch (choice) {
      case 1:
        displayStudentProfile(studentProfile);
        break;
      case 2:
        displayMenu(menuPrices);
        break;
      case 3:
        placeOrder(orderItems, menuPrices);
        break;
      case 4:
        displayCurrentOrder(orderItems, menuPrices);
        break;
      case 5:
        displayVouchers(validVouchers);
        break;
      case 6:
        checkout(orderItems, menuPrices, studentProfile, validVouchers);
        break;
      case 7:
        print('\nThank you for using Smart Campus Canteen!');
        running = false;
        break;
      default:
        print('\nInvalid choice. Please select a number from 1 to 7.');
    }
  }
}