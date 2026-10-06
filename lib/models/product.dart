class Product {
  final int id;
  final String name;
  final String sku;
  final int brandId;
  final List<int> categoryIds;
  final List<int> supplierIds;
  final double price;
  final int stock;
  final String description;
  final DateTime? deletedAt;

  const Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.brandId,
    required this.categoryIds,
    required this.supplierIds,
    required this.price,
    required this.stock,
    required this.description,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Product copyWith({
    String? name,
    String? sku,
    int? brandId,
    List<int>? categoryIds,
    List<int>? supplierIds,
    double? price,
    int? stock,
    String? description,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      brandId: brandId ?? this.brandId,
      categoryIds: categoryIds ?? this.categoryIds,
      supplierIds: supplierIds ?? this.supplierIds,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      deletedAt:
          clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'brandId': brandId,
      'categoryIds': categoryIds,
      'supplierIds': supplierIds,
      'price': price,
      'stock': stock,
      'description': description,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final categories =
        json['categoryIds'] is List ? json['categoryIds'] as List : const [];

    final suppliers =
        json['supplierIds'] is List ? json['supplierIds'] as List : const [];

    return Product(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id'] ?? 0}') ?? 0,
      name: json['name']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      brandId: json['brandId'] is int
          ? json['brandId'] as int
          : int.tryParse('${json['brandId'] ?? 0}') ?? 0,
      categoryIds: categories
          .map(
            (e) => e is int ? e : int.tryParse('$e') ?? 0,
          )
          .toList(),
      supplierIds: suppliers
          .map(
            (e) => e is int ? e : int.tryParse('$e') ?? 0,
          )
          .toList(),
      price: json['price'] is num
          ? (json['price'] as num).toDouble()
          : double.tryParse('${json['price'] ?? 0}') ?? 0,
      stock: json['stock'] is int
          ? json['stock'] as int
          : int.tryParse('${json['stock'] ?? 0}') ?? 0,
      description: json['description']?.toString() ?? '',
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.tryParse(json['deletedAt'].toString()),
    );
  }
}