class Category {
  final int id;
  final String name;
  final int brandId;
  final String description;
  final DateTime? deletedAt;

  const Category({
    required this.id,
    required this.name,
    required this.brandId,
    required this.description,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Category copyWith({
    String? name,
    int? brandId,
    String? description,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      brandId: brandId ?? this.brandId,
      description: description ?? this.description,
      deletedAt:
          clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brandId': brandId,
      'description': description,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id'] ?? 0}') ?? 0,
      name: json['name']?.toString() ?? '',
      brandId: json['brandId'] is int
          ? json['brandId'] as int
          : int.tryParse('${json['brandId'] ?? 0}') ?? 0,
      description: json['description']?.toString() ?? '',
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.tryParse(json['deletedAt'].toString()),
    );
  }
}