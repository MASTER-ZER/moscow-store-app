class GameAccount {
  final int id;
  final int gameId;
  final String title;
  final String? description;
  final double price;
  final double? originalPrice;
  final String? rank;
  final int? level;
  final List<String> images;
  final bool isSold;
  final bool isActive;
  final DateTime? createdAt;

  const GameAccount({
    required this.id,
    required this.gameId,
    required this.title,
    this.description,
    required this.price,
    this.originalPrice,
    this.rank,
    this.level,
    this.images = const [],
    this.isSold = false,
    this.isActive = true,
    this.createdAt,
  });

  bool get hasDiscount =>
      originalPrice != null && originalPrice! > price;

  factory GameAccount.fromJson(Map<String, dynamic> json) {
    return GameAccount(
      id: json['id'] as int,
      gameId: json['game_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      originalPrice: (json['original_price'] as num?)?.toDouble(),
      rank: json['rank'] as String?,
      level: json['level'] as int?,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isSold: (json['is_sold'] as bool?) ?? false,
      isActive: (json['is_active'] as bool?) ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'game_id': gameId,
      'title': title,
      'description': description,
      'price': price,
      'original_price': originalPrice,
      'rank': rank,
      'level': level,
      'images': images,
      'is_active': isActive,
    };
  }
}
