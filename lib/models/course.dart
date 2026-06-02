class Course {
  final int id;
  final int? gameId;
  final String title;
  final String? description;
  final double price;
  final double? originalPrice;
  final List<String> features;
  final String? image;
  final bool isActive;
  final DateTime? createdAt;

  const Course({
    required this.id,
    this.gameId,
    required this.title,
    this.description,
    required this.price,
    this.originalPrice,
    this.features = const [],
    this.image,
    this.isActive = true,
    this.createdAt,
  });

  bool get hasDiscount =>
      originalPrice != null && originalPrice! > price;

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as int,
      gameId: json['game_id'] as int?,
      title: json['title'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      originalPrice: (json['original_price'] as num?)?.toDouble(),
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      image: json['image'] as String?,
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
      'features': features,
      'image': image,
      'is_active': isActive,
    };
  }
}
