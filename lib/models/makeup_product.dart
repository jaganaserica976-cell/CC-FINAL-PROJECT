class MakeupProduct {
  final String id;
  final String name;
  final String brand;
  final String category;
  final double price;
  final String imageUrl;
  final bool isFavorite;

  const MakeupProduct({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  MakeupProduct copyWith({
    String? id,
    String? name,
    String? brand,
    String? category,
    double? price,
    String? imageUrl,
    bool? isFavorite,
  }) {
    return MakeupProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
      'isFavorite': isFavorite,
    };
  }

  factory MakeupProduct.fromJson(Map<String, dynamic> json) {
    return MakeupProduct(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Product',
      brand: json['brand']?.toString() ?? 'Unknown Brand',
      category: json['category']?.toString() ?? 'Other',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl']?.toString() ?? '',
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}
