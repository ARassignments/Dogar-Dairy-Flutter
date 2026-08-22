class MonthlySupplyModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String address;
  final String route;
  final double dailyBuffaloLiters;
  final double dailyCowLiters;
  final double dailyGoatLiters;
  final double ratePerLiterBuffalo;
  final double ratePerLiterCow;
  final double ratePerLiterGoat;
  final String preferredSlot; // 'morning', 'evening', 'both'
  final String preferredTime;
  final String status; // 'active', 'paused', 'pending', 'expired'
  final DateTime startDate;
  final DateTime? pauseStartDate;
  final DateTime? pauseEndDate;
  final String assignedRider;
  final String riderPhone;
  final String? notes;

  MonthlySupplyModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    required this.route,
    this.dailyBuffaloLiters = 0.0,
    this.dailyCowLiters = 0.0,
    this.dailyGoatLiters = 0.0,
    this.ratePerLiterBuffalo = 220.0,
    this.ratePerLiterCow = 200.0,
    this.ratePerLiterGoat = 280.0,
    this.preferredSlot = 'morning',
    this.preferredTime = '6:30 AM',
    this.status = 'active',
    required this.startDate,
    this.pauseStartDate,
    this.pauseEndDate,
    this.assignedRider = 'Tariq Mahmood',
    this.riderPhone = '+923410292698',
    this.notes,
  });

  double get totalDailyLiters =>
      dailyBuffaloLiters + dailyCowLiters + dailyGoatLiters;

  double get dailyCost =>
      (dailyBuffaloLiters * ratePerLiterBuffalo) +
      (dailyCowLiters * ratePerLiterCow) +
      (dailyGoatLiters * ratePerLiterGoat);

  double get estimatedMonthlyCost => dailyCost * 30;

  double get estimatedMonthlyLiters => totalDailyLiters * 30;

  MonthlySupplyModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? address,
    String? route,
    double? dailyBuffaloLiters,
    double? dailyCowLiters,
    double? dailyGoatLiters,
    double? ratePerLiterBuffalo,
    double? ratePerLiterCow,
    double? ratePerLiterGoat,
    String? preferredSlot,
    String? preferredTime,
    String? status,
    DateTime? startDate,
    DateTime? pauseStartDate,
    DateTime? pauseEndDate,
    String? assignedRider,
    String? riderPhone,
    String? notes,
  }) {
    return MonthlySupplyModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      address: address ?? this.address,
      route: route ?? this.route,
      dailyBuffaloLiters: dailyBuffaloLiters ?? this.dailyBuffaloLiters,
      dailyCowLiters: dailyCowLiters ?? this.dailyCowLiters,
      dailyGoatLiters: dailyGoatLiters ?? this.dailyGoatLiters,
      ratePerLiterBuffalo: ratePerLiterBuffalo ?? this.ratePerLiterBuffalo,
      ratePerLiterCow: ratePerLiterCow ?? this.ratePerLiterCow,
      ratePerLiterGoat: ratePerLiterGoat ?? this.ratePerLiterGoat,
      preferredSlot: preferredSlot ?? this.preferredSlot,
      preferredTime: preferredTime ?? this.preferredTime,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      pauseStartDate: pauseStartDate ?? this.pauseStartDate,
      pauseEndDate: pauseEndDate ?? this.pauseEndDate,
      assignedRider: assignedRider ?? this.assignedRider,
      riderPhone: riderPhone ?? this.riderPhone,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'address': address,
      'route': route,
      'dailyBuffaloLiters': dailyBuffaloLiters,
      'dailyCowLiters': dailyCowLiters,
      'dailyGoatLiters': dailyGoatLiters,
      'ratePerLiterBuffalo': ratePerLiterBuffalo,
      'ratePerLiterCow': ratePerLiterCow,
      'ratePerLiterGoat': ratePerLiterGoat,
      'preferredSlot': preferredSlot,
      'preferredTime': preferredTime,
      'status': status,
      'startDate': startDate.toIso8601String(),
      'pauseStartDate': pauseStartDate?.toIso8601String(),
      'pauseEndDate': pauseEndDate?.toIso8601String(),
      'assignedRider': assignedRider,
      'riderPhone': riderPhone,
      'notes': notes,
    };
  }

  factory MonthlySupplyModel.fromMap(Map<String, dynamic> map, String docId) {
    return MonthlySupplyModel(
      id: docId,
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? 'Customer',
      customerPhone: map['customerPhone'] ?? '',
      address: map['address'] ?? '',
      route: map['route'] ?? 'Route A - North Nazimabad',
      dailyBuffaloLiters: (map['dailyBuffaloLiters'] as num?)?.toDouble() ?? 0.0,
      dailyCowLiters: (map['dailyCowLiters'] as num?)?.toDouble() ?? 0.0,
      dailyGoatLiters: (map['dailyGoatLiters'] as num?)?.toDouble() ?? 0.0,
      ratePerLiterBuffalo:
          (map['ratePerLiterBuffalo'] as num?)?.toDouble() ?? 220.0,
      ratePerLiterCow: (map['ratePerLiterCow'] as num?)?.toDouble() ?? 200.0,
      ratePerLiterGoat:
          (map['ratePerLiterGoat'] as num?)?.toDouble() ?? 280.0,
      preferredSlot: map['preferredSlot'] ?? 'morning',
      preferredTime: map['preferredTime'] ?? '6:30 AM',
      status: map['status'] ?? 'active',
      startDate: map['startDate'] != null
          ? DateTime.tryParse(map['startDate']) ?? DateTime.now()
          : DateTime.now(),
      pauseStartDate: map['pauseStartDate'] != null
          ? DateTime.tryParse(map['pauseStartDate'])
          : null,
      pauseEndDate: map['pauseEndDate'] != null
          ? DateTime.tryParse(map['pauseEndDate'])
          : null,
      assignedRider: map['assignedRider'] ?? 'Tariq Mahmood',
      riderPhone: map['riderPhone'] ?? '+923410292698',
      notes: map['notes'],
    );
  }
}
