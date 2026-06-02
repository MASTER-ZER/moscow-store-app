class Order {
  final int id;
  final String orderNumber;
  final int? customerId;
  final String? customerName;
  final String? customerPhone;
  final int? gameId;
  final int? packageId;
  final int? accountId;
  final int? courseId;
  final String orderType;
  final String? loginType;
  final String? playerId;
  final String? accountUsername;
  final String? accountPassword;
  final String? paymentMethod;
  final String paymentType;
  final double totalAmount;
  final String status;
  final String? notes;
  final String? adminNotes;
  final String source;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Joined data
  final String? gameName;
  final String? gameNameAr;
  final String? packageName;
  final String? packageAmount;
  final String? accountTitle;

  const Order({
    required this.id,
    required this.orderNumber,
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.gameId,
    this.packageId,
    this.accountId,
    this.courseId,
    this.orderType = 'topup',
    this.loginType,
    this.playerId,
    this.accountUsername,
    this.accountPassword,
    this.paymentMethod,
    this.paymentType = 'transfer',
    required this.totalAmount,
    this.status = 'pending',
    this.notes,
    this.adminNotes,
    this.source = 'app',
    this.createdAt,
    this.updatedAt,
    this.gameName,
    this.gameNameAr,
    this.packageName,
    this.packageAmount,
    this.accountTitle,
  });

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'processing':
        return 'جاري التنفيذ';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  static const statusColors = {
    'pending': '#F59E0B',
    'processing': '#3B82F6',
    'completed': '#22C55E',
    'cancelled': '#EF4444',
  };

  String get statusColor => statusColors[status] ?? '#6B7280';

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      orderNumber: json['order_number'] as String,
      customerId: json['customer_id'] as int?,
      customerName: json['customer_name'] as String?,
      customerPhone: json['customer_phone'] as String?,
      gameId: json['game_id'] as int?,
      packageId: json['package_id'] as int?,
      accountId: json['account_id'] as int?,
      courseId: json['course_id'] as int?,
      orderType: (json['order_type'] as String?) ?? 'topup',
      loginType: json['login_type'] as String?,
      playerId: json['player_id'] as String?,
      accountUsername: json['account_username'] as String?,
      accountPassword: json['account_password'] as String?,
      paymentMethod: json['payment_method'] as String?,
      paymentType: (json['payment_type'] as String?) ?? 'transfer',
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: (json['status'] as String?) ?? 'pending',
      notes: json['notes'] as String?,
      adminNotes: json['admin_notes'] as String?,
      source: (json['source'] as String?) ?? 'app',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      gameName: json['game_name'] as String?,
      gameNameAr: json['game_name_ar'] as String?,
      packageName: json['package_name'] as String?,
      packageAmount: json['package_amount'] as String?,
      accountTitle: json['account_title'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'game_id': gameId,
      'package_id': packageId,
      'account_id': accountId,
      'course_id': courseId,
      'order_type': orderType,
      'login_type': loginType,
      'player_id': playerId,
      'account_username': accountUsername,
      'account_password': accountPassword,
      'payment_method': paymentMethod,
      'payment_type': paymentType,
      'total_amount': totalAmount,
      'status': status,
      'notes': notes,
      'admin_notes': adminNotes,
      'source': source,
    };
  }

  Order copyWith({String? status, String? adminNotes}) {
    return Order(
      id: id,
      orderNumber: orderNumber,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      gameId: gameId,
      packageId: packageId,
      accountId: accountId,
      courseId: courseId,
      orderType: orderType,
      loginType: loginType,
      playerId: playerId,
      accountUsername: accountUsername,
      accountPassword: accountPassword,
      paymentMethod: paymentMethod,
      paymentType: paymentType,
      totalAmount: totalAmount,
      status: status ?? this.status,
      notes: notes,
      adminNotes: adminNotes ?? this.adminNotes,
      source: source,
      createdAt: createdAt,
      updatedAt: updatedAt,
      gameName: gameName,
      gameNameAr: gameNameAr,
      packageName: packageName,
      packageAmount: packageAmount,
      accountTitle: accountTitle,
    );
  }
}
