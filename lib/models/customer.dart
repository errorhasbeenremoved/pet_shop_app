class LoyaltyCard {
  final String number;
  final String level;
  final int bonusPoints;

  const LoyaltyCard({
    required this.number,
    required this.level,
    required this.bonusPoints,
  });

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'level': level,
      'bonusPoints': bonusPoints,
    };
  }

  factory LoyaltyCard.fromJson(Map<String, dynamic> json) {
    return LoyaltyCard(
      number: json['number']?.toString() ?? '',
      level: json['level']?.toString() ?? 'Bronze',
      bonusPoints: json['bonusPoints'] is int
          ? json['bonusPoints'] as int
          : int.tryParse('${json['bonusPoints'] ?? 0}') ?? 0,
    );
  }
}

class Customer {
  final int id;
  final String name;
  final String email;
  final String phone;
  final LoyaltyCard card;
  final DateTime? deletedAt;

  const Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.card,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Customer copyWith({
    String? name,
    String? email,
    String? phone,
    LoyaltyCard? card,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Customer(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      card: card ?? this.card,
      deletedAt:
          clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'card': card.toJson(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    final cardJson = json['card'] is Map
        ? Map<String, dynamic>.from(json['card'] as Map)
        : <String, dynamic>{};

    return Customer(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id'] ?? 0}') ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      card: LoyaltyCard.fromJson(cardJson),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.tryParse(json['deletedAt'].toString()),
    );
  }
}