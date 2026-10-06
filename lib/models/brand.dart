class Brand {
  final int id;
  final String name;
  final String country;
  final String description;
  final DateTime? deletedAt;

  const Brand({
    required this.id,
    required this.name,
    required this.country,
    required this.description,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Brand copyWith({
    String? name,
    String? country,
    String? description,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Brand(
      id: id,
      name: name ?? this.name,
      country: country ?? this.country,
      description: description ?? this.description,
      deletedAt:
          clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'description': description,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id'] ?? 0}') ?? 0,
      name: json['name']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.tryParse(json['deletedAt'].toString()),
    );
  }
}