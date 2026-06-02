class PaymentMethod {
  final int id;
  final String name;
  final String nameAr;
  final String type;
  final String? details;
  final String? accountNumber;
  final String? accountName;
  final String? icon;
  final bool isActive;
  final int sortOrder;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.nameAr,
    this.type = 'bank',
    this.details,
    this.accountNumber,
    this.accountName,
    this.icon,
    this.isActive = true,
    this.sortOrder = 0,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as int,
      name: json['name'] as String,
      nameAr: json['name_ar'] as String,
      type: (json['type'] as String?) ?? 'bank',
      details: json['details'] as String?,
      accountNumber: json['account_number'] as String?,
      accountName: json['account_name'] as String?,
      icon: json['icon'] as String?,
      isActive: (json['is_active'] as bool?) ?? true,
      sortOrder: (json['sort_order'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'name_ar': nameAr,
      'type': type,
      'details': details,
      'account_number': accountNumber,
      'account_name': accountName,
      'icon': icon,
      'is_active': isActive,
      'sort_order': sortOrder,
    };
  }
}
