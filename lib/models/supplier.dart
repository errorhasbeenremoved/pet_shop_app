class Supplier {
  final int id;
  final String name;
  final int brandId;
  final String email;
  final String phone;
  final String description;
  final DateTime? deletedAt;

  const Supplier({
    required this.id,
    required this.name,
    required this.brandId,
    required this.email,
    required this.phone,
    required this.description,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Supplier copyWith({
    String? name,
    int? brandId,
    String? email,
    String? phone,
    String? description,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Supplier(
      id: id,
      name: name ?? this.name,
      brandId: brandId ?? this.brandId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
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
      'email': email,
      'phone': phone,
      'description': description,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id'] ?? 0}') ?? 0,
      name: json['name']?.toString() ?? '',
      brandId: json['brandId'] is int
          ? json['brandId'] as int
          : int.tryParse('${json['brandId'] ?? 0}') ?? 0,
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.tryParse(json['deletedAt'].toString()),
    );
  }
}