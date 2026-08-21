class DeliveryItem {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String address;
  final String route;
  final DateTime date;
  final String slot; // 'morning' or 'evening'
  final double buffaloLiters;
  final double cowLiters;
  final double goatLiters;
  final double extraLiters;
  final double totalAmount;
  final String status; // 'delivered', 'pending', 'paused', 'missed', 'extra'
  final DateTime? deliveredAt;
  final String riderName;
  final String riderPhone;
  final String lactometerScore;
  final String fatPercentage;
  final String? notes;

  DeliveryItem({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    required this.route,
    required this.date,
    required this.slot,
    this.buffaloLiters = 0.0,
    this.cowLiters = 0.0,
    this.goatLiters = 0.0,
    this.extraLiters = 0.0,
    required this.totalAmount,
    this.status = 'pending',
    this.deliveredAt,
    this.riderName = 'Tariq Mahmood',
    this.riderPhone = '+923410292698',
    this.lactometerScore = '29.5 LR (Grade A+)',
    this.fatPercentage = '7.2% Natural Fat',
    this.notes,
  });

  double get totalLiters => buffaloLiters + cowLiters + goatLiters + extraLiters;

  DeliveryItem copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? address,
    String? route,
    DateTime? date,
    String? slot,
    double? buffaloLiters,
    double? cowLiters,
    double? goatLiters,
    double? extraLiters,
    double? totalAmount,
    String? status,
    DateTime? deliveredAt,
    String? riderName,
    String? riderPhone,
    String? lactometerScore,
    String? fatPercentage,
    String? notes,
  }) {
    return DeliveryItem(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      address: address ?? this.address,
      route: route ?? this.route,
      date: date ?? this.date,
      slot: slot ?? this.slot,
      buffaloLiters: buffaloLiters ?? this.buffaloLiters,
      cowLiters: cowLiters ?? this.cowLiters,
      goatLiters: goatLiters ?? this.goatLiters,
      extraLiters: extraLiters ?? this.extraLiters,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      riderName: riderName ?? this.riderName,
      riderPhone: riderPhone ?? this.riderPhone,
      lactometerScore: lactometerScore ?? this.lactometerScore,
      fatPercentage: fatPercentage ?? this.fatPercentage,
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
      'date': date.toIso8601String(),
      'slot': slot,
      'buffaloLiters': buffaloLiters,
      'cowLiters': cowLiters,
      'goatLiters': goatLiters,
      'extraLiters': extraLiters,
      'totalAmount': totalAmount,
      'status': status,
      'deliveredAt': deliveredAt?.toIso8601String(),
      'riderName': riderName,
      'riderPhone': riderPhone,
      'lactometerScore': lactometerScore,
      'fatPercentage': fatPercentage,
      'notes': notes,
    };
  }

  factory DeliveryItem.fromMap(Map<String, dynamic> map, String id) {
    return DeliveryItem(
      id: id,
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? 'Customer',
      customerPhone: map['customerPhone'] ?? '',
      address: map['address'] ?? '',
      route: map['route'] ?? 'Main Route',
      date: map['date'] != null ? DateTime.tryParse(map['date']) ?? DateTime.now() : DateTime.now(),
      slot: map['slot'] ?? 'morning',
      buffaloLiters: (map['buffaloLiters'] as num?)?.toDouble() ?? 0.0,
      cowLiters: (map['cowLiters'] as num?)?.toDouble() ?? 0.0,
      goatLiters: (map['goatLiters'] as num?)?.toDouble() ?? 0.0,
      extraLiters: (map['extraLiters'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'pending',
      deliveredAt: map['deliveredAt'] != null ? DateTime.tryParse(map['deliveredAt']) : null,
      riderName: map['riderName'] ?? 'Tariq Mahmood',
      riderPhone: map['riderPhone'] ?? '+923410292698',
      lactometerScore: map['lactometerScore'] ?? '29.5 LR (Grade A+)',
      fatPercentage: map['fatPercentage'] ?? '7.2% Natural Fat',
      notes: map['notes'],
    );
  }
}
