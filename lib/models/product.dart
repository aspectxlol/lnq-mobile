class Product {
  final int id;
  final String name;
  final String? description;
  final int price;
  final String? imageId;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.imageId,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: json['price'] as int,
      imageId: json['imageId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageId': imageId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get formattedPrice {
    return 'Rp ${(price / 1000).toStringAsFixed(0)}.000';
  }
}
