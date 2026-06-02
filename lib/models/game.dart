class Game {
  final int id;
  final String name;
  final String nameAr;
  final String slug;
  final String? description;
  final String? icon;
  final String? image;
  final String color;
  final String loginType;
  final bool isActive;
  final int sortOrder;
  final DateTime? createdAt;

  const Game({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.slug,
    this.description,
    this.icon,
    this.image,
    this.color = '#00B3E5',
    this.loginType = 'id',
    this.isActive = true,
    this.sortOrder = 0,
    this.createdAt,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] as int,
      name: json['name'] as String,
      nameAr: json['name_ar'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      image: json['image'] as String?,
      color: (json['color'] as String?) ?? '#00B3E5',
      loginType: (json['login_type'] as String?) ?? 'id',
      isActive: (json['is_active'] as bool?) ?? true,
      sortOrder: (json['sort_order'] as int?) ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'name_ar': nameAr,
      'slug': slug,
      'description': description,
      'icon': icon,
      'image': image,
      'color': color,
      'login_type': loginType,
      'is_active': isActive,
      'sort_order': sortOrder,
    };
  }

  Game copyWith({
    int? id,
    String? name,
    String? nameAr,
    String? slug,
    String? description,
    String? icon,
    String? image,
    String? color,
    String? loginType,
    bool? isActive,
    int? sortOrder,
  }) {
    return Game(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      image: image ?? this.image,
      color: color ?? this.color,
      loginType: loginType ?? this.loginType,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
    );
  }
}
