class GamePackage {
  final int id;
  final int gameId;
  final String name;
  final String? amount;
  final String? category;
  final double price;
  final double? originalPrice;
  final bool isActive;
  final int sortOrder;
  final DateTime? createdAt;

  const GamePackage({
    required this.id,
    required this.gameId,
    required this.name,
    this.amount,
    this.category,
    required this.price,
    this.originalPrice,
    this.isActive = true,
    this.sortOrder = 0,
    this.createdAt,
  });

  bool get hasDiscount =>
      originalPrice != null && originalPrice! > price;

  factory GamePackage.fromJson(Map<String, dynamic> json) {
    return GamePackage(
      id: json['id'] as int,
      gameId: json['game_id'] as int,
      name: json['name'] as String,
      amount: json['amount'] as String?,
      category: json['category'] as String?,
      price: (json['price'] as num).toDouble(),
      originalPrice: (json['original_price'] as num?)?.toDouble(),
      isActive: (json['is_active'] as bool?) ?? true,
      sortOrder: (json['sort_order'] as int?) ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'game_id': gameId,
      'name': name,
      'amount': amount,
      'category': category,
      'price': price,
      'original_price': originalPrice,
      'is_active': isActive,
      'sort_order': sortOrder,
    };
  }

  GamePackage copyWith({
    int? id,
    int? gameId,
    String? name,
    String? amount,
    String? category,
    double? price,
    double? originalPrice,
    bool? isActive,
    int? sortOrder,
  }) {
    return GamePackage(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
    );
  }
}
