class KhataCustomer {
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String address;
  final String route;
  final double currentBalance; // Positive = Due from customer
  final double totalLitersThisMonth;
  final double totalBilledThisMonth;
  final double totalPaidThisMonth;
  final DateTime? lastPaymentDate;
  final double? lastPaymentAmount;
  final String paymentStatus; // 'paid', 'pending', 'overdue'

  KhataCustomer({
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    required this.route,
    required this.currentBalance,
    required this.totalLitersThisMonth,
    required this.totalBilledThisMonth,
    required this.totalPaidThisMonth,
    this.lastPaymentDate,
    this.lastPaymentAmount,
    this.paymentStatus = 'pending',
  });

  KhataCustomer copyWith({
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? address,
    String? route,
    double? currentBalance,
    double? totalLitersThisMonth,
    double? totalBilledThisMonth,
    double? totalPaidThisMonth,
    DateTime? lastPaymentDate,
    double? lastPaymentAmount,
    String? paymentStatus,
  }) {
    return KhataCustomer(
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      address: address ?? this.address,
      route: route ?? this.route,
      currentBalance: currentBalance ?? this.currentBalance,
      totalLitersThisMonth: totalLitersThisMonth ?? this.totalLitersThisMonth,
      totalBilledThisMonth: totalBilledThisMonth ?? this.totalBilledThisMonth,
      totalPaidThisMonth: totalPaidThisMonth ?? this.totalPaidThisMonth,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      lastPaymentAmount: lastPaymentAmount ?? this.lastPaymentAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }
}

class KhataEntry {
  final String id;
  final String customerId;
  final DateTime date;
  final String type; // 'delivery_debit', 'payment_credit', 'adjustment'
  final double liters;
  final double amount;
  final String description;
  final String paymentMethod; // 'Cash', 'JazzCash', 'EasyPaisa', 'Bank Transfer', 'N/A'

  KhataEntry({
    required this.id,
    required this.customerId,
    required this.date,
    required this.type,
    this.liters = 0.0,
    required this.amount,
    required this.description,
    this.paymentMethod = 'N/A',
  });
}
