// Ammo item model - null-safe
class AmmoItem {
  final int id;
  final String name;
  final String category;
  final String caliber;
  final String manufacturer;
  final double price;
  final String currency;
  final int stockQuantity;
  final int roundsPerBox;
  final double weightGPerRound;
  final bool licenseRequired;
  final int minAge;
  final String imageUrl;
  final String description;
  final String notes;

  AmmoItem({
    required this.id,
    required this.name,
    required this.category,
    required this.caliber,
    required this.manufacturer,
    required this.price,
    required this.currency,
    required this.stockQuantity,
    required this.roundsPerBox,
    required this.weightGPerRound,
    required this.licenseRequired,
    required this.minAge,
    required this.imageUrl,
    required this.description,
    required this.notes,
  });

  factory AmmoItem.fromJson(Map<String, dynamic> json) {
    return AmmoItem(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      caliber: json['caliber'] as String,
      manufacturer: json['manufacturer'] as String,
      price: (json['price'] is int) ? (json['price'] as int).toDouble() : (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      stockQuantity: json['stock_quantity'] as int,
      roundsPerBox: json['rounds_per_box'] as int,
      weightGPerRound: (json['weight_g_per_round'] is int)
          ? (json['weight_g_per_round'] as int).toDouble()
          : (json['weight_g_per_round'] as num).toDouble(),
      licenseRequired: json['license_required'] as bool,
      minAge: json['min_age'] as int,
      imageUrl: json['image_url'] as String,
      description: json['description'] as String,
      notes: (json['notes'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'caliber': caliber,
      'manufacturer': manufacturer,
      'price': price,
      'currency': currency,
      'stock_quantity': stockQuantity,
      'rounds_per_box': roundsPerBox,
      'weight_g_per_round': weightGPerRound,
      'license_required': licenseRequired,
      'min_age': minAge,
      'image_url': imageUrl,
      'description': description,
      'notes': notes,
    };
  }
}
