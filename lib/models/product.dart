import '../utils/currency_utils.dart';

class Product {
  final int id;
  final String name;
  final String? description;
  final int price;
  final int? priceAtSale;
  final String? imageId;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.priceAtSale,
    this.imageId,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] == null
          ? null
          : json['description'] as String,
      price: json['price'] as int,
      priceAtSale: json['priceAtSale'] == null
          ? null
          : json['priceAtSale'] as int,
      imageId: json['imageId'] == null ? null : json['imageId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      if (priceAtSale != null) 'priceAtSale': priceAtSale,
      'imageId': imageId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get formattedPrice {
    return formatIdr(price);
  }

  String? getImageUrl(String baseUrl) {
    if (imageId == null) return null;
    return '$baseUrl/api/images/$imageId';
  }
}
