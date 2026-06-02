class Customer {
  final int id;
  final String name;
  final String phone;
  final double balance;
  final int points;
  final String level;
  final String? referralCode;
  final bool isActive;
  final DateTime? createdAt;

  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.balance = 0,
    this.points = 0,
    this.level = 'starter',
    this.referralCode,
    this.isActive = true,
    this.createdAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String,
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      points: (json['points'] as int?) ?? 0,
      level: (json['level'] as String?) ?? 'starter',
      referralCode: json['referral_code'] as String?,
      isActive: (json['is_active'] as bool?) ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'password': '********',
      'balance': balance,
      'points': points,
      'level': level,
      'referral_code': referralCode,
    };
  }
}
