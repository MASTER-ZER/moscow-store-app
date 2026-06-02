class WalletTransaction {
  final int id;
  final int customerId;
  final String type;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String? reason;
  final int? referenceId;
  final DateTime? createdAt;

  const WalletTransaction({
    required this.id,
    required this.customerId,
    required this.type,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    this.reason,
    this.referenceId,
    this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] as int,
      customerId: json['customer_id'] as int,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      balanceBefore: (json['balance_before'] as num).toDouble(),
      balanceAfter: (json['balance_after'] as num).toDouble(),
      reason: json['reason'] as String?,
      referenceId: json['reference_id'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}
